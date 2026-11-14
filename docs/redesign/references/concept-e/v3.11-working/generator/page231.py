# R2-31 · Tablets (gap pass): Stage Manager, the foldable hinge, the Undo toast at medium width and tablet browsers.
# Built behaviour only (layout by window width, dot_metrics.dart: compact < 600, medium 600–839, expanded >= 840);
# frames are the approved R2-1 tablet shells (E-R2-1, ED-265 to ED-268) and the R2-7 toast (ED-281).
_p = open(os.path.join(HERE, '..', 'r229', 'page229.py'), encoding='utf-8').read()
exec(_p[:_p.rindex('# ---------------------------------------------------------------- page')])
R21 = open(os.path.join(HERE, '..', 'audit', 'project', 'E-R2-1.dc.html'), encoding='utf-8').read()
WEBF = open(os.path.join(HERE, '..', 'r230', 'web_full.html'), encoding='utf-8').read()
MF = "-apple-system, 'SF Pro Text', system-ui, sans-serif"


def _frame(s, st):
    d = 0
    for m in re.finditer(r'<div\b|</div>', s[st:]):
        d += 1 if m.group(0) == '<div' else -1
        if d == 0:
            return s[st:st + m.end()]


def r21(label):
    i = R21.index(label)
    return _frame(R21, R21.index('<div style="position: relative; width: ', i))


IPAD_MED, AND_MED, FOLD, IPAD_SPLIT = r21('1b · Medium · iPad Air portrait'), r21('3b · Medium · portrait 800'), r21('4b · Foldable unfolded'), r21('2c · Compact · Split View')
IPAD_EXP = r21('1a · Expanded · iPad Air landscape')


def bare(fr, r=12):
    # A device frame as an app window: no bezel shadow, window corners, no status bar.
    fr = re.sub(r'box-shadow: 0 0 0 1px rgba\(36,31,43,\.2\), 0 0 0 12px #241F2B, 0 0 0 13px rgba\(36,31,43,\.35\);', 'box-shadow: 0 0 0 1px rgba(36,31,43,.16), 0 18px 44px rgba(36,31,43,.22);', fr, count=1)
    fr = re.sub(r'border-radius: (22|30)px;', 'border-radius: %dpx;' % r, fr, count=1)
    return re.sub(r'<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: (24|40)px;[^"]*">.*?</div>', '', fr, count=1, flags=re.S)


def add(fr, html): k = fr.rindex('</div>'); return fr[:k] + html + fr[k:]


def scaled(fr, w, h, s): return '<div style="width: %dpx; height: %dpx; flex: none;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>' % (round(w * s), round(h * s), w, h, s, fr)


# ---------------------------------------------------------------- 1 · Stage Manager (iPad)
def stage(win, ww, wh, s, x, y, note=None):
    thumbs = ''.join('<div style="width: 120px; height: 86px; border-radius: 10px; background: %s; box-shadow: 0 6px 16px rgba(0,0,0,.25); transform: perspective(300px) rotateY(18deg);"></div>' % c for c in ('@@I1@@', '@@I2@@', '@@I3@@'))
    dots = '<div aria-hidden="true" style="position: absolute; left: %dpx; top: %dpx; width: 34px; height: 5px; border-radius: 3px; background: rgba(36,31,43,.35);"></div>' % (x + round(ww * s) // 2 - 17, y - 12)
    corner = '<div aria-hidden="true" style="position: absolute; left: %dpx; top: %dpx; width: 18px; height: 18px; border-right: 4px solid rgba(36,31,43,.35); border-bottom: 4px solid rgba(36,31,43,.35); border-radius: 0 0 10px 0;"></div>' % (x + round(ww * s) - 10, y + round(wh * s) - 10)
    other = '<div style="position: absolute; left: %dpx; top: %dpx; width: 360px; height: 520px; border-radius: 12px; background: @@I4@@; opacity: .8; box-shadow: 0 10px 30px rgba(0,0,0,.2);"></div>' % (x + round(ww * s) - 120, y + 70)
    inner = ('<div style="position: absolute; inset: 0; background: linear-gradient(160deg, @@W1@@, @@W2@@ 55%%, @@W3@@);"></div>'
             '<div style="position: absolute; left: 22px; top: 200px; display: flex; flex-direction: column; gap: 26px;">%s</div>%s'
             '<div style="position: absolute; left: %dpx; top: %dpx;">%s</div>%s%s') % (thumbs, other, x, y, scaled(win, ww, wh, s), dots, corner)
    return ('<div role="img" aria-label="iPad with Stage Manager" style="position: relative; width: 1366px; height: 1024px; border-radius: 34px; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 14px #241F2B, 0 0 0 15px rgba(36,31,43,.35); font-family: %s;">'
            '<div style="position: absolute; left: 0; right: 0; top: 0; height: 24px; display: flex; justify-content: space-between; padding: 0 24px; align-items: center; font: 600 13px %s; color: #FEFEFE; z-index: 5;"><span>10:42 Tue 3 Nov</span><span>100 %%</span></div>%s</div>') % (MF, MF, inner)


SM_MED = stage(bare(IPAD_MED), 820, 1180, 0.8, 300, 46)
SM_EXP = stage(bare(IPAD_EXP), 1180, 820, 0.88, 220, 90)

# ---------------------------------------------------------------- 2 · Foldable hinge
HINGE_V = '<div aria-hidden="true" style="position: absolute; left: 349px; top: 0; bottom: 0; width: 2px; background: repeating-linear-gradient(to bottom, rgba(36,31,43,.45) 0 6px, transparent 6px 12px); z-index: 60;"></div>'
HINGE_H = ('<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 419px; height: 2px; background: repeating-linear-gradient(to right, rgba(36,31,43,.45) 0 6px, transparent 6px 12px); z-index: 60;"></div>'
           '<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 420px; bottom: 0; background: linear-gradient(180deg, rgba(36,31,43,.10), rgba(36,31,43,.02)); z-index: 59;"></div>')
FOLD_BOOK = add(FOLD, HINGE_V)
FOLD_TABLE = add(FOLD, HINGE_H)

# ---------------------------------------------------------------- 3 · Undo toast at medium width (R2-7 toast, centred on the content area)
def toast_at(left, width, bottom, msg, radius=16, font=MF):
    return ('<div role="status" aria-live="polite" style="position: absolute; left: %dpx; bottom: %dpx; width: %dpx; z-index: 45; min-height: 52px; border-radius: %dpx; background: #2E2836; color: #FBF7F1; display: flex; align-items: center; gap: 8px; padding: 4px 4px 4px 16px; box-sizing: border-box; font: 600 15px/20px %s; box-shadow: 0 8px 24px rgba(36,31,43,.20);">'
            '<span style="min-width: 0;">%s</span><button style="margin-left: auto; height: 44px; padding: 0 12px; border: 0; background: none; color: #A3E2D9; font: 700 15px %s;">Undo</button></div>') % (left, bottom, width, radius, font, msg, font)


T_IPAD = add(IPAD_MED, toast_at(210, 400, 40, 'Marked done'))
T_AND = add(AND_MED, toast_at(80 + (720 - 440) // 2, 440, 40, 'Read moved to Wed 4 Nov', 8, 'Roboto, system-ui, sans-serif'))
T_FOLD = add(FOLD, toast_at(80 + (620 - 400) // 2, 400, 32, 'Marked done', 8, 'Roboto, system-ui, sans-serif'))

# ---------------------------------------------------------------- 4 · Tablet browsers
def safari(body, w=1180, h=820):
    bar = ('<div style="position: absolute; left: 0; right: 0; top: 0; height: 70px; background: #F2F1F4; box-shadow: 0 1px 0 #DDD7E0; z-index: 70; font: 13px %s; color: #241F2B;">'
           '<div style="height: 24px; display: flex; justify-content: space-between; padding: 0 22px; align-items: center; font-weight: 600;"><span>10:42 Tue 3 Nov</span><span>100 %%</span></div>'
           '<div style="display: flex; align-items: center; gap: 14px; padding: 0 18px; height: 40px;"><span style="color: #2F7DF6; font-size: 18px;">‹ ›</span><span style="flex: 1; display: flex; justify-content: center;"><span style="width: 420px; height: 32px; border-radius: 10px; background: #E4E2E8; display: flex; align-items: center; justify-content: center; gap: 6px; font-size: 14px;">%s dottoday.app</span></span><span style="color: #2F7DF6;">%s</span></div></div>') % (MF, sv('<rect x="5" y="11" width="14" height="10" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path>', 12), sv(PLUS, 18))
    return ('<div style="position: relative; width: %dpx; height: %dpx; border-radius: 30px; background: #FBF7F1; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 12px #241F2B, 0 0 0 13px rgba(36,31,43,.35);">%s'
            '<div style="position: absolute; left: 0; right: 0; top: 70px; bottom: 0; overflow: hidden;">%s</div></div>') % (w, h, bar, body)


def web_body():
    # The approved web Workspace (E-FullA-v2) without its desktop browser chrome, shifted up under Safari's bar.
    i = WEBF.index('<!-- sidebar')
    inner = WEBF[i:WEBF.rindex('</div>')]
    inner = inner.replace('top: 52px; bottom: 0; width: 216px;', 'top: 0; bottom: 0; width: 216px;', 1).replace('position: absolute; left: 216px; top: 52px;', 'position: absolute; left: 216px; top: 0;', 1)
    return '<div style="position: relative; width: 1280px; height: 800px; transform: scale(.922); transform-origin: 0 0;">%s</div>' % inner


B_SAFARI = safari(web_body())


def chrome_and(fr):
    bar = ('<div style="position: absolute; left: 0; right: 0; top: 0; height: 104px; background: #F1ECF4; z-index: 70; font-family: Roboto, system-ui, sans-serif; color: #241F2B; box-shadow: 0 1px 0 #DDD7E0;">'
           '<div style="height: 40px; display: flex; justify-content: space-between; padding: 0 22px; align-items: center; font: 500 14px Roboto;"><span>10:42</span><span>100%%</span></div>'
           '<div style="display: flex; align-items: center; gap: 12px; padding: 0 14px; height: 56px;"><span style="color: #4E4757;">%s</span><span style="flex: 1; height: 44px; border-radius: 22px; background: #FFFDF9; display: flex; align-items: center; gap: 8px; padding: 0 16px; font: 400 15px Roboto;">%s dottoday.app/#/today</span><span style="width: 26px; height: 26px; border-radius: 6px; box-shadow: inset 0 0 0 2px #4E4757; display: flex; align-items: center; justify-content: center; font: 600 12px Roboto;">2</span><span>⋮</span></div></div>') % (
        sv('<path d="M3 11l9-8 9 8v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"></path>', 20), sv('<rect x="5" y="11" width="14" height="10" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path>', 14))
    return add(fr, bar)


def chrome_wrap(fr):
    bar = chrome_and('<div></div>')[len('<div>'):-len('</div>')]
    inner = bare(fr, 0).replace('box-shadow: 0 0 0 1px rgba(36,31,43,.16), 0 18px 44px rgba(36,31,43,.22);', '', 1)
    return ('<div style="position: relative; width: 800px; height: 1280px; border-radius: 22px; background: #FBF7F1; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 12px #241F2B, 0 0 0 13px rgba(36,31,43,.35);">%s'
            '<div style="position: absolute; left: 0; top: 64px;">%s</div></div>') % (bar, inner)


B_CHROME = chrome_wrap(AND_MED)

# ---------------------------------------------------------------- page
def fcol2(lab, fr, w, h, s, *n): return col(round(w * s) + 4, label(lab), scaled(fr, w, h, s), notes(*n))
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start; flex-wrap: wrap;">%s</div>' % ''.join(c)
s1 = row(fcol2('iPad · Stage Manager, a medium window (820 wide)', SM_MED, 1366, 1024, 0.62, B('Built') + ' The layout follows the window, never the device: 820 wide is medium, so the iPad top tabs (R2-1 1b)', B('Built') + ' Resizing re-lays out live; nothing is lost'),
         fcol2('iPad · Stage Manager, a large window (1180 wide)', SM_EXP, 1366, 1024, 0.62, B('Built') + ' At 840 and wider the sidebar and Workspace (R2-1 1a)', B('Built') + ' Under 600 the phone layout, as Split View ½ (R2-1 2c)'))
s2 = row(fcol2('Foldable · unfolded flat (book)', FOLD_BOOK, 700, 840, 0.6, B('Built') + ' 700 wide is medium: the rail, as any medium window', P('Not built') + ' Hinge awareness: the app reads no display features, so content spans the fold (dashed line)'),
         fcol2('Foldable · tabletop', FOLD_TABLE, 700, 840, 0.6, P('Not built') + ' Posture: half-open, the same medium layout runs across the fold', D('Design rule') + ' No pane or text across a hinge (ED-099, ED-110); tabletop as the compact layout (ED-168). Needs code'),
         fcol2('Foldable · folded', EP_ATODAY, 412, 892, 0.47, B('Built') + ' Folded, the outer screen is a phone: the approved Android Today, compact'))
s3 = row(fcol2('iPad · medium · Undo toast', T_IPAD, 820, 1180, 0.4, B('Built') + ' A floating toast, centred on the content (no tab bar at the bottom at medium)', B('Built') + ' 30 s window, a new change replaces it, ⌘Z / Ctrl+Z (R2-7)'),
         fcol2('Android tablet · medium · Undo toast', T_AND, 800, 1280, 0.4, B('Built') + ' Centred on the content beside the rail, never under it', B('Built') + ' M3 snackbar corners (8)'),
         fcol2('Foldable · Undo toast', T_FOLD, 700, 840, 0.5, B('Built') + ' The same placement on the unfolded foldable'))
s4 = row(fcol2('iPad · Safari, landscape (expanded)', B_SAFARI, 1180, 820, 0.6, B('Built') + ' The web app follows the window like the native one: at 1180 the web Workspace (ED-172)', B('Built') + ' Touch and keyboard both work; / and the single keys with a keyboard'),
         fcol2('Android tablet · Chrome, portrait (medium)', B_CHROME, 800, 1280, 0.38, B('Built') + ' At 800 wide the rail, as the native medium layout', D('Design-only') + ' Chrome’s own bar is the browser’s'))
RULES = [('Window, not device', 'Every tablet case is a width class of the window: Stage Manager, Split View, foldables and browsers all follow compact, medium and expanded.'),
         ('One toast', 'The R2-7 toast, centred on the content area at medium and expanded; never under a rail or a sidebar.'),
         ('Hinge: code needed', 'The app reads no display features yet; the approved rule (no pane or text across a hinge) needs a code task.'),
         ('Browsers', 'Tablet browsers get the same layouts as the native app at the same width (ED-172).'),
         ('Nothing lost', 'Resizing a window or folding a phone keeps the open task, the scroll and any draft.'),
         ('Text from the app', 'Every string is built. Tasks and dates are examples. No new copy.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 GAP PASS · R2-31</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Tablets: windows, folds and browsers</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">Stage Manager, the foldable hinge, the Undo toast at medium width and tablet browsers. As built, on the approved R2-1 tablet frames. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed · gap pass'), tag('tn', 'iPad, Android tablet, foldable'), tag('tn', '@@THEME@@'))
page_body = (body + section('1 · Stage Manager', s1) + section('2 · The foldable hinge', s2) + section('3 · The Undo toast at medium width', s3) + section('4 · Tablet browsers', s4) + section('Rules', rules))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-31 · Tablets</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-31-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-31.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-31.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('0 0 0 14px #F3ECE4', '0 0 0 14px #241F2B').replace('background: none; color: #A3E2D9; font: 700 15px', 'background: none; color: #0B4642; font: 700 15px').replace('#F2F1F4', '#2C2A30').replace('#E4E2E8', '#3A3740').replace('#F1ECF4', '#2C2A30').replace('class="blk-d', 'class="blk').replace('<title>E · R2-31 · Tablets</title>', '<title>E · R2-31 · Tablets · Dark</title>')
open('project/E-R2-31-Dark.dc.html', 'w', encoding='utf-8').write(dk)
print('ok')
