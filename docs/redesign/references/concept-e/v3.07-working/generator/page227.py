# R2-27 · Day states (gap pass): all done, past day, 3+ overlaps, all-day chips, empty today; task sheets for a done,
# a past and a calendar task; the 5-alert limit. Built behaviour and strings only (see the research notes in ED-330).
_p = open(os.path.join(HERE, '..', 'r226', 'page226.py'), encoding='utf-8').read()
exec(_p[:_p.rindex('# ---------------------------------------------------------------- page')])
CAL_G = '<rect x="3" y="5" width="18" height="16" rx="2.5"></rect><path d="M3 10h18M8 3v4M16 3v4"></path>'


def cut(fr, a_marker, b_marker, new=''):
    a = fr.index(a_marker)
    b = fr.index(b_marker, a + len(a_marker))
    return fr[:a] + new + fr[b:]


def all_done(fr):
    fr = _re2.sub(r'<span style="width: 28px; height: 28px; border-radius: 50%; box-shadow: inset 0 0 0 2\.5px (#[0-9A-Fa-f]{6});"></span>',
                  lambda m: '<span style="width: 28px; height: 28px; border-radius: 50%%; background: %s; color: #fff; display: flex; align-items: center; justify-content: center;">%s</span>' % (m.group(1), sv(CHECK, 15, 3)), fr)
    fr = _re2.sub(r'background: #FFFDF9; box-shadow: inset 0 0 0 4px (#[0-9A-Fa-f]{6}); color: \1;', lambda m: 'background: %s; color: #fff;' % m.group(1), fr)
    fr = fr.replace('font-size: 17px; font-weight: 700; color: #241F2B;', 'font-size: 17px; font-weight: 700; color: #6A6273;').replace('font-size: 17px; font-weight: 700;">', 'font-size: 17px; font-weight: 700; color: #6A6273;">')
    return fr


def no_now(fr):
    fr = cut(fr, '<!-- now bead -->', '<!--')
    return _re2.sub(r' · <span style="color: #11615C;">add here</span>', '', fr)


DONE_DAY = no_now(all_done(overrun_today(EP_TODAY).replace(' · not done', ''))).replace('3 of 9 done', '9 of 9 done')
REVIEW = ('<div role="group" aria-label="Day review" style="position: absolute; left: 16px; right: 16px; bottom: 106px; z-index: 30; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08), 0 10px 30px rgba(36,31,43,.14); padding: 14px 16px;">'
          '<div style="font: 800 17px Manrope;">Day review</div><div class="num" style="font: 500 14px -apple-system, system-ui; color: #6A6273; margin-top: 2px;">8 h 30 min until Wake Up at 7:00 AM</div>'
          '<div class="num" style="font: 600 15px -apple-system, system-ui; margin-top: 8px;">9 of 9 done</div><div style="font: 600 15px -apple-system, system-ui; color: #0B4642;">Nothing left to move</div>'
          '<span role="button" style="display: inline-flex; margin-top: 8px; height: 40px; padding: 0 14px; align-items: center; font: 700 14px -apple-system, system-ui; color: #0B4642;">Not now</span></div>')
I_DONE = add(DONE_DAY, REVIEW)


def skipped_lunch(fr):
    a = fr.index('<!-- lunch -->')
    b = fr.index('<!-- dentist -->')
    seg = fr[a:b].replace('background: #FFFDF9; box-shadow: inset 0 0 0 4px #D75E89; color: #D75E89;', 'background: #FBF7F1; border: 3px dashed #D75E8999; box-sizing: border-box; color: #D75E8966;')
    seg = seg.replace('font-size: 17px; font-weight: 700;', 'font-size: 17px; font-weight: 700; color: #8A8494;', 1)
    return fr[:a] + seg + fr[b:]


PILL = '<span aria-label="Back to today" role="button" style="position: absolute; top: 58px; right: 112px; z-index: 20; height: 32px; padding: 0 12px; border-radius: 16px; background: #E2EFEC; color: #0B4642; display: flex; align-items: center; gap: 6px; font: 700 13px -apple-system, system-ui;"><span style="width: 8px; height: 8px; border-radius: 50%; background: #11615C;"></span>Today</span>'
I_PAST = add(skipped_lunch(no_now(overrun_today(EP_TODAY))).replace('>Tue 3 Nov<', '>Mon 2 Nov<', 1).replace('aria-label="Tue 3 Nov', 'aria-label="Mon 2 Nov', 1).replace('3 of 9 done', '6 of 9 done'), PILL)
# 3+ overlaps: a chain of two-name knots (built: always pairwise)
_ki = EP_TODAY.index('<!-- knot -->')
_knot = EP_TODAY[_ki:EP_TODAY.index('<!-- call with sam -->')]
_ci = EP_TODAY.index('<!-- call with sam -->')
_call = EP_TODAY[_ci:EP_TODAY.index('<!-- now bead -->')]
_quick = (_call.replace('Call with Sam', 'Quick sync').replace('10:30–11:00 AM', '10:45–11:15 AM').replace('#2A9D8F', '#8B5CF6').replace('#289588', '#8B5CF6').replace('rgba(42,157,143,.2)', 'rgba(139,92,246,.2)'))
I_OVER3 = EP_TODAY.replace(_call, _call + _knot.replace('Overlap · 10:30–11:00', 'Overlap · 10:45–11:00').replace('#5B5FD6', '#2A9D8F').replace('#2A9D8F" stroke-width="3.5" stroke-linecap="round"></path></svg>', '#8B5CF6" stroke-width="3.5" stroke-linecap="round"></path></svg>') + _quick, 1)
# All-day chips above the day (built: tinted chips, no limit, they scroll)
_tip = EP_TODAY[EP_TODAY.index('  <!-- one tip -->'):EP_TODAY.index('  <!-- thread -->')]
CHIPS = ('  <div role="group" aria-label="All day" style="position: absolute; top: 192px; left: 16px; right: 0; height: 40px; display: flex; gap: 8px; overflow: hidden; white-space: nowrap;">%s</div>\n') % ''.join(
    '<span role="button" style="height: 40px; padding: 0 14px 0 8px; border-radius: 20px; background: %s22; display: flex; align-items: center; gap: 8px; font: 700 14px -apple-system, system-ui; color: #241F2B; flex: none;"><span style="width: 24px; height: 24px; border-radius: 50%%; box-shadow: inset 0 0 0 2.5px %s; color: %s; display: flex; align-items: center; justify-content: center;">%s</span>%s</span>' % (c, c, c, sv(ic, 13), t)
    for t, c, ic in [('Mum’s birthday', BLU, CAL_G), ('Pay the rent', AMB, CHECK), ('Bins out', GRN, CHECK), ('Library books due', BRN, CHECK)])
I_ALLDAY = EP_TODAY.replace(_tip, CHIPS, 1)
# Empty today on Android (built: the same empty line and actions as any day)
EMPTY_A = ('<!-- empty -->\n  <div style="position: absolute; top: 270px; left: 16px; right: 16px; display: flex; flex-direction: column; gap: 10px; font-family: Roboto, system-ui;">'
           '<div style="font: 400 15px/21px Roboto, system-ui; color: #6A6273; padding: 4px 4px 8px;">Nothing planned · pull the strip to plan or tap +</div>'
           '<span role="button" style="height: 48px; border-radius: 24px; border: 1.5px dashed #C9C1CF; display: flex; align-items: center; justify-content: center; gap: 6px; font: 500 15px Roboto, system-ui; color: #0B4642;">%sAdd to this day</span>'
           '<span role="button" style="height: 48px; border-radius: 24px; background: #E2EFEC; display: flex; align-items: center; justify-content: center; font: 500 15px Roboto, system-ui; color: #0B4642;">Pull from inbox · 3</span>'
           '<span role="button" style="height: 48px; border-radius: 24px; display: flex; align-items: center; justify-content: center; font: 500 15px Roboto, system-ui; color: #0B4642;">Copy a day…</span></div>\n  ') % sv(PLUS, 16)
A_EMPTY = cut(EP_ATODAY, '<!-- thread (same identity) -->', '<!-- Day button', EMPTY_A).replace('3 of 9 done · 7 h 40 planned', 'Nothing planned · 16 h free', 1)
WAKE_EMPTY = ('<div style="width: 358px; box-sizing: border-box; border-radius: 28px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.07), 0 14px 40px rgba(36,31,43,.08); padding: 22px 20px;">'
              '<div style="font: 800 24px/30px Manrope;">Good morning. Tuesday 3 November.</div><div style="font: 600 15px -apple-system, system-ui; color: #6A6273; margin-top: 6px;">Nothing planned yet</div>'
              '<span role="button" style="display: flex; margin-top: 18px; height: 52px; border-radius: 26px; background: #11615C; color: #fff; align-items: center; justify-content: center; font: 800 17px Manrope;">Plan today</span>'
              '<span role="button" style="display: flex; margin-top: 6px; height: 44px; align-items: center; justify-content: center; font: 700 16px -apple-system, system-ui; color: #11615C;">Later</span></div>')

# ---------------------------------------------------------------- task sheets
_SH = EP_SHEET


def sheet_base(meta):
    s = _SH.replace('9:00–11:00 AM · <b style="color: #11615C;">18 min left</b>', meta, 1)
    s = cut(s, '<div style="display: flex; align-items: center; gap: 8px; margin: 10px 0 0 2px; font-size: 13px; color: #6A6273;" class="num">', '<div style="display: grid;')
    a = s.index('<div style="margin-top: 14px; min-height: 56px; border-radius: 22px; background: #F6F1EA;')
    b = s.index('<div style="display: flex; flex-direction: column; align-items: center; gap: 2px; margin-top: 12px;', a)
    return s[:a] + s[b:]


def filled_head(s):
    s = s.replace('background: radial-gradient(closest-side, #FFFDF9 calc(100% - 5px), transparent calc(100% - 4.5px)), conic-gradient(#5B5FD6 0 85%, #5B5FD633 85% 100%); color: #5B5FD6;', 'background: #5B5FD6; color: #fff;', 1)
    return s.replace('<button aria-label="Mark done" style="width: 44px; height: 44px; border: 0; background: none; display: flex; align-items: center; justify-content: center; flex: none;"><span style="width: 28px; height: 28px; border-radius: 50%; box-shadow: inset 0 0 0 2.5px #5B5FD6;"></span></button>',
                     '<button aria-label="Mark not done" style="width: 44px; height: 44px; border: 0; background: none; display: flex; align-items: center; justify-content: center; flex: none;"><span style="width: 28px; height: 28px; border-radius: 50%%; background: #5B5FD6; color: #fff; display: flex; align-items: center; justify-content: center;">%s</span></button>' % sv(CHECK, 15, 3), 1)


def hollow_head(s):
    return s.replace('background: radial-gradient(closest-side, #FFFDF9 calc(100% - 5px), transparent calc(100% - 4.5px)), conic-gradient(#5B5FD6 0 85%, #5B5FD633 85% 100%);', 'background: #FFFDF9; box-shadow: inset 0 0 0 5px #5B5FD6;', 1)


_DONE_TILE = '<button style="height: 64px; border: 0; border-radius: 18px; background: #11615C; color: #fff;'
SH_DONE = filled_head(sheet_base('Mon, Nov 2 · 9:00–11:00 AM · 2 h'))
_i = SH_DONE.index(_DONE_TILE)
_e = SH_DONE.index('</button>', _i)
SH_DONE = SH_DONE[:_i] + '<button style="height: 64px; border: 0; border-radius: 18px; background: #F1ECE4; color: #241F2B; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 6px; font-size: 13px; font-weight: 700;">%sNot done</button>' % sv('<circle cx="12" cy="12" r="8"></circle>', 22) + SH_DONE[_e + 9:]
SH_PAST = hollow_head(sheet_base('Mon, Nov 2 · 9:00–11:00 AM · 2 h'))
_si = SH_PAST.index('Shift the rest</button>')
_ss = SH_PAST.rfind('<button style="', 0, _si)
SH_PAST = SH_PAST[:_ss] + SH_PAST[_ss:].replace('<button style="', '<button disabled style="opacity: .38; ', 1)


def cal_sheet():
    s = hollow_head(sheet_base('Today · 2:00–2:30 PM · 30 min')).replace('#5B5FD6', '#7A7280')
    s = _re2.sub(r'(aria-label="Title" style="[^"]*">)Deep work: roadmap<', r'\1Dentist<', s, count=1)
    s = _re2.sub(r'(aria-label="Colour and icon: )[^"]*', r'\1grey, calendar', s, count=1)
    k = s.index('aria-label="Colour and icon')
    a = s.index('<svg', k)
    b = s.index('</svg>', a) + 6
    s = s[:a] + sv(CAL_G, 26) + s[b:]
    g = s.index('<div style="display: grid;')
    line = ('<div class="num" style="display: flex; align-items: center; gap: 8px; margin: 10px 0 0 2px; font-size: 13px; color: #6A6273;">%sChanges go back to Work</div>') % sv(CAL_G, 14)
    return s[:g] + line + s[g:]


SH_CAL = cal_sheet()
SH_DONE = SH_DONE.replace('>Tue 3 Nov<', '>Mon 2 Nov<', 1)
SH_PAST = SH_PAST.replace('>Tue 3 Nov<', '>Mon 2 Nov<', 1)
ALERTS = ('<div style="display: flex; align-items: center; justify-content: space-between; margin: 10px 0 12px;"><span style="width: 54px;"></span><span style="font: 600 17px %s;">Alerts</span><span style="font: 600 17px %s; color: #11615C;">Done</span></div>'
          '<div style="border-radius: 18px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s</div>'
          '<div style="margin: 16px 2px 8px; font: 700 12px %s; letter-spacing: .6px; color: #6A6273;">ADD AN ALERT</div>'
          '<div style="display: flex; flex-wrap: wrap; gap: 8px; opacity: .45;" aria-disabled="true">%s</div>'
          '<div style="margin-top: 10px; font: 600 14px %s; color: #0B4642;">Up to 5 alerts</div>'
          '<div style="margin-top: 16px; border-radius: 18px; background: #FFFDF9; padding: 10px 14px; display: flex; align-items: center; gap: 12px; box-shadow: 0 0 0 1px rgba(36,31,43,.06);"><span style="flex: 1;"><span style="display: block; font: 600 16px %s;">Wind Down reminder</span><span style="display: block; font: 400 13px %s; color: #6A6273;">Every evening, with tomorrow&#39;s first task</span></span>%s</div>') % (
    IOSF, IOSF, ''.join('<div style="display: flex; align-items: center; min-height: 48px; padding: 0 6px 0 14px;%s"><span class="num" style="flex: 1; font: 400 16px %s;">%s</span><span role="button" aria-label="Remove %s" style="width: 44px; height: 44px; display: flex; align-items: center; justify-content: center; color: #6A6273;">%s</span></div>' % (
        '' if i == 4 else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', IOSF, t, t, sv(X_I, 16)) for i, t in enumerate(['60 min before', '30 min before', '10 min before', 'at start', 'at end'])),
    IOSF, ''.join('<span class="num" style="height: 36px; padding: 0 12px; border-radius: 18px; background: #ECE5DC; display: flex; align-items: center; font: 600 14px %s;">%s</span>' % (IOSF, t) for t in ['15 min before', '5 min before', '10 min after end']),
    IOSF, IOSF, IOSF, ios_switch(True))
I_ALERTS = big_sheet(EP_EDITOR, ALERTS, 200)

# ---------------------------------------------------------------- page
def fcol(w, lab, fr, *n): return col(w, label(lab), fr, notes(*n))
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start;">%s</div>' % ''.join(c)
stack = lambda *c: '<div style="display: flex; flex-direction: column; gap: 18px;">%s</div>' % ''.join(c)
s1 = (row(fcol(390, 'iPhone · every task done, after Wind Down', I_DONE, B('Built') + ' No celebration and no score: “9 of 9 done”, then the Day review with “Nothing left to move” and Not now', B('Built') + ' The same review a day with leftovers gets; never compared with other days'),
          fcol(390, 'iPhone · a past day (Mon 2 Nov)', I_PAST, B('Built') + ' The “● Today” pill takes you back; no banner; no prompts', B('Built') + ' Ended unticked: “· not done”. Skipped: a dashed, faded dot and a muted title (Lunch). Free time loses “add here”', B('Built') + ' Still editable: drag and the Done circle work'),
          fcol(390, 'iPhone · three tasks overlapping', I_OVER3, B('Built') + ' Overlaps are always pairwise: three tasks make a chain of knots, each naming two', B('Built') + ' Dense days are not compacted: each row keeps its height, gaps under 15 min are not drawn, the day scrolls'),
          fcol(390, 'iPhone · all-day tasks and events', I_ALLDAY, B('Built') + ' All-day items are tinted chips above the day, not rows on the thread; they scroll sideways with no limit', B('Built') + ' Hold a chip and drag it onto the thread to give it a time; drop a task on the Wake Up cap to make it all-day (R2-25)'))
      + row(fcol(412, 'Android · today with nothing planned', A_EMPTY, B('Built') + ' “Nothing planned · 16 h free”; the empty line and Add to this day, Pull from inbox · 3, Copy a day…', B('Built') + ' The same as any empty day; a past empty day shows the line only'),
            col(358, label('The Wake Up card on an empty day'), WAKE_EMPTY, notes(B('Built') + ' “Nothing planned yet”, Plan today, Later; phones only', P('Not built') + ' Show less has no “Rest of today” on Android; its empty view is the line and Later'))))
s2 = row(fcol(390, 'iPhone · a done task, from a past day', SH_DONE, B('Built') + ' The Done tile becomes Not done; the dot is filled; “Mon, Nov 2 · 9:00–11:00 AM · 2 h”'),
         fcol(390, 'iPhone · a past task, not done', SH_PAST, B('Built') + ' No past label in the sheet; Shift the rest is off for past tasks; Move and Focus stay'),
         fcol(390, 'iPhone · a calendar event', SH_CAL, B('Built') + ' Editable like a task, with one line: “Changes go back to Work”, or “From Work · changes stay in Dottoday” when send-back is off', B('Built') + ' No Pinned row for events'),
         fcol(390, 'iPhone · five alerts already', I_ALERTS, B('Built') + ' At five, every Add chip is off and “Up to 5 alerts” shows; remove one to add another', P('Not built') + ' A custom time: the chips are the list'))
RULES = [('No shame', 'A finished day gets no confetti or score; a past day says “not done”, never missed.'),
         ('Nothing hidden', 'Dense days keep every row; all-day items stay visible as chips.'),
         ('Editable past', 'Past days can still be fixed: drag, tick and edit work.'),
         ('Calendar events', 'Edited like tasks; the sheet says where changes go.'),
         ('Same everywhere (R-13)', 'iPhone and Android share these states; tablets, Mac and web use the same rows in their layouts.'),
         ('Text from the app', 'Every string is built (app_en.arb). Tasks and times are examples. No new copy.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 GAP PASS · R2-27</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Day states</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">A finished day, a past day, overlapping and all-day tasks, an empty today, and the task sheet for done, past and calendar tasks and the alert limit. As built, on the approved Today and task-sheet frames. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed · gap pass'), tag('tn', 'iPhone, Android'), tag('tn', '@@THEME@@'))
page_body = body + section('1 · The day', s1) + section('2 · Task sheets', s2) + section('Rules', rules)
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-27 · Day states</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-27-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-27.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-27.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('class="blk-d', 'class="blk').replace('<title>E · R2-27 · Day states</title>', '<title>E · R2-27 · Day states · Dark</title>')
open('project/E-R2-27-Dark.dc.html', 'w', encoding='utf-8').write(dk)
print('ok')
