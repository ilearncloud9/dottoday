import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
from ws import *
from frames import _ICON
IND = '#5B5FD6'
def sv(p, s=20, w=2): return '<svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true" style="stroke-width: %s;">%s</svg>' % (s, s, w, p)
SUN = '<circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M2 12h2M20 12h2M5 5l1.5 1.5M17.5 17.5L19 19M5 19l1.5-1.5M17.5 6.5L19 5"></path>'
MOON = '<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"></path>'; CHECK = '<path d="M5 12.5l4.5 4.5L19 7.5"></path>'; BELL = '<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4zM10 20a2 2 0 0 0 4 0"></path>'
HAND = '<path d="M8 13V5.5a1.5 1.5 0 0 1 3 0V11M11 10.5V4.5a1.5 1.5 0 0 1 3 0V11M14 10.5V6a1.5 1.5 0 0 1 3 0v8a6 6 0 0 1-6 6h-1a6 6 0 0 1-5-2.7L3 14a1.5 1.5 0 0 1 2.4-1.8L8 15"></path>'
CSS = '''
@keyframes obGrow{0%{transform:scaleY(0)}35%,85%{transform:scaleY(1)}100%{transform:scaleY(1)}}
@keyframes obPop{0%,var(--d,10%){transform:scale(0);opacity:0}calc(var(--d,10%) + 8%){transform:scale(1.18);opacity:1}100%{transform:scale(1);opacity:1}}
@keyframes obPop1{0%,10%{transform:scale(0);opacity:0}18%{transform:scale(1.18);opacity:1}24%,100%{transform:scale(1);opacity:1}}
@keyframes obPop2{0%,30%{transform:scale(0);opacity:0}38%{transform:scale(1.18);opacity:1}44%,100%{transform:scale(1);opacity:1}}
@keyframes obPop3{0%,50%{transform:scale(0);opacity:0}58%{transform:scale(1.18);opacity:1}64%,100%{transform:scale(1);opacity:1}}
@keyframes obPop4{0%,70%{transform:scale(0);opacity:0}78%{transform:scale(1.18);opacity:1}84%,100%{transform:scale(1);opacity:1}}
@keyframes obFly{0%,20%{transform:translate(0,0) scale(1);opacity:1}55%{transform:translate(var(--fx),var(--fy)) scale(.55);opacity:1}60%,100%{transform:translate(var(--fx),var(--fy)) scale(.55);opacity:0}}
@keyframes obPulse{0%{box-shadow:0 0 0 0 rgba(17,97,92,.45)}70%{box-shadow:0 0 0 18px rgba(17,97,92,0)}100%{box-shadow:0 0 0 0 rgba(17,97,92,0)}}
@keyframes obSpin{0%{transform:rotate(-40deg)}50%{transform:rotate(25deg)}100%{transform:rotate(-40deg)}}
@keyframes obSlide{0%,15%{transform:translateY(-140%);opacity:0}28%,80%{transform:translateY(0);opacity:1}92%,100%{transform:translateY(-140%);opacity:0}}
@keyframes obFadeA{0%,40%{opacity:1;transform:none}50%,90%{opacity:0;transform:scale(.97)}100%{opacity:1;transform:none}}
@keyframes obFadeB{0%,40%{opacity:0;transform:scale(1.03)}50%,90%{opacity:1;transform:none}100%{opacity:0;transform:scale(1.03)}}
@keyframes obSweep{0%,30%{transform:translateX(0);opacity:1}55%,100%{transform:translateX(120%);opacity:0}}
@keyframes obFill{0%,35%{background:transparent;box-shadow:inset 0 0 0 3px #D9A23A}45%,100%{background:#D9A23A;box-shadow:inset 0 0 0 3px #D9A23A}}
@keyframes obDrag{0%,20%{transform:translate(0,0)}45%,75%{transform:translate(0,-118px)}100%{transform:translate(0,-118px)}}
@keyframes obType{0%{width:0}40%,100%{width:112px}}
@keyframes obClose{0%,30%{transform:scale(1);border-radius:50%}60%,100%{transform:scale(.42);border-radius:50%}}
.ob-grow{transform-origin:top;animation:obGrow 6s cubic-bezier(.3,.7,.2,1) infinite}
.ob-p1{animation:obPop1 6s cubic-bezier(.3,1.4,.5,1) infinite}.ob-p2{animation:obPop2 6s cubic-bezier(.3,1.4,.5,1) infinite}
.ob-p3{animation:obPop3 6s cubic-bezier(.3,1.4,.5,1) infinite}.ob-p4{animation:obPop4 6s cubic-bezier(.3,1.4,.5,1) infinite}
.ob-fly{animation:obFly 4s cubic-bezier(.5,0,.3,1) infinite}.ob-pulse{animation:obPulse 1.8s ease-out infinite}
.ob-spin{animation:obSpin 7s ease-in-out infinite}.ob-slide{animation:obSlide 5s cubic-bezier(.2,.8,.2,1) infinite}
.ob-fa{animation:obFadeA 6s ease-in-out infinite}.ob-fb{animation:obFadeB 6s ease-in-out infinite}
.ob-sweep{animation:obSweep 5s cubic-bezier(.6,0,.3,1) infinite}.ob-fill{animation:obFill 4s ease infinite}
.ob-drag{animation:obDrag 4s cubic-bezier(.4,0,.2,1) infinite}.ob-type{overflow:hidden;white-space:nowrap;display:inline-block;animation:obType 3.5s steps(12) infinite}
.ob-close{animation:obClose 5s cubic-bezier(.5,0,.2,1) infinite}
@keyframes obSky{0%,15%{background-position:0% 0%}50%,65%{background-position:0% 100%}100%{background-position:0% 0%}}
@keyframes obSun{0%,15%{transform:translate(0,180px)}50%,65%{transform:translate(0,0)}100%{transform:translate(0,180px)}}
@keyframes obFling{0%,25%{transform:translate(0,0) rotate(0)}55%,100%{transform:translate(420px,-40px) rotate(18deg);opacity:0}}
@keyframes obRise{0%,25%{transform:translateY(12px);opacity:0}45%,100%{transform:none;opacity:1}}
@keyframes obWave{0%,100%{transform:scaleY(.35)}50%{transform:scaleY(1)}}
@keyframes obHl{0%,20%{background:transparent}35%,100%{background:rgba(17,97,92,.16)}}
@keyframes obRing{0%{stroke-dashoffset:100}100%{stroke-dashoffset:40}}
.ob-sky{background-size:100% 300%;animation:obSky 7s ease-in-out infinite}.ob-sun{animation:obSun 7s cubic-bezier(.4,0,.2,1) infinite}
.ob-fling{animation:obFling 3.5s cubic-bezier(.5,0,.3,1) infinite}.ob-rise{animation:obRise 4s ease-out infinite}
.ob-wave{transform-origin:center;animation:obWave .9s ease-in-out infinite}.ob-hl{border-radius:6px;padding:0 2px;animation:obHl 4s ease infinite}
@media (prefers-reduced-motion: reduce){[class*="ob-"]{animation:none!important}}
'''
def phone(inner, android=False, chrome=True):
    W, Hh, top_ = (412, 892, 40) if android else (390, 844, 54)
    isl = ('<div aria-hidden="true" style="position: absolute; top: 12px; left: 198px; width: 16px; height: 16px; border-radius: 50%; background: #000; z-index: 20;"></div>' if android else
           '<div aria-hidden="true" style="position: absolute; top: 11px; left: 132px; width: 126px; height: 37px; border-radius: 25px; background: #000; z-index: 20;"></div>')
    return ('<div style="position: relative; width: %dpx; height: %dpx; border-radius: %dpx; background: %s; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 9px #241F2B, 0 0 0 10px rgba(36,31,43,.35); font-family: Manrope, system-ui, sans-serif; color: %s;">%s'
            '<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: %dpx; display: flex; align-items: center; justify-content: space-between; padding: 0 34px; font: 600 15px -apple-system, system-ui; color: %s; z-index: 15;"><span>9:41</span><span>100 %%</span></div>'
            '%s<div aria-hidden="true" style="position: absolute; bottom: 8px; left: 128px; width: 134px; height: 5px; border-radius: 3px; background: %s; z-index: 15;"></div></div>') % (W, Hh, 55, GROUND, INK, isl, top_, INK, inner, INK)
def btn(t, primary=True, extra=''):
    return ('<button style="width: 100%%; height: 56px; border: 0; border-radius: 28px; font: 800 17px Manrope; %s %s">%s</button>' % (
        ('background: %s; color: #fff;' % ACC) if primary else 'background: transparent; color: #0B4642;', extra, t))
def abs_(l, t, w, inner, extra=''): return '<div style="position: absolute; left: %dpx; top: %dpx; width: %dpx; %s">%s</div>' % (l, t, w, extra, inner)
def big(t, sz=32): return '<div role="heading" style="font: 800 %dpx/%dpx Manrope; letter-spacing: -0.6px;">%s</div>' % (sz, sz + 6, t)
def sub(t): return '<div style="font: 500 16px/23px Manrope; color: %s; margin-top: 8px;">%s</div>' % (SEC, t)
def dotc(col, ic, d=40, st='ahead', cls=''):
    s = ('background: %s; color: #fff;' % col) if st == 'done' else ('background: %s; box-shadow: inset 0 0 0 3.5px %s; color: %s;' % (SURF, col, col))
    return '<span class="%s" aria-hidden="true" style="width: %dpx; height: %dpx; border-radius: 50%%; display: inline-flex; align-items: center; justify-content: center; flex: none; %s">%s</span>' % (cls, d, d, s, sv(_ICON.get(ic, ''), int(d * .5)) if ic else '')
AGE = '<div style="font: 500 12px Manrope; color: %s; text-align: center; margin-top: 10px;">Dottoday is for people aged 13 and over.</div>' % SEC

# ---------- A · Draw your day: one living screen, the thread grows as you answer
def A1():
    return phone(abs_(28, 110, 334, big('Let’s draw your day.', 34) + sub('Three taps. Each answer becomes a dot on your thread.'))
                 + '<div class="ob-grow" style="position: absolute; left: 194px; top: 300px; height: 360px; width: 0; border-left: 4px dotted #BEB6C7;"></div>'
                 + abs_(150, 300, 92, '<div style="display: flex; flex-direction: column; align-items: center; gap: 6px;">%s<span style="font: 700 13px Manrope; color: %s;">7:00</span></div>' % (dotc('#D9A23A', None, 48, cls='ob-p1').replace('</span>', sv(SUN, 24) + '</span>', 1), SEC))
                 + abs_(28, 690, 334, btn('Start') + AGE))
def A2():
    chips = [('Morning run', '#E2725B', 'Morning run', -150, -260), ('Deep work', IND, 'Deep work: roadmap', 10, -200), ('Gym', '#8B5CF6', 'Gym', -60, -140), ('Read', '#8C6A4F', 'Read', 90, -90)]
    ch = ''.join(('<span class="ob-fly" style="--fx: %dpx; --fy: %dpx; animation-delay: %.1fs; height: 44px; padding: 0 14px 0 6px; border-radius: 22px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.10), 0 4px 12px rgba(36,31,43,.08); display: inline-flex; align-items: center; gap: 8px; font: 700 15px Manrope;">%s%s</span>') % (fx, fy, k * .35, SURF, dotc(c, ic, 32), t)
                 for k, (t, c, ic, fx, fy) in enumerate(chips))
    th = ''.join('<div style="display: flex; align-items: center; gap: 12px; height: 54px;">%s<span style="line-height: 1.2;"><span class="num" style="display: block; font: 500 12px Manrope; color: %s;">%s</span><span style="display: block; font: 700 15px Manrope;">%s</span></span></div>' % (dotc(c, ic, 36, cls=cl), SEC, tm, t)
                 for t, tm, c, ic, cl in (('Morning run', '7:15', '#E2725B', 'Morning run', 'ob-p1'), ('Deep work', '9:00', IND, 'Deep work: roadmap', 'ob-p2'), ('Gym', '6:00 PM', '#8B5CF6', 'Gym', 'ob-p3'), ('Read', '9:30 PM', '#8C6A4F', 'Read', 'ob-p4')))
    return phone(abs_(28, 96, 334, big('What fills your days?', 28) + sub('Tap any. They land on the thread at a time that fits.'))
                 + '<div style="position: absolute; left: 47px; top: 240px; height: 300px; border-left: 4px dotted #BEB6C7;"></div>'
                 + abs_(28, 228, 334, '<div style="display: flex; align-items: center; gap: 12px; height: 44px; color: %s; font: 600 13px Manrope;">%s Wake Up · 7:00</div>%s' % (SEC, dotc('#D9A23A', None, 40, 'done').replace('</span>', sv(SUN, 20) + '</span>', 1), th))
                 + abs_(20, 600, 350, '<div style="display: flex; flex-wrap: wrap; gap: 8px; justify-content: center;">%s</div>' % ch)
                 + abs_(28, 750, 334, btn('That’s my day')))
def A3():
    return phone(abs_(28, 96, 334, big('And when do you wind down?', 28) + sub('Drag the moon. Your thread closes there.'))
                 + '<div style="position: absolute; left: 47px; top: 230px; height: 420px; width: 4px; background: linear-gradient(%s, %s);"></div>' % ('#D9A23A', IND)
                 + abs_(28, 220, 334, ''.join('<div style="display: flex; align-items: center; gap: 12px; height: 70px;">%s<span style="font: 700 15px Manrope;">%s</span></div>' % (dotc(c, ic, 36, 'done' if k == 0 else 'ahead'), t)
                                              for k, (t, c, ic) in enumerate((('Wake Up · 7:00', '#D9A23A', None), ('Morning run · 7:15', '#E2725B', 'Morning run'), ('Deep work · 9:00', IND, 'Deep work: roadmap'), ('Gym · 6:00 PM', '#8B5CF6', 'Gym'), ('Read · 9:30 PM', '#8C6A4F', 'Read')))))
                 + abs_(26, 600, 340, '<div style="display: flex; align-items: center; gap: 12px;"><span class="ob-pulse" style="width: 48px; height: 48px; border-radius: 50%%; background: #E6E3F7; color: #4B3FB0; display: flex; align-items: center; justify-content: center;">%s</span>'
                                       '<span style="font: 800 22px Manrope;">11:00 PM</span><span class="num" style="margin-left: auto; font: 600 14px Manrope; color: #0B4642;">8 h of sleep</span></div>' % sv(MOON, 24))
                 + abs_(28, 750, 334, btn('Close my thread')))
def A4():
    return phone(abs_(28, 110, 334, '<div style="text-align: center;">' + big('Your first thread is ready.', 30) + sub('Tomorrow is planned. Today is open.') + '</div>')
                 + '<div class="ob-close" style="position: absolute; left: 115px; top: 300px; width: 160px; height: 160px; border-radius: 50%%; background: radial-gradient(closest-side, %s calc(100%% - 16px), transparent calc(100%% - 15.5px)), conic-gradient(#D9A23A 0 10%%, #E2725B 10%% 25%%, %s 25%% 55%%, #8B5CF6 55%% 75%%, #8C6A4F 75%% 90%%, #4B3FB0 90%% 100%%);"></div>' % (GROUND, IND)
                 + abs_(28, 520, 334, '<div style="border-radius: 20px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06); padding: 14px 16px; display: flex; flex-direction: column; gap: 10px;">'
                                      '<div style="display: flex; align-items: center; gap: 10px; font: 600 15px Manrope;">%s<span style="flex: 1;">Nudge me before tasks</span><span style="font: 700 14px Manrope; color: #0B4642;">Ask later</span></div>'
                                      '<div style="display: flex; align-items: center; gap: 10px; font: 600 15px Manrope;">%s<span style="flex: 1;">Show me less</span><span style="font: 700 14px Manrope; color: #0B4642;">Minimal</span></div></div>' % (SURF, sv(BELL, 20), sv('<circle cx="12" cy="12" r="8"></circle>', 20)))
                 + abs_(28, 690, 334, btn('Open today') + '<div style="margin-top: 6px;">%s</div>' % btn('Sync with an account', False)))

# ---------- B · Try it first: start inside a sample day, learn by doing
def coach(t, step, extra=''):
    dots = ''.join('<span style="width: %dpx; height: 6px; border-radius: 3px; background: %s;"></span>' % (18 if k == step else 6, ACC if k <= step else '#DDD7E0') for k in range(3))
    return ('<div role="status" style="position: absolute; left: 16px; right: 16px; bottom: 34px; border-radius: 24px; background: #2E2836; color: #FBF7F1; padding: 14px 18px; z-index: 12; box-shadow: 0 12px 32px rgba(36,31,43,.25);">'
            '<div style="display: flex; gap: 4px; margin-bottom: 8px;">%s</div><div style="font: 700 17px/23px Manrope;">%s</div>%s</div>') % (dots, t, extra)
def sample_rows(fill=False, drag=False):
    rows = [('Coffee', '7:30', '#D9A23A', 'Coffee & plan the day'), ('Walk', '12:00', '#469763', 'Pick up parcel'), ('Read', '9:30 PM', '#8C6A4F', 'Read')]
    out = ''
    for k, (t, tm, c, ic) in enumerate(rows):
        d = dotc(c, ic, 40)
        if fill and k == 0: d = '<span class="ob-fill ob-pulse" style="width: 40px; height: 40px; border-radius: 50%%; display: inline-flex; align-items: center; justify-content: center; color: #fff; flex: none;">%s</span>' % sv(CHECK, 20, 3)
        wrap = 'class="ob-drag"' if (drag and k == 1) else ''
        out += '<div %s style="display: flex; align-items: center; gap: 12px; height: 70px; position: relative; z-index: %d;">%s<span style="line-height: 1.25;"><span class="num" style="display: block; font: 500 13px Manrope; color: %s;">%s</span><span style="display: block; font: 700 17px Manrope;">%s</span></span></div>' % (wrap, 3 if wrap else 1, d, SEC, tm, t)
        if k == 0: out += '<div style="margin-left: 54px; height: 54px; border-radius: 16px; border: 2px dashed rgba(17,97,92,.45); display: flex; align-items: center; padding: 0 12px; font: 600 14px Manrope; color: #0B4642;">1 h free</div>'
    return out
def sample_screen(inner_rows, cap):
    return (abs_(24, 64, 342, '<div style="display: flex; align-items: center; gap: 8px;"><span style="font: 800 28px Manrope;">Today</span><span style="height: 26px; padding: 0 10px; border-radius: 13px; background: #FBEBC8; color: #9A5A0E; font: 700 12px Manrope; display: flex; align-items: center;">Sample day</span></div>')
            + '<div style="position: absolute; left: 43px; top: 130px; height: 420px; border-left: 4px dotted #BEB6C7;"></div>' + abs_(24, 124, 342, inner_rows) + cap)
def B1():
    return phone(abs_(28, 160, 334, '<div style="text-align: center;">%s<div style="margin-top: 26px;">%s</div>%s</div>' % (
        '<div class="ob-p1" style="display: inline-flex;">%s</div>' % dotc(ACC, None, 96, 'done').replace('</span>', sv(CHECK, 44, 2.6) + '</span>', 1), big('Plans that bend<br>when your day does.', 32), sub('No set-up. Try it on a sample day first.')))
                 + abs_(28, 650, 334, btn('Try it') + '<div style="margin-top: 6px;">%s</div>' % btn('I already have an account', False) + AGE))
def B2(): return phone(sample_screen(sample_rows(fill=True), coach('Tap a dot to finish it.', 0, '<div style="font: 500 14px Manrope; color: #CFC6D6; margin-top: 4px;">It fills with its colour. Tap again to reopen.</div>')))
def B3(): return phone(sample_screen(sample_rows(drag=True), coach('Hold and drag Walk into the free hour.', 1)) + '<div class="ob-drag" style="position: absolute; left: 76px; top: 300px; color: %s; z-index: 13;">%s</div>' % (INK, sv(HAND, 34, 1.8)))
def B4():
    field = ('<div style="position: absolute; left: 16px; right: 16px; top: 520px; height: 56px; border-radius: 18px; background: %s; box-shadow: 0 0 0 2px %s; display: flex; align-items: center; padding: 0 16px; font: 600 18px Manrope; z-index: 12;">'
             '<span class="ob-type">call Sam 6pm</span><span style="width: 2px; height: 24px; background: %s;"></span><span class="num" style="margin-left: auto; font: 700 13px Manrope; color: #0B4642;">6:00 PM</span></div>') % (SURF, ACC, ACC)
    return phone(sample_screen(sample_rows(), coach('Type it the way you’d say it.', 2, '<div style="margin-top: 10px;">%s</div>' % btn('Make it my day', True, 'height: 48px; background: #A3E2D9; color: #062F2C;'))) + field)
def B5():
    return phone(abs_(24, 64, 342, '<div style="font: 800 28px Manrope;">Today</div>')
                 + '<div class="ob-sweep" style="position: absolute; left: 24px; top: 124px; width: 342px; opacity: .9;">%s</div>' % sample_rows()
                 + abs_(24, 380, 342, '<div style="border-radius: 24px; background: %s; box-shadow: 0 12px 32px rgba(36,31,43,.14); padding: 18px;">%s%s'
                                      '<div style="display: flex; gap: 8px; margin-top: 14px;"><span style="flex: 1; height: 52px; border-radius: 16px; background: #FBEBC8; display: flex; align-items: center; gap: 8px; padding: 0 12px; font: 700 16px Manrope;">%s 7:00</span>'
                                      '<span style="flex: 1; height: 52px; border-radius: 16px; background: #E6E3F7; display: flex; align-items: center; gap: 8px; padding: 0 12px; font: 700 16px Manrope;">%s 11:00 PM</span></div>'
                                      '<div style="margin-top: 14px;">%s</div></div>' % (SURF, big('Now it’s yours.', 24), sub('The sample clears. Set the two ends of your day.'), sv(SUN, 20), sv(MOON, 20), btn('Start my day'))))

# ---------- C · Pick your rhythm: three bold cards, a morph, one nudge
def clock(arc_from, arc_to, col, size=240, label=''):
    a, b = arc_from / 24 * 100, arc_to / 24 * 100
    return ('<div style="position: relative; width: %dpx; height: %dpx;"><div class="ob-spin" style="position: absolute; inset: 0; border-radius: 50%%; background: radial-gradient(closest-side, %s calc(100%% - 26px), transparent calc(100%% - 25.5px)), conic-gradient(#ECE5DC 0 %.1f%%, %s %.1f%% %.1f%%, #ECE5DC %.1f%% 100%%);"></div>'
            '<span style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font: 800 22px Manrope; text-align: center;">%s</span></div>') % (size, size, SURF, a, col, a, b, b, label)
def C1():
    cards = ('<div style="position: absolute; left: 30px; right: 30px; top: 200px; height: 440px; border-radius: 34px; background: %s; box-shadow: 0 20px 50px rgba(36,31,43,.14); display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 18px; z-index: 3;">%s'
             '<div style="font: 800 26px Manrope;">Early bird</div><div class="num" style="font: 600 16px Manrope; color: %s;">6:00 – 10:00 PM</div></div>'
             '<div style="position: absolute; left: 46px; right: 46px; top: 214px; height: 440px; border-radius: 34px; background: #EFE7DB; transform: rotate(4deg); z-index: 2;"></div>'
             '<div style="position: absolute; left: 60px; right: 60px; top: 226px; height: 440px; border-radius: 34px; background: #E6E3F7; transform: rotate(-5deg); z-index: 1;"></div>') % (SURF, clock(6, 22, '#D9A23A', 220, '16 h<br><span style="font: 600 13px Manrope; color: %s;">awake</span>' % SEC), SEC)
    dots = '<div style="position: absolute; left: 0; right: 0; top: 680px; display: flex; justify-content: center; gap: 8px;">%s</div>' % ''.join('<span style="width: %dpx; height: 8px; border-radius: 4px; background: %s;"></span>' % (22 if k == 0 else 8, ACC if k == 0 else '#DDD7E0') for k in range(4))
    return phone(abs_(28, 90, 334, big('What’s your rhythm?', 30) + sub('Swipe. Early bird · Nine to six · Night owl · My own.')) + cards + dots + abs_(28, 730, 334, btn('This is me')))
def C2():
    full = ''.join('<div style="display: flex; align-items: center; gap: 10px; height: 46px;">%s<span style="font: 700 15px Manrope;">%s</span></div>' % (dotc(c, ic, 30), t) for t, c, ic in (('Morning run', '#E2725B', 'Morning run'), ('Deep work', IND, 'Deep work: roadmap'), ('Lunch', '#D9668F', 'Lunch'), ('Gym', '#8B5CF6', 'Gym'), ('Read', '#8C6A4F', 'Read')))
    mini = ('<div style="display: flex; flex-direction: column; align-items: center; gap: 14px; padding-top: 30px;"><span style="width: 150px; height: 150px; border-radius: 50%%; background: radial-gradient(closest-side, %s calc(100%% - 13px), transparent calc(100%% - 12.5px)), conic-gradient(%s 0 85%%, %s33 85%% 100%%); display: flex; align-items: center; justify-content: center; font: 800 40px Manrope;">18</span>'
            '<span style="font: 800 18px Manrope;">Deep work</span><span style="height: 40px; padding: 0 18px; border-radius: 20px; background: %s; color: #fff; display: flex; align-items: center; font: 700 15px Manrope;">Done</span></div>') % (SURF, IND, IND, ACC)
    stage = ('<div style="position: absolute; left: 28px; right: 28px; top: 222px; height: 400px; border-radius: 30px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.08); overflow: hidden;">'
             '<div class="ob-fa" style="position: absolute; inset: 0; padding: 18px;"><div style="font: 700 12px Manrope; letter-spacing: .6px; color: %s;">EVERYTHING</div>%s</div>'
             '<div class="ob-fb" style="position: absolute; inset: 0; padding: 18px;"><div style="font: 700 12px Manrope; letter-spacing: .6px; color: %s;">LESS</div>%s</div></div>') % (SURF, SEC, full, SEC, mini)
    seg = ('<div style="position: absolute; left: 28px; right: 28px; top: 640px; height: 52px; border-radius: 26px; background: #ECE5DC; display: flex; padding: 4px; box-sizing: border-box; font: 700 16px Manrope;">'
           '<span style="flex: 1; border-radius: 22px; background: %s; color: %s; display: flex; align-items: center; justify-content: center; box-shadow: 0 1px 3px rgba(36,31,43,.12);">Everything</span><span style="flex: 1; display: flex; align-items: center; justify-content: center; color: #4E4757;">Less</span></div>') % (SURF, ACC)
    return phone(abs_(28, 90, 334, big('How much do you want to see?', 28) + sub('Watch it change. Pick the one that feels calm.')) + stage + seg + abs_(28, 730, 334, btn('Continue')))
def C3():
    note = ('<div class="ob-slide" style="position: absolute; left: 12px; right: 12px; top: 58px; border-radius: 22px; background: rgba(250,247,242,.92); backdrop-filter: blur(20px); box-shadow: 0 10px 30px rgba(36,31,43,.18); padding: 12px 14px; display: flex; gap: 10px; z-index: 14;">'
            '%s<div style="line-height: 1.3;"><div style="font: 700 14px -apple-system, system-ui;">Dottoday · now</div><div style="font: 600 15px -apple-system, system-ui;">Deep work starts in 10 min</div><div style="font: 500 14px -apple-system, system-ui; color: %s;">9:00 – 11:00 · then Lunch</div></div></div>') % (dotc(IND, 'Deep work: roadmap', 36), SEC)
    return phone(note + abs_(28, 230, 334, '<div style="text-align: center;"><span class="ob-pulse" style="display: inline-flex; width: 88px; height: 88px; border-radius: 50%%; background: #E2EFEC; color: %s; align-items: center; justify-content: center;">%s</span>'
                                       '<div style="margin-top: 22px;">%s</div>%s</div>' % (ACC, sv(BELL, 40, 1.8), big('A tap before each task?', 28), sub('Like this one. Change the timing any time.')))
                 + abs_(28, 690, 334, btn('Yes, nudge me') + '<div style="margin-top: 6px;">%s</div>' % btn('Not now', False)))
def C4():
    return phone('<div class="ob-close" style="position: absolute; left: 75px; top: 220px; width: 240px; height: 240px; border-radius: 50%%; background: radial-gradient(closest-side, %s calc(100%% - 26px), transparent calc(100%% - 25.5px)), conic-gradient(#ECE5DC 0 25%%, #D9A23A 25%% 92%%, #ECE5DC 92%% 100%%);"></div>' % GROUND
                 + abs_(28, 520, 334, '<div style="text-align: center;">%s%s</div>' % (big('Welcome to your day.', 30), sub('The ring becomes your day dot, and Today opens.')))
                 + abs_(28, 690, 334, btn('Open today') + '<div style="margin-top: 6px;">%s</div>' % btn('Sync with an account', False)))


# ---------- D · Say your day: one sentence becomes a proposed thread
WAVE = ''.join('<span class="ob-wave" style="width: 5px; height: 34px; border-radius: 3px; background: %s; animation-delay: %.2fs;"></span>' % (ACC, k * .12) for k in range(9))
def D1():
    return phone(abs_(28, 120, 334, '<div style="text-align: center;">' + big('Tell me about your day.', 32) + sub('One sentence is enough. Dottoday draws the rest.') + '</div>')
                 + abs_(28, 330, 334, '<div style="height: 120px; border-radius: 28px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.08), 0 14px 34px rgba(36,31,43,.10); display: flex; align-items: center; justify-content: center; gap: 6px;">%s</div>'
                                      '<div style="text-align: center; font: 600 14px Manrope; color: %s; margin-top: 12px;">Listening… or type instead</div>' % (SURF, WAVE, SEC))
                 + abs_(28, 690, 334, btn('Hold to talk') + '<div style="margin-top: 6px;">%s</div>' % btn('Type it', False) + AGE))
def D2():
    hl = lambda t, d: '<span class="ob-hl" style="animation-delay: %.1fs;">%s</span>' % (d, t)
    sent = 'I wake at %s, %s from 9, %s after work and I’m in bed by %s.' % (hl('7', 0), hl('deep work', .4), hl('gym', .8), hl('11', 1.2))
    chips = ''.join('<span class="ob-rise" style="animation-delay: %.1fs; height: 40px; padding: 0 12px 0 6px; border-radius: 20px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.10); display: inline-flex; align-items: center; gap: 8px; font: 700 14px Manrope;">%s%s</span>' % (k * .4, SURF, d, t)
                    for k, (t, d) in enumerate((('Wake Up 7:00', dotc('#D9A23A', None, 28, 'done').replace('</span>', sv(SUN, 14) + '</span>', 1)), ('Deep work 9:00', dotc(IND, 'Deep work: roadmap', 28)), ('Gym 6:00 PM', dotc('#8B5CF6', 'Gym', 28)), ('Wind Down 11:00 PM', dotc('#4B3FB0', None, 28).replace('</span>', sv(MOON, 14) + '</span>', 1)))))
    return phone(abs_(28, 100, 334, big('Got it.', 32) + '<div style="margin-top: 18px; font: 600 22px/32px Manrope;">“%s”</div>' % sent)
                 + abs_(28, 420, 334, '<div style="font: 700 13px Manrope; letter-spacing: .6px; color: %s;">I HEARD</div><div style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px;">%s</div>' % (SEC, chips))
                 + abs_(28, 730, 334, btn('Show me')))
def D3():
    rows = ''.join('<div style="display: flex; align-items: center; gap: 12px; height: 64px;">%s<span style="line-height: 1.25; flex: 1;"><span class="num" style="display: block; font: 500 13px Manrope; color: %s;">%s</span><span style="display: block; font: 700 16px Manrope;">%s</span></span>%s</div>' % (
        ('<span aria-hidden="true" style="width: 36px; height: 36px; border-radius: 50%%; flex: none; border: 2.5px dashed %s; box-sizing: border-box; display: flex; align-items: center; justify-content: center; color: %s;">%s</span>' % (c, c, sv(_ICON[ic], 16)) if ic else dotc(c, None, 36, 'done')),
        SEC, tm, t, '<span style="font: 700 12px Manrope; color: #0B4642; background: #E2EFEC; padding: 2px 8px; border-radius: 10px;">new</span>' if ic else '') for t, tm, c, ic in (
        ('Wake Up', '7:00 AM', '#D9A23A', None), ('Deep work', '9:00 – 11:00 AM', IND, 'Deep work: roadmap'), ('Gym', '6:00 – 7:00 PM', '#8B5CF6', 'Gym'), ('Wind Down', '11:00 PM', '#4B3FB0', None)))
    return phone(abs_(28, 90, 334, big('Is this your day?', 30) + sub('Nothing is saved until you say yes.'))
                 + '<div style="position: absolute; left: 45px; top: 210px; height: 260px; border-left: 4px dotted #BEB6C7;"></div>' + abs_(28, 200, 334, rows)
                 + abs_(28, 640, 334, btn('Yes, that’s my day') + '<div style="margin-top: 6px;">%s</div>' % btn('Change something', False)))
def D4():
    return phone(abs_(28, 260, 334, '<div style="text-align: center;"><span class="ob-p1" style="display: inline-flex;">%s</span><div style="margin-top: 24px;">%s</div>%s</div>' % (
        dotc(ACC, None, 96, 'done').replace('</span>', sv(CHECK, 44, 2.6) + '</span>', 1), big('Your day is drawn.', 30), sub('Say or type more any time: the Add button listens too.')))
                 + abs_(28, 690, 334, btn('Open today') + '<div style="margin-top: 6px;">%s</div>' % btn('Sync with an account', False)))

# ---------- E · Sunrise, sunset: set your day on the sky
SKY = 'linear-gradient(180deg, @@2E2836@@ 0%, @@4B3FB0@@ 18%, @@D9668F@@ 36%, @@F2B880@@ 52%, @@FBEBC8@@ 68%, @@FBF7F1@@ 84%, @@FBF7F1@@ 100%)'
def skyphone(inner, cls='ob-sky'):
    return phone('<div class="%s" style="position: absolute; inset: 0; background: %s;"></div>' % (cls, SKY) + inner)
def sun(col='@@D9A23A@@', cls='ob-sun', glyph=SUN):
    return '<div class="%s" style="width: 96px; height: 96px; border-radius: 50%%; background: %s; box-shadow: 0 0 60px %s; display: flex; align-items: center; justify-content: center; color: #fff;">%s</div>' % (cls, col, col, sv(glyph, 40, 1.8))
FROST = 'border-radius: 26px; background: rgba(251,247,241,.86); backdrop-filter: blur(16px); padding: 18px 20px; box-shadow: 0 8px 24px rgba(36,31,43,.12);'
def E1():
    return skyphone(abs_(24, 100, 342, big('Good morning.', 36) + sub('Let’s find where your day begins and ends.'), FROST)
                    + '<div style="position: absolute; left: 0; right: 0; top: 560px; height: 2px; background: rgba(36,31,43,.15);"></div>'
                    + abs_(147, 420, 96, sun()) + abs_(28, 690, 334, btn('Begin') + AGE))
def E2():
    return skyphone(abs_(24, 90, 342, big('When does the sun come up for you?', 28) + sub('Drag the sun. The sky follows.'), FROST)
                    + abs_(147, 360, 96, sun()) + '<div style="position: absolute; left: 0; right: 0; top: 560px; height: 2px; background: rgba(36,31,43,.15);"></div>'
                    + abs_(110, 590, 170, '<div class="num" style="text-align: center; font: 800 44px Manrope;">7:00 <span style="font-size: 22px;">AM</span></div>', FROST.replace('padding: 18px 20px', 'padding: 6px 10px'))
                    + abs_(28, 730, 334, btn('That’s my morning')))
def E3():
    stars = ''.join('<span style="position: absolute; left: %dpx; top: %dpx; width: 3px; height: 3px; border-radius: 50%%; background: @@FBEBC8@@;"></span>' % (x, y) for x, y in ((40, 220), (120, 160), (300, 200), (220, 260), (340, 140), (80, 300), (260, 120)))
    return phone('<div style="position: absolute; inset: 0; background: linear-gradient(180deg, @@171416@@ 0%, @@2E2836@@ 45%, @@4B3FB0@@ 100%);"></div>' + stars
                 + abs_(28, 100, 334, '<div style="color: @@FBF7F1@@;">' + big('And when does it set?', 30) + '<div style="font: 500 16px/23px Manrope; color: @@CFC6D6@@; margin-top: 8px;">Drag the moon to your Wind Down.</div></div>')
                 + abs_(147, 400, 96, sun('@@6B5FD6@@', 'ob-p1', MOON)) + abs_(28, 590, 334, '<div class="num" style="text-align: center; font: 800 44px Manrope; color: @@FBF7F1@@;">11:00 <span style="font-size: 22px;">PM</span></div><div style="text-align: center; font: 600 15px Manrope; color: @@A3E2D9@@; margin-top: 4px;">16 h awake · 8 h of sleep</div>')
                 + abs_(28, 730, 334, btn('That’s my night', True, 'background: @@A3E2D9@@; color: @@062F2C@@;')))
def E4():
    return phone('<div class="ob-sky" style="position: absolute; left: 0; right: 0; top: 0; height: 330px; background: %s;"></div>' % SKY
                 + abs_(28, 90, 334, big('Your day, between sun and moon.', 28))
                 + '<div class="ob-grow" style="position: absolute; left: 194px; top: 360px; height: 260px; border-left: 4px dotted @@BEB6C7@@;"></div>'
                 + abs_(170, 340, 50, dotc('@@D9A23A@@', None, 48, 'done').replace('</span>', sv(SUN, 22) + '</span>', 1)) + abs_(170, 610, 50, dotc('@@4B3FB0@@', None, 48, 'done', 'ob-p3').replace('</span>', sv(MOON, 22) + '</span>', 1))
                 + abs_(28, 700, 334, btn('Fill it in')))

# ---------- F · Swipe to set up: a deck of yes / no cards
def deck_card(t, b, art, top_=220, cls='', z=3, rot=0, bg=None):
    return ('<div class="%s" style="position: absolute; left: 34px; right: 34px; top: %dpx; height: 400px; border-radius: 32px; background: %s; box-shadow: 0 18px 44px rgba(36,31,43,.16); transform: rotate(%ddeg); z-index: %d; padding: 26px; box-sizing: border-box; display: flex; flex-direction: column; gap: 14px;">'
            '<div style="flex: 1; display: flex; align-items: center; justify-content: center;">%s</div><div style="font: 800 24px/30px Manrope;">%s</div><div style="font: 500 15px/21px Manrope; color: %s;">%s</div></div>') % (cls, top_, bg or SURF, rot, z, art, t, SEC, b)
def yesno():
    return ('<div style="position: absolute; left: 0; right: 0; top: 660px; display: flex; justify-content: center; gap: 28px;">'
            '<span style="width: 68px; height: 68px; border-radius: 50%%; background: %s; box-shadow: 0 0 0 1.5px rgba(36,31,43,.18); display: flex; align-items: center; justify-content: center; font: 800 15px Manrope; color: %s;">Skip</span>'
            '<span style="width: 68px; height: 68px; border-radius: 50%%; background: %s; display: flex; align-items: center; justify-content: center; color: #fff;">%s</span></div>') % (SURF, SEC, ACC, sv(CHECK, 30, 3))
def progress(n):
    return '<div style="position: absolute; left: 34px; right: 34px; top: 120px; display: flex; gap: 6px;">%s</div>' % ''.join('<span style="flex: 1; height: 5px; border-radius: 3px; background: %s;"></span>' % (ACC if k < n else '#DDD7E0') for k in range(5))
def F1():
    return phone(abs_(28, 140, 334, '<div style="text-align: center;">' + big('Five quick cards.', 34) + sub('Swipe right for yes, left to skip. About 20 seconds.') + '</div>')
                 + deck_card('Swipe me →', 'Try it: this one just says hello.', '<span style="font-size: 64px;">👋</span>', 330, 'ob-fling', 3)
                 + deck_card('', '', '', 344, '', 2, 4, '#EFE7DB') + abs_(28, 760, 334, AGE))
def F2():
    art = '<div style="display: flex; gap: 10px;">%s%s</div>' % (time_chip('Wake Up', '7:00', '#FBEBC8', SUN), time_chip('Wind Down', '11:00 PM', '#E6E3F7', MOON))
    return phone(progress(1) + abs_(34, 150, 322, '<div style="font: 700 14px Manrope; color: %s;">1 of 5</div>' % SEC)
                 + deck_card('Up at 7, wind down at 11?', 'Most people start here. Tap a time to change it.', art, 220, 'ob-fling', 3)
                 + deck_card('', '', '', 234, '', 2, -4, '#EFE7DB') + yesno())
def time_chip(l, t, bg, ic):
    return '<span style="height: 64px; padding: 0 14px; border-radius: 18px; background: %s; display: flex; flex-direction: column; justify-content: center; gap: 2px;"><span style="display: flex; gap: 6px; align-items: center; font: 600 12px Manrope; color: #4E4757;">%s%s</span><span class="num" style="font: 800 18px Manrope;">%s</span></span>' % (bg, sv(ic, 14), l, t)
def F3():
    art = '<div style="display: flex; flex-direction: column; gap: 8px;">%s</div>' % ''.join('<span style="display: flex; align-items: center; gap: 10px; font: 700 16px Manrope;">%s%s</span>' % (dotc(c, ic, 34), t) for t, c, ic in (('Morning run', '#E2725B', 'Morning run'), ('Deep work', IND, 'Deep work: roadmap'), ('Read', '#8C6A4F', 'Read')))
    return phone(progress(2) + abs_(34, 150, 322, '<div style="font: 700 14px Manrope; color: %s;">2 of 5</div>' % SEC) + deck_card('Start with a few habits?', 'They go on tomorrow at times that fit.', art, 220, '', 3) + deck_card('', '', '', 234, '', 2, 4, '#EFE7DB') + yesno())
def F4():
    note = '<div style="width: 100%%; border-radius: 18px; background: rgba(250,247,242,.95); box-shadow: 0 6px 18px rgba(36,31,43,.14); padding: 10px 12px; display: flex; gap: 10px; align-items: center;">%s<span style="font: 600 14px/18px -apple-system, system-ui;">Deep work starts in 10 min</span></div>' % dotc(IND, 'Deep work: roadmap', 30)
    return phone(progress(3) + abs_(34, 150, 322, '<div style="font: 700 14px Manrope; color: %s;">3 of 5</div>' % SEC) + deck_card('A nudge before each task?', 'You choose how early, later.', note, 220, '', 3) + deck_card('', '', '', 234, '', 2, -4, '#EFE7DB') + yesno())
def F5():
    sm = ''.join('<div style="display: flex; align-items: center; gap: 10px; height: 44px; font: 600 15px Manrope;"><span style="width: 24px; height: 24px; border-radius: 50%%; display: flex; align-items: center; justify-content: center; %s">%s</span>%s</div>' % (
        ('background: %s; color: #fff;' % ACC) if y else 'box-shadow: inset 0 0 0 2px #8A8494;', sv(CHECK, 14, 3) if y else '', t) for t, y in (('Day 7:00 – 11:00 PM', True), ('3 habits on tomorrow', True), ('Nudges on', True), ('Everything (full planner)', True), ('Account: later', False)))
    return phone(progress(5) + abs_(28, 160, 334, big('All set.', 34) + sub('Here’s what you chose. Change any of it in Settings.') + '<div style="margin-top: 18px; border-radius: 22px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06); padding: 8px 16px;">%s</div>' % (SURF, sm))
                 + abs_(28, 700, 334, btn('Open today')))

SC = .5
def fr(html, label, note):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: 390px; height: 844px; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13px; line-height: 19px; color: #4E4757;">%s</div></figure>') % (390 * SC + 24, label, 390 * SC + 24, 844 * SC + 20, SC, html, note)
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def opt(title, tags, pitch, flow, keeps, frames):
    li = ''.join('<li style="margin: 0 0 6px;">%s</li>' % n for n in keeps)
    fl = ''.join('<span style="height: 30px; padding: 0 12px; border-radius: 15px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.10); display: inline-flex; align-items: center; font: 700 13px Manrope;">%s</span>' % (SURF, s) for s in flow)
    return ('<section aria-label="%s" style="display: flex; gap: 28px; align-items: flex-start;"><div style="width: 360px; flex: none; display: flex; flex-direction: column; gap: 10px;">'
            '<div style="font: 800 26px Manrope;">%s</div><div style="display: flex; flex-wrap: wrap; gap: 6px;">%s</div><div style="font: 600 16px/23px Manrope;">%s</div>'
            '<div style="display: flex; flex-wrap: wrap; gap: 6px; align-items: center;">%s</div><ul style="margin: 4px 0 0; padding-left: 18px; font-size: 14px; line-height: 21px; color: #4E4757;">%s</ul></div>'
            '<div style="display: flex; gap: 22px; align-items: flex-start;">%s</div></section>') % (title, title, tags, pitch, fl, li, ''.join(frames))
rows = [
 opt('A · Draw your day', tag('tn', '4 screens · ~45 s') + tag('tn', 'Motion: the thread grows'),
     'One living screen. Each answer becomes a dot, and you watch your own thread draw itself.',
     ['Wake Up', '→', 'Habits land', '→', 'Wind Down closes it', '→', 'Ready'],
     ['<b>Motion:</b> the dotted thread grows down from Wake Up; habit chips arc onto it and pop into dots with a spring; the ring closes into the day dot.',
      '<b>Changes from today:</b> no Layout or Reminders steps up front; both become quiet choices on the last screen (“Ask later”, “Show me less”). Account is optional at the end.',
      '<b>Feels like:</b> building, not filling in a form.'],
     [fr(A1(), '1 · Let’s draw your day', 'The Wake Up dot pops in at 7:00; the thread starts to grow.'),
      fr(A2(), '2 · Habits fly onto the thread', 'Tap a chip: it shrinks and flies to its time; the dot pops in.'),
      fr(A3(), '3 · Drag the moon', 'The thread turns from dawn to dusk; the moon pulses until you set it.'),
      fr(A4(), '4 · Ready', 'The day’s colours close into one ring. Nudges and Less are one tap, or later.')]),
 opt('B · Try it first', tag('tn', '5 screens · learn by doing') + tag('tn', 'Motion: coach and sweep'),
     'No questions first. You land on a sample day and learn the three moves that matter, then make it yours.',
     ['Hello', '→', 'Finish a dot', '→', 'Drag', '→', 'Type a task', '→', 'Make it yours'],
     ['<b>Motion:</b> the target pulses; the dot fills with its colour as you tap; a hand shows the drag; your typing appears; the sample sweeps away.',
      '<b>Changes from today:</b> the habits and layout steps go; you learn Done, drag and quick add (R-04, R-06) before any set-up. Only Wake Up and Wind Down are asked.',
      '<b>Feels like:</b> the app already works for you in 30 seconds.'],
     [fr(B1(), '1 · Hello', 'One promise, one button. Sign in stays one tap away.'),
      fr(B2(), '2 · Tap a dot', 'Coffee pulses, then fills: the first win.'),
      fr(B3(), '3 · Drag into the gap', 'The hand shows the move; Walk slides up into the free hour.'),
      fr(B4(), '4 · Say it', '“call Sam 6pm” types itself; the time is read as you type.'),
      fr(B5(), '5 · Make it yours', 'The sample sweeps off; set your two ends of the day.')]),
 opt('C · Pick your rhythm', tag('tn', '4 screens · bold and visual') + tag('tn', 'Motion: ring, morph, live nudge'),
     'Big, swipeable choices instead of forms: your rhythm as a 24-hour ring, the layout as a live morph, one real-looking nudge.',
     ['Rhythm', '→', 'How much to see', '→', 'Nudge', '→', 'Welcome'],
     ['<b>Motion:</b> the 24-hour ring turns as you swipe cards; the preview morphs between Everything and Less; a real notification slides in; the ring shrinks into the day dot.',
      '<b>Changes from today:</b> day shape becomes four rhythm cards (with “My own” for exact times); Layout shows a live preview; habits move to the first Today as suggestions.',
      '<b>Feels like:</b> choosing, not configuring.'],
     [fr(C1(), '1 · What’s your rhythm?', 'Stacked cards; the awake arc of the ring swings as you swipe.'),
      fr(C2(), '2 · How much to see', 'The preview cross-fades between the full thread and the Now ring.'),
      fr(C3(), '3 · A tap before each task?', 'A sample notification slides down so you see what you say yes to.'),
      fr(C4(), '4 · Welcome', 'The ring closes into the day dot, then Today opens.')]),
 opt('D · Say your day', tag('tn', '4 screens · voice or text') + tag('tn', 'Motion: waveform, words become dots'),
     'Tell it your day in one sentence. The words light up, become chips, then a proposed thread you accept.',
     ['Tell me', '→', 'I heard', '→', 'Is this your day?', '→', 'Drawn'],
     ['<b>Motion:</b> a live waveform while you speak; the times and tasks in your sentence highlight one by one and rise as chips; proposed dots are dashed until you say yes.',
      '<b>Rules kept:</b> it is a proposal (ProposalSheet rule: nothing saved before “Yes”); the sentence is read on the device by the built parser, nothing is sent off it. Spoken input needs the system’s on-device speech; typing always works.',
      '<b>Feels like:</b> talking to a planner, not setting one up.'],
     [fr(D1(), '1 · Tell me about your day', 'Hold to talk, or type. The waveform moves with your voice.'),
      fr(D2(), '2 · I heard', 'Times and tasks highlight in the sentence and rise as chips.'),
      fr(D3(), '3 · Is this your day?', 'Dashed “new” dots: a proposal. Yes writes it; Change edits.'),
      fr(D4(), '4 · Drawn', 'The Add button keeps listening the same way later.')]),
 opt('E · Sunrise, sunset', tag('tn', '4 screens · immersive') + tag('tn', 'Motion: the sky changes with you'),
     'Set your day on a living sky: drag the sun up for Wake Up, the moon down for Wind Down; the horizon becomes your thread.',
     ['Good morning', '→', 'Sunrise', '→', 'Sunset', '→', 'Your day'],
     ['<b>Motion:</b> the sky gradient shifts from night to day as the sun rises; stars appear at dusk; the horizon folds into the vertical thread with the two end dots.',
      '<b>Changes from today:</b> Wake Up and Wind Down are the whole set-up; habits, nudges and layout are asked in context later (first Today, first task start, Settings).',
      '<b>Feels like:</b> calm and memorable, a strong first impression.'],
     [fr(E1(), '1 · Good morning', 'The sun waits on the horizon; the sky is still dawn.'),
      fr(E2(), '2 · Drag the sun', 'As it rises the sky brightens; the time reads out large.'),
      fr(E3(), '3 · Drag the moon', 'Night sky with stars; awake time and sleep show live.'),
      fr(E4(), '4 · Your day', 'The horizon becomes the thread between your two dots.')]),
 opt('F · Swipe to set up', tag('tn', '5 cards · ~20 s') + tag('tn', 'Motion: cards fling, progress fills'),
     'A deck of five yes / skip cards with sensible defaults. Swipe right to keep, left to skip; a summary at the end.',
     ['Hello card', '→', 'Day', '→', 'Habits', '→', 'Nudges', '→', 'Layout', '→', 'All set'],
     ['<b>Motion:</b> each card flings off with a tilt; the next rises; the top progress bar fills; buttons mirror the swipe for anyone who can’t swipe (and for screen readers).',
      '<b>Changes from today:</b> every step becomes one default you accept or skip; nothing to type. The last card summarises, and all of it stays editable in Settings.',
      '<b>Feels like:</b> fast and playful; the shortest path to Today.'],
     [fr(F1(), '1 · Five quick cards', 'A practice card teaches the swipe.'),
      fr(F2(), '2 · Your day', 'Default 7:00 to 11:00 PM; tap a time to change it.'),
      fr(F3(), '3 · A few habits', 'Three suggestions on tomorrow; skip if you’d rather not.'),
      fr(F4(), '4 · Nudges', 'A real-looking notification on the card.'),
      fr(F5(), '5 · All set', 'A plain summary of the five answers.')]),
]
notes = ['<b>New proposals, not decisions.</b> R2-16 (the built flow drawn in E) is unchanged on its own board. Pick one, mix parts, or ask for changes; nothing is built until you approve.',
         '<b>All three keep what the app needs:</b> the 13+ age note on the first screen, Wake Up and Wind Down, an optional account, and the Full / Minimal choice (asked or deferred). New copy is marked for your review.',
         '<b>Motion plays on this board</b> (loops). Every motion stops under Reduce Motion and is replaced by the end state; nothing flashes; durations 200–600 ms in the app.',
         '<b>Other widths:</b> Android uses the same screens with its own controls; tablets, Mac and web show them in a centred column, as on R2-16.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 36px; line-height: 42px; font-weight: 800; letter-spacing: -0.8px;">E · Onboarding · six new directions</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Your request: a creative redesign of the first thing people see, with a different flow from today’s, crisp, modern and with motion. Six options for you to compare (D, E and F added at your request). iPhone shown at 50 %%. Dark on E-Onboarding-Options-Dark.</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s') % (tag('th', 'Options · for owner decision'), tag('tn', 'Light'), li, '\n'.join(rows))
helmet = AB['helmet'].replace('</style>', CSS + '</style>', 1)
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · Onboarding options</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + helmet
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 40px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
assert CSS.strip()[:20] in page.replace('@@','')
os.makedirs('project', exist_ok=True)
page_out = re.sub(r'@@([0-9A-Fa-f]{6})@@', r'#\1', page)
open('project/E-Onboarding-Options.dc.html', 'w', encoding='utf-8').write(page_out)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · Onboarding options</title>', '<title>E · Onboarding options · Dark</title>').replace('Dark on E-Onboarding-Options-Dark.', 'Light on E-Onboarding-Options.').replace('<span class="tn">Light</span>', '<span class="tn">Dark</span>')
dark = re.sub(r'@@([0-9A-Fa-f]{6})@@', r'#\1', dark).replace('background: rgba(250,247,242,.95);', 'background: rgba(43,38,42,.95); color: #F3ECE4;')
dark = dark.replace('height: 48px; background: #A3E2D9; color: #A3E2D9;">Make it my day', 'height: 48px; background: #11615C; color: #FFFFFF;">Make it my day')  # coach card is light in dark
open('project/E-Onboarding-Options-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
