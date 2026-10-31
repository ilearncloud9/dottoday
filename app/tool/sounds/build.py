"""Builds the shipped sound files from tool/sounds/originals/.

Run from app/:  python3 -I tool/sounds/build.py [--only ID ...]
         then:  python3 -I tool/sounds/credits.py

docs/12-sounds.md §5. For each third-party manifest entry:

1. trim leading and trailing silence; downmix to mono at 44.1 kHz;
2. shape: loop to `loopToMs` when the entry asks (start.insistent); or,
   for an entry with `loop`, author a seamless loop of `loop.toMs` whose
   seam is a `loop.crossfadeMs` equal-power crossfade (a short source is
   first repeated with the same crossfade); else cap at the category's
   longest duration with a fade, fade the cut tail;
3. level: one linear gain towards the category's loudness target, then a
   -1 dBTP true-peak limiter (4x oversampled, attack 5 ms, release 50 ms)
   allowed to absorb at most 6 dB, so a short sound never becomes a click.
   A sound still more than 4 LU under its target is not pushed further: it
   is listed as a quiet outlier for the ear pass. No noise-floor lift.
4. fade in over `fadeInMs` when the entry asks, after levelling, so the
   fade doesn't pull the measured loudness down, with a 20 ms tail fade
   so the loop restarts without a click (docs/12 §2.3.1).

Writes:

  android/app/src/main/res/raw/<file>.m4a   Android channel sound
  ios/Runner/Sounds/<file>.caf              iOS / macOS notification sound
  assets/sounds/<file>.m4a                  web preview + in-app playback

Android gets AAC, not Vorbis: this ffmpeg build has no libvorbis, Opus in
Ogg needs Android 10 (minSdk is 26), and `dot_alarm.m4a` already ships
the same way. `.caf` is IMA4 ADPCM: iOS notification sounds take linear
PCM, IMA4, µ-law or a-law, and IMA4 is a quarter of PCM's size.

`durationMs`, `loudnessLufs` and `truePeakDbtp` in the manifest are
rewritten from the result (CREDITS.md is credits.py's). First-party entries
(tool/gen_sounds.dart) are never rebuilt, only measured; each also gets
an IMA4 `.caf` copy of the same audio in ios/Runner/Sounds, so every
catalogue sound is in the iOS app bundle (AlarmKit plays bundle sounds
only, docs/15-alarms.md). Originals may be FLAC, Ogg or MP3.
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
MANIFEST = APP / "assets" / "sounds" / "manifest.json"
ORIGINALS = APP / "tool" / "sounds" / "originals"
ANDROID_RAW = APP / "android" / "app" / "src" / "main" / "res" / "raw"
IOS_SOUNDS = APP / "ios" / "Runner" / "Sounds"
WEB_SOUNDS = APP / "assets" / "sounds"

# Per category: (loudness target LUFS, shortest ms, longest ms, cap fade s).
# Consistency within a category beats one global figure (owner, phase 1).
CATEGORIES = {
    "quiet": (-20.0, 0, 1500, 0.5),
    "clear": (-16.0, 0, 4000, 0.5),
    "play": (-16.0, 0, 4000, 0.5),
    "done": (-16.0, 0, 4000, 0.5),
    "start": (-14.0, 3000, 28000, 1.0),
}
CEILING_DBTP = -1.0
LIMITER_MAX_DB = 6.0
OUTLIER_LU = 4.0
OVERSAMPLE = 4
SAMPLE_RATE = 44100
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
        "apad=whole_dur=1,loudnorm=print_format=json",
        "-f", "null", "-",
    )
    match = _LOUDNORM_JSON.search(log)
    if match is None:
        raise BuildError(f"{path.name}: no loudness reading")
    data = json.loads(match.group(0))
    return float(data["input_i"]), float(data["input_tp"])


def gain_db(target: float, lufs: float, peak: float) -> float:
    """The linear gain before the limiter: towards [target], but never so
    much that the limiter must take more than LIMITER_MAX_DB off the peak.

    >>> gain_db(-16.0, -20.0, -6.0)   # reaches the target, no limiting
    4.0
    >>> gain_db(-16.0, -30.0, -2.0)   # stops where the limiter takes 6 dB
    7.0
    """
    return min(target - lufs, CEILING_DBTP - peak + LIMITER_MAX_DB)


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
    """Per-window RMS level of [path]."""
    samples = _read_samples(path)
    size = round(SAMPLE_RATE * window_s)
    levels = []
    for i in range(0, len(samples), size):
        chunk = samples[i : i + size]
        power = sum(x * x for x in chunk) / len(chunk)
        levels.append(10 * math.log10(power) if power > 1e-12 else -120.0)
    return levels


def _read_samples(path: Path) -> array.array:
    """Mono float samples of [path] at SAMPLE_RATE."""
    raw = subprocess.run(
        ["ffmpeg", "-hide_banner", "-nostdin", "-v", "error", "-i", str(path),
         "-f", "f32le", "-ac", "1", "-ar", str(SAMPLE_RATE), "-"],
        capture_output=True, check=True,
    ).stdout
    samples = array.array("f")
    samples.frombytes(raw[: len(raw) // 4 * 4])
    return samples


def _write_samples(samples: array.array, out: Path) -> None:
    subprocess.run(
        ["ffmpeg", "-hide_banner", "-nostdin", "-v", "error", "-y",
         "-f", "f32le", "-ar", str(SAMPLE_RATE), "-ac", "1", "-i", "-",
         "-c:a", "pcm_f32le", str(out)],
        input=samples.tobytes(), check=True,
    )


def crossfade(a: array.array, b: array.array, n: int) -> array.array:
    """[a] then [b], the last [n] samples of [a] blended into the first [n]
    of [b] with equal-power gains (unrelated material keeps its level).

    >>> list(crossfade(array.array("f", [1, 1]), array.array("f", [2, 2]), 0))
    [1.0, 1.0, 2.0, 2.0]
    """
    out = a[: len(a) - n]
    for i in range(n):
        x = (i + 0.5) / n * math.pi / 2
        out.append(a[len(a) - n + i] * math.cos(x) + b[i] * math.sin(x))
    out.extend(b[n:])
    return out


def seamless_loop(samples: array.array, length: int, fade: int) -> array.array:
    """[length] samples that repeat without a click: the head is the
    crossfade of what would follow the cut into the start, so the last
    sample runs straight into the first (docs/12 §2.3).

    >>> s = array.array("f", range(10))
    >>> list(seamless_loop(s, 6, 0))
    [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
    """
    if len(samples) <= fade:
        raise BuildError("source shorter than the loop crossfade")
    source = samples
    while len(source) < length + fade:
        source = crossfade(source, samples, fade)
    tail = source[length : length + fade]
    return crossfade(tail, source[:length], fade)[: length]


def _loop(trimmed: Path, out: Path, loop: dict) -> str:
    length = round(loop["toMs"] / 1000 * SAMPLE_RATE)
    fade = round(loop["crossfadeMs"] / 1000 * SAMPLE_RATE)
    samples = _read_samples(trimmed)
    _write_samples(seamless_loop(samples, length, fade), out)
    return f"loop {loop['toMs'] / 1000:g} s from {len(samples) / SAMPLE_RATE:.1f} s"


def _trim(source: Path, out: Path) -> None:
    window_s = 0.01
    start, end = sound_span(_rms_db(source, window_s), window_s)
    _ffmpeg("-i", str(source), "-af",
            f"aformat=sample_rates={SAMPLE_RATE}:channel_layouts=mono,"
            f"atrim={start}:{end},asetpts=N/SR/TB",
            "-c:a", "pcm_f32le", str(out))


def _shape(trimmed: Path, out: Path, entry: dict) -> str:
    """Loops, caps and fades [trimmed]; returns a note for the report."""
    _, _, longest_ms, cap_fade = CATEGORIES[entry["category"]]
    if "loop" in entry:
        return _loop(trimmed, out, entry["loop"])
    length = duration_seconds(trimmed)
    longest = longest_ms / 1000
    if "loopToMs" in entry:
        # Back to back, no gap; the final repeat fades out (start.insistent).
        repeats = max(2, round(entry["loopToMs"] / 1000 / length))
        while repeats * length > longest:
            repeats -= 1
        filters = [f"aloop=loop={repeats - 1}:size={round(length * SAMPLE_RATE)}",
                   f"afade=t=out:st={(repeats - 1) * length:.4f}:d={length:.4f}"]
        note = f"looped x{repeats}"
    elif length > longest:
        filters = [f"atrim=0:{longest}",
                   f"afade=t=out:st={longest - cap_fade}:d={cap_fade}"]
        note = f"capped from {length:.2f} s"
    else:
        # The trim cuts inside a quiet tail: fade it so it can't click.
        start = max(length - TAIL_FADE_SECONDS, 0)
        filters = [f"afade=t=out:st={start:.4f}:d={TAIL_FADE_SECONDS}"]
        note = ""
    _ffmpeg("-i", str(trimmed), "-af", ",".join(filters),
            "-c:a", "pcm_f32le", str(out))
    return note


def _level(shaped: Path, out: Path, gain: float, limit_dbtp: float,
           fade_in_ms: int = 0) -> None:
    # Oversampled so the limiter holds true peaks, not just sample peaks.
    limit = 10 ** (limit_dbtp / 20)
    # A faded-in loop restarts from silence, so its end fades too: the
    # seam is then a quick dip, never a click.
    fade_in = (f",afade=t=in:d={fade_in_ms / 1000:g},areverse,"
               f"afade=t=in:d={TAIL_FADE_SECONDS},areverse"
               if fade_in_ms else "")
    _ffmpeg("-i", str(shaped), "-af",
            f"volume={gain:.2f}dB,aresample={SAMPLE_RATE * OVERSAMPLE},"
            f"alimiter=limit={limit:.4f}:attack=5:release=50:level=0:latency=1,"
            f"aresample={SAMPLE_RATE}{fade_in}",
            "-c:a", "pcm_f32le", str(out))


def _encode(shaped: Path, m4a: Path, caf: Path) -> None:
    _ffmpeg("-i", str(shaped), "-c:a", "aac", "-b:a", AAC_BITRATE,
            "-ar", str(SAMPLE_RATE), "-movflags", "+faststart", *BITEXACT,
            str(m4a))
    _encode_caf(shaped, caf)


def _encode_caf(source: Path, caf: Path) -> None:
    _ffmpeg("-i", str(source), "-c:a", "adpcm_ima_qt", "-ac", "1",
            "-ar", str(SAMPLE_RATE), *BITEXACT, "-f", "caf", str(caf))


def build_one(entry: dict, work: Path) -> dict:
    """Builds [entry]; returns its report row."""
    sources = sorted(ORIGINALS.glob(f"{entry['file']}.*"))
    if len(sources) != 1:
        raise BuildError(f"{entry['id']}: {len(sources)} originals (run fetch.py)")
    target = CATEGORIES[entry["category"]][0]
    trimmed, shaped, leveled = (work / n for n in ("t.wav", "s.wav", "l.wav"))
    m4a, caf = work / "out.m4a", work / "out.caf"
    _trim(sources[0], trimmed)
    note = _shape(trimmed, shaped, entry)
    lufs, peak = measure(shaped)
    gain = gain_db(target, lufs, peak)
    limit_dbtp = CEILING_DBTP
    for _ in range(4):
        _level(shaped, leveled, gain, limit_dbtp, entry.get("fadeInMs", 0))
        _encode(leveled, m4a, caf)
        out_lufs, out_peak = measure(m4a)
        # Resampling and AAC can overshoot a little: lower the limit.
        if out_peak <= CEILING_DBTP + 0.05:
            break
        limit_dbtp -= out_peak - CEILING_DBTP
    shutil.copyfile(m4a, ANDROID_RAW / f"{entry['file']}.m4a")
    shutil.copyfile(m4a, WEB_SOUNDS / f"{entry['file']}.m4a")
    shutil.copyfile(caf, IOS_SOUNDS / f"{entry['file']}.caf")
    return {
        "id": entry["id"],
        "durationMs": round(duration_seconds(m4a) * 1000),
        "lufs": out_lufs,
        "peak": out_peak,
        "target": target,
        "limited": max(0.0, peak + gain - CEILING_DBTP),
        "note": note,
        "kb": (caf.stat().st_size + m4a.stat().st_size) // 1024,
    }


def measure_first_party(entry: dict) -> None:
    """Records [entry]'s duration and loudness; its file is never touched."""
    # The Android copy: ffprobe can't read Apple's own IMA4 .caf files.
    files = sorted(ANDROID_RAW.glob(f"{entry['file']}.*"))
    if not files:
        raise BuildError(f"{entry['id']}: no file in res/raw")
    lufs, peak = measure(files[0])
    _record(entry, round(duration_seconds(files[0]) * 1000), lufs, peak)
    _encode_caf(files[0], IOS_SOUNDS / f"{entry['file']}.caf")


def _record(entry: dict, duration_ms: int, lufs: float, peak: float) -> None:
    entry["durationMs"] = duration_ms
    entry["loudnessLufs"] = round(lufs, 1)
    entry["truePeakDbtp"] = round(peak, 1)


def _write_manifest(manifest: dict) -> None:
    text = json.dumps(manifest, indent=2, ensure_ascii=False) + "\n"
    MANIFEST.write_text(text, encoding="utf-8")


def _print_report(rows: list[dict]) -> None:
    print(f"{'id':18} {'ms':>6} {'LUFS':>6} {'aim':>4} {'dBTP':>5} "
          f"{'lim':>4} {'KB':>4}  note")
    for r in rows:
        print(f"{r['id']:18} {r['durationMs']:6} {r['lufs']:6.1f} "
              f"{r['target']:4.0f} {r['peak']:5.1f} {r['limited']:4.1f} "
              f"{r['kb']:4}  {r['note']}")
    outliers = [r for r in rows if r["lufs"] < r["target"] - OUTLIER_LU]
    print(f"\nQuiet outliers (> {OUTLIER_LU:.0f} LU under target after the "
          f"limiter), for the ear pass: {len(outliers)}")
    for r in outliers:
        print(f"  {r['id']}: {r['lufs']:.1f} LUFS, target {r['target']:.0f}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--only", nargs="*", help="sound ids to build")
    args = parser.parse_args(argv)

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    for directory in (ANDROID_RAW, IOS_SOUNDS, WEB_SOUNDS):
        directory.mkdir(parents=True, exist_ok=True)
    rows = []
    with tempfile.TemporaryDirectory() as tmp:
        for entry in manifest["sounds"]:
            if args.only and entry["id"] not in args.only:
                continue
            if "sourceUrl" not in entry:
                measure_first_party(entry)
                continue
            row = build_one(entry, Path(tmp))
            _record(entry, row["durationMs"], row["lufs"], row["peak"])
            rows.append(row)
    _write_manifest(manifest)
    _print_report(rows)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except BuildError as e:
        print(f"FAILED {e}", file=sys.stderr)
        sys.exit(1)
