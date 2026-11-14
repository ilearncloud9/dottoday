# R2-23 · Proposal flows (ED-323): Break it down, Smallest step and Unstick, Help with thinking (on-device status),
# Reality thread. Built strings only (app_en.arb); docs/11 B1-B3, A3; docs/09 M10.6, M10.7, M14.2.
_p = open(os.path.join(HERE, '..', 'r222', 'page222.py'), encoding='utf-8').read()
exec(_p[:_p.index('# ---------------------------------------------------------------- 1 · Routines (11 C2)')])
exec(open(os.path.join(HERE, 'frames.py'), encoding='utf-8').read())
# From R2-21 (approved): the Data and privacy rows and the page-text style.
def drows():
    return [irow('teal', SYNC_I, 'Sync', value='Synced'), irow('violet', CAL_I, 'Calendars', sub='Events on your timeline'),
            irow('teal', SHARE_I, 'Export', sub='Your data, free to take'), irow('grey', TRASH_I, 'Trash', sub='Deleted tasks stay 30 days')]
def pt(t): return '<div style="padding: 10px 20px 0; font-size: 13px; line-height: 18px; color: #6A6273;">%s</div>' % t
ANF = 'Roboto, system-ui, sans-serif'
SORT_I = '<path d="M4 6h16M4 12h10M4 18h6"></path>'
GRIP_I = '<circle cx="9" cy="6" r="1.2" fill="currentColor"></circle><circle cx="15" cy="6" r="1.2" fill="currentColor"></circle><circle cx="9" cy="12" r="1.2" fill="currentColor"></circle><circle cx="15" cy="12" r="1.2" fill="currentColor"></circle><circle cx="9" cy="18" r="1.2" fill="currentColor"></circle><circle cx="15" cy="18" r="1.2" fill="currentColor"></circle>'
ARROW_I = '<path d="M5 12h14M13 6l6 6-6 6"></path>'
DOWN_I = '<path d="M6 9l6 6 6-6"></path>'
SHIELD_I = '<path d="M12 3l8 3v6c0 4.5-3.4 8.2-8 9-4.6-.8-8-4.5-8-9V6z"></path>'
DOC_I = '<path d="M7 3h7l5 5v13H7z"></path><path d="M14 3v5h5M10 13h6M10 17h6"></path>'
INK, MUT, TEAL_D = '#241F2B', '#6A6273', '#11615C'


def mins(m): return '%d min' % m if m < 60 else ('%d h' % (m // 60) if m % 60 == 0 else '%d h %d' % (m // 60, m % 60))


def chip(t, f, bg='#E2EFEC', fg='#0B4642'):
    return '<span style="display: inline-flex; align-items: center; height: 24px; padding: 0 10px; border-radius: 12px; background: %s; color: %s; font: 700 12px %s; white-space: nowrap;">%s</span>' % (bg, fg, f, t)


# ---------------------------------------------------------------- 1 · Break it down (11 B1)
TASK, DAYT, COLR = 'Write the Q4 report', 'Wed 4 Nov 2:00–4:00 PM', IND
STEPS = [('Gather the numbers', 20), ('Outline the sections', 25), ('Write the draft', 75), ('Read it through', 15)]


def seg_ring(n, share, col, d=30):
    return ring(d, share, col, w=3.5, inner='<span class="num" style="font: 800 12px Manrope; color: %s;">%d</span>' % (INK, n))


def step_row(n, title, m, total, f, col=COLR, empty=False, open_=False, depth=0):
    t = ('<span style="color: #8A8494;">Step %d</span>' % n) if empty else title
    length = chip(mins(m), f, '#ECE5DC', '#4E4757') if m else chip('+ time', f, '#ECE5DC', '#4E4757')
    pad = 14 + depth * 30
    lead = (seg_ring(n, m / total, col) if depth == 0 else '<span aria-hidden="true" style="width: 12px; height: 12px; margin: 0 9px; border-radius: 50%%; box-shadow: inset 0 0 0 2.5px %s; flex: none;"></span>' % col)
    return ('<div role="listitem" style="display: flex; align-items: center; gap: 8px; min-height: 52px; padding-left: %dpx; box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);">'
            '<span role="button" aria-label="Reorder %s" style="width: 22px; height: 44px; display: flex; align-items: center; justify-content: center; color: #A39BAA; flex: none;">%s</span>%s'
            '<span role="textbox" aria-label="Step %d" style="flex: 1; min-width: 0; font: 600 15px/20px %s; color: %s; padding: 2px 0; border-bottom: 1px dashed rgba(36,31,43,.18);">%s</span>%s'
            '<span role="button" aria-label="More for %s" style="width: 40px; height: 44px; display: flex; align-items: center; justify-content: center; color: #6A6273; flex: none;">%s</span></div>') % (
        pad - 14 + 4, title or 'Step %d' % n, sv(GRIP_I, 16), lead, n, f, INK, t, length, title or 'Step %d' % n, sv(DOWN_I if not open_ else '<path d="M6 15l6-6 6 6"></path>', 16))


def add_step(f):
    return ('<div role="button" style="margin: 10px 12px 12px; height: 44px; border-radius: 22px; border: 1.5px dashed #C9C1CF; display: flex; align-items: center; justify-content: center; gap: 6px; font: 700 14px %s; color: #0B4642;">%sAdd a step</div>') % (f, sv(PLUS, 16))


def bd_open(f):
    subs = [('Intro and summary', 15), ('Numbers by team', 45), ('Next quarter', 15)]
    inner = ''.join(step_row(3, t, m, 75, f, depth=1) for t, m in subs)
    return ('<div style="background: #F6F1EA;">%s<div style="display: flex; align-items: center; gap: 8px; padding: 8px 14px 10px 48px;"><span style="font: 600 12px %s; color: #6A6273; flex: 1;">depth 2 of 3</span>'
            '<span role="button" style="height: 34px; padding: 0 12px; border-radius: 17px; background: #FFFDF9; box-shadow: inset 0 0 0 1px #DDD7E0; display: flex; align-items: center; font: 700 13px %s; color: #0B4642;">Break this down</span>'
            '<span role="button" style="height: 34px; padding: 0 12px; border-radius: 17px; display: flex; align-items: center; font: 700 13px %s; color: #4E4757;">Remove step</span></div></div>') % (inner, f, f, f)


def bd_body(f, rows_html, total, before, origin, hint=None, can_accept=True, title_sz=24):
    hint_html = ''
    if hint:
        hint_html = ('<div style="margin-top: 10px; border-radius: 16px; background: #F6F1EA; padding: 10px 12px; display: flex; align-items: center; gap: 10px;"><span role="button" style="flex: 1; font: 600 13px/18px %s; color: #0B4642;">%s</span>'
                     '<span role="button" style="font: 700 12.5px %s; color: #4E4757; white-space: nowrap;">Don\'t show again</span></div>') % (f, hint, f)
    lead_len = mins(total) if total == before else 'was %s → now %s' % (mins(before), mins(total))
    lead = ('<div style="display: flex; align-items: center; gap: 12px; padding: 12px 14px; box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);"><span style="width: 34px; height: 34px; border-radius: 50%%; box-shadow: inset 0 0 0 3px %s; flex: none; color: %s; display: flex; align-items: center; justify-content: center;">%s</span>'
            '<span style="flex: 1; min-width: 0;"><span style="display: block; font: 800 16px Manrope;">%s</span><span class="num" style="display: block; font: 500 12.5px %s; color: #6A6273;">%s · %s</span></span></div>') % (
        COLR, COLR, sv(DOC_I, 17), TASK, f, DAYT, lead_len)
    pic = ('<span aria-hidden="true" style="display: flex; align-items: center; gap: 6px; flex: none;"><span style="width: 18px; height: 18px; border-radius: 50%%; box-shadow: inset 0 0 0 2.5px %s88;"></span>%s<span style="width: %dpx; height: %dpx; border-radius: 50%%; box-shadow: inset 0 0 0 3px %s;"></span></span>') % (
        COLR, sv(ARROW_I, 12), 18 if total == before else 24, 18 if total == before else 24, COLR)
    acc = 'background: #11615C; color: #fff;' if can_accept else 'background: #E4DED6; color: #8A8494;'
    return ('<div style="display: flex; align-items: center; gap: 10px; margin-top: 12px;"><div style="flex: 1; min-width: 0; display: flex; align-items: center; gap: 8px;"><span role="heading" style="font: 800 %dpx/30px Manrope, system-ui;">Break it down</span>%s</div>'
            '<button aria-label="Close" style="width: 44px; height: 44px; border: 0; background: transparent; display: flex; align-items: center; justify-content: center;"><span style="width: 32px; height: 32px; border-radius: 50%%; background: #ECE5DC; color: #4E4757; display: flex; align-items: center; justify-content: center;">%s</span></button></div>%s'
            '<div style="margin-top: 10px; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); overflow: hidden;">%s<div role="list">%s</div>%s</div>'
            '<div style="display: flex; align-items: center; gap: 10px; margin: 12px 4px 0;">%s<span class="num" style="font: 600 13.5px %s; color: #4E4757;">Total %s · the dot grows to fit</span></div>'
            '<div style="margin: 6px 4px 0; font: 500 12.5px/17px %s; color: #6A6273;">You\'ll be asked for the first step only if this stays unstarted (Smallest step)</div>'
            '<button style="margin-top: 14px; width: 100%%; height: 54px; border: 0; border-radius: 27px; %s display: flex; align-items: center; justify-content: center; font: 800 17px Manrope, system-ui;">Accept</button>'
            '<button style="display: block; margin: 4px auto 0; height: 44px; padding: 0 16px; border: 0; background: transparent; color: #11615C; font: 700 15px %s;">Discard</button>'
            '<div style="text-align: center; font: 600 12.5px %s; color: #6A6273;">Nothing is saved until you accept</div>') % (
        title_sz, chip(origin, f), sv(X_I, 16), hint_html, lead, rows_html, add_step(f), pic, f, mins(total), f, acc, f, f)


TOT = sum(m for _, m in STEPS)
MODEL_ROWS = lambda f: ''.join(step_row(i + 1, t, m, TOT, f) for i, (t, m) in enumerate(STEPS))
OPEN_ROWS = lambda f: (''.join(step_row(i + 1, t, m, TOT, f, open_=(i == 2)) + (bd_open(f) if i == 2 else '') for i, (t, m) in enumerate(STEPS)))
RULE_ROWS = lambda f: ''.join(step_row(i + 1, '', 40, 120, f, empty=True) for i in range(3))
# Entry: the approved editor (G2-5 D) with no steps yet; Break it down sits in the Steps header (sheet_subtasks.dart).
EMPTY = (EP_EMPTY.replace('Call the dentist', TASK).replace('2:00–2:20 PM', '2:00–4:00 PM').replace('2:00 – 2:20 PM', '2:00 – 4:00 PM').replace('>20 min<', '>2 h<')
         .replace('<span>Steps</span></div>', '<span>Steps</span><span role="button" style="display: inline-flex; align-items: center; gap: 5px; color: #11615C; font: 700 14px -apple-system, system-ui; margin: -4px 0;">%sBreak it down</span></div>' % sv(SORT_I, 15), 1))
assert 'Break it down' in EMPTY and TASK in EMPTY
I_BD = big_sheet(EMPTY, bd_body(IOSF, MODEL_ROWS(IOSF), TOT, 120, 'on-device'), 50)
I_BD_OPEN = big_sheet(EMPTY, bd_body(IOSF, OPEN_ROWS(IOSF), TOT, 120, 'on-device'), 50)
I_BD_RULES = big_sheet(EMPTY, bd_body(IOSF, RULE_ROWS(IOSF), 120, 120, 'simple rules', 'Made with simple rules · Turn on Apple Intelligence for smarter plans', False), 50)
A_BD = big_sheet(EP_ASHEET, bd_body(ANF, MODEL_ROWS(ANF), TOT, 120, 'on-device', title_sz=22).replace("-apple-system, 'SF Pro Text', system-ui, sans-serif", ANF), 44, 28)
LENGTH = ('<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08), 0 12px 30px rgba(36,31,43,.12); padding: 16px; width: 300px; box-sizing: border-box;">'
          '<div style="font: 700 16px %s;">How long is this step?</div><div style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 12px;">%s</div>'
          '<div role="button" style="margin-top: 10px; height: 44px; display: flex; align-items: center; font: 600 15px %s; color: #4E4757;">No time</div></div>') % (
    IOSF, ''.join('<span role="button" style="height: 40px; padding: 0 14px; border-radius: 20px; display: flex; align-items: center; font: 700 14px %s; %s">%s</span>' % (
        IOSF, 'background: #11615C; color: #fff;' if m == 20 else 'background: #ECE5DC; color: #241F2B;', mins(m)) for m in (5, 10, 15, 20, 30, 45, 60)), IOSF)
ADD_BD = ('<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 16px; width: 340px; box-sizing: border-box; font-family: %s;">'
          '<div style="font: 600 13px %s; color: #6A6273;">What is it?</div><div style="margin-top: 6px; font: 700 20px Manrope; border-bottom: 2px solid #11615C; padding-bottom: 6px;">Write the Q4 report</div>'
          '<div role="button" style="margin-top: 10px; height: 44px; display: inline-flex; align-items: center; gap: 6px; color: #11615C; font: 700 15px %s;">%sBreak it down</div>'
          '<div style="margin-top: 4px; display: flex; align-items: center; gap: 8px;">%s</div></div>') % (IOSF, IOSF, IOSF, sv(SORT_I, 16), chip('4 steps · saved with the task', IOSF))
HINT_BD = ('<div style="width: 340px; border-radius: 20px; background: #F6F1EA; padding: 12px 14px; font-family: %s;"><div style="font: 600 15px %s; color: #241F2B;">Break it into steps?</div>'
           '<div style="display: flex; gap: 8px; margin-top: 10px;"><span role="button" style="height: 40px; padding: 0 16px; border-radius: 20px; background: #11615C; color: #fff; display: flex; align-items: center; font: 700 14px %s;">Show me</span>'
           '<span role="button" style="height: 40px; padding: 0 16px; border-radius: 20px; display: flex; align-items: center; font: 700 14px %s; color: #0B4642;">Not now</span></div></div>') % (IOSF, IOSF, IOSF, IOSF)


def window(w, h, left, right_w, right, label_):
    return ('<div role="img" aria-label="%s" style="position: relative; width: %dpx; height: %dpx; border-radius: 14px; overflow: hidden; background: #FBF7F1; box-shadow: 0 0 0 1px rgba(36,31,43,.14), 0 20px 50px rgba(36,31,43,.12); font-family: system-ui;">'
            '<div style="height: 38px; display: flex; align-items: center; gap: 8px; padding: 0 14px; box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.12);"><span style="width: 12px; height: 12px; border-radius: 50%%; background: #EC6A5E;"></span><span style="width: 12px; height: 12px; border-radius: 50%%; background: #F4BF4F;"></span><span style="width: 12px; height: 12px; border-radius: 50%%; background: #61C554;"></span></div>'
            '<div style="position: absolute; top: 38px; left: 0; right: %dpx; bottom: 0; padding: 24px 28px; opacity: .55;">%s</div>'
            '<div role="dialog" style="position: absolute; top: 38px; right: 0; bottom: 0; width: %dpx; box-sizing: border-box; padding: 4px 20px 16px; background: #FBF7F1; box-shadow: -1px 0 0 rgba(36,31,43,.12), -16px 0 40px rgba(36,31,43,.10); overflow: hidden;">%s</div></div>') % (
        label_, w, h, right_w, left, right_w, right)


def wide_day():
    rows = [('1:00–1:45 PM', 'Lunch', PNK, True), ('2:00–4:00 PM', TASK, IND, False), ('4:30–5:00 PM', 'Inbox zero', BLU, False), ('6:00–7:00 PM', 'Gym', VIO, False)]
    return ('<div style="font: 800 28px Manrope;">Wednesday 4 November</div><div style="margin-top: 18px; display: flex; flex-direction: column; gap: 6px;">%s</div>') % ''.join(
        '<div style="display: flex; align-items: center; gap: 14px; height: 56px; padding: 0 14px; border-radius: 18px; background: %s;"><span style="width: 30px; height: 30px; border-radius: 50%%; %s"></span><span><span class="num" style="display: block; font: 500 13px system-ui; color: #6A6273;">%s</span><span style="display: block; font: 700 16px Manrope;">%s</span></span></div>' % (
            '#FFFDF9' if t == TASK else 'transparent', ('background: %s;' % c) if d else ('box-shadow: inset 0 0 0 3px %s;' % c), tm, t) for tm, t, c, d in rows)


W_BD = window(1180, 760, wide_day(), 440, bd_body('system-ui', MODEL_ROWS('system-ui'), TOT, 120, 'on-device'), 'Mac and web: Break it down as a panel beside the day')

# ---------------------------------------------------------------- 2 · Smallest step and Unstick (11 B2, B3)
SMALL_T = "Just Pull last quarter's notes · 15 min?"
SMALL = ('<div style="flex-basis: 100%%; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; padding: 6px 8px 2px 58px;"><span style="font: 600 14px/19px -apple-system, system-ui; color: #0B4642;">%s</span>'
         '<span role="button" style="height: 34px; padding: 0 14px; border-radius: 17px; background: #CFE8E4; color: #062F2C; display: flex; align-items: center; font: 700 14px -apple-system, system-ui;">Start</span></div>') % SMALL_T
_live_end = '<span style="width: 28px; height: 28px; border-radius: 50%; box-shadow: inset 0 0 0 2.5px #5B5FD6;"></span></button>\n   </div>'


def with_small(fr, f):
    assert fr.count(_live_end) == 1
    fr = fr.replace('display: flex; align-items: center; padding: 8px 0 8px 10px;">', 'display: flex; flex-wrap: wrap; align-items: center; padding: 8px 0 10px 10px;">', 1)
    return fr.replace(_live_end, _live_end[:-6] + SMALL.replace('-apple-system, system-ui', f) + '</div>', 1)


I_SMALL = with_small(EP_TODAY, '-apple-system, system-ui')
UNSTICK = ('<div style="position: relative; padding: 0 16px 8px 78px;"><span aria-hidden="true" style="position: absolute; left: 42px; top: 0; bottom: 0; width: 0; border-left: 4px dotted #BEB6C7;"></span>'
           '<div style="font: 500 13.5px/18px -apple-system, system-ui; color: #6A6273;">What\'s the very first thing you\'d physically do?</div>'
           '<div style="display: flex; align-items: center; gap: 4px; margin-top: 4px;"><span role="textbox" style="flex: 1; height: 38px; display: flex; align-items: center; font: 400 16px -apple-system, system-ui; color: #8A8494; border-bottom: 1.5px solid #C9C1CF;">e.g. Open the folder</span>'
           '<span role="button" aria-label="Make it step 1" style="width: 44px; height: 44px; display: flex; align-items: center; justify-content: center; color: #0B4642;">%s</span></div></div>') % sv(ARROW_I, 20)
_parcel = None  # set from the frame: the end of the Call with Sam row


def with_unstick(fr):
    i = fr.index('>Call with Sam</div>')
    k = fr.index('<!--', i)
    return fr[:k] + UNSTICK.replace('border-left: 4px dotted #BEB6C7;', 'border-left: 4px solid #2A9D8F;') + fr[k:]


I_UNSTICK = with_unstick(EP_TODAY)
I_UNSTICK_DONE = with_toast(EP_TODAY.replace('10:30–11:00 AM</div>', '10:30–11:00 AM · 0 of 1</div>', 1), 'Step 1 added to Call with Sam', 'Undo')
I_SMALL_NOTE = ios_lock('9:10', 'Tuesday 3 November', ios_note(SMALL_T.replace("'", '&#39;'), 'Deep work: roadmap', 'now'), 330)
A_SMALL = with_small(EP_ATODAY, 'Roboto, system-ui') if EP_ATODAY.count(_live_end) == 1 else None
WEEKCARD = ('<div style="width: 200px; border-radius: 16px; background: #E8E7FA; padding: 10px 12px; font-family: %s;"><div class="num" style="font: 600 12px %s; color: #4B3FB0;">9:00–11:00</div><div style="font: 800 14px/18px Manrope; color: #241F2B;">Deep work: roadmap</div>'
            '<div role="button" style="margin-top: 6px; font: 600 12px/16px %s; color: #0B4642;">Just Pull last quarter\'s notes · 15 min?</div></div>') % (IOSF, IOSF, IOSF)

# ---------------------------------------------------------------- 3 · Help with thinking: the on-device model, per platform (M14.2)
BODY_T = "Break it down and suggestions are worked out on this device: Apple Intelligence on iPhone and Mac, Gemini Nano on Android, the browser's built-in model in Chrome. Where none is available, Dottoday uses your own history and simple rules. What you type is never sent to a server; what was asked and answered stays on this device."


def ptitle(t, f=IOSF): return '<div style="padding: 18px 20px 4px; font: 700 17px %s; color: #241F2B;">%s</div>' % (f, t)
def ptext(t, f=IOSF, c='#4E4757'): return '<div style="padding: 0 20px; font: 400 15px/21px %s; color: %s;">%s</div>' % (f, c, t)
def obtn(t, f=IOSF): return '<div style="padding: 10px 20px 0;"><span role="button" style="display: inline-flex; height: 40px; padding: 0 16px; border-radius: 20px; box-shadow: inset 0 0 0 1.5px #C9C1CF; align-items: center; font: 600 15px %s; color: #11615C;">%s</span></div>' % (f, t)
def statusline(t, f=IOSF): return '<div style="margin: 10px 16px 0; border-radius: 16px; background: #E2EFEC; padding: 12px 14px; font: 600 14.5px/20px %s; color: #0B4642;">%s</div>' % (f, t)


IDP2 = withbar(ipage('Data and privacy', 'Settings', igroup(drows(), 'Data') + igroup([irow('violet', SHIELD_I, 'Privacy', sub='Help with thinking')], 'Privacy')))
PRIV_TOP = (ptitle('On your device') + ptext('Tasks are stored encrypted on this device, and the app works fully offline.') + ptitle('No tracking') + ptext('No ads, no analytics, no third-party trackers.')
            + ptitle('When you sign in') + ptext('Sync sends your tasks over an encrypted connection to your own account, and nowhere else.'))
def thinking_block(status, f=IOSF, opens=False, ios=False):
    return (ptitle('Help with thinking', f) + ptext(BODY_T, f) + statusline(status, f) + (obtn('Open Settings', f) if opens else '')
            + (('<div style="padding: 8px 20px 0; font: 400 13px/18px %s; color: #6A6273;">Opens Dottoday&#39;s page in Settings. Apple doesn&#39;t let apps open Apple Intelligence directly: go back to Settings, then Apple Intelligence &amp; Siri.</div>' % f) if ios else '')
            + obtn('Clear thinking history', f))
I_PRIV = withbar(ipage('Privacy', 'Data and privacy', PRIV_TOP[:PRIV_TOP.index(ptitle('No tracking'))] + thinking_block('Turn on Apple Intelligence in iPhone Settings › Apple Intelligence &amp; Siri. Dottoday will use it automatically.', opens=True, ios=True)))
I_PRIV_DONE = with_toast(withbar(ipage('Privacy', 'Data and privacy', PRIV_TOP + thinking_block('On this device now: the built-in model.'))), 'Thinking history cleared')
A_PRIV = withbar(apage('Privacy', thinking_block("Gemini Nano is downloading on this phone. Dottoday will use it once it&#39;s ready.", ANF).replace('padding: 18px 20px 4px', 'padding: 8px 16px 4px', 1)), True)
STATES = [('Available', 'All', 'On this device now: the built-in model.'),
          ('Off', 'iPhone', 'Turn on Apple Intelligence in iPhone Settings › Apple Intelligence &amp; Siri. Dottoday will use it automatically. <b>+ Open Settings</b>'),
          ('Off', 'Mac', 'Turn on Apple Intelligence in System Settings › Apple Intelligence &amp; Siri. Dottoday will use it automatically. <b>+ Open Settings</b>'),
          ('Getting ready', 'iPhone, Mac', 'Apple Intelligence is getting ready on this device. It can take a while.'),
          ('Can download', 'Android', 'Gemini Nano can be downloaded on this phone; it downloads in the background.'),
          ('Downloading', 'Android', "Gemini Nano is downloading on this phone. Dottoday will use it once it&#39;s ready."),
          ('Can download', 'Chrome', "This browser can download its built-in AI model. Dottoday will use it once it&#39;s there."),
          ('Downloading', 'Chrome', "This browser is downloading its built-in AI model. Dottoday will use it once it&#39;s ready."),
          ('Not possible', 'All', "This device can&#39;t run the built-in model. Dottoday uses your history and simple rules."),
          ('No model', 'Other browsers, unknown', 'On this device now: your history and simple rules.')]
STATE_TABLE = ('<div style="width: 900px; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); overflow: hidden;">%s</div>') % ''.join(
    '<div style="display: grid; grid-template-columns: 140px 190px 1fr; gap: 14px; padding: 12px 18px; box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10); font: 500 14px/20px Manrope;"><span style="font-weight: 800;">%s</span><span style="color: #6A6273;">%s</span><span>%s</span></div>' % s for s in STATES)
HINTS = ['Made with simple rules · Turn on Apple Intelligence for smarter plans', 'Made with simple rules · Apple Intelligence is getting ready for smarter plans',
         "Made with simple rules · Gemini Nano makes smarter plans once it&#39;s on this phone", "Made with simple rules · Your browser&#39;s built-in AI makes smarter plans once it&#39;s ready"]
HINT_LIST = '<div style="display: flex; flex-direction: column; gap: 8px; width: 420px;">%s</div>' % ''.join(
    '<div style="border-radius: 16px; background: #F6F1EA; padding: 10px 12px; font: 600 13px/18px %s; color: #0B4642;">%s</div>' % (IOSF, h) for h in HINTS)
DUMP_LIST = '<div style="display: flex; flex-direction: column; gap: 6px; width: 420px;">%s</div>' % ''.join(
    chip(t, IOSF, '#ECE5DC', '#4E4757') for t in ['Plans with Apple Intelligence on this device', 'Plans with Gemini Nano on this phone', "Plans with your browser&#39;s built-in AI, on this device", 'Plans with simple rules'])

# ---------------------------------------------------------------- 4 · Reality thread (11 A3)
_tip = EP_TODAY[EP_TODAY.index('  <!-- one tip -->'):EP_TODAY.index('  <!-- thread -->')]


def tipslot(inner): return '  <div style="position: absolute; top: 192px; left: 16px; right: 16px; height: 40px; display: flex; align-items: center;">%s</div>\n' % inner


CAPTION = ('<div style="flex: 1; height: 40px; border-radius: 20px; background: #F6F1EA; display: flex; align-items: center; padding-left: 16px; font: 600 13px -apple-system, system-ui; color: #241F2B;"><span style="flex: 1;">Your reality thread appears after about 10 finished tasks · 6 so far</span>'
           '<span role="button" aria-label="Hide until tomorrow" style="width: 44px; height: 44px; display: flex; align-items: center; justify-content: center; color: #6A6273;">%s</span></div>') % sv(X_I, 14)
SEG = ('<div role="radiogroup" aria-label="Plan or reality" style="display: flex; padding: 3px; border-radius: 20px; background: #ECE5DC; width: 220px;">'
       '<span role="radio" aria-checked="false" style="flex: 1; height: 34px; border-radius: 17px; display: flex; align-items: center; justify-content: center; font: 600 14px -apple-system, system-ui; color: #4E4757;">Plan</span>'
       '<span role="radio" aria-checked="true" style="flex: 1; height: 34px; border-radius: 17px; display: flex; align-items: center; justify-content: center; gap: 5px; font: 700 14px -apple-system, system-ui; background: #FFFDF9; box-shadow: 0 1px 3px rgba(36,31,43,.14); color: #241F2B;">%sReality</span></div>') % sv(CHECK, 13, 2.6)
I_PENDING = EP_TODAY.replace(_tip, tipslot(CAPTION), 1)


def ghost(top):
    return '<span aria-hidden="true" style="position: absolute; left: 33px; top: %dpx; width: 22px; height: 22px; border-radius: 50%%; box-shadow: inset 0 0 0 2px rgba(36,31,43,.22); background: transparent;"></span>' % top


REAL = [('6:45–7:30 AM</div>', '6:50–7:40 AM · planned 6:45 AM · took 50 min</div>'),
        ('7:30–7:45 AM</div>', '7:40–7:55 AM · planned 7:30 AM · took 15 min</div>'),
        ('8:00–8:15 AM <svg', '8:00–8:20 AM · took 20 min <svg'),
        ('9:00–11:00 AM · <span style="color: #11615C; font-weight: 700;">Now, 18 min left</span>', '9:05 AM – now · planned 9:00–11:00 AM · 1 h 37 in · <span role="button" style="color: #11615C; font-weight: 700; text-decoration: underline dotted;">usually 2 h 20</span>'),
        ('10:30–11:00 AM</div>', '10:30–11:00 AM · not started yet</div>')]


def reality(fr):
    fr = fr.replace(_tip, tipslot(SEG), 1)
    for a, b in REAL:
        assert fr.count(a) == 1, a
        i = fr.index(a)
        j = fr.rfind('<div role="listitem" style="position: relative; height: ', 0, i)
        if j > fr.rfind('<!--', 0, i) - 400:  # plain rows only; the live card already grows
            fr = fr[:j] + fr[j:j + 60].replace('; height: ', '; padding: 4px 0; min-height: ', 1) + fr[j + 60:]
        fr = fr.replace(a, b, 1)
    fr = fr.replace('Hold a dot to select several tasks', '')
    insight = ('<div role="status" style="position: absolute; left: 16px; right: 16px; bottom: 106px; z-index: 30; border-radius: 20px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08), 0 10px 30px rgba(36,31,43,.14); padding: 12px 8px 12px 16px; display: flex; align-items: center; gap: 10px;">'
               '<span style="flex: 1; font: 600 14px/19px -apple-system, system-ui; color: #241F2B;">Deep work: roadmap usually takes you 2 h 20 · Add will suggest it</span>'
               '<span role="button" style="height: 40px; padding: 0 16px; border-radius: 20px; background: #E2EFEC; color: #0B4642; display: flex; align-items: center; font: 700 14px -apple-system, system-ui;">OK</span></div>')
    k = fr.rindex('</div>')
    return fr[:k] + insight + fr[k:]


I_REAL = reality(EP_TODAY)
EXPLAIN = ('<div style="width: 300px; border-radius: 18px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08), 0 12px 30px rgba(36,31,43,.14); padding: 14px 16px; font-family: %s;">'
           '<div style="font: 700 15px %s;">usually 2 h 20</div><div style="font: 400 14px/20px %s; color: #6A6273; margin-top: 2px;">based on your last 6 times · median</div>'
           '<div role="button" style="margin-top: 8px; min-height: 44px; display: flex; align-items: center; font: 600 15px %s; color: #11615C;">Reset for this task on this device</div></div>') % (IOSF, IOSF, IOSF, IOSF)
RESET = ios_alert('Forget what Deep work: roadmap taught, on this device?', '', 'Keep', 'Reset')
LEARN_ROWS = lambda ready: [irow('teal', '<path d="M4 19V9M10 19V5M16 19v-6M22 19H2"></path>', 'Reality thread', sub=("Ready · Plan / Reality is in Today&#39;s header" if ready else 'Dottoday is learning how your days really go. Your reality thread appears after about 10 finished tasks.'), value=(None if ready else '6/10'), chev=False),
                            irow('indigo', CLOCK, 'Task lengths', sub='Ready for 12 tasks', chev=False), irow('violet', SORT_I, 'Step lengths', sub='Ready for 5 steps', chev=False)]
LEARN_FOOT = 'Learning happens on your device. Your actual start and end times sync with your account like the rest of your plan; the learned numbers themselves are never uploaded.'
I_LEARN0 = withbar(ipage('Learn my day', 'Your day', igroup(LEARN_ROWS(False), 'Learning') + pt(LEARN_FOOT)))
R_TOASTS = [('Steps added to Write the Q4 report', 'Undo'), ('Step 1 added to Call with Sam', 'Undo'), ('Thinking history cleared', None), ('Learning for Deep work: roadmap reset on this device', None)]

# ---------------------------------------------------------------- page
def fcol(w, lab, fr, *n): return col(w, label(lab), fr, notes(*n))
def scaled(fr, w, h, sc): return '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>' % (w * sc + 14, h * sc + 14, w, h, sc, fr)
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start;">%s</div>' % ''.join(c)
stack = lambda *c: '<div style="display: flex; flex-direction: column; gap: 18px;">%s</div>' % ''.join(c)
s1 = (row(fcol(390, 'iPhone · the editor, no steps yet: Break it down', EMPTY, B('Built') + ' In the Steps header of the full sheet (sheet_subtasks.dart); in Show less, a Break it down button on the task sheet when there are no steps', D('Design-only') + ' The approved editor (G2-5 D, ED-086); the task is an example'),
          fcol(390, 'iPhone · the proposal (on-device model)', I_BD, B('Built') + ' Up to 5 steps from the model; each has a ring sized by its length, a title to edit, a length and More', B('Built') + ' The lead row says “was 2 h → now 2 h 15”; Total, then the Smallest step line', B('Rule') + ' Nothing is saved until Accept (ProposalSheet)'),
          fcol(390, 'iPhone · a step opened', I_BD_OPEN, B('Built') + ' Sub-steps, “depth 2 of 3”, Break this down and Remove step; saved as “Write the draft · Intro and summary”'),
          fcol(390, 'iPhone · no model: simple rules', I_BD_RULES, B('Built') + ' Three empty steps that split the length; Accept waits until each has a title', B('Built') + ' The hint opens Settings › Privacy; Don’t show again hides it')))
s1b = row(fcol(412, 'Android · the proposal', A_BD, B('Built') + ' The same sheet over the Android task screen'),
          col(1180 * .62 + 14, label('Mac and web · a panel beside the day'), scaled(W_BD, 1180, 760, .62), notes(B('Built') + ' At wide widths the proposal is a right-hand panel: Esc discards, focus stays inside it', B('Built') + ' From Add it stays a sheet')),
          stack(col(340, label('Length of a step'), LENGTH, notes(B('Built') + ' “How long is this step?”; “+ time” when a step has none')),
                col(340, label('In Add, before the task exists'), ADD_BD, notes(B('Built') + ' Off until there is a title; after Accept the steps wait on the draft and save with the task')),
                col(340, label('Show less: the reveal hint'), HINT_BD, notes(B('Built') + ' After saving a task over an hour with no steps; Show me opens Break it down'))))
s2 = (row(fcol(390, 'iPhone · Smallest step on the live task', I_SMALL, B('Built') + ' 10 min after the planned start, if no step is ticked and it has not started: “Just {first step} · {length}?” and Start, which opens Focus', B('Built') + ' In the accent, never a warning; it goes away by itself once a step is ticked, the task starts or its end passes'),
          fcol(390, 'iPhone · the same as a notification', I_SMALL_NOTE, B('Built') + ' Title “Just … · 15 min?”, the task underneath, one Start action; quiet hours keep it silent'),
          fcol(390, 'iPhone · Unstick under a task moved three times', I_UNSTICK, B('Built') + ' After three moves (drag, Running late, Rebalance) and no steps: one question and a field', B('Built') + ' Not a proposal: the answer is step 1 at once, with Undo'),
          fcol(390, 'iPhone · after Make it step 1', I_UNSTICK_DONE, B('Built') + ' Step 1 is written and the move count resets in one undoable change', D('Design-only') + ' “0 of 1” under the task'))
      + row(*([col(412 * .6 + 14, label('Android · Smallest step'), scaled(A_SMALL, 412, 892, .6), notes(B('Built') + ' The same line and Start'))] if A_SMALL else []),
            col(240, label('Week · the card’s last line'), WEEKCARD, notes(B('Built') + ' On tall cards: Smallest step opens Focus, Unstick opens the question in a sheet; on short cards it is a screen-reader action')),
            col(420, label('Neither shows'), notes(B('Built') + ' While the Reality thread is on', B('Built') + ' There is no dismiss: each one leaves when its reason does'))))
s3 = (row(fcol(390, 'iPhone · Settings › Data and privacy, with Privacy', IDP2, Q('Design choice') + ' A Privacy group under Data on the approved page (R2-21) holds the built Privacy page; the row and its subtitle are built strings'),
          fcol(390, 'iPhone · Help with thinking, Apple Intelligence off', I_PRIV, B('Built') + ' The paragraph, this device’s status, Open Settings (iPhone and Mac only) and its note, Clear thinking history', B('Built') + ' No switch in Dottoday: the model is used when the system has it'),
          fcol(390, 'iPhone · model on, history cleared', I_PRIV_DONE, B('Built') + ' “On this device now: the built-in model.”; the toast'),
          fcol(412, 'Android · Gemini Nano downloading', A_PRIV, B('Built') + ' Re-read each time the app comes back'))
      + row(col(900, label('Every status line (Settings › Privacy)'), STATE_TABLE, notes(B('Built') + ' Apple Foundation Models on iPhone and Mac, Gemini Nano on Android, Chrome’s built-in model on the web; anything else uses your history and simple rules')),
            stack(col(420, label('The hint on a rules answer'), HINT_LIST, notes(B('Built') + ' Only while the model is off, can download or is downloading')),
                  col(420, label('Brain dump’s caption'), DUMP_LIST, notes(B('Built') + ' Says what planned the dump')))))
s4 = (row(fcol(390, 'iPhone · Today, still learning', I_PENDING, B('Built') + ' Under 10 finished tasks with real start and end in 90 days; × hides it until tomorrow', B('Built') + ' Not in Show less or low-energy mode'),
          fcol(390, 'iPhone · Reality on', I_REAL, B('Built') + ' Plan | Reality in the day header, for this session; tasks sit where they really ran, with “planned …”, “took …”, “… in”, “usually …”, “not started yet”', B('Built') + ' Drag is off; the insight shows when the usual length differs from the plan by 15 min or more; OK hides it', D('Design-only') + ' The faint plan rings beside moved dots'),
          stack(col(300, label('Tap “usually 2 h 20”'), EXPLAIN, notes(B('Built') + ' How it was worked out; reset for this task')),
                col(300, label('Reset'), RESET, notes(B('Built') + ' Then “Learning for Deep work: roadmap reset on this device”'))),
          fcol(390, 'iPhone · Settings › Your day › Learn my day', I_LEARN0, B('Built') + ' Progress until the reveal; no switch'),
          )
      + row(col(390, label('Learn my day, after the reveal'), '<div style="width: 390px; margin: 0 -16px; font-family: -apple-system, system-ui;">%s</div>' % igroup(LEARN_ROWS(True), 'Learning'), notes(B('Built') + ' The first time, the header switch is highlighted once and reads “Plan and reality view is now in the day header”')),
            col(420, label('What the toasts say (the approved toast, R2-7)'), '<div style="display: flex; flex-direction: column; gap: 10px;">%s</div>' % ''.join(toast(t, a, 420) for t, a in R_TOASTS), notes(B('Built') + ' Break it down and Unstick write with Undo')),
            col(520, label('Elsewhere'), notes(B('Built') + ' Tablets: the R2-1 shell, sheets as on phones; the Reality switch in the day header', B('Built') + ' Mac and web: the same header switch on today’s card; Reality never appears on Week', P('Not drawn') + ' Android Reality and Learn my day: the same rows in M3'))))
RULES = [('Proposals before writes', 'Break it down is the one flow here that proposes: nothing is written before Accept (CLAUDE.md §11). Discard, ×, swipe down or Esc write nothing.'),
         ('Undo for the quiet ones', 'Unstick writes its one step with Undo; Smallest step only opens Focus; the reality insight writes nothing.'),
         ('On this device', 'The model runs on the device or not at all; what you type never leaves it (ADR-0009). No model means your history and simple rules.'),
         ('No shame', 'Smallest step and Unstick use the accent, never red; “not started yet”, never late or missed.'),
         ('Same everywhere (R-13)', 'Every flow on every platform; Mac and web show proposals as a side panel.'),
         ('Text from the app', 'Every string on this board is built (app_en.arb). Tasks, times and counts are examples. No new copy is proposed.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 · R2-23</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Proposal flows and learning</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">Break it down, Smallest step and Unstick, Help with thinking (the on-device model) and the Reality thread. Every platform; only what is built is drawn. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed · ED-323 · 14 Nov 2026'), tag('tn', 'iPhone, Android, iPad, Mac, web'), tag('tn', '@@THEME@@'))
page_body = (body + section('1 · Break it down', s1 + s1b) + section('2 · Smallest step and Unstick', s2) + section('3 · Help with thinking', s3) + section('4 · Reality thread', s4) + section('Rules', rules))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-23 · Proposal flows</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-23-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-23.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-23.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('class="blk-d', 'class="blk').replace('<title>E · R2-23 · Proposal flows</title>', '<title>E · R2-23 · Proposal flows · Dark</title>')
open('project/E-R2-23-Dark.dc.html', 'w', encoding='utf-8').write(dk)
print('ok', 'A_SMALL', bool(A_SMALL))
