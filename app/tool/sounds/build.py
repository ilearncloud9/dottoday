"""Builds the shipped sound files from tool/sounds/originals/.

Run from app/:  python3 -I tool/sounds/build.py [--only ID ...] [--credits]

docs/12-sounds.md §5. For each third-party manifest entry: trim leading and
trailing silence, downmix to mono at 44.1 kHz, cap at 20 s with a 1 s fade,
then one linear gain to -16 LUFS integrated with a -1 dBTP ceiling (the
ceiling wins for short, peaky sounds, which then stay below -16; nothing is
compressed or limited). Writes:

  android/app/src/main/res/raw/<file>.m4a   Android channel sound
  ios/Runner/Sounds/<file>.caf              iOS / macOS notification sound
  assets/sounds/<file>.m4a                  web preview + in-app playback

Android gets AAC, not Vorbis: this ffmpeg build has no libvorbis, Opus in
Ogg needs Android 10 (minSdk is 26), and `dot_alarm.m4a` already ships
the same way. `.caf` is IMA4 ADPCM: iOS notification sounds take linear
PCM, IMA4, µ-law or a-law, and IMA4 is a quarter of PCM's size.

`durationMs` in the manifest and the repo's CREDITS.md are rewritten from
the result. First-party entries (tool/gen_sounds.dart) are never rebuilt;
only their duration is read.
"""

from __future__ import annotations

import argparse
import array
import json
import math
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

APP = Path(__file__).resolve().parents[2]
REPO = APP.parent
MANIFEST = APP / "assets" / "sounds" / "manifest.json"
ORIGINALS = APP / "tool" / "sounds" / "originals"
ANDROID_RAW = APP / "android" / "app" / "src" / "main" / "res" / "raw"
IOS_SOUNDS = APP / "ios" / "Runner" / "Sounds"
WEB_SOUNDS = APP / "assets" / "sounds"
CREDITS = REPO / "CREDITS.md"

TARGET_LUFS = -16.0
CEILING_DBTP = -1.0
SAMPLE_RATE = 44100
MAX_SECONDS = 20.0
FADE_SECONDS = 1.0
AAC_BITRATE = "128k"
# Silence = more than this below the loudest 10 ms (keeps reverb tails).
SILENCE_DB = -70
TAIL_FADE_SECONDS = 0.02
BITEXACT = ["-fflags", "+bitexact", "-flags:a", "+bitexact", "-map_metadata", "-1"]

_LOUDNORM_JSON = re.compile(r"\{[^{}]*\"input_i\"[^{}]*\}", re.S)


class BuildError(Exception):
    """A sound that can't be built to the targets."""


def _run(args: list[str]) -> str:
    """Runs [args] (never through a shell) and returns stderr."""
    done = subprocess.run(args, capture_output=True, text=True, check=False)
    if done.returncode != 0:
        raise BuildError(f"{args[0]} failed: {done.stderr[-800:]}")
    return done.stderr


def _ffmpeg(*args: str) -> str:
    return _run(["ffmpeg", "-hide_banner", "-nostdin", "-y", *args])


def duration_seconds(path: Path) -> float:
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "default=nw=1:nk=1", str(path)],
        capture_output=True, text=True, check=True,
    ).stdout
    return float(out.strip())


def measure(path: Path) -> tuple[float, float]:
    """(integrated LUFS, true peak dBTP) of [path].

    Padded to 1 s of silence first: a sound shorter than one 400 ms gating
    block has no integrated loudness otherwise.
    """
    log = _ffmpeg(
        "-i", str(path), "-af",
        f"apad=whole_dur=1,loudnorm=I={TARGET_LUFS}:TP={CEILING_DBTP}"
        ":print_format=json",
        "-f", "null", "-",
    )
    match = _LOUDNORM_JSON.search(log)
    if match is None:
        raise BuildError(f"{path.name}: no loudness reading")
    data = json.loads(match.group(0))
    return float(data["input_i"]), float(data["input_tp"])


def gain_db(lufs: float, peak: float) -> float:
    """The one linear gain that meets both targets; the ceiling wins.

    >>> gain_db(-20.0, -6.0)   # room to reach -16
    4.0
    >>> gain_db(-20.0, -2.0)   # peak would pass -1: stop at the ceiling
    1.0
    """
    return min(TARGET_LUFS - lufs, CEILING_DBTP - peak)


def sound_span(rms_db: list[float], window_s: float) -> tuple[float, float]:
    """(start, end) seconds of the sound inside its leading/trailing silence.

    [rms_db] is the level of each [window_s] window. Silence is any window
    more than SILENCE_DB below the loudest one; inner pauses are kept.

    >>> sound_span([-120, -90, -6, -30, -100, -20, -95, -120], 0.01)
    (0.02, 0.06)
    >>> sound_span([-120, -120], 0.01)
    (0.0, 0.02)
    """
    loudest = max(rms_db, default=-120.0)
    heard = [i for i, db in enumerate(rms_db) if db > loudest + SILENCE_DB]
    if not heard or loudest <= -100:
        return 0.0, len(rms_db) * window_s
    return round(heard[0] * window_s, 6), round((heard[-1] + 1) * window_s, 6)


def _rms_db(path: Path, window_s: float) -> list[float]:
    """Per-window RMS level of [path] (mono float samples via a pipe)."""
    raw = subprocess.run(
        ["ffmpeg", "-hide_banner", "-nostdin", "-v", "error", "-i", str(path),
         "-f", "f32le", "-ac", "1", "-ar", str(SAMPLE_RATE), "-"],
        capture_output=True, check=True,
    ).stdout
    samples = array.array("f")
    samples.frombytes(raw[: len(raw) // 4 * 4])
    size = round(SAMPLE_RATE * window_s)
    levels = []
    for i in range(0, len(samples), size):
        chunk = samples[i : i + size]
        power = sum(x * x for x in chunk) / len(chunk)
        levels.append(10 * math.log10(power) if power > 1e-12 else -120.0)
    return levels


def _trim(source: Path, out: Path) -> None:
    window_s = 0.01
    start, end = sound_span(_rms_db(source, window_s), window_s)
    _ffmpeg("-i", str(source), "-af",
            f"aformat=sample_rates={SAMPLE_RATE}:channel_layouts=mono,"
            f"atrim={start}:{end},asetpts=N/SR/TB",
            "-c:a", "pcm_f32le", str(out))


def _shape(trimmed: Path, out: Path, gain: float) -> None:
    length = duration_seconds(trimmed)
    if length > MAX_SECONDS:
        start = MAX_SECONDS - FADE_SECONDS
        filters = [f"atrim=0:{MAX_SECONDS}",
                   f"afade=t=out:st={start}:d={FADE_SECONDS}"]
    else:
        # The trim cuts inside a quiet tail: fade it so it can't click.
        start = max(length - TAIL_FADE_SECONDS, 0)
        filters = [f"afade=t=out:st={start:.4f}:d={TAIL_FADE_SECONDS}"]
    filters.append(f"volume={gain:.2f}dB")
    _ffmpeg("-i", str(trimmed), "-af", ",".join(filters),
            "-c:a", "pcm_f32le", str(out))


def _encode(shaped: Path, m4a: Path, caf: Path) -> None:
    _ffmpeg("-i", str(shaped), "-c:a", "aac", "-b:a", AAC_BITRATE,
            "-ar", str(SAMPLE_RATE), "-movflags", "+faststart", *BITEXACT,
            str(m4a))
    _ffmpeg("-i", str(shaped), "-c:a", "adpcm_ima_qt", "-ar", str(SAMPLE_RATE),
            *BITEXACT, "-f", "caf", str(caf))


def build_one(entry: dict, work: Path) -> dict:
    """Builds [entry]; returns its report row."""
    sources = sorted(ORIGINALS.glob(f"{entry['file']}.*"))
    if len(sources) != 1:
        raise BuildError(f"{entry['id']}: {len(sources)} originals (run fetch.py)")
    trimmed, shaped = work / "trimmed.wav", work / "shaped.wav"
    m4a, caf = work / "out.m4a", work / "out.caf"
    _trim(sources[0], trimmed)
    lufs, peak = measure(trimmed)
    gain = gain_db(lufs, peak)
    _shape(trimmed, shaped, gain)
    _encode(shaped, m4a, caf)
    # AAC can overshoot the ceiling a little; take it back.
    out_lufs, out_peak = measure(m4a)
    for _ in range(3):
        if out_peak <= CEILING_DBTP + 0.05:
            break
        gain -= out_peak - CEILING_DBTP
        _shape(trimmed, shaped, gain)
        _encode(shaped, m4a, caf)
        out_lufs, out_peak = measure(m4a)
    shutil.copyfile(m4a, ANDROID_RAW / f"{entry['file']}.m4a")
    shutil.copyfile(m4a, WEB_SOUNDS / f"{entry['file']}.m4a")
    shutil.copyfile(caf, IOS_SOUNDS / f"{entry['file']}.caf")
    return {
        "id": entry["id"],
        "durationMs": round(duration_seconds(m4a) * 1000),
        "lufs": out_lufs,
        "peak": out_peak,
        "kb": (caf.stat().st_size + m4a.stat().st_size) // 1024,
    }


def first_party_duration_ms(entry: dict) -> int:
    # The Android copy: ffprobe can't read Apple's own IMA4 .caf files.
    files = sorted(ANDROID_RAW.glob(f"{entry['file']}.*"))
    if not files:
        raise BuildError(f"{entry['id']}: no file in res/raw")
    return round(duration_seconds(files[0]) * 1000)


def credits_markdown(manifest: dict) -> str:
    """CREDITS.md: one section per credited source, one row per sound."""
    lines = [
        "# Credits",
        "",
        "Generated from `app/assets/sounds/manifest.json` by",
        "`app/tool/sounds/build.py`. Do not edit by hand.",
        "",
    ]
    for key, source in manifest["sources"].items():
        if not source.get("credit"):
            continue
        lines += [f"## {source['name']}", "", source["notice"], ""]
        lines += ["| Dottoday id | Dottoday name | Original | Source page |",
                  "|---|---|---|---|"]
        for s in manifest["sounds"]:
            if s["source"] == key:
                lines.append(f"| `{s['id']}` | {s['name']} | {s['sourceTitle']}"
                             f" | <{s['sourceUrl']}> |")
        lines.append("")
    first_party = [s["name"] for s in manifest["sounds"]
                   if not manifest["sources"][s["source"]].get("credit")]
    lines += ["## Made for Dottoday", "",
              "Synthesised by `app/tool/gen_sounds.dart`; no third-party audio: "
              + ", ".join(first_party) + ".", ""]
    return "\n".join(lines)


def _write_manifest(manifest: dict) -> None:
    text = json.dumps(manifest, indent=2, ensure_ascii=False) + "\n"
    MANIFEST.write_text(text, encoding="utf-8")


def _print_report(rows: list[dict]) -> None:
    print(f"{'id':22} {'ms':>6} {'LUFS':>6} {'dBTP':>6} {'KB':>5}")
    for r in rows:
        flag = "  below -16 (peak-limited)" if r["lufs"] < TARGET_LUFS - 0.5 else ""
        print(f"{r['id']:22} {r['durationMs']:6} {r['lufs']:6.1f} "
              f"{r['peak']:6.1f} {r['kb']:5}{flag}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--only", nargs="*", help="sound ids to build")
    parser.add_argument("--credits", action="store_true",
                        help="only rewrite CREDITS.md")
    args = parser.parse_args(argv)

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if not args.credits:
        for directory in (ANDROID_RAW, IOS_SOUNDS, WEB_SOUNDS):
            directory.mkdir(parents=True, exist_ok=True)
        rows = []
        with tempfile.TemporaryDirectory() as tmp:
            for entry in manifest["sounds"]:
                if args.only and entry["id"] not in args.only:
                    continue
                if "sourceUrl" not in entry:
                    entry["durationMs"] = first_party_duration_ms(entry)
                    continue
                row = build_one(entry, Path(tmp))
                entry["durationMs"] = row["durationMs"]
                rows.append(row)
        _write_manifest(manifest)
        _print_report(rows)
    CREDITS.write_text(credits_markdown(manifest), encoding="utf-8")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except BuildError as e:
        print(f"FAILED {e}", file=sys.stderr)
        sys.exit(1)
