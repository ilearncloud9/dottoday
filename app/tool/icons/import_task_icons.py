#!/usr/bin/env python3
"""Builds assets/design/task_icons.json, the source of the task icon library
(docs/10 §3 "Icon set", docs/adr/0012-task-icon-library.md).

Run from app/ with the unpacked npm packages (data only, never executed):

  python3 -I tool/icons/import_task_icons.py \
      --lucide <lucide-static@0.460.0>/package \
      --tabler <@tabler/icons@3.24.0>/package \
      --mapping mapping.json --labels labels.json

mapping.json: Structured name -> {"src": "lucide:<slug>" | "tabler:<slug>" |
"skip" | "none"}. labels.json: {"categories": {key: {en, de, es, fr}},
"icons": {name: {category, de, es, fr}}}.

Rows whose source is "concept-a" or "dottoday" are hand-drawn and kept from
the existing JSON; only Lucide/Tabler rows are rebuilt. Then run
`dart run tool/gen_task_icons.dart`.
"""
import argparse
import json
import re
import xml.etree.ElementTree as ET

OUT = 'assets/design/task_icons.json'

# Picker order (docs/10 §3): Dottoday's own planning icons first.
CATEGORIES = [
    'planning', 'health', 'fitness', 'food', 'home', 'work', 'tech', 'travel',
    'nature', 'animals', 'people', 'leisure', 'shopping', 'style', 'faith',
    'symbols',
]


# The persisted keys of the Concept A set (docs/05 `icon_key`), kept even
# where the drawing now comes from a library.
KEEP_KEYS = {
    'code', 'run', 'mail', 'call', 'meal', 'book', 'list', 'language',
    'heart', 'travel', 'cart', 'home', 'tv', 'bag', 'music', 'meds', 'water',
    'pet', 'gym', 'car', 'money', 'gift', 'camera', 'star', 'people',
    'document',
}


def num(v):
    s = f'{float(v):.3f}'.rstrip('0').rstrip('.')
    return '0' if s in ('', '-0') else s


def circle(cx, cy, rx, ry=None):
    ry = rx if ry is None else ry
    a = f'{num(rx)} {num(ry)} 0 1 0'
    return (f'M{num(cx - rx)} {num(cy)}a{a} {num(2 * rx)} 0'
            f'a{a} {num(-2 * rx)} 0')


def rect(x, y, w, h, rx, ry):
    if rx == 0 and ry == 0:
        return f'M{num(x)} {num(y)}h{num(w)}v{num(h)}h{num(-w)}z'
    a = f'{num(rx)} {num(ry)} 0 0 1'
    return (f'M{num(x + rx)} {num(y)}h{num(w - 2 * rx)}a{a} {num(rx)} {num(ry)}'
            f'v{num(h - 2 * ry)}a{a} {num(-rx)} {num(ry)}h{num(-(w - 2 * rx))}'
            f'a{a} {num(-rx)} {num(-ry)}v{num(-(h - 2 * ry))}'
            f'a{a} {num(rx)} {num(-ry)}z')


def points(p, close):
    nums = [num(n) for n in re.findall(r'-?(?:\d+\.?\d*|\.\d+)(?:e-?\d+)?', p)]
    pairs = [f'{nums[i]} {nums[i + 1]}' for i in range(0, len(nums), 2)]
    return 'M' + 'L'.join(pairs) + ('z' if close else '')


def absolute_start(d):
    """A path's leading `m` is relative to the origin; once paths are joined
    it would be relative to the previous one's end. Make it `M`, keeping the
    pairs after it as the relative line-tos they were."""
    n = r'(-?(?:\d+\.?\d*|\.\d+)(?:e-?\d+)?)'
    m = re.match(rf'm\s*{n}[\s,]*{n}\s*,?', d)
    if not m:
        return d
    rest = d[m.end():].lstrip()
    head = f'M{m[1]} {m[2]}'
    if rest and not rest[0].isalpha():
        return f'{head}l{rest}'
    return head + rest


def f(el, name, default=0.0):
    return float(el.get(name, default))


def element_d(el):
    tag = el.tag.split('}')[-1]
    if el.get('stroke') == 'none':
        return ''  # Tabler's invisible 24x24 bounding box.
    if tag == 'path':
        return absolute_start(el.get('d').strip())
    if tag == 'circle':
        return circle(f(el, 'cx'), f(el, 'cy'), f(el, 'r'))
    if tag == 'ellipse':
        return circle(f(el, 'cx'), f(el, 'cy'), f(el, 'rx'), f(el, 'ry'))
    if tag == 'rect':
        rx = f(el, 'rx', el.get('ry', 0))
        ry = f(el, 'ry', el.get('rx', 0))
        w, h = f(el, 'width'), f(el, 'height')
        rx, ry = min(rx, w / 2), min(ry, h / 2)
        return rect(f(el, 'x'), f(el, 'y'), w, h, rx, ry)
    if tag == 'line':
        return (f"M{num(f(el, 'x1'))} {num(f(el, 'y1'))}"
                f"L{num(f(el, 'x2'))} {num(f(el, 'y2'))}")
    if tag in ('polyline', 'polygon'):
        return points(el.get('points'), tag == 'polygon')
    raise ValueError(f'unsupported SVG element {tag}')


def svg_d(path):
    root = ET.parse(path).getroot()
    return ''.join(element_d(el) for el in root.iter() if el is not root)


def svg_file(args, src):
    lib, slug = src.split(':')
    if lib == 'lucide':
        return f'{args.lucide}/icons/{slug}.svg'
    return f'{args.tabler}/icons/outline/{slug}.svg'


def key_of(name):
    return re.sub(r'[^a-z0-9]+', '_', name.lower()).strip('_')


def main():
    ap = argparse.ArgumentParser()
    for a in ('lucide', 'tabler', 'mapping', 'labels'):
        ap.add_argument(f'--{a}', required=True)
    args = ap.parse_args()
    mapping = json.load(open(args.mapping))
    labels = json.load(open(args.labels))
    old = json.load(open(OUT))
    # Rows with an existing key (Concept A's 26 keep theirs, docs/05) and the
    # hand-drawn ones survive; labels.json fills names they lack, and their
    # drawing comes from the library when they point at one.
    kept = [r for r in old['icons']
            if r['source'] in ('concept-a', 'dottoday') or r['key'] in KEEP_KEYS]
    for r in kept:
        lab = labels['icons'].get(r['name']['en'])
        if lab:
            for lang in ('de', 'es', 'fr'):
                r['name'].setdefault(lang, lab[lang])
        if ':' in r['source']:
            r['d'] = svg_d(svg_file(args, r['source']))
    taken = {r['name']['en'] for r in kept}
    old_names = {r['name']['en']: r['name'] for r in old['icons']}
    rows = list(kept)
    for name, m in sorted(mapping.items(), key=lambda e: e[0].lower()):
        if m['src'] in ('skip', 'none') or name in taken:
            continue
        lab = labels['icons'][name]
        # Names already in the JSON were reviewed there (e.g. fr Chess is
        # "Échiquier": "Échecs" also means failures, docs/10 no-shame rule).
        names = old_names.get(name) or {
            'en': name, 'de': lab['de'], 'es': lab['es'], 'fr': lab['fr']}
        rows.append({
            'key': key_of(name),
            'name': names,
            'category': lab['category'],
            'source': m['src'],
            'd': svg_d(svg_file(args, m['src'])),
        })
    order = {c: i for i, c in enumerate(CATEGORIES)}
    planning = [r for r in rows if r['category'] == 'planning']
    rest = sorted((r for r in rows if r['category'] != 'planning'),
                  key=lambda r: (order[r['category']], r['name']['en'].lower()))
    prev = {c['key']: c['name'] for c in old['categories']}
    cats = [{'key': c, 'name': prev.get(c) or labels['categories'][c]}
            for c in CATEGORIES]
    out = {
        'categories': cats,
        'plain': old['plain'],
        'legacy': old['legacy'],
        'icons': planning + rest,
    }
    with open(OUT, 'w') as fh:
        json.dump(out, fh, ensure_ascii=False, indent=1)
        fh.write('\n')
    print(f'wrote {OUT}: {len(out["icons"])} icons')


if __name__ == '__main__':
    main()
