import os, sys, re
H = int(sys.argv[1])
OB = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/onb/build.py'
src = open(OB, encoding='utf-8').read(); src = src[:src.index('# ---------- A · Draw your day')].replace('H = int(sys.argv[1])', '')
exec(compile(src, 'onb_helpers', 'exec'))
from frames import device
CSS2 = CSS + '''
@keyframes sgRing{0%{stroke-dashoffset:302}45%,100%{stroke-dashoffset:0}}
@keyframes sgDrop{0%,30%{transform:translateY(-220px) scale(.6);opacity:0}48%{transform:translateY(8px) scale(1.08);opacity:1}56%,100%{transform:none;opacity:1}}
@keyframes sgNow{0%,100%{box-shadow:0 0 0 0 rgba(17,97,92,.5)}50%{box-shadow:0 0 0 8px rgba(17,97,92,0)}}
@keyframes sgHint{0%,10%{opacity:0;transform:translateY(8px)}20%,80%{opacity:1;transform:none}92%,100%{opacity:0;transform:translateY(-4px)}}
@keyframes sgSheen{0%{background-position:-200% 0}100%{background-position:200% 0}}
.sg-ring{stroke-dasharray:302;animation:sgRing 4.5s cubic-bezier(.6,0,.2,1) infinite}
.sg-drop{animation:sgDrop 4.5s cubic-bezier(.3,1.3,.5,1) infinite}.sg-now{animation:sgNow 2s ease-in-out infinite}
.sg-hint{animation:sgHint 5s ease infinite}
@media (prefers-reduced-motion: reduce){[class*="sg-"]{animation:none!important}.sg-ring{stroke-dashoffset:0}}
'''
NOW = 10.7
# ---- shared vertical day thread from Wake Up to Wind Down (the product's signature)
def ends(y0, y1, x=50, extra=''):
    sunv = '<span style="width: 44px; height: 44px; border-radius: 50%%; background: #D9A23A; color: #fff; display: flex; align-items: center; justify-content: center; box-shadow: 0 6px 18px rgba(217,162,58,.45);">%s</span>' % sv(SUN, 22)
    moonv = '<span style="width: 44px; height: 44px; border-radius: 50%%; background: #4B3FB0; color: #fff; display: flex; align-items: center; justify-content: center; box-shadow: 0 6px 18px rgba(75,63,176,.4);">%s</span>' % sv(MOON, 22)
    return ('<div style="position: absolute; left: %dpx; top: %dpx; height: %dpx; width: 4px; margin-left: -2px; background: linear-gradient(#D9A23A, #5B5FD6 60%%, #4B3FB0); border-radius: 2px;"></div>'
            '<div style="position: absolute; left: %dpx; top: %dpx;">%s</div><div style="position: absolute; left: %dpx; top: %dpx;">%s</div>%s') % (x, y0 + 22, y1 - y0, x - 22, y0, sunv, x - 22, y1, moonv, extra)
def S1():
    ring = ('<svg width="132" height="132" viewBox="0 0 120 120" aria-hidden="true"><circle cx="60" cy="60" r="48" fill="none" stroke="#11615C33" stroke-width="10"></circle>'
            '<circle class="sg-ring" cx="60" cy="60" r="48" fill="none" stroke="#11615C" stroke-width="10" stroke-linecap="round" transform="rotate(-90 60 60)" stroke-dashoffset="0"></circle></svg>')
    return phone('<div style="position: absolute; left: 193px; top: 60px; height: 170px; width: 0; border-left: 4px dotted #BEB6C7;"></div>'
                 + '<div class="ob-grow" style="position: absolute; left: 193px; top: 360px; height: 120px; width: 0; border-left: 4px dotted #BEB6C7;"></div>'
                 + abs_(129, 228, 132, '<div role="img" aria-label="The day dot, drawing itself">%s</div>' % ring)
                 + abs_(28, 500, 334, '<div style="text-align: center;">%s%s</div>' % (big('Your day, as a thread.', 34), sub('See where the time goes. Move it all when the day moves.')))
                 + abs_(28, 650, 334, btn('Start my day') + '<div style="margin-top: 4px;">%s</div>' % btn('I have an account', False) + AGE))
def S2():
    hand = '<span style="position: absolute; left: 72px; top: 6px; font: 800 15px Manrope; color: #9A5A0E;">Wake Up · 7:00 AM</span>'
    return phone(abs_(28, 84, 334, big('Your day runs from…', 30) + sub('Drag the sun and the moon. You can fine-tune each weekday later.'))
                 + '<div style="position: absolute; left: 20px; right: 20px; top: 230px; height: 430px; border-radius: 32px; background: linear-gradient(180deg, #FBEBC8 0%, #FFFDF9 30%, #FFFDF9 70%, #E6E3F7 100%); box-shadow: 0 0 0 1px rgba(36,31,43,.06);"></div>'
                 + ends(250, 590, 90) + abs_(140, 256, 220, '<div style="font: 800 22px Manrope;">7:00 AM</div><div style="font: 600 13px Manrope; color: %s;">Wake Up</div>' % SEC)
                 + abs_(140, 596, 220, '<div style="font: 800 22px Manrope;">11:00 PM</div><div style="font: 600 13px Manrope; color: %s;">Wind Down</div>' % SEC)
                 + abs_(140, 410, 210, '<div class="num" style="font: 800 34px Manrope; color: #0B4642;">16 h</div><div style="font: 600 14px Manrope; color: %s;">awake · 8 h of sleep</div>' % SEC)
                 + '<div class="ob-pulse" style="position: absolute; left: 68px; top: 250px; width: 44px; height: 44px; border-radius: 50%; z-index: 0;"></div>'
                 + abs_(28, 720, 334, btn('Continue')))
def thread_today(y0, y1, task=False, drop=False, x=50):
    span = y1 - y0
    def yt(h): return y0 + (h - 7) / 16 * span
    now = ('<div style="position: absolute; left: %dpx; top: %dpx; display: flex; align-items: center; gap: 8px;"><span class="sg-now" style="width: 14px; height: 14px; border-radius: 50%%; background: %s; border: 2px solid #fff; box-sizing: border-box;"></span>'
           '<span class="num" style="font: 700 12px Manrope; color: %s; padding: 0 6px; border-radius: 9px; background: %s; box-shadow: 0 0 0 1px rgba(17,97,92,.3);">10:42</span></div>') % (x - 7, yt(NOW) - 7, ACC, ACC, SURF)
    t = ''
    if task:
        t = ('<div class="%s" style="position: absolute; left: %dpx; top: %dpx; display: flex; align-items: center; gap: 12px;">%s<span style="line-height: 1.25;"><span class="num" style="display: block; font: 500 13px Manrope; color: %s;">6:00 – 7:00 PM</span>'
             '<span style="display: block; font: 800 18px Manrope;">Gym</span></span></div>') % ('sg-drop' if drop else '', x - 22, yt(18) - 22, dotc('#8B5CF6', 'Gym', 44), SEC)
    return ends(y0, y1, x, now + t)
SUGG = [('Gym 6pm', '#8B5CF6', 'Gym'), ('Call Mum 3pm', '#2A9D8F', 'Call with Sam'), ('Deep work 2h', IND, 'Deep work: roadmap'), ('Read 9:30pm', '#8C6A4F', 'Read')]
def S3():
    chips = ''.join('<span style="height: 40px; padding: 0 12px 0 5px; border-radius: 20px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.10); display: inline-flex; align-items: center; gap: 7px; font: 700 14px Manrope;">%s%s</span>' % (SURF, dotc(c, ic, 30), t) for t, c, ic in SUGG)
    field = ('<div style="height: 60px; border-radius: 20px; background: %s; box-shadow: 0 0 0 2px %s, 0 10px 28px rgba(17,97,92,.14); display: flex; align-items: center; gap: 10px; padding: 0 10px 0 18px;">'
             '<span class="ob-type" style="font: 700 19px Manrope;">gym 6pm</span><span style="width: 2px; height: 26px; background: %s;"></span>'
             '<span class="num" style="margin-left: auto; height: 40px; padding: 0 12px; border-radius: 14px; background: #E2EFEC; color: #0B4642; display: flex; align-items: center; gap: 6px; font: 700 14px Manrope;">%s6:00 PM · 1 h</span></div>') % (SURF, ACC, ACC, sv('<rect x="3.5" y="5" width="17" height="15" rx="3"></rect><path d="M3.5 10h17"></path>', 16))
    return phone(abs_(28, 84, 334, big('What’s one thing for today?', 28) + sub('Say it the way you would to a friend.'))
                 + thread_today(220, 470, x=50) + abs_(100, 300, 260, '<div style="font: 600 14px/20px Manrope; color: %s;">Today, between your sun and moon. It lands where you say.</div>' % SEC)
                 + abs_(20, 510, 350, field + '<div style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 12px;">%s</div>' % chips)
                 + abs_(28, 730, 334, btn('Put it on today')))
def S4():
    note = ('<div class="ob-slide" style="position: absolute; left: 12px; right: 12px; top: 58px; border-radius: 22px; background: rgba(250,247,242,.94); backdrop-filter: blur(20px); box-shadow: 0 10px 30px rgba(36,31,43,.18); padding: 12px 14px; display: flex; gap: 10px; z-index: 14;">'
            '%s<div style="line-height: 1.3;"><div style="font: 700 13px -apple-system, system-ui; color: %s;">DOTTODAY · in 10 min</div><div style="font: 700 15px -apple-system, system-ui;">Gym starts at 6:00</div><div style="font: 500 14px -apple-system, system-ui; color: %s;">Then Read at 9:30</div></div></div>') % (dotc('#8B5CF6', 'Gym', 36), SEC, SEC)
    return phone(note + thread_today(150, 470, task=True, drop=True, x=50)
                 + abs_(20, 500, 350, '<div style="border-radius: 28px; background: %s; box-shadow: 0 -2px 0 rgba(36,31,43,.04), 0 18px 44px rgba(36,31,43,.16); padding: 22px;">%s%s<div style="margin-top: 18px;">%s</div><div style="margin-top: 2px;">%s</div></div>' % (
                     SURF, big('Want this before Gym?', 24), sub('A quiet nudge 10 minutes before each task. Change it any time.'), btn('Allow nudges'), btn('Not now', False))))
def S5(ios=True):
    rows = thread_today(130, 650, task=True, x=50)
    hint = ('<div class="sg-hint" style="position: absolute; left: 96px; top: 520px; height: 40px; padding: 0 14px; border-radius: 20px; background: #2E2836; color: #FBF7F1; display: flex; align-items: center; gap: 8px; font: 700 14px Manrope; z-index: 12;">%sTap the dot when it’s done</div>') % sv(HAND, 18, 1.8)
    bar = ('<div style="position: absolute; left: 16px; right: 16px; bottom: 34px; height: 64px; border-radius: 32px; background: rgba(255,255,255,.7); backdrop-filter: blur(16px); box-shadow: 0 0 0 .5px rgba(36,31,43,.10), 0 10px 30px rgba(36,31,43,.12); display: flex; align-items: center; justify-content: space-around; font: 600 11px Manrope; color: %s;">'
           '<span style="color: %s;">Today</span><span>Inbox</span><span>Calendar</span><span>Search</span></div>') % (SEC, ACC)
    sync = ('<div style="position: absolute; left: 16px; right: 16px; top: 676px; border-radius: 20px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 10px 12px 10px 16px; display: flex; align-items: center; gap: 10px;">'
            '<span style="flex: 1; font: 600 14px/19px Manrope;">Keep your day on all your devices</span><span style="height: 36px; padding: 0 14px; border-radius: 18px; background: #E2EFEC; color: #0B4642; display: flex; align-items: center; font: 700 14px Manrope;">Sign in</span><span style="color: %s; font: 600 18px Manrope;">✕</span></div>') % (SURF, SEC)
    head = abs_(24, 64, 342, '<div style="display: flex; align-items: baseline; gap: 10px;"><span style="font: 800 30px Manrope;">Tue 3 Nov</span></div><div class="num" style="font: 600 14px Manrope; color: %s;">1 planned · 16 h awake</div>' % SEC)
    return phone(head + rows + hint + sync + bar)
def LATER():
    card = lambda when, t, b, ic: ('<div style="flex: 1; border-radius: 22px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 16px;"><div style="font: 700 12px Manrope; letter-spacing: .6px; color: %s;">%s</div>'
                                   '<div style="display: flex; gap: 10px; align-items: center; margin-top: 8px;"><span style="width: 36px; height: 36px; border-radius: 50%%; background: #E2EFEC; color: %s; display: flex; align-items: center; justify-content: center; flex: none;">%s</span><span style="font: 800 16px Manrope;">%s</span></div>'
                                   '<div style="font: 500 13px/19px Manrope; color: %s; margin-top: 6px;">%s</div></div>') % (SURF, SEC, when, ACC, sv(ic, 18), t, SEC, b)
    return ('<div style="display: flex; gap: 14px; width: 1100px;">%s%s%s%s</div>') % (
        card('DAY 2 · ON OPEN', 'Want it simpler?', 'Try Less: just the next dot. One tap to switch back.', '<circle cx="12" cy="12" r="8"></circle><circle cx="12" cy="12" r="3"></circle>'),
        card('AFTER 3 TASKS', 'Make it a habit', 'Repeat Gym every Mon, Wed, Fri? It suggests; you decide.', '<path d="M4 10V9a3 3 0 0 1 3-3h12l-3-3M20 14v1a3 3 0 0 1-3 3H5l3 3"></path>'),
        card('FIRST WIND DOWN', 'Close the day', 'Move what’s left to tomorrow, kindly. No streaks.', MOON),
        card('SECOND DEVICE', 'Sign in to sync', 'Only when it helps; the app works fully without it.', '<rect x="3" y="5" width="12" height="14" rx="2"></rect><rect x="15" y="9" width="6" height="10" rx="1.5"></rect>'))
# Android: the system permission dialog after Allow nudges
def A4():
    sysd = ('<div style="position: absolute; inset: 0; background: rgba(0,0,0,.32); z-index: 20;"></div><div role="dialog" style="position: absolute; left: 36px; right: 36px; top: 300px; border-radius: 28px; background: #ECE6F0; padding: 24px; z-index: 21; font-family: Roboto, system-ui;">'
            '<div style="display: flex; justify-content: center; color: #4E4757;">%s</div><div style="font: 400 22px/28px Roboto; text-align: center; margin-top: 14px;">Allow <b>Dottoday</b> to send you notifications?</div>'
            '<div style="margin-top: 22px; display: flex; flex-direction: column; gap: 8px;"><span style="height: 44px; border-radius: 22px; background: #CFE8E4; color: #062F2C; display: flex; align-items: center; justify-content: center; font: 500 15px Roboto;">Allow</span>'
            '<span style="height: 44px; border-radius: 22px; color: #11615C; display: flex; align-items: center; justify-content: center; font: 500 15px Roboto;">Don’t allow</span></div></div>') % sv(BELL, 28)
    return phone(thread_today(150, 470, task=True, x=50) + sysd, android=True)
def tablet(android, inner, blur_bg=True):
    w, h = (1280, 800) if android else (1180, 820)
    bg = ('<div aria-hidden="true" style="position: absolute; inset: 0; filter: blur(14px); opacity: .55;">%s</div>' % ('<div style="position: absolute; left: 0; top: 0; bottom: 0; width: 216px; background: #F3EEE6;"></div>'
          + ''.join('<div style="position: absolute; left: %dpx; top: %dpx; width: 180px; height: %dpx; border-radius: 18px; background: %s;"></div>' % (300 + 230 * i, 140 + 60 * (i % 2), 120 + 40 * i, c) for i, c in enumerate(('#E2EFEC', '#E6E3F7', '#FBEBC8', '#F1ECE4'))))) if blur_bg else ''
    return device(w, h, bg + '<div style="position: absolute; left: %dpx; top: 60px; width: 430px; height: %dpx; border-radius: 34px; background: %s; box-shadow: 0 30px 80px rgba(36,31,43,.22); overflow: hidden;">%s</div>' % ((w - 430) // 2, h - 120, GROUND, inner), android)
def card_inner(phone_html):
    # the phone screen's content inside a tablet card (no bezel), scaled to the card
    s = re.sub(r'^<div style="position: relative; width: 390px; height: 844px; border-radius: 55px;[^"]*"', '<div style="position: relative; width: 390px; height: 844px; transform: scale(.82); transform-origin: 0 0; margin-left: 55px; background: transparent;"', phone_html, count=1)
    return re.sub(r'<div aria-hidden="true" style="position: absolute; top: 11px; left: 132px; width: 126px; height: 37px; border-radius: 25px; background: #000; z-index: 20;"></div>', '', s)
F = {'s1': S1(), 's2': S2(), 's3': S3(), 's4': S4(), 's5': S5(), 'a4': A4(),
     't2': tablet(False, card_inner(S2())), 't3': tablet(True, card_inner(S3()))}
SC = .52
def fr(key, w, h, sc, label, note, time=None):
    t = ('<span class="num" style="margin-left: 8px; font: 700 12px Manrope; color: #0B4642; background: #E2EFEC; padding: 2px 8px; border-radius: 10px; white-space: nowrap;">%s</span>' % time) if time else ''
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 800 16px Manrope; color: #241F2B; display: flex; align-items: center;">%s%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 24, label, t, w * sc + 24, h * sc + 20, w, h, sc, F[key], note)
flow = [fr('s1', 390, 844, SC, '1 · Hello', 'One promise, one action. The day dot draws itself and its thread runs on into the next screen: no splash, no carousel.', '0 s'),
        fr('s2', 390, 844, SC, '2 · Your day', 'The only set-up: drag the sun and moon. Sensible 7:00 and 11:00 defaults make it one tap.', '~5 s'),
        fr('s3', 390, 844, SC, '3 · Your first thing', 'Your own thread, now marker included. Type or tap a suggestion; the time is read as you type.', '~15 s'),
        fr('s4', 390, 844, SC, '4 · A nudge, in context', 'Gym drops onto 6 PM. The ask appears only now, with a preview of that exact reminder; then the system prompt.', '~22 s'),
        fr('s5', 390, 844, SC, '5 · You’re in', 'The real Today, not a summary. One hint that fades after the first tap; a dismissible offer to sync.', '<30 s')]
other = [fr('a4', 412, 892, .5, 'Android · the system prompt, after Allow nudges', 'Android 13+ asks only after the user said yes in context, so the system dialog is expected, not a surprise.'),
         fr('t2', 1180, 820, .4, 'iPad · Your day', 'Tablets, Mac and web: the same steps in a 430 card over the blurred app, so the destination is always in view.'),
         fr('t3', 1280, 800, .4, 'Android tablet · Your first thing', '')]
PRIN = [('Value before set-up', 'People reach their own day in under 30 seconds and three taps (Start, Continue, Put it on today). Everything else is deferred.', 'Apple: avoid delays before the content; defer non-essential requests. Material “Quickstart”.'),
        ('Ask in context, never at launch', 'Notifications are asked the moment they mean something: right after the first task, with that task’s own reminder previewed.', 'Apple WWDC25 privacy guidance; Android 13 notification permission guidance.'),
        ('Personal from the first second', 'Your sun and moon shape the thread; your first task is the first dot. No sample data to unlearn.', 'Material “Self-Select”: few choices, tied to what the app does.'),
        ('One continuous motion story', 'The welcome dot becomes the thread; the thread becomes Today. Every motion explains where you are. Reduce Motion: cross-fades, nothing moves.', 'HIG Motion: purposeful, brief, optional.'),
        ('Progressive disclosure', 'Layout, habits, review and sync are offered later, at the moment they help (the row below).', 'Teach UI in context, not up front.'),
        ('Calm, kind copy', 'No streaks, no “missed”, no pressure. Skip is never punished; every choice is editable.', 'The app’s no-shame rule (CLAUDE.md §11).')]
prin = ''.join('<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div><div style="font: 600 12px/17px Manrope; color: #0B4642; margin-top: 8px;">%s</div></div>' % p for p in PRIN)
MOT = [('Day dot', 'Ring draws 0 → 100 %', '900 ms', 'ease-in-out', 'Shown complete'), ('Thread', 'Grows into the next screen (shared element)', '450 ms', 'decelerate', 'Cross-fade'),
       ('Sun and moon', 'Follow the finger; light haptic at each hour', 'live', 'spring 0.8', 'No haptic change'), ('First task', 'Drops onto its time with a small bounce', '420 ms', 'spring 0.7', 'Appears in place'),
       ('Reminder preview', 'Slides from the top like the real one', '320 ms', 'decelerate', 'Fades in'), ('Hint', 'Fades in, out after first tap', '200 ms', 'standard', 'Static, then gone')]
mot = '<table style="border-collapse: collapse; width: 100%%; font: 500 14px Manrope; color: #241F2B;"><tr style="text-align: left; color: #6A6273; font-weight: 700;"><td>Element</td><td>Motion</td><td>Time</td><td>Easing</td><td>Reduce Motion</td></tr>%s</table>' % ''.join('<tr>%s</tr>' % ''.join('<td>%s</td>' % c for c in r) for r in MOT)
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def section(title, inner, sub_=''):
    return '<section aria-label="%s" style="display: flex; flex-direction: column; gap: 14px;"><div style="font: 800 26px Manrope;">%s</div>%s%s</section>' % (title, title, ('<div style="font: 500 16px/24px Manrope; color: #4E4757; max-width: 1400px;">%s</div>' % sub_) if sub_ else '', inner)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">DOTTODAY · ONBOARDING · RECOMMENDED</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">The First Thread</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1500px;">From opening the app to your own day in under 30 seconds and three taps. You set the two ends of your day, put one real thing on it, and only then is a reminder offered: for that thing. One continuous motion carries the day dot into your thread and your thread into Today. '
        'Built on Apple’s and Android’s own guidance and on what made the six options work. Dark on E-Onboarding-Signature-Dark.</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Recommendation · for owner decision'), tag('tn', 'iPhone, Android, iPad'), tag('tn', 'Light'))
page_body = (body
    + section('The flow', '<div style="display: flex; gap: 22px; align-items: flex-start;">%s</div>' % ''.join(flow), 'Five screens; three required taps. Back is always available; there is no Skip because nothing is required beyond tapping Continue.')
    + section('Later, at the right moment', LATER(), 'What today’s flow asks up front (layout, habits, review, account) is offered once, in context, as a dismissible card. Saying no is never asked again.')
    + section('Android and larger screens', '<div style="display: flex; gap: 22px; align-items: flex-start;">%s</div>' % ''.join(other))
    + section('Why it works', '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1700px;">%s</div>' % prin)
    + section('Motion spec', '<div style="max-width: 1100px; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;">%s</div>' % mot,
              'All motion plays on this board. In the app: system springs (SwiftUI / Compose), 200–900 ms, interruptible; haptics on iPhone and Android where the system offers them.')
    + section('Accessibility and trust', '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 24px; color: #4E4757; columns: 2; column-gap: 48px; max-width: 1600px;">%s</ul>' % ''.join('<li>%s</li>' % x for x in (
        'VoiceOver / TalkBack: the sun and moon are adjustable sliders (“Wake Up, 7:00 AM, swipe up or down”); the day dot is one image.',
        'Text up to 200 %: each screen scrolls; buttons stay reachable at the bottom.',
        'Reduce Motion and Remove animations: every move becomes a cross-fade; nothing loops in the app.',
        'Contrast ≥ 4.5:1 for text; colour is never the only signal (icons and words on every dot).',
        'Age note (13+) on the first screen; privacy: the first task is parsed on the device; nothing is sent without an account.',
        'Returning users: “I have an account” goes straight to sign-in and restore, never through set-up again.')))
    + section('What changes from the built flow', '<div style="font: 500 15px/23px Manrope; color: #4E4757; max-width: 1500px;">The built flow has seven steps (Welcome, Layout, Day shape, Habits, Reminders, Account, Done). The First Thread keeps Welcome and Day shape (made visual), replaces Habits with one real first task, moves Reminders into context, and moves Layout and Account to the “later” cards. New copy is marked for review. Building it replaces the current flow (no second flow is kept).</div>'))
helmet = AB['helmet'].replace('</style>', CSS2 + '</style>', 1)
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · The First Thread</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + helmet
        + '\n<div style="width: 1800px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1800,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-Onboarding-Signature.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · The First Thread</title>', '<title>E · The First Thread · Dark</title>').replace('Dark on E-Onboarding-Signature-Dark.', 'Light on E-Onboarding-Signature.').replace('<span class="tn">Light</span>', '<span class="tn">Dark</span>')
dark = dark.replace('background: #ECE6F0; padding: 24px;', 'background: #2B2930; padding: 24px; color: #E6E0E9;')  # M3 dark system dialog
dark = dark.replace('background: rgba(250,247,242,.94);', 'background: rgba(43,38,42,.94); color: #F3ECE4;')
open('project/E-Onboarding-Signature-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
