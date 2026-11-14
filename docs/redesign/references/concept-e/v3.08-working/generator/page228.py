# R2-28 · Small states (gap pass): picking a day and no free slot, a quiet week, Search with no results, calendar access,
# export and import results, App lock after a failed try, missions a phone can't run. Built behaviour and strings only.
_p = open(os.path.join(HERE, '..', 'r227', 'page227.py'), encoding='utf-8').read()
exec(_p[:_p.rindex('# ---------------------------------------------------------------- page')])
SEARCH_I = '<circle cx="11" cy="11" r="7"></circle><path d="M20 20l-4-4"></path>'

# ---------------------------------------------------------------- 1 · Move to a day; no free slot
DOTS = {2: [COR, BLU, IND], 3: [COR, AMB, BLU, IND, PNK], 4: [BLU, IND], 5: [IND, PNK], 6: [VIO], 9: [BLU], 10: [IND, GRN], 12: [PNK], 17: [BLU, VIO]}


def month_dots(sel=5, today=3):
    head = ''.join('<span style="text-align: center; font: 600 12px %s; color: #6A6273;">%s</span>' % (IOSF, d) for d in 'MTWTFSS')
    cells = ['<span></span>'] * 6
    for d in range(1, 31):
        past = d < today
        st = ('background: #11615C; color: #fff;' if d == sel else ('box-shadow: inset 0 0 0 1.5px #11615C; color: #0B4642;' if d == today else ('color: #A39BAA;' if past else 'color: #241F2B;')))
        dots = ''.join('<span style="width: 5px; height: 5px; border-radius: 50%%; background: %s;"></span>' % c for c in DOTS.get(d, [])[:4])
        cells.append('<span role="button" aria-label="%d November%s" style="height: 48px; display: flex; flex-direction: column; align-items: center; gap: 3px;"><span class="num" style="width: 34px; height: 34px; border-radius: 17px; display: flex; align-items: center; justify-content: center; font: 700 15px Manrope; %s">%d</span><span style="display: flex; gap: 2px; height: 5px;">%s</span></span>' % (
            d, ', selected' if d == sel else '', st, d, dots))
    return ('<div style="display: flex; justify-content: space-between; align-items: center; margin: 12px 0 8px;"><span role="button" aria-label="Previous month" style="width: 44px; height: 44px; display: flex; align-items: center; justify-content: center; color: #11615C;">%s</span>'
            '<span style="font: 800 17px Manrope;">November 2026</span><span role="button" aria-label="Next month" style="width: 44px; height: 44px; display: flex; align-items: center; justify-content: center; color: #11615C;">%s</span></div>'
            '<div style="display: grid; grid-template-columns: repeat(7, 1fr); gap: 2px;">%s%s</div>') % (sv('<path d="M15 6l-6 6 6 6"></path>', 18), sv(CHEV, 18), head, ''.join(cells))


MOVE_SHEET = ('<div style="text-align: center; margin: 12px 0 4px; font: 600 17px %s;">Move to</div>%s') % (IOSF, month_dots())
I_MOVE = big_sheet(EP_SHEET, MOVE_SHEET, 330)
SCHED = ('<div style="text-align: center; margin: 12px 0 14px; font: 600 17px %s;">Schedule Buy a birthday gift</div>'
         '<div style="border-radius: 18px; background: #F6F1EA; padding: 14px 16px; font: 500 15px/21px %s; color: #4E4757;">No free slot today or tomorrow. Make room on Today, or drag it in from the week.</div>'
         '<div style="margin-top: 12px; border-radius: 18px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.06);"><div role="button" style="min-height: 52px; display: flex; align-items: center; padding: 0 16px; font: 600 16px %s; color: #11615C;">Pick a time…</div></div>') % (IOSF, IOSF, IOSF)
I_SCHED = big_sheet(I_INBOX, SCHED, 520)

# ---------------------------------------------------------------- 2 · A quiet week (nothing planned)
def quiet_week(f=IOSF):
    dots = ''.join('<div style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; padding: 6px 0;"><span style="font: 600 12px %s; color: #6A6273;">%s</span><span aria-hidden="true" style="width: 22px; height: 22px; border-radius: 50%%; box-shadow: inset 0 0 0 3px #E4DED6;"></span><span class="num" style="font: 600 12px %s; color: #6A6273;">0/0</span></div>' % (f, d, f) for d in 'MTWTFSS')
    rings = ''.join('<span style="display: flex; flex-direction: column; align-items: center; gap: 4px;"><span style="width: 22px; height: 22px; border-radius: 50%%; box-shadow: inset 0 0 0 3px #E4DED6;"></span><span style="font: 700 11px Manrope; color: #6A6273;">%s</span></span>' % d for d in 'MTWTFSS')
    return ('<div style="display: flex; align-items: center; margin-top: 12px;"><span role="heading" style="flex: 1; font: 800 24px Manrope;">This week</span><span style="width: 32px; height: 32px; border-radius: 50%%; background: #ECE5DC; color: #4E4757; display: flex; align-items: center; justify-content: center;">%s</span></div>'
            '<div class="num" style="font: 500 14px %s; color: #6A6273;">November 9 – November 15</div>'
            '<div style="margin-top: 12px; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 10px; display: flex; gap: 2px;">%s</div>'
            '<div style="display: flex; gap: 6px; margin-top: 12px;">%s</div>'
            '<div style="margin-top: 12px; border-radius: 18px; background: #E2EFEC; padding: 12px 14px; font: 600 15px/21px %s; color: #0B4642;">A quiet week: nothing was planned.</div>'
            '<div style="margin-top: 12px; border-radius: 22px; background: #FBF7F1; box-shadow: 0 0 0 1px rgba(36,31,43,.10); padding: 16px; text-align: center;"><div style="font: 800 11px Manrope; letter-spacing: 1px; color: #6A6273;">NOV 9 – NOV 15</div><div style="display: flex; justify-content: space-between; margin-top: 10px;">%s</div><div style="margin-top: 10px; font: 800 14px Manrope; color: #11615C;">dottoday</div></div>'
            '<span role="button" style="display: flex; margin-top: 10px; height: 48px; border-radius: 24px; background: #11615C; color: #fff; align-items: center; justify-content: center; gap: 8px; font: 700 16px %s;">%sShare image</span>'
            '<div style="margin-top: 10px; text-align: center; font: 500 13px %s; color: #6A6273;">No streaks here — just what happened.</div>') % (
        sv(X_I, 16), f, dots, chip('0 of 0 done', f, '#ECE5DC', '#241F2B'), f, rings, f, sv(SHARE_I, 18), f)


I_QUIET = big_sheet(EP_TODAY, quiet_week(), 50)

# ---------------------------------------------------------------- 3 · Search with no results
def search_page(f=IOSF):
    chips = ''.join('<span style="height: 34px; padding: 0 12px; border-radius: 17px; display: flex; align-items: center; font: 600 14px %s; flex: none; %s">%s</span>' % (
        f, 'background: #11615C; color: #fff;' if t == 'Done' else 'background: #FFFDF9; color: #241F2B; box-shadow: inset 0 0 0 1px rgba(36,31,43,.14);', t) for t in ['All', 'Today', 'This week', 'Inbox', 'Done'])
    rec = ''.join('<span role="button" aria-label="Search for %s again" style="height: 36px; padding: 0 14px; border-radius: 18px; background: #ECE5DC; display: flex; align-items: center; font: 600 14px %s;">%s</span>' % (t, f, t) for t in ['dentist', 'roadmap', 'Sam'])
    inner = ('<div style="position: absolute; top: 92px; left: 20px; right: 20px; font: 700 34px/41px -apple-system, \'SF Pro Display\', system-ui;">Search</div>'
             '<div style="position: absolute; top: 134px; left: 20px; font: 500 15px %s; color: #6A6273;">Everything you&#39;ve planned</div>'
             '<div style="position: absolute; top: 166px; left: 16px; right: 16px; height: 44px; border-radius: 12px; background: #ECE5DC; display: flex; align-items: center; gap: 8px; padding: 0 12px; font: 400 17px %s; color: #241F2B;"><span style="color: #6A6273;">%s</span>car service invoice</div>'
             '<div style="position: absolute; top: 222px; left: 16px; right: 0; display: flex; gap: 8px; overflow: hidden;">%s</div>'
             '<div style="position: absolute; top: 300px; left: 20px; right: 20px; text-align: center;"><div style="font: 700 19px/25px Manrope;">No matches for “car service invoice”</div>'
             '<div style="font: 400 15px %s; color: #6A6273; margin-top: 6px;">Try fewer words, or another filter.</div>'
             '<span role="button" style="display: inline-flex; margin-top: 14px; height: 44px; padding: 0 18px; border-radius: 22px; box-shadow: inset 0 0 0 1.5px #C9C1CF; align-items: center; font: 600 15px %s; color: #11615C;">Show all</span></div>'
             '<div style="position: absolute; top: 470px; left: 20px; right: 20px;"><div style="font: 700 12px %s; letter-spacing: .6px; color: #6A6273;">RECENT</div><div style="display: flex; gap: 8px; margin-top: 8px;">%s</div></div>') % (
        f, f, sv(SEARCH_I, 18), chips, f, f, f, rec)
    return withbar(phone(inner))


I_SEARCH0 = search_page()

# ---------------------------------------------------------------- 4 · Calendar access
CAL_ALERT = ios_alert('“Dottoday” Would Like to Access Your Calendar', 'Dottoday shows your calendar events on your timeline, next to your tasks.', 'Don&#39;t Allow', 'Allow')
I_CALASK = over(I_CAL0, CAL_ALERT, 300, 270)
ERR = ('<div style="margin: 18px 16px 0; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.06); padding: 22px 18px; text-align: center; font-family: -apple-system, system-ui;">'
       '<div style="font: 700 18px -apple-system, system-ui;">This didn&#39;t load</div><div style="font: 400 15px -apple-system, system-ui; color: #6A6273; margin-top: 6px;">Your tasks are safe on this device.</div>'
       '<span role="button" style="display: inline-flex; margin-top: 14px; height: 44px; padding: 0 20px; border-radius: 22px; background: #11615C; color: #fff; align-items: center; font: 600 16px -apple-system, system-ui;">Try again</span></div>')
I_CALERR = withbar(ipage('Calendars', 'Data and privacy', cap_('On this device') + ERR, 'Your calendar events on the timeline, next to your tasks. Free, always.'))
SMALL_TOASTS = [('Something went wrong. Try again.', None), ('Exported', None), ('Couldn&#39;t save or share the file. Nothing was changed.', None),
                ('This file is over 25 MB, too large to import. Nothing was changed.', None), ('Backup imported', 'Undo'), ('Backup restored', 'Undo'), ('This device has no passcode, so Dottoday can&#39;t lock.', None)]

# ---------------------------------------------------------------- 6 · Missions a phone can't run (Settings)
# Mission icons: the app's own TaskIcon glyphs (task_icons.gen.dart): the ones the mission screens use, target and star for the two on-screen ones.
M_IC = {'Stand up': 'M10 5a2 2 0 1 0 4 0a2 2 0 1 0 -4 0M3 17a2 2 0 1 0 4 0a2 2 0 1 0 -4 0M17 17a2 2 0 1 0 4 0a2 2 0 1 0 -4 0M10.8 6.6l-4.6 8.8M13.2 6.6l4.6 8.8M7 17h10',
        'Walk': 'M13 4m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0M7 21l3 -4M16 21l-2 -4l-3 -3l1 -6M6 12l2 -3l4 -1l3 3l3 1',
        'Light': 'M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5M9 18h6M10 22h4',
        'Breathe': 'M6.081 20c1.612 0 2.919 -1.335 2.919 -2.98v-9.763c0 -.694 -.552 -1.257 -1.232 -1.257c-.205 0 -.405 .052 -.584 .15l-.13 .083c-1.46 1.059 -2.432 2.647 -3.404 5.824c-.42 1.37 -.636 2.962 -.648 4.775c-.012 1.675 1.261 3.054 2.877 3.161l.203 .007zM17.92 20c-1.613 0 -2.92 -1.335 -2.92 -2.98v-9.763c0 -.694 .552 -1.257 1.233 -1.257c.204 0 .405 .052 .584 .15l.13 .083c1.46 1.059 2.432 2.647 3.405 5.824c.42 1.37 .636 2.962 .648 4.775c.012 1.675 -1.261 3.054 -2.878 3.161l-.202 .007zM9 12a3 3 0 0 0 3 -3a3 3 0 0 0 3 3M12 4v5',
        'Catch the dot': 'M2 12a10 10 0 1 0 20 0a10 10 0 1 0 -20 0M6 12a6 6 0 1 0 12 0a6 6 0 1 0 -12 0M10 12a2 2 0 1 0 4 0a2 2 0 1 0 -4 0',
        'Pick today&#39;s one thing': 'M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8-6.2-3.2-6.2 3.2L7 14.2 2 9.3l6.9-1z'}
def micon(t): return '<span aria-hidden="true" style="width: 30px; height: 30px; border-radius: 8px; background: #E2EFEC; color: #0B4642; display: flex; align-items: center; justify-content: center; flex: none;">%s</span>' % sv('<path d="%s"></path>' % M_IC[t], 18)
def mrow(t, sub=None, sel=False, dim=False):
    return ('<div role="radio" aria-checked="%s" style="min-height: 52px; display: flex; align-items: center; gap: 12px; padding: 6px 14px; box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);%s">%s<span style="flex: 1;"><span style="display: block; font: 400 16px %s;">%s</span>%s</span>%s</div>') % (
        'true' if sel else 'false', ' opacity: .55;' if dim else '', micon(t), IOSF, t, ('<span style="display: block; font: 400 13px %s; color: #6A6273;">%s</span>' % (IOSF, sub)) if sub else '',
        ('<span style="color: #11615C;">%s</span>' % sv(CHECK, 18, 2.6)) if sel else '')


MISS = (cap_('Mission') + card([mrow('Stand up', sel=True), mrow('Walk', 'This phone has no sensor for it', dim=True), mrow('Light', 'Allow access in the phone&#39;s settings to use it', dim=True),
                                mrow('Breathe'), mrow('Catch the dot'), mrow('Pick today&#39;s one thing', 'Needs at least two dots that day.')])
        + cap_('Backup mission') + card([plain_row('Backup mission', val='None', last=True)]))
I_MISS = withbar(ipage('Missions', 'Wake Up and Wind Down', MISS))

# ---------------------------------------------------------------- page
def fcol(w, lab, fr, *n): return col(w, label(lab), fr, notes(*n))
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start;">%s</div>' % ''.join(c)
TS = lambda L, w=420: '<div style="display: flex; flex-direction: column; gap: 10px;">%s</div>' % ''.join(toast(t, a, w) for t, a in L)
s1 = row(fcol(390, 'iPhone · Move › Move to', I_MOVE, B('Built') + ' A month with each day’s task colours; past days dimmed, today ringed; tap a day and it moves at the same time, with Undo', B('Built') + ' This is the Date… step of the approved When picker (ED-099)'),
         fcol(390, 'iPhone · Schedule from the Inbox, no free slot', I_SCHED, B('Built') + ' “No free slot today or tomorrow. Make room on Today, or drag it in from the week.” Pick a time… still works'),
         fcol(390, 'iPhone · This week with nothing planned', I_QUIET, B('Built') + ' “A quiet week: nothing was planned.”; empty rings with 0/0; no Busiest or Lightest chips; no carry card', B('Built') + ' Share stays available', P('Not built') + ' A first-week state: the sheet always shows seven days'),
         fcol(390, 'iPhone · Search with no results', I_SEARCH0, B('Built') + ' “No matches for …”, “Try fewer words, or another filter.”, Show all when a filter is on, and Recent below'))
s2 = row(fcol(390, 'iPhone · connecting a calendar', I_CALASK, B('Built') + ' Connect a calendar shows the system prompt with Dottoday’s reason; the page doesn’t change underneath, then the calendars appear', P('Not built') + ' A “connecting” spinner; Google and Microsoft sign in in the browser'),
         fcol(390, 'iPhone · calendars didn’t load', I_CALERR, B('Built') + ' The shared error state: This didn’t load, Your tasks are safe on this device., Try again'),
         fcol(390, 'iPhone · Missions the phone can’t run', I_MISS, B('Built') + ' Every mission stays listed; a line says why one can’t run: no sensor, no access, or not enough dots', B('Built') + ' If a sensor fails during the alarm, the mission counts as done and the Wake Up card opens; no error', D('Design-only') + ' An icon on each mission, from the app’s own task icons: the ones its mission screens show (stand up, walking, light bulb, lungs), a target for Catch the dot and a star for one thing; the built list is text only (owner comment “add icons”)'),
         col(420, label('Results with no progress screen'), TS(SMALL_TOASTS), notes(B('Built') + ' Export, import and restore run without a progress screen; each ends in one of these', B('Built') + ' App lock: a failed or cancelled Face ID leaves the locked screen as it is, with Unlock (R2-24); no message', P('Not built') + ' Progress for export, import or connecting; a lock-out message')))
RULES = [('Calm results', 'Nothing blocks the screen; each action ends in one plain line, and the risky ones have Undo.'),
         ('No shame', 'A quiet week is “quiet”, not empty or failed; no streaks.'),
         ('Nothing hidden', 'Missions a phone can’t run stay listed, with the reason.'),
         ('Privacy', 'Calendar access is asked once, with Dottoday’s own reason.'),
         ('Same everywhere (R-13)', 'Android, tablets, Mac and web show the same states in their own controls.'),
         ('Text from the app', 'Every string is built (app_en.arb and the iOS permission text). Tasks and dates are examples. No new copy.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 GAP PASS · R2-28</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Small states</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">Picking a day, no free slot, a quiet week, Search with no results, calendar access, results of export and import, App lock after a failed try, and missions a phone can’t run. As built. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed · gap pass'), tag('tn', 'iPhone; others the same'), tag('tn', '@@THEME@@'))
page_body = body + section('1 · Picking and finding', s1) + section('2 · Access, results and missions', s2) + section('Rules', rules)
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-28 · Small states</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-28-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-28.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-28.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('class="blk-d', 'class="blk').replace('<title>E · R2-28 · Small states</title>', '<title>E · R2-28 · Small states · Dark</title>')
open('project/E-R2-28-Dark.dc.html', 'w', encoding='utf-8').write(dk)
print('ok')
