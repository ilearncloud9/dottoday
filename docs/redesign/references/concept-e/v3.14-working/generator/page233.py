# R2-33 · Settings pages never drawn (audit §1): Settings › Planning, Sounds, and Siri & Shortcuts.
# Built rows, order and strings (planning_group.dart, sounds_page.dart, siri_page.dart); ED-332 icons on every platform.
_p = open(os.path.join(HERE, '..', 'r230', 'page230.py'), encoding='utf-8').read()
exec(_p[:_p.rindex('# ---------------------------------------------------------------- page')])


def irow2(t, sub=None, value=None, sw=None, chev=True, last=False, check=False):
    r = irow(None, None, t, sub=sub, value=value, sw=sw, chev=chev and sw is None and not check, last=last)
    key = t.replace('&#39;', "'")
    ic = stile(key) if key in ICONS else (stile(t) if t in ICONS else '')
    r = r.replace('gap: 12px; padding: 7px 14px; color: #241F2B;', 'gap: 12px; padding: 7px 14px; color: #241F2B;', 1)
    k = r.index('>') + 1
    r = r[:k] + ic + r[k:]
    if check:
        k = r.rindex('</div>')
        r = r[:k] + '<span style="color: #11615C; flex: none;">%s</span>' % sv(CHECK, 18, 2.6) + r[k:]
    return r


def arow2(t, sub=None, sw=None, value=None, last=False):
    # Android row inside a card: the iPhone row's structure (icon, title, supporting text, trailing value or switch) in Material.
    key = t.replace('&#39;', "'")
    lead = SI.circle(*ICONS[key], False) if key in ICONS else ''
    r = arow(t, sub, sw)
    if not sub:
        r = r.replace('min-height: 72px', 'min-height: 56px', 1)
    if value:
        k = r.rindex('</div>')
        r = r[:k] + '<span style="font: 400 14px Roboto, system-ui; color: #4E4757; flex: none;">%s</span>' % value + r[k:]
    if not last:
        r = r.replace('box-sizing: border-box;">', 'box-sizing: border-box; box-shadow: inset 0 -1px 0 rgba(36,31,43,.07);">', 1)
    k = r.index('>') + 1
    return r[:k] + lead + r[k:]


def aradio(sel): return ('<span role="radio" aria-checked="%s" style="width: 20px; height: 20px; border-radius: 50%%; box-shadow: inset 0 0 0 2px %s; display: flex; align-items: center; justify-content: center; flex: none;">%s</span>') % (
    'true' if sel else 'false', '#11615C' if sel else '#7A7280', '<span style="width: 10px; height: 10px; border-radius: 50%; background: #11615C;"></span>' if sel else '')


def achoice(t, sub=None, sel=False, last=False):
    r = arow(t, sub)
    if not sub:
        r = r.replace('min-height: 72px', 'min-height: 56px', 1)
    k = r.rindex('</div>')
    r = r[:k] + aradio(sel) + r[k:]
    if not last:
        r = r.replace('box-sizing: border-box;">', 'box-sizing: border-box; box-shadow: inset 0 -1px 0 rgba(36,31,43,.07);">', 1)
    return r


# ---------------------------------------------------------------- 1 · Planning
PLAN_ROWS = [('Default duration', None, '30 min', None), ('Routines', None, '2', None), ('Snap to', None, '5 min', None), ('Shift later tasks', None, 'Ask each time', None),
             ('Show free time', 'Dotted gaps on the thread', None, True), ('Running-late nudge', 'Offer to shift the rest of the day', None, True),
             ('Ask when a dot hasn&#39;t started', '10 minutes after its start, one gentle ping: “Start Run?”', None, True),
             ('Plan-your-inbox nudge', 'Once a day from Wake Up, when the Inbox holds tasks', None, True), ('Roll unfinished to tomorrow', 'Otherwise they return to the Inbox', None, False)]
LOW = ('Low-energy mode', 'Today shows only what&#39;s next and nudges pause, until your next Wake Up', None, False)
I_PLAN = withbar(ipage('Planning', 'Settings', igroup([irow2(t, s, v, w) for t, s, v, w in PLAN_ROWS[:4]]) + igroup([irow2(t, s, v, w) for t, s, v, w in PLAN_ROWS[4:]] + [irow2(*LOW[:3], sw=LOW[3])])))
SHIFT_SHEET = ('<div style="display: flex; align-items: center; justify-content: space-between; margin: 10px 0 12px;"><span style="font: 400 17px %s; color: #11615C;">Cancel</span><span style="font: 600 17px %s;">Shift later tasks</span><span style="width: 54px;"></span></div>'
               '<div style="border-radius: 18px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s</div>') % (IOSF, IOSF, ''.join(
    '<div role="radio" aria-checked="%s" style="min-height: 50px; display: flex; align-items: center; padding: 0 16px; font: 400 17px %s;%s"><span style="flex: 1;">%s</span>%s</div>' % (
        'true' if o == 'Ask each time' else 'false', IOSF, '' if o == 'Never' else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', o,
        ('<span style="color: #11615C;">%s</span>' % sv(CHECK, 18, 2.6)) if o == 'Ask each time' else '') for o in ['Ask each time', 'Always', 'Never']))
I_SHIFT = big_sheet(I_PLAN, SHIFT_SHEET, 520)
A_PLAN = withbar(apage('Planning', '<div style="height: 4px;"></div>' + acard([arow2(t, s, w, v, last=(n == 3)) for n, (t, s, v, w) in enumerate(PLAN_ROWS[:4])]) + '<div style="height: 12px;"></div>'
                       + acard([arow2(t, s, w, v, last=(n == 2)) for n, (t, s, v, w) in enumerate(PLAN_ROWS[4:7])])), True)
M_PLAN = setwin('Planning', 'Planning', mgroup('', [mrow(t, s, val=v, sw=w, chev=w is None, last=(i == 3)) for i, (t, s, v, w) in enumerate(PLAN_ROWS[:4])])
                + mgroup('', [mrow(t, s, val=v, sw=w, chev=False, last=False) for t, s, v, w in PLAN_ROWS[4:]] + [mrow(LOW[0], LOW[1], sw=False, chev=False, last=True)]))

# ---------------------------------------------------------------- 2 · Sounds
DOT = ['Dot', 'Chime', 'Bell', 'Ripple', 'Dot alarm']
QUIET = ['Slip', 'Whisper', 'Soft', 'Bubble', 'Pull']
def srow(t, sub=None, sel=False, last=False):
    return ('<div role="radio" aria-checked="%s" style="min-height: 46px; display: flex; align-items: center; gap: 12px; padding: 6px 14px;%s"><span style="flex: 1;"><span style="display: block; font: 400 16px %s;">%s</span>%s</span>%s</div>') % (
        'true' if sel else 'false', '' if last else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', IOSF, t,
        ('<span style="display: block; font: 400 13px %s; color: #6A6273;">%s</span>' % (IOSF, sub)) if sub else '', ('<span style="color: #11615C;">%s</span>' % sv(CHECK, 18, 2.6)) if sel else '')
def sgroup(cap, rows): return ('<div style="padding: 14px 20px 6px; font-size: 13px; color: #6A6273;">%s</div>' % cap) + '<div style="margin: 0 16px; border-radius: 18px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s</div>' % ''.join(rows)
SND_TOP = (pt('Task reminders play this, unless a task has its own. Tap one to hear it.') + sgroup('Task reminders', [srow('System sound'), srow('None', 'Shows and vibrates, without a sound', last=True)])
           + sgroup('Dottoday', [srow(n, sel=(n == 'Dot'), last=(n == 'Dot alarm')) for n in DOT]) + sgroup('Quiet', [srow(n, last=(n == 'Pull')) for n in QUIET]))
I_SND = withbar(ipage('Sounds', 'Reminders', SND_TOP))
SND_BOTTOM = (igroup([irow2('Start sound', 'Rings for the first task of your day and when a routine starts', 'Dot alarm'), irow2('Done sound', 'When you tick a task done', 'Swift', last=True)], 'Also')
              + igroup([irow2('Sounds in app', 'The Done sound and the Focus tick', sw=True), irow2('Haptics in app', 'Taps you feel as you drag, drop and tick a task done', sw=True, last=True)], 'Sound effects',
                       'Sounds and haptics may not play, depending on your device&#39;s settings.')
              + '<div style="padding: 12px 20px; font: 400 13px %s; color: #6A6273;">Sounds from notificationsounds.com (CC BY 4.0).</div>' % IOSF)
I_SND2 = withbar(ipage('Sounds', 'Reminders', '<div style="height: 6px;"></div>' + SND_BOTTOM).replace('top: 92px; left: 20px; right: 20px; font: 700 34px', 'top: 92px; left: 20px; right: 20px; opacity: 0; font: 700 34px', 1))
START = ['Morning', 'Soft bells', 'Sunrise', 'Gentle', 'Dawn chorus', 'Insistent', 'Wind chimes', 'Clock bell']
START_SHEET = ('<div style="display: flex; align-items: center; justify-content: space-between; margin: 10px 0 12px;"><span style="font: 400 17px %s; color: #11615C;">Cancel</span><span style="font: 600 17px %s;">Start sound</span><span style="width: 54px;"></span></div>'
               '<div style="border-radius: 18px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s</div>') % (IOSF, IOSF, ''.join(
    srow(n, 'Loud and repeating. Use it if quieter sounds don&#39;t reach you.' if n == 'Insistent' else None, sel=(n == 'Dawn chorus'), last=(n == START[-1])) for n in START))
I_START = big_sheet(I_SND2, START_SHEET, 200)
A_SND = withbar(apage('Sounds', '<div style="padding: 0 16px 4px; font: 400 14px/20px Roboto, system-ui; color: #4E4757;">Task reminders play this, unless a task has its own. Tap one to hear it.</div>'
                      + asec('Task reminders') + acard([achoice('System sound'), achoice('None', 'Shows and vibrates, without a sound', last=True)])
                      + asec('Dottoday') + acard([achoice(n, sel=(n == 'Dot'), last=(n == 'Dot alarm')) for n in DOT])
                      + asec('Quiet') + acard([achoice(n, last=(n == 'Pull')) for n in QUIET])), True)

# ---------------------------------------------------------------- 3 · Siri & Shortcuts (iPhone)
PHRASES = [('Add a task in Dottoday', 'Siri asks what to add. Say a time and it goes on your day; otherwise it goes to the Inbox.', 'plus', 'teal'),
           ('What&#39;s next in Dottoday', 'Siri says what&#39;s on now, or what comes next.', 'ring', 'indigo'),
           ('Mark my task done in Dottoday', 'Ticks off the task you&#39;re on.', 'check', 'green'),
           ('Give my task 15 more minutes in Dottoday', 'Gives the task you&#39;re on 15 more minutes.', 'clock', 'amber'),
           ('Start focus in Dottoday', 'Opens Focus on the task you&#39;re on.', 'ring', 'violet')]
def prow(t, sub, g, c, last=False):
    r = irow(None, None, '“%s”' % t, sub=sub, chev=False, last=last)
    k = r.index('>') + 1
    return r[:k] + SI.tile(c, SI.P[g], False) + r[k:]
I_SIRI = withbar(ipage('Siri &amp; Shortcuts', 'Help and about',
                       pt('Siri can add a task, tell you what&#39;s next, and help with the task you&#39;re on — without opening Dottoday.') + pt('Say “Hey Siri” or hold the side button, then say a phrase.')
                       + igroup([prow(*p, last=(i == len(PHRASES) - 1)) for i, p in enumerate(PHRASES)], 'What you can say')
                       + igroup([(lambda r: r[:r.index('>') + 1] + SI.tile('indigo', '<path d="M12 15V3M7 8l5-5 5 5M5 15v4a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-4"></path>', False) + r[r.index('>') + 1:])(irow(None, None, 'Open Shortcuts', last=True))], 'Shortcuts', 'The same five actions are in the Shortcuts app, ready for the Action button, Control Center or your Home Screen.')))

# ---------------------------------------------------------------- page
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start; flex-wrap: wrap;">%s</div>' % ''.join(c)
def scw(fr, w, h, s): return '<div style="width: %dpx; height: %dpx; flex: none;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>' % (round(w * s), round(h * s), w, h, s, fr)
def fp(lab, fr, w, h, s, *n): return col(round(w * s) + 4, label(lab), scw(fr, w, h, s), notes(*n))
s1 = row(fp('iPhone · Settings › Planning', I_PLAN, 390, 844, 0.62, B('Built') + ' The rows and order of the Planning group, with Low-energy mode last (R2-22)', D('Design-only') + ' A page of its own from the Settings root (G2-4, ED-084); icons from ED-332',
            Q('Copy') + ' “Running-late nudge” says “late”, which the no-shame rule bans: needs your word (e.g. “Need-more-time nudge”)'),
         fp('iPhone · Shift later tasks', I_SHIFT, 390, 844, 0.62, B('Built') + ' Ask each time, Always, Never'),
         fp('Android · Settings › Planning', A_PLAN, 412, 892, 0.6, B('Built') + ' The iPhone page’s two groups in Material cards: values trailing, switches, the ED-332 circles'),
         fp('Mac · Settings window › Planning', M_PLAN, 900, 760, 0.42, D('Design-only') + ' The Planning pane of the approved Settings window; web the same in two panes (R2-11, R2-30)'))
s2 = row(fp('iPhone · Settings › Reminders › Sounds', I_SND, 390, 844, 0.62, B('Built') + ' The task reminder sound for every task without its own: System sound, None, then Dottoday, Quiet, Clear and Playful (48 in all)', B('Built') + ' Tapping one plays it'),
         fp('iPhone · Sounds, further down', I_SND2, 390, 844, 0.62, B('Built') + ' Start sound and Done sound, Sounds in app, Haptics in app, the footer and the credit'),
         fp('iPhone · Start sound', I_START, 390, 844, 0.62, B('Built') + ' The start sounds, with the Insistent note'),
         fp('Android · Sounds', A_SND, 412, 892, 0.6, B('Built') + ' The same page as on iPhone, in Material: the same groups, captions and order in cards, M3 radio buttons for the choice', D('Design-only') + ' Rule (owner comment): every Android screen mirrors the iPhone screen’s structure with Android-native components'))
s3 = row(fp('iPhone · Settings › Help and about › Siri & Shortcuts', I_SIRI, 390, 844, 0.62, B('Built') + ' iPhone only: the five phrases and Open Shortcuts', B('Built') + ' Android has static shortcuts and Quick Settings tiles instead (R2-17, R2-29); Mac and web have no Siri page'),
         col(520, label('Where each page lives'), notes(B('Built') + ' Planning: Settings › Planning; Sounds: Settings › Reminders › Sounds; Siri &amp; Shortcuts: Settings › Help and about (iPhone)',
                                                        D('Design-only') + ' On tablets, Mac and web the same pages open in the right pane (R2-11) or the Settings window (R2-30)')))
RULES = [('As built', 'Every row, order and string is the app’s; only the page frame is the approved Settings design.'),
         ('Icons', 'Each row has its one icon and colour on every platform (ED-332).'),
         ('Hear it first', 'Tapping a sound plays it; nothing changes until you pick.'),
         ('No shame', '“Running-late nudge” is the one string that breaks the rule; it is flagged for your word.'),
         ('Parity (R-13)', 'Planning and Sounds are the same everywhere; Siri is iPhone-only by nature, with Android’s shortcuts as its counterpart.'),
         ('Text from the app', 'Every string is built. Values are examples. No new copy.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 · R2-33</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Planning, Sounds and Siri</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">Three Settings pages that were never drawn (audit §1): Planning, Sounds, and Siri &amp; Shortcuts. As built. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed'), tag('tn', 'iPhone, Android, Mac'), tag('tn', '@@THEME@@'))
page_body = (body + section('1 · Settings › Planning', s1) + section('2 · Sounds', s2) + section('3 · Siri &amp; Shortcuts', s3) + section('Rules', rules))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-33 · Planning, Sounds and Siri</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
open('project/E-R2-33.dc.html', 'w', encoding='utf-8').write(fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-33-Dark.').replace('@@THEME@@', 'Light'))
dk = fill(darkify(page.replace('@@OTHER@@', 'Light on E-R2-33.').replace('@@THEME@@', 'Dark')), XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('background: #F6E2EA; color: #9C3D63;', 'background: #523342; color: #F2A7C1;')
open('project/E-R2-33-Dark.dc.html', 'w', encoding='utf-8').write(dk.replace('<title>E · R2-33 · Planning, Sounds and Siri</title>', '<title>E · R2-33 · Planning, Sounds and Siri · Dark</title>'))
print('ok')
