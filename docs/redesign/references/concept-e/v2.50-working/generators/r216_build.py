import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
from ws import *
from frames import _ICON, device
def sv(p, s=20, w=2): return '<svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true" style="stroke-width: %s;">%s</svg>' % (s, s, w, p)
CHL = '<path d="M15 5l-7 7 7 7"></path>'; CHECK = '<path d="M5 12.5l4.5 4.5L19 7.5"></path>'; SUN = '<circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M2 12h2M20 12h2M5 5l1.5 1.5M17.5 17.5L19 19M5 19l1.5-1.5M17.5 6.5L19 5"></path>'
MOON = '<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"></path>'; BELL = '<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4zM10 20a2 2 0 0 0 4 0"></path>'
def btn(t, primary=True):
    return ('<button style="width: 100%%; height: 54px; border: 0; border-radius: 27px; font: 800 17px Manrope; %s">%s</button>' % (
        ('background: %s; color: #fff;' % ACC) if primary else ('background: transparent; color: #0B4642;'), t))
def top(i, n, skip=True):
    dots = ''.join('<span style="width: %dpx; height: 8px; border-radius: 4px; background: %s;"></span>' % (20 if k == i else 8, ACC if k <= i else '#DDD7E0') for k in range(n))
    return ('<div style="display: flex; align-items: center; height: 48px;"><button style="height: 44px; border: 0; background: none; color: #0B4642; font: 600 17px Manrope; display: flex; align-items: center; gap: 2px; padding: 0;">%sBack</button>'
            '<span role="img" aria-label="Step %d of %d" style="flex: 1; display: flex; justify-content: center; gap: 6px;">%s</span>'
            '<button style="height: 44px; border: 0; background: none; color: %s; font: 600 17px Manrope; visibility: %s;">Skip</button></div>') % (sv(CHL, 22, 2.4), i + 1, n, dots, SEC, 'visible' if skip else 'hidden')
def hd(t, b): return '<div role="heading" style="font: 800 30px/36px Manrope; margin-top: 22px;">%s</div><div style="font: 500 17px/25px Manrope; color: %s; margin-top: 10px;">%s</div>' % (t, SEC, b)
def thread_art(w):
    return ('<div role="img" aria-label="The day dot, drawing itself" style="position: relative; height: 240px; display: flex; align-items: center; justify-content: center;">'
            '<span style="position: absolute; left: 50%%; top: 12px; bottom: 12px; width: 0; border-left: 4px dotted #BEB6C7;"></span>'
            '<span style="position: absolute; left: 50%%; top: 12px; height: 92px; width: 4px; margin-left: 0; background: %s;"></span>'
            '<span style="position: relative; width: 112px; height: 112px; border-radius: 50%%; background: radial-gradient(closest-side, %s calc(100%% - 12px), transparent calc(100%% - 11.5px)), conic-gradient(%s 0 62%%, %s33 62%% 100%%);"></span></div>') % (ACC, GROUND, ACC, ACC)
def welcome(w):
    return ('<div style="padding-top: 40px;">%s</div><div role="heading" style="font: 800 34px/40px Manrope; text-align: center;">Your day, as a thread.</div>'
            '<div style="font: 500 17px/25px Manrope; color: %s; text-align: center; margin-top: 12px;">Plan your day as dots on a line, see where the time goes, and move it all when the day moves.</div>'
            '<div style="margin-top: 34px; display: flex; flex-direction: column; gap: 6px;">%s%s</div><div style="font: 500 13px Manrope; color: %s; text-align: center; margin-top: 10px;">Dottoday is for people aged 13 and over.</div>') % (
                thread_art(w), SEC, btn('Get started'), btn('I already have an account', False), SEC)
def layout_card(t, b, art, on):
    return ('<div role="radio" aria-checked="%s" style="border-radius: 22px; background: %s; box-shadow: %s; padding: 14px; display: flex; gap: 14px; align-items: center;">%s'
            '<div style="flex: 1;"><div style="font: 800 18px Manrope;">%s</div><div style="font: 500 14px/20px Manrope; color: %s; margin-top: 4px;">%s</div></div>'
            '<span style="width: 26px; height: 26px; border-radius: 50%%; flex: none; display: flex; align-items: center; justify-content: center; %s">%s</span></div>') % (
                'true' if on else 'false', SURF, ('0 0 0 2.5px %s' % ACC) if on else '0 0 0 1px rgba(36,31,43,.10)', art, t, SEC, b,
                ('background: %s; color: #fff;' % ACC) if on else 'box-shadow: inset 0 0 0 2px #8A8494;', sv(CHECK, 16, 3) if on else '')
def sk_min(): return '<span aria-hidden="true" style="width: 84px; height: 110px; flex: none; border-radius: 16px; background: %s; display: flex; align-items: center; justify-content: center;"><span style="width: 52px; height: 52px; border-radius: 50%%; background: radial-gradient(closest-side, %s calc(100%% - 6px), transparent calc(100%% - 5.5px)), conic-gradient(#5B5FD6 0 85%%, #5B5FD633 85%% 100%%);"></span></span>' % (GROUND, GROUND)
def sk_full():
    rows = ''.join('<span style="display: flex; align-items: center; gap: 6px;"><span style="width: 12px; height: 12px; border-radius: 50%%; background: %s;"></span><span style="height: 6px; width: %dpx; border-radius: 3px; background: #DDD7E0;"></span></span>' % (c, l) for c, l in (('#E2725B', 40), ('#4A9BD6', 30), ('#5B5FD6', 46), ('#D9668F', 34), ('#469763', 38)))
    return '<span aria-hidden="true" style="width: 84px; height: 110px; flex: none; border-radius: 16px; background: %s; display: flex; flex-direction: column; justify-content: center; gap: 9px; padding: 0 12px; box-sizing: border-box;">%s</span>' % (GROUND, rows)
def layout(w):
    return ('<div role="heading" style="font: 800 30px/36px Manrope; margin-top: 30px;">How much do you want to see?</div><div style="font: 500 17px/25px Manrope; color: %s; margin-top: 10px;">You can change this any time, from the top of Settings.</div>'
            '<div style="display: flex; flex-direction: column; gap: 12px; margin-top: 24px;">%s%s</div><div style="margin-top: 26px;">%s</div>') % (
                SEC, layout_card('The full planner', 'The whole thread, week and month, routines, reviews, widgets and every setting.', sk_full(), True),
                layout_card('Just the next dot', "What's now and what's next. Add, do, done. Nothing to set up.", sk_min(), False), btn('Continue'))
def time_row(icon, label, t, col):
    return ('<div style="display: flex; align-items: center; gap: 12px; min-height: 60px; padding: 0 14px; border-radius: 18px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">'
            '<span style="width: 36px; height: 36px; border-radius: 50%%; background: %s; display: flex; align-items: center; justify-content: center; color: #4E4757;">%s</span>'
            '<span style="flex: 1; font: 700 17px Manrope;">%s</span><span class="num" style="height: 40px; padding: 0 14px; border-radius: 12px; background: #F1ECE4; display: flex; align-items: center; font: 700 17px Manrope;">%s</span></div>') % (SURF, col, sv(icon, 20), label, t)
def day_shape(w, i, n):
    return (top(i, n) + hd('When does your day start and end?', 'Your tasks live between these two. You can change them, or give each weekday its own, in Settings.')
            + '<div style="display: flex; flex-direction: column; gap: 10px; margin-top: 22px;">%s%s</div>' % (time_row(SUN, 'Wake Up', '7:00 AM', '#FBEBC8'), time_row(MOON, 'Wind Down', '11:00 PM', '#E6E3F7'))
            + '<div style="font: 700 17px Manrope; margin-top: 22px;">How much sleep do you want?</div><div style="display: flex; gap: 8px; margin-top: 10px;">%s</div>' % ''.join(
                '<span style="flex: 1; height: 44px; border-radius: 22px; display: flex; align-items: center; justify-content: center; font: 700 16px Manrope; %s">%s</span>' % (
                    ('background: #E2EFEC; color: #0B4642; box-shadow: inset 0 0 0 1.5px %s;' % ACC) if h == '8 h' else 'background: %s; box-shadow: inset 0 0 0 1px rgba(36,31,43,.14);' % SURF, h) for h in ('7 h', '7 h 30', '8 h', '9 h'))
            + '<div class="num" style="margin-top: 10px; font: 600 14px Manrope; color: #0B4642;">Wind Down 11:00 PM · 8 h of sleep</div><div style="margin-top: 26px;">%s</div>' % btn('Continue'))
HAB = [('Morning run', '7:00 AM · 45 min', '#E2725B', 'Morning run', True), ('Deep work', '9:00 AM · 2 h', '#5B5FD6', 'Deep work: roadmap', True), ('Lunch', '12:30 PM · 45 min', '#D9668F', 'Lunch', True),
       ('Walk', '5:30 PM · 30 min', '#469763', 'Pick up parcel', False), ('Gym', '6:00 PM · 1 h', '#8B5CF6', 'Gym', False), ('Read', '9:30 PM · 30 min', '#8C6A4F', 'Read', False), ('Plan tomorrow', '10:30 PM · 15 min', '#D9A23A', 'Coffee & plan the day', False)]
def habits(w, i, n):
    rows = ''.join(('<div role="checkbox" aria-checked="%s" style="display: flex; align-items: center; gap: 12px; min-height: 52px; padding: 4px 12px 4px 6px; border-radius: 16px; %s">'
                    '<span style="width: 36px; height: 36px; border-radius: 50%%; display: flex; align-items: center; justify-content: center; flex: none; %s">%s</span>'
                    '<span style="flex: 1; line-height: 1.25;"><span style="display: block; font: 700 16px Manrope;">%s</span><span class="num" style="display: block; font: 500 13px Manrope; color: %s;">%s</span></span>'
                    '<span style="width: 24px; height: 24px; border-radius: 50%%; display: flex; align-items: center; justify-content: center; %s">%s</span></div>') % (
                       'true' if on else 'false', 'background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06);' % SURF, ('background: %s; color: #fff;' % c) if on else ('box-shadow: inset 0 0 0 3px %s; color: %s;' % (c, c)),
                       sv(_ICON[ic], 18), t, SEC, m, ('background: %s; color: #fff;' % ACC) if on else 'box-shadow: inset 0 0 0 2px #8A8494;', sv(CHECK, 14, 3) if on else '') for t, m, c, ic, on in HAB)
    return top(i, n) + hd('What fills your days?', "Pick up to five. They go on tomorrow's thread at times that fit your day; change them any time.") + '<div role="group" style="display: flex; flex-direction: column; gap: 6px; margin-top: 16px;">%s</div><div style="margin-top: 16px;">%s</div>' % (rows, btn('Add 3 to tomorrow'))
def tog(on): return '<span role="switch" aria-checked="%s" style="width: 51px; height: 31px; border-radius: 16px; flex: none; position: relative; background: %s;"><span style="position: absolute; top: 2px; %s width: 27px; height: 27px; border-radius: 50%%; background: #FFFFFF; box-shadow: 0 2px 4px rgba(0,0,0,.18);"></span></span>' % ('true' if on else 'false', ACC if on else '#DDD7E0', 'right: 2px;' if on else 'left: 2px;')
def reminders(w, i, n):
    row = lambda ic, t, d: ('<div style="display: flex; align-items: center; gap: 12px; min-height: 64px; padding: 8px 14px; border-radius: 18px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06);"><span style="color: #4E4757; display: flex;">%s</span>'
                             '<span style="flex: 1; line-height: 1.3;"><span style="display: block; font: 700 16px Manrope;">%s</span><span style="display: block; font: 500 13px Manrope; color: %s;">%s</span></span>%s</div>') % (SURF, sv(ic, 22), t, SEC, d, tog(True))
    return (top(i, n) + hd('Want a nudge?', 'Dottoday reminds you when a task starts and before Wind Down. You can change this any time in Settings.')
            + '<div style="display: flex; flex-direction: column; gap: 10px; margin-top: 22px;">%s%s</div>' % (row(BELL, 'Before each task', 'How early is up to you, in Settings'), row(MOON, 'At Wind Down', "Tomorrow's first task, so the morning has no surprises"))
            + '<div style="margin-top: 28px; display: flex; flex-direction: column; gap: 6px;">%s%s</div>' % (btn('Allow notifications'), btn('Not now', False)))
def account(w, i, n, android):
    ob = lambda t, pre: '<button style="width: 100%%; height: 54px; border: 0; border-radius: 27px; background: %s; box-shadow: inset 0 0 0 1.5px rgba(36,31,43,.22); font: 700 17px Manrope; color: %s; display: flex; align-items: center; justify-content: center; gap: 10px;">%s%s</button>' % (SURF, INK, pre, t)
    apple = ''; g = '<span aria-hidden="true" style="font: 800 18px Manrope; color: #4A9BD6;">G</span>'
    btns = ([ob('Continue with Apple', apple)] if not android else []) + [ob('Continue with Google', g), ob('Continue with email', sv('<rect x="3" y="5" width="18" height="14" rx="3"></rect><path d="M3 7l9 6 9-6"></path>', 20))]
    return (top(i, n) + hd('Keep your tasks in sync?', "Sign in to use Dottoday on all your devices with a copy kept safe. Or don't: everything works on this device without an account.")
            + '<div style="margin-top: 26px; display: flex; flex-direction: column; gap: 10px;">%s</div><div style="margin-top: 14px;">%s</div>' % (''.join(btns), btn('Continue without an account', False)))
def done(w, i, n, ios):
    rows = ''.join('<div style="display: flex; align-items: center; gap: 12px; height: 52px;"><span style="width: 32px; height: 32px; border-radius: 50%%; flex: none; box-shadow: inset 0 0 0 3px %s; background: %s; color: %s; display: flex; align-items: center; justify-content: center;">%s</span><span style="line-height: 1.25;"><span class="num" style="display: block; font: 500 13px Manrope; color: %s;">%s</span><span style="display: block; font: 700 16px Manrope;">%s</span></span></div>' % (
        c, SURF, c, sv(_ICON[ic], 16), SEC, m.split(' · ')[0], t) for t, m, c, ic, on in HAB if on)
    card = ('<div style="margin-top: 18px; border-radius: 22px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06); padding: 12px 16px; position: relative;"><div style="font: 700 13px Manrope; letter-spacing: .6px; color: %s;">TOMORROW</div>'
            '<div style="position: relative; margin-top: 4px;"><span style="position: absolute; left: 14px; top: 8px; bottom: 8px; border-left: 4px dotted #BEB6C7;"></span>'
            '<div style="display: flex; align-items: center; gap: 12px; height: 36px; color: %s; font: 500 13px Manrope;"><span style="width: 32px; height: 32px; border-radius: 50%%; background: #FBEBC8; position: relative;"></span>Wake Up · 7:00 AM</div>%s'
            '<div style="display: flex; align-items: center; gap: 12px; height: 36px; color: %s; font: 500 13px Manrope;"><span style="width: 32px; height: 32px; border-radius: 50%%; background: #E6E3F7; position: relative;"></span>Wind Down · 11:00 PM</div></div></div>') % (SURF, SEC, SEC, rows, SEC)
    siri = '<div style="margin-top: 12px; font: 500 14px Manrope; color: %s; text-align: center;">You can also ask Siri "What\'s next in Dottoday".</div>' % SEC if ios else ''
    return top(i, n, skip=False) + hd('Your first thread', 'Tomorrow, from Wake Up to Wind Down. Add to it, drag things around, or start with today.') + card + '<div style="margin-top: 22px;">%s</div>%s' % (btn('Open today'), siri)
def first_task(w, i, n):
    return (top(i, n) + hd("What's one thing for today?", 'Type it the way you\'d say it, like "call Sam 6pm". It goes on your thread.')
            + '<div style="margin-top: 22px; height: 56px; border-radius: 18px; background: %s; box-shadow: 0 0 0 2px %s; display: flex; align-items: center; padding: 0 16px; font: 600 18px Manrope;">call Sam 6pm<span style="width: 2px; height: 24px; background: %s; margin-left: 2px;"></span></div>' % (SURF, ACC, ACC)
            + '<div class="num" style="margin-top: 8px; font: 600 14px Manrope; color: #0B4642;">Today · 6:00 PM</div><div style="margin-top: 22px;">%s</div>' % btn('Put it on today'))

def phone(android, inner):
    W, Hh, top_ = (412, 892, 40) if android else (390, 844, 54)
    f = 'Roboto, system-ui' if android else '-apple-system, system-ui'
    isl = ('<div aria-hidden="true" style="position: absolute; top: 12px; left: 198px; width: 16px; height: 16px; border-radius: 50%; background: #000; z-index: 20;"></div>' if android else
           '<div aria-hidden="true" style="position: absolute; top: 11px; left: 132px; width: 126px; height: 37px; border-radius: 25px; background: #000; z-index: 20;"></div>')
    return ('<div style="position: relative; width: %dpx; height: %dpx; border-radius: %dpx; background: %s; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 %dpx #241F2B, 0 0 0 %dpx rgba(36,31,43,.35); font-family: Manrope, system-ui, sans-serif; color: %s;">%s'
            '<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: %dpx; display: flex; align-items: center; justify-content: space-between; padding: 0 %dpx; font: 600 15px %s; color: %s;"><span>10:42</span><span>100 %%</span></div>'
            '<div style="position: absolute; left: 20px; right: 20px; top: %dpx;">%s</div></div>') % (W, Hh, 44 if android else 55, GROUND, 8 if android else 9, 9 if android else 10, INK, isl, top_, 24 if android else 34, f, INK, top_ + 4, inner)
def tablet(android, inner):
    w, h = (1280, 800) if android else (1180, 820)
    cw = 520
    return device(w, h, '<div style="position: absolute; left: %dpx; top: %dpx; width: %dpx;">%s</div>' % ((w - cw) // 2, 40, cw, inner), android)
NF = 6  # full flow after welcome: layout, day shape, habits, reminders, account, done (dots count steps after Welcome? built: steps list minus welcome)
F = {}
F['p1'] = phone(False, welcome(350)); F['p2'] = phone(False, layout(350)); F['p3'] = phone(False, day_shape(350, 2, 7)); F['p4'] = phone(False, habits(350, 3, 7))
F['p5'] = phone(False, reminders(350, 4, 7)); F['p6'] = phone(False, account(350, 5, 7, False)); F['p7'] = phone(False, done(350, 6, 7, True)); F['p8'] = phone(False, first_task(350, 4, 5))
F['a1'] = phone(True, layout(372)); F['a2'] = phone(True, account(372, 5, 7, True))
F['t1'] = tablet(False, welcome(520)); F['t2'] = tablet(True, habits(520, 3, 7))
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label, note=''):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 14px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13px; line-height: 19px; color: #4E4757;">%s</div></figure>') % (w * sc + 18, label, w * sc + 18, h * sc + 18, w, h, sc, F[key], note)
S = .45
r1 = [fr('p1', 390, 844, S, 'O1 · Welcome', 'The day dot draws itself (static with Reduce Motion). Sign in goes to O5 as “Welcome back”.'), fr('p2', 390, 844, S, '0 · Layout', 'Full or Minimal (docs/14 §4); no Back or Skip here.'),
      fr('p3', 390, 844, S, 'O2 · Day shape', 'Wake Up and Wind Down with the live sleep line.'), fr('p4', 390, 844, S, 'O3 · Habits (Full)', 'Up to five starter habits on tomorrow’s thread.'),
      fr('p5', 390, 844, S, 'O4 · Reminders', 'Allow opens the system prompt; Not now keeps going.'), fr('p6', 390, 844, S, 'O5 · Account (Full)', 'The approved sign-in buttons (CR-160 rules); everything works without an account.'),
      fr('p7', 390, 844, S, 'O6 · Done (Full)', 'Tomorrow’s thread with the picked habits; Open today.'), fr('p8', 390, 844, S, 'Minimal · First task', 'Minimal’s last step instead of Habits, Account and Done.')]
r2 = [fr('a1', 412, 892, S, 'Android · Layout'), fr('a2', 412, 892, S, 'Android · Account', 'No Apple button on Android.'),
      fr('t1', 1180, 820, .4, 'iPad · Welcome', 'Tablets: the same steps in one centred column (520), full screen; there is nothing behind it yet.'), fr('t2', 1280, 800, .4, 'Android tablet · Habits', '')]
notes = ['<b>Never designed (CR-089):</b> the onboarding flow is built (<code>features/onboarding</code>: Welcome, Layout, Day shape, Habits, Reminders, Account, Done; Minimal: Welcome, Layout, Day shape, Reminders, First task). This board draws it in E, on every platform, with the built copy only.',
         '<b>One frame for every step (built):</b> ‹ Back, the step dots (“Step 3 of 7”; Welcome counts), Skip; none on Welcome and Layout; no Skip on Done. One primary action at the bottom of each step.',
         '<b>E parts:</b> the thread and day dot on Welcome; the Full and Minimal sketches on Layout; the task dots with icons on Habits; tomorrow’s thread on Done. No-shame copy: nothing is required, everything can change later.',
         '<b>Width:</b> phones full screen; tablets, Mac and web the same steps in a centred 520 column. Accessibility: 44 pt / 48 dp targets, the dots have a spoken “Step 3 of 7”, Reduce Motion stops the dot drawing.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
def row(title, frs): return '<section aria-label="%s" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">%s</div><div style="display: flex; gap: 20px; align-items: flex-start; flex-wrap: wrap;">%s</div></section>' % (title, title, ''.join(frs))
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-16 · Onboarding (all platforms)</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 3, sixth board. Dark on E-R2-16-Dark. For owner review.</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s%s') % (
            tag('th', 'Proposed · for owner review'), tag('tn', 'Light'), li, row('iPhone · the full flow, then Minimal’s last step', r1), row('Android and tablets', r2))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-16</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1700px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1700,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-16.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-16</title>', '<title>E · R2-16 · Dark</title>').replace('Dark on E-R2-16-Dark.', 'Light on E-R2-16.').replace('<span class="tn">Light</span>', '<span class="tn">Dark</span>')
open('project/E-R2-16-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
