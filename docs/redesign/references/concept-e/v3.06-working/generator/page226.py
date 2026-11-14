# R2-26 · Time states (gap pass): overrun, Now in the morning and between tasks, Focus past its end.
# Built behaviour and strings only: shared/dot/thread_day.dart (missed), today_prompt.dart (Need more time?),
# running_late_sheet.dart, domain/focus/focus_state.dart, macos/Runner/DayDotStatusItem.swift, wake_up_card_*.dart.
_p = open(os.path.join(HERE, '..', 'r225', 'page225.py'), encoding='utf-8').read()
exec(_p[:_p.rindex('# ---------------------------------------------------------------- page')].replace("os.path.join(HERE, '..', 'r224', 'page224.py')", "os.path.join(HERE, '..', 'r224', 'page224.py')"))
CODE_I = '<path d="M8 7l-5 5 5 5M16 7l5 5-5 5M14 4l-4 16"></path>'
AUD = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/a21b100f-12b5-489d-9702-7c7846acea81/scratchpad/audit/project/'


def bframe(board, st):
    s = open(AUD + board + '.dc.html', encoding='utf-8').read()
    d = 0
    for m in _re2.finditer(r'<div\b|</div>', s[st:]):
        d += 1 if m.group(0) == '<div' else -1
        if d == 0:
            return s[st:st + m.end()]


# ---------------------------------------------------------------- 1 · Overrun on Today (built: the dot turns "missed")
def overrun_today(fr):
    a = fr.index('<!-- deep work (now) -->')
    b = fr.index('<!-- knot -->')
    row = ('<!-- deep work (ended, not done) -->\n   <div role="listitem" style="position: relative; height: 54px; display: flex; align-items: center; padding: 0 8px 0 20px;">'
           '<span aria-hidden="true" style="position: absolute; left: 42px; top: 0; height: 50%; width: 4px; background: #4A9BD6;"></span><span aria-hidden="true" style="position: absolute; left: 42px; top: 50%; bottom: 0; width: 4px; background: #5B5FD6;"></span>'
           '<span style="position: relative; width: 48px; display: flex; justify-content: center;"><span style="width: 34px; height: 34px; border-radius: 50%; background: #FFFDF9; box-shadow: inset 0 0 0 4px #5B5FD6; color: #5B5FD6; display: flex; align-items: center; justify-content: center">@@ICON@@</span></span>'
           '<div style="flex: 1; min-width: 0; padding-left: 10px; line-height: 1.25;"><div class="num" style="font-size: 13px; color: #6A6273;">9:00–11:00 AM · not done</div><div style="font-size: 17px; font-weight: 700; color: #241F2B;">Deep work: roadmap</div></div>'
           '<button aria-label="Deep work: roadmap, not done. Mark done" style="width: 44px; height: 44px; border: 0; background: transparent; padding: 0; display: flex; align-items: center; justify-content: center;"><span style="width: 28px; height: 28px; border-radius: 50%; box-shadow: inset 0 0 0 2.5px #5B5FD6;"></span></button></div>\n   ').replace('@@ICON@@', sv(CODE_I, 19))
    fr = fr[:a] + row + fr[b:]
    fr = _re2.sub(r'background: radial-gradient\(closest-side, #FFFDF9 calc\(100% - 5px\), transparent calc\(100% - 5px \+ 0\.5px\)\), conic-gradient\(#289588 0 40%, rgba\(42,157,143,\.2\) 40% 100%\);', 'background: #FFFDF9; box-shadow: inset 0 0 0 4px #2A9D8F;', fr, count=1)
    fr = fr.replace('10:30–11:00 AM</div>', '10:30–11:00 AM · not done</div>', 1)
    fr = fr.replace('aria-label="Now, 10:42"', 'aria-label="Now, 11:12"').replace('>10:42</span>', '>11:12</span>', 1)
    return fr


NUDGE = ('<div role="group" aria-label="Need more time?" style="position: absolute; left: 16px; right: 16px; bottom: 106px; z-index: 30; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08), 0 10px 30px rgba(36,31,43,.14); padding: 14px 16px;">'
         '<div style="font: 800 17px Manrope;">Need more time?</div><div style="font: 500 14px -apple-system, system-ui; color: #6A6273;">“Deep work: roadmap” ended 12 min ago</div>'
         '<div style="display: flex; gap: 8px; margin-top: 10px;"><span role="button" style="height: 40px; padding: 0 16px; border-radius: 20px; background: #11615C; color: #fff; display: flex; align-items: center; font: 700 14px -apple-system, system-ui;">Catch up</span>'
         '<span role="button" style="height: 40px; padding: 0 14px; display: flex; align-items: center; font: 700 14px -apple-system, system-ui; color: #0B4642;">Not now</span></div></div>')
O_TODAY = overrun_today(EP_TODAY)
O_NUDGE = add(O_TODAY, NUDGE)


def opt(t, d, sel=False):
    return ('<div role="radio" aria-checked="%s" style="display: flex; align-items: center; gap: 12px; min-height: 60px; padding: 8px 14px; box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);"><span style="width: 22px; height: 22px; border-radius: 50%%; flex: none; box-shadow: inset 0 0 0 %s;"></span>'
            '<span style="flex: 1;"><span style="display: block; font: 600 16px %s;">%s</span><span class="num" style="display: block; font: 400 13px %s; color: #6A6273;">%s</span></span></div>') % (
        'true' if sel else 'false', '7px #11615C' if sel else '2px #8A8494', IOSF, t, IOSF, d)


LATE = ('<div style="display: flex; align-items: center; justify-content: space-between; margin: 10px 0 12px;"><span style="font: 400 17px %s; color: #11615C;">Cancel</span><span style="font: 600 17px %s;">Running late</span><span style="font: 600 17px %s; color: #11615C;">Done</span></div>'
        '<div style="font: 600 13px %s; color: #6A6273;">How late</div><div style="display: flex; gap: 8px; margin-top: 8px;">%s</div>'
        '<div style="margin-top: 16px; border-radius: 18px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s%s%s</div>') % (
    IOSF, IOSF, IOSF, IOSF, ''.join('<span role="radio" class="num" style="height: 40px; padding: 0 16px; border-radius: 20px; display: flex; align-items: center; font: 700 15px %s; %s">%s</span>' % (
        IOSF, 'background: #11615C; color: #fff;' if m == 15 else 'background: #ECE5DC; color: #241F2B;', '+%d min' % m) for m in (5, 15, 30)),
    opt('Shift the rest', '4 tasks move 15 min later', True), opt('Skip “Lunch”', 'Frees its time; nothing else moves'), opt('Shorten “Lunch”', 'Starts 15 min later, still ends at 1:15 PM'))
O_LATE = big_sheet(O_TODAY, LATE, 380)

# ---------------------------------------------------------------- 2 · Now (minimal) through the day: the built Now / Next up / Nothing else today rule
NOWF = bframe('E-PhonesMinimal', 5057)
ANOWF = bframe('E-PhonesMinimal', 79082)
TASKS = [(6.75, 7.5, COR, 'done'), (7.5, 7.75, AMB, 'done'), (8.0, 8.25, BLU, 'done'), (9.0, 11.0, IND, 'a'), (10.5, 11.0, '#2A9D8F', 'a'),
         (12.5, 13.25, PNK, 'a'), (14.0, 14.5, GRY, 'cal'), (15.0, 15.75, GRN, 'a'), (18.0, 19.0, VIO, 'a'), (21.5, 22.0, BRN, 'a')]


def horizon(now, label, done_upto):
    X = lambda t: max(0.0, min(350.0, (t - 7) * 21.875))
    nx = X(now)
    out = '<span style="position: absolute; left: 0; width: %.1fpx; top: 11.5px; height: 3px; background: #11615C;"></span><span style="position: absolute; left: %.1fpx; right: 0; top: 11.5px; height: 0; border-top: 3px dotted #BEB6C7;"></span>' % (nx, nx)
    out += '<span style="position: absolute; left: -8px; top: 5px; width: 16px; height: 16px; border-radius: 50%; background: #FBEBC8; box-shadow: 0 0 0 2px #FBF7F1;"></span>'
    for a, b, c, st in TASKS:
        x = X(a) - 7
        if a < done_upto and st == 'done':
            out += '<span style="position: absolute; left: %.1fpx; top: 6px; width: 14px; height: 14px; border-radius: 50%%; background: %s; box-shadow: 0 0 0 2px #FBF7F1;"></span>' % (x, c)
        elif st == 'cal':
            out += '<span style="position: absolute; left: %.1fpx; top: 6px; width: 14px; height: 14px; border-radius: 50%%; background: #FBF7F1; box-shadow: inset 0 0 0 2px #7A7280, 0 0 0 2px #FBF7F1;"></span>' % x
        else:
            out += '<span style="position: absolute; left: %.1fpx; top: 6px; width: 14px; height: 14px; border-radius: 50%%; background: #FFFDF9; box-shadow: inset 0 0 0 2.5px %s, 0 0 0 2px #FBF7F1;"></span>' % (x, c)
    out += '<span style="position: absolute; left: 342px; top: 5px; width: 16px; height: 16px; border-radius: 50%; background: #E6E3F7; box-shadow: 0 0 0 2px #FBF7F1;"></span>'
    out += '<span style="position: absolute; left: %.1fpx; top: 6px; width: 14px; height: 14px; border-radius: 50%%; background: #11615C; border: 2px solid #fff; box-sizing: border-box; box-shadow: 0 0 0 1px rgba(17,97,92,.4); z-index: 2;"></span>' % (nx - 7)
    lbls = [(0, '7 AM'), (163.0, '3 PM'), (316.0, '11 PM')]
    out += ''.join('<span class="num" style="position: absolute; left: %.1fpx; top: 28px; font-size: 12px; color: #6A6273; white-space: nowrap;">%s</span>' % (x, t) for x, t in lbls if abs(x - nx) > 40)
    out += '<span class="num" style="position: absolute; left: %.1fpx; top: 28px; font-size: 12px; font-weight: 700; color: #11615C;">%s</span>' % (max(0, nx - 14), label)
    return ('<!-- horizon -->\n  <button aria-label="Day horizon, 7 AM to 11 PM, now %s. Opens Today." style="position: absolute; top: 134px; left: 20px; width: 350px; height: 48px; border: 0; background: none; padding: 2px 0 0; display: block;"><div style="position: relative; width: 350px; height: 44px;">%s</div></button>\n  ') % (label, out)


def nowframe(base, now, label, center):
    hi = base.rfind('<button', 0, base.index('Day horizon'))
    top = int(_re2.search(r'top: (\d+)px', base[hi:hi + 400]).group(1))
    pre = base[:hi].replace('Now 10:42 · ', 'Now %s · ' % label, 1)
    pk = base.find('<!-- Day chip')
    if pk < 0:
        pk = base.index('<!-- Day button')
    post = base[pk:]
    return pre + horizon(now, label, now).replace('top: 134px;', 'top: %dpx;' % top, 1) + center + '\n  ' + post


def bigdot(col, ic, f=IOSF):
    return ('<span aria-hidden="true" style="width: 200px; height: 200px; border-radius: 50%%; background: #FFFDF9; box-shadow: inset 0 0 0 12px %s, 0 18px 40px rgba(36,31,43,.10); color: %s; display: flex; align-items: center; justify-content: center;">%s</span>') % (col, col, sv(ic, 64, 1.8))


def nrow(lbl, title, time, col, f=IOSF, meta=None, tick=False):
    return ('<div style="display: flex; align-items: center; gap: 12px; min-height: 52px;"><span style="width: 52px; flex: none; font: 600 13px %s; color: #6A6273;">%s</span><span style="width: 26px; height: 26px; border-radius: 50%%; flex: none; box-shadow: inset 0 0 0 3px %s;"></span>'
            '<span style="flex: 1; min-width: 0;"><span style="display: block; font: 700 15px Manrope; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">%s</span>%s</span><span class="num" style="font: 600 14px %s; color: #6A6273;">%s</span>%s</div>') % (
        f, lbl, col, title, ('<span class="num" style="display: block; font: 500 13px %s; color: #6A6273;">%s</span>' % (f, meta)) if meta else '', f, time,
        ('<span role="button" aria-label="Mark %s done" style="width: 44px; height: 44px; display: flex; align-items: center; justify-content: center;"><span style="width: 26px; height: 26px; border-radius: 50%%; box-shadow: inset 0 0 0 2.5px %s;"></span></span>' % (title, col)) if tick else '')


def center_next(col, ic, title, rng, free, rows, f=IOSF):
    return ('<!-- next up, drawn large -->\n  <div style="position: absolute; top: 200px; left: 20px; right: 20px; display: flex; flex-direction: column; align-items: center; text-align: center;">%s'
            '<div style="margin-top: 16px; font: 800 12px Manrope; letter-spacing: .8px; color: #6A6273;">NEXT UP</div><div style="font: 800 26px/32px Manrope; margin-top: 2px;">%s</div>'
            '<div class="num" style="font: 600 15px %s; color: #6A6273; margin-top: 2px;">%s</div><div class="num" style="font: 700 15px %s; color: #0B4642; margin-top: 6px;">%s</div></div>'
            '<div style="position: absolute; left: 20px; right: 20px; top: 560px;">%s</div>') % (bigdot(col, ic), title, f, rng, f, free, ''.join(rows))


MORNING = ('<!-- the Wake Up card (R2-19) -->\n  <div style="position: absolute; top: 210px; left: 20px; right: 20px; border-radius: 28px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.07), 0 14px 40px rgba(36,31,43,.08); padding: 22px 20px;">'
           '<div style="font: 800 24px/30px Manrope;">Good morning. Tuesday 3 November.</div><div class="num" style="font: 600 15px -apple-system, system-ui; color: #6A6273; margin-top: 4px;">9 planned · ends 10:00 PM</div>'
           '<div style="display: flex; align-items: center; gap: 12px; margin-top: 18px;"><span style="width: 44px; height: 44px; border-radius: 50%%; box-shadow: inset 0 0 0 4px %s; color: %s; display: flex; align-items: center; justify-content: center;">%s</span>'
           '<span><span style="display: block; font: 700 13px -apple-system, system-ui; color: #6A6273;">First</span><span style="display: block; font: 800 18px Manrope;">Morning run</span><span class="num" style="display: block; font: 600 14px -apple-system, system-ui; color: #6A6273;">6:45 AM</span></span></div>'
           '<span role="button" style="display: flex; margin-top: 18px; height: 52px; border-radius: 26px; background: #11615C; color: #fff; align-items: center; justify-content: center; font: 800 17px Manrope;">Start the day</span>'
           '<span role="button" style="display: flex; margin-top: 6px; height: 44px; align-items: center; justify-content: center; font: 700 16px -apple-system, system-ui; color: #11615C;">Later</span></div>') % (
    COR, COR, sv('<circle cx="14" cy="4.5" r="1.5"></circle><path d="M9 20l3-6 3 2v5M6 11l3.5-3 4 1 2 3 3 1"></path>', 22))
N_MORNING = nowframe(NOWF, 6.5, '6:30', MORNING)
N_BETWEEN = nowframe(NOWF, 8.5, '8:30', center_next(IND, CODE_I, 'Deep work: roadmap', '9:00–11:00 AM', '30 min free', [nrow('Next', 'Call with Sam', '10:30 AM', '#2A9D8F')]))
N_OVER = nowframe(NOWF, 11.2, '11:12', center_next(PNK, FORK_I, 'Lunch', '12:30–1:15 PM', '1 h 18 min free',
                                                  [nrow('Earlier', 'Deep work: roadmap', '9:00 AM', IND, meta='· not done', tick=True), nrow('', 'Call with Sam', '10:30 AM', '#2A9D8F', meta='· not done', tick=True)]))
A_OVER = nowframe(ANOWF, 11.2, '11:12', center_next(PNK, FORK_I, 'Lunch', '12:30–1:15 PM', '1 h 18 min free',
                                                   [nrow('Earlier', 'Deep work: roadmap', '9:00 AM', IND, ANF, '· not done', True)], ANF).replace("-apple-system, 'SF Pro Text', system-ui, sans-serif", ANF))

# ---------------------------------------------------------------- 3 · Focus past the planned end (built: clamps at 0, stays open)
FOC = bframe('E-R2-9', 5792)
F_END = (FOC.replace('0 85%, #5B5FD633 85% 100%', '0 100%, #5B5FD633 100% 100%').replace('85 percent of its time used', '100 percent of its time used')
         .replace('>18 min left<', '>0 min left<').replace('>8:00 left<', '>0:00 left<').replace('>10:42<', '>11:12<', 1))
AFOC = bframe('E-R2-9', 14597)
A_END = (AFOC.replace('0 85%, #5B5FD633 85% 100%', '0 100%, #5B5FD633 100% 100%').replace('85 percent of its time used', '100 percent of its time used')
         .replace('>18 min left<', '>0 min left<').replace('>8:00 left<', '>0:00 left<').replace('>10:42<', '>11:12<', 1))
F_TOASTS = [('Deep work: roadmap done', 'Undo'), ('Deep work: roadmap · 15 min more', 'Undo')]
OVERDUE = ios_note('Deep work: roadmap', 'Ended 12 minutes ago. Done?', '11:12')

# ---------------------------------------------------------------- 4 · Mac menu bar after the end (built: Next up)
MB = bframe('E-R2-17', 71671)
def _mb():
    m = MB
    # the ahead list loses Lunch (it becomes the header item)
    li = m.index('>Lunch · 12:30 PM<')
    st = m.rfind('<div', 0, li); e = m.index('</div>', li) + 6
    m = m[:st] + m[e:]
    for t in ('>Done<', '>+15 min<'):
        k = m.index(t); st = m.rfind('<div', 0, k); e = m.index('</div>', k) + 6
        m = m[:st] + m[e:]
    k = m.index('<b>Deep work: roadmap</b> · until 11:00 AM'); st = m.rfind('<div', 0, k); e = m.index('</div>', k) + 6
    item = m[st:e].replace('<b>Deep work: roadmap</b> · until 11:00 AM', '<b>Lunch</b> · 12:30 PM').replace('#5B5FD633', '#D9668F33').replace('stroke="#5B5FD6"', 'stroke="#D9668F"').replace('30.7 36.1', '0 36.1')
    m = m[:st] + item + m[e:]
    m = m.replace('Deep work: roadmap · until 11:00 AM', 'Lunch · 12:30 PM', 1).replace('>Now<', '>Next up<', 1).replace('10:42', '11:12')
    return m


MB_O = _mb()

# ---------------------------------------------------------------- page
def fcol(w, lab, fr, *n): return col(w, label(lab), fr, notes(*n))
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start;">%s</div>' % ''.join(c)
stack = lambda *c: '<div style="display: flex; flex-direction: column; gap: 18px;">%s</div>' % ''.join(c)
TS = lambda L, w=420: '<div style="display: flex; flex-direction: column; gap: 10px;">%s</div>' % ''.join(toast(t, a, w) for t, a in L)
s1 = row(fcol(390, 'iPhone · Today at 11:12, Deep work not ticked', O_TODAY, B('Built') + ' At the planned end the live card becomes an ordinary row: “9:00–11:00 AM · not done”, the dot drawn like one still ahead, the Done circle kept', B('Built') + ' Muted text, never red; no “late” and no minutes-over count', B('Built') + ' The now bead sits in the next free gap (15 min or more)'),
         fcol(390, 'iPhone · Need more time?', O_NUDGE, B('Built') + ' 5 to 60 min after the end, if something is planned later; once a day; not in Show less or low-energy mode', B('Built') + ' Catch up opens Running late; more than 10 min over opens Rebalance (“… ran over by 15 min · here’s a plan”)'),
         fcol(390, 'iPhone · Running late', O_LATE, B('Built') + ' How late: +5, +15, +30. Shift the rest, Skip or Shorten the next task; the ended task is not the target', B('Built') + ' Shift the rest goes through the Rebalance proposal: nothing moves before you accept'),
         col(390, label('Other places, as built'), stack(cardwrap(390, OVERDUE, 14), notes(B('Built') + ' “Ending now” and “Ended 12 minutes ago. Done?” arrive only if you added those alerts; the default is 10 min before',
                                                                                            B('Built') + ' Reality view keeps it running: “9:10 – now · planned 9:00 – 11:00 · 2 h 2 min in”',
                                                                                            B('Built') + ' Widgets and the Mac menu bar move on to Next up; the Live Activity holds at 0:00 for 30 min, then ends'))))
s2 = row(fcol(390, 'iPhone · Now at 6:30, before the first task', N_MORNING, Q('Design choice') + ' In the morning, Now shows the approved Wake Up card (R2-19): “Good morning. …”, “9 planned · ends 10:00 PM”, First, Start the day, Later'),
         fcol(390, 'iPhone · Now at 8:30, between tasks', N_BETWEEN, Q('Design choice') + ' No task running: Now shows Next up, the same rule as the widgets and the Mac menu bar, with “30 min free”', B('Built') + ' Strings: Next up, {duration} free'),
         fcol(390, 'iPhone · Now at 11:12, after an overrun', N_OVER, Q('Design choice') + ' Next up again; tasks that ended unticked stay reachable under Earlier with “· not done” and their Done circle'),
         fcol(412, 'Android · Now at 11:12', A_OVER, B('Built') + ' The same rule; nothing else today shows the approved end-of-day view (E-PhonesMinimal)'))
s3 = row(fcol(390, 'iPhone · Focus past its planned end', F_END, B('Built') + ' Nothing ends by itself: the ring holds full, “0 min left”, the step timer at 0:00; Focus stays open until Done, +15 min or ‹ Today', B('Built') + ' The 15-min chime keeps going while Focus is open'),
         fcol(412, 'Android · the same', A_END, B('Built') + ' Deep work’s Do Not Disturb was set until the planned end, so it is already off'),
         col(420, label('What Focus says'), TS(F_TOASTS), notes(B('Built') + ' Done closes Focus with Undo; +15 min stays', P('Not built') + ' Pause: there is none; leaving Focus keeps the task’s time running')))
s4 = row(col(760, label('Mac menu bar at 11:12'), MB_O, notes(B('Built') + ' The day-dot icon moves on: Next up · Lunch · 12:30 PM; Done and +15 min leave with the live task', P('Not built') + ' The floating Now mini window (ED-066) has no code yet, so its overrun is not drawn')),
         col(500, label('Rule across surfaces'), notes(B('Built') + ' Now → Next up → Nothing else today: one rule on widgets, the menu bar and (by design) the Now view',
                                                     B('Rule') + ' An ended task is never called late, missed or overdue on screen; it is “not done” until you tick it or move it')))
RULES = [('No shame', '“· not done”, never late, missed or red. The nudge asks “Need more time?” once, and Not now is enough.'),
         ('Proposals before writes', 'Catch up and Shift the rest go through Rebalance: nothing moves before Accept plan.'),
         ('Nothing ends by itself', 'Focus and the task stay as they are until you act; the app only stops counting at 0.'),
         ('One rule for “now”', 'Now, Next up, Nothing else today: the same on the Now view, widgets and the Mac menu bar.'),
         ('Same everywhere (R-13)', 'iPhone, Android, iPad, Mac and web show the same states.'),
         ('Text from the app', 'Every string is built (app_en.arb). Times and tasks are examples. No new copy.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 GAP PASS · R2-26</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Time states</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">What happens when a task runs past its end, what Now shows in the morning and between tasks, and Focus past its end. As built, on the approved Today, Now, Focus and menu bar frames. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed · gap pass · not recorded yet'), tag('tn', 'iPhone, Android, Mac'), tag('tn', '@@THEME@@'))
page_body = body + section('1 · Past the planned end, on Today', s1) + section('2 · Now through the day', s2) + section('3 · Focus past its end', s3) + section('4 · The Mac menu bar', s4) + section('Rules', rules)
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-26 · Time states</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-26-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-26.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-26.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('class="blk-d', 'class="blk').replace('<title>E · R2-26 · Time states</title>', '<title>E · R2-26 · Time states · Dark</title>')
open('project/E-R2-26-Dark.dc.html', 'w', encoding='utf-8').write(dk)
print('ok')
