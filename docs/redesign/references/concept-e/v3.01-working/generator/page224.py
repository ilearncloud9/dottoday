# R2-24 · The rest (ED-326): This week (review, carry, share), Calendars, App lock, Help and about (Help, feedback,
# About, What's new), web install, and a German and French long-string pass. Built strings only (app_en/de/fr.arb).
_p = open(os.path.join(HERE, '..', 'r223', 'page223.py'), encoding='utf-8').read()
exec(_p[:_p.index('# ---------------------------------------------------------------- page')].replace("os.path.join(HERE, 'frames.py')", "os.path.join(HERE, '..', 'r223', 'frames.py')"))
LOCK_I = '<rect x="5" y="11" width="14" height="10" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path>'
HELP_I = '<circle cx="12" cy="12" r="9"></circle><path d="M9.5 9a2.5 2.5 0 0 1 4.9.7c0 1.7-2.4 2.2-2.4 3.8M12 17h.01"></path>'
MAIL_I = '<rect x="3" y="5" width="18" height="14" rx="2.5"></rect><path d="M3 7l9 6 9-6"></path>'
INFO_I = '<circle cx="12" cy="12" r="9"></circle><path d="M12 11v6M12 7.5h.01"></path>'
MIC_I = '<rect x="9" y="3" width="6" height="11" rx="3"></rect><path d="M5 11a7 7 0 0 0 14 0M12 18v3"></path>'
DL_I = '<path d="M12 4v11M7 10l5 5 5-5M5 20h14"></path>'


def page_body(t): return '<div style="padding: 0 20px; font: 400 15px/21px -apple-system, system-ui; color: #4E4757;">%s</div>' % t


def btn_fill(t, f=IOSF): return '<div style="padding: 14px 16px 0;"><span role="button" style="display: flex; height: 50px; border-radius: 25px; background: #11615C; color: #fff; align-items: center; justify-content: center; font: 700 16px %s;">%s</span></div>' % (f, t)


def sw_row(col, t, sub=None, on=True, last=False):
    subh = ('<span style="display: block; font-size: 13px; color: #6A6273;">%s</span>' % sub) if sub else ''
    return ('<div style="min-height: 48px; display: flex; align-items: center; gap: 12px; padding: 6px 14px;%s"><span aria-hidden="true" style="width: 14px; height: 14px; border-radius: 50%%; background: %s; flex: none;"></span>'
            '<span style="flex: 1; font-size: 16px;">%s%s</span>%s</div>') % ('' if last else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', col, t, subh, ios_switch(on))


def card(rows): return '<div style="margin: 0 16px; border-radius: 18px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s</div>' % ''.join(rows)
def cap_(t): return '<div style="padding: 16px 20px 6px; font-size: 13px; color: #6A6273;">%s</div>' % t
def plain_row(t, sub=None, color='#241F2B', last=False, val=None):
    return ('<div style="min-height: 48px; display: flex; align-items: center; gap: 12px; padding: 6px 14px;%s"><span style="flex: 1; font-size: 16px; color: %s;">%s%s</span>%s</div>') % (
        '' if last else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', color, t, ('<span style="display: block; font-size: 13px; color: #6A6273;">%s</span>' % sub) if sub else '',
        ('<span style="font-size: 16px; color: #6A6273;">%s</span>' % val) if val else '')


# ---------------------------------------------------------------- 1 · This week
WEEK = [('M', 2, 5, 6), ('T', 3, 3, 9), ('W', 4, 6, 7), ('T', 5, 7, 8), ('F', 6, 5, 6), ('S', 7, 2, 2), ('S', 8, 1, 1)]


def wdots(sel=3, f=IOSF):
    cells = ''
    for i, (d, n, done, tot) in enumerate(WEEK):
        cells += ('<div role="button" aria-label="%s: %d of %d done" style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; padding: 6px 0; border-radius: 14px;%s"><span style="font: 600 12px %s; color: #6A6273;">%s</span>%s'
                  '<span class="num" style="font: 600 12px %s; color: #4E4757;">%d/%d</span></div>') % (
            d, done, tot, ' background: #E2EFEC;' if i == sel else '', f, d, ring(30, done / tot, '#11615C', w=4), f, done, tot)
    return '<div style="display: flex; gap: 2px;">%s</div>' % cells


DAYTHREAD = [('Morning run', '6:45 AM – 7:30 AM', COR, True), ('Team standup', '8:00 AM – 8:15 AM', BLU, True), ('Deep work: roadmap', '9:00 AM – 11:00 AM', IND, False)]


def week_top(f=IOSF):
    thread = ''.join('<div style="display: flex; align-items: center; gap: 10px; min-height: 30px;"><span style="width: 12px; height: 12px; border-radius: 50%%; %s flex: none;"></span><span style="flex: 1; font: 600 14px %s;%s">%s</span><span class="num" style="font: 500 12px %s; color: #6A6273;">%s</span></div>' % (
        ('background: %s;' % c) if d else ('box-shadow: inset 0 0 0 2.5px %s;' % c), f, ' text-decoration: line-through; color: #6A6273;' if d else '', t, f, tm) for t, tm, c, d in DAYTHREAD)
    chips = ''.join(chip(t, f, '#ECE5DC', '#241F2B') for t in ['29 of 39 done', 'Busiest · Tuesday', 'Lightest · Sunday'])
    return ('<div style="display: flex; align-items: center; margin-top: 12px;"><span role="heading" style="flex: 1; font: 800 24px Manrope;">This week</span><span style="width: 32px; height: 32px; border-radius: 50%%; background: #ECE5DC; color: #4E4757; display: flex; align-items: center; justify-content: center;">%s</span></div>'
            '<div class="num" style="font: 500 14px %s; color: #6A6273;">November 2 – November 8</div>'
            '<div style="margin-top: 12px; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 10px;">%s'
            '<div style="margin-top: 8px; padding: 8px 6px 2px; box-shadow: inset 0 0.5px 0 rgba(36,31,43,.10);">%s<div style="display: flex; justify-content: space-between; font: 600 12.5px %s; color: #6A6273; margin-top: 4px;"><span>9 planned · busiest</span><span>+6 more</span></div></div></div>'
            '<div style="display: flex; flex-wrap: wrap; gap: 6px; margin-top: 12px;">%s</div>'
            '<div style="margin-top: 12px; border-radius: 18px; background: #E2EFEC; padding: 12px 14px; font: 600 15px/21px %s; color: #0B4642;">Mornings mostly went to plan. Tuesday carried the most; Sunday breathed.</div>') % (
        sv(X_I, 16), f, wdots(1, f), thread, f, chips, f)


def carry(f=IOSF):
    return ('<div style="margin-top: 12px; border-radius: 18px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 12px 14px;"><div style="font: 600 15px %s;">3 unfinished · move them to next week?</div>'
            '<div style="display: flex; gap: 8px; margin-top: 10px;"><span role="button" style="height: 40px; padding: 0 18px; border-radius: 20px; background: #11615C; color: #fff; display: flex; align-items: center; font: 700 14px %s;">Place</span>'
            '<span role="button" style="height: 40px; padding: 0 14px; border-radius: 20px; display: flex; align-items: center; font: 700 14px %s; color: #0B4642;">Leave in Inbox</span></div></div>') % (f, f, f)


def share_card(titles=False, w=330):
    dots = ''.join('<span style="display: flex; flex-direction: column; align-items: center; gap: 4px;">%s<span style="font: 700 11px Manrope; color: #6A6273;">%s</span></span>' % (ring(32, done / tot, '#11615C', w=4.5), d) for d, n, done, tot in WEEK)
    tl = ('<div style="margin-top: 12px; font: 500 12.5px/18px Manrope; color: #4E4757; text-align: left;">Mon · Morning run, Team standup<br>Tue · Deep work: roadmap, Lunch<br>Wed · Dentist, Gym</div>') if titles else ''
    return ('<div role="img" aria-label="Share image: this week in seven dots" style="width: %dpx; box-sizing: border-box; border-radius: 22px; background: #FBF7F1; box-shadow: 0 0 0 1px rgba(36,31,43,.10); padding: 18px; text-align: center;">'
            '<div style="font: 800 11px Manrope; letter-spacing: 1px; color: #6A6273;">NOV 2 – NOV 8</div><div style="display: flex; justify-content: space-between; margin-top: 12px;">%s</div>%s'
            '<div style="margin-top: 14px; font: 800 14px Manrope; color: #11615C;">dottoday</div></div>') % (w, dots, tl)


def week_share(f=IOSF):
    return ('<div style="margin-top: 12px;">%s</div><div style="display: flex; align-items: center; gap: 10px; margin-top: 10px; min-height: 44px;"><span style="flex: 1; font: 500 16px %s;">Show task titles</span>%s</div>'
            '<span role="button" style="display: flex; margin-top: 6px; height: 50px; border-radius: 25px; background: #11615C; color: #fff; align-items: center; justify-content: center; gap: 8px; font: 700 16px %s;">%sShare image</span>'
            '<div style="margin-top: 12px; text-align: center; font: 500 13px %s; color: #6A6273;">No streaks here — just what happened.</div>') % (share_card(False, 358), f, ios_switch(False), f, sv(SHARE_I, 18), f)


I_WEEK1 = big_sheet(EP_TODAY, week_top(), 50)
I_WEEK2 = big_sheet(EP_TODAY, '<div style="margin-top: 8px; font: 800 17px Manrope; text-align: center;">This week</div>' + carry() + week_share(), 50)
PROMPT = ('<div role="group" style="position: absolute; left: 16px; right: 16px; bottom: 106px; z-index: 30; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08), 0 10px 30px rgba(36,31,43,.14); padding: 14px 16px;">'
          '<div style="font: 800 17px Manrope;">This week</div><div style="font: 500 14px -apple-system, system-ui; color: #6A6273;">Your week in seven dots</div>'
          '<div style="display: flex; gap: 8px; margin-top: 10px;"><span role="button" style="height: 40px; padding: 0 16px; border-radius: 20px; background: #11615C; color: #fff; display: flex; align-items: center; font: 700 14px -apple-system, system-ui;">See the week</span>'
          '<span role="button" style="height: 40px; padding: 0 14px; display: flex; align-items: center; font: 700 14px -apple-system, system-ui; color: #0B4642;">Not now</span></div></div>')
_k = EP_TODAY.rindex('</div>')
I_PROMPT = EP_TODAY[:_k] + PROMPT + EP_TODAY[_k:]
CARRY_ROWS = [p_row('Pick up parcel', None, GRN, 'moved to Mon 9:00 AM', 'keep'), p_row('Call the bank', None, AMB, 'moved to Mon 2:00 PM', 'keep'), p_row('Read', None, BRN, 'moved to Tue 9:30 PM', 'keep')]
I_CARRY = big_sheet(I_WEEK2, proposal('Next week', '3 unfinished tasks, each in the first free time that fits', CARRY_ROWS, 'Place them'), 210)
W_TOASTS = [('Placed in next week', None), ('3 tasks sent to the Inbox', 'Undo')]

# ---------------------------------------------------------------- 2 · Calendars
CAL_INTRO = 'Your calendar events on the timeline, next to your tasks. Free, always.'
ONLINE = (cap_('Google and Microsoft') + card([plain_row('Sign in to connect Google or Microsoft', color='#11615C', last=True)]))
I_CAL0 = withbar(ipage('Calendars', 'Data and privacy', cap_('Connected') + card([plain_row('No calendars connected yet', color='#6A6273', last=True)])
                       + pt('Dottoday asks your device once to see your calendars. Then you choose which ones come in.') + obtn('Connect a calendar') + ONLINE, CAL_INTRO))
I_CAL_DENIED = withbar(ipage('Calendars', 'Data and privacy', inotice('Calendar access is off', "Dottoday can&#39;t show your events until calendar access is allowed in your device settings.", 'Open settings') + ONLINE, CAL_INTRO))
ACCT = 'alex@example.com'
I_CAL1 = withbar(ipage('Calendars', 'Data and privacy',
                       cap_('On this device') + card([sw_row(BLU, 'Work'), sw_row(GRN, 'Family'), sw_row(GRY, 'Holidays', 'Read-only', False, True)])
                       + cap_(ACCT) + card([sw_row(VIO, 'Personal'), sw_row(PNK, 'Birthdays', 'Read-only', False), plain_row('Disconnect', color='#11615C', last=True)])
                       + cap_('Google and Microsoft') + card([plain_row('Connect Google Calendar', color='#11615C'), plain_row('Connect Microsoft Outlook', color='#11615C', last=True)])
                       , CAL_INTRO))
I_CAL2 = withbar(ipage('Calendars', 'Data and privacy',
                       cap_('Send changes back') + card([sw_row(BLU, 'Work', on=False), sw_row(VIO, 'Personal', on=True, last=True)])
                       + pt('Moves, resizes and renames you make here go to the calendar, earlier ones too. Repeating and all-day events change here only.')
                       + cap_('When the day shifts') + card([plain_row('Move calendar events too', 'When you shift the rest. Shared and repeating events stay put.', last=True).replace('</span></div>', '</span>%s</div>' % ios_switch(True), 1)])
                       + cap_('Travel time') + card([plain_row('Suggest travel time', 'Before events with a place. Worked out on this device; no maps are asked', last=True).replace('</span></div>', '</span>%s</div>' % ios_switch(False), 1)])))
I_DISC = over(I_CAL1, ios_alert('Disconnect %s?' % ACCT, 'Its events leave your timeline on every device. Events with your subtasks or notes go to Trash.', 'Cancel', 'Disconnect'), 300, 270)


def bstrip(t, acts):
    b = ''.join('<span role="button" style="height: 36px; padding: 0 12px; border-radius: 18px; display: flex; align-items: center; font: 700 14px -apple-system, system-ui; color: #0B4642;%s">%s</span>' % (' background: #FFFDF9;' if i == 0 else '', a) for i, a in enumerate(acts))
    return ('<div role="status" style="width: 420px; box-sizing: border-box; display: flex; align-items: center; gap: 10px; padding: 8px 8px 8px 14px; border-radius: 18px; background: #E2EFEC;">'
            '<span style="flex: 1; font: 600 14.5px/19px -apple-system, system-ui; color: #241F2B;">%s</span><span style="display: flex; gap: 2px; flex: none;">%s</span></div>') % (t, b)


BANNERS = '<div style="display: flex; flex-direction: column; gap: 10px;">%s</div>' % ''.join([
    bstrip('2 events changed in your calendar too', ['Keep mine', 'Use calendar&#39;s']), bstrip('1 change hasn&#39;t reached your calendar yet', ['Try again']),
    bstrip('Dottoday can&#39;t reach this account until you reconnect it', ['Reconnect'])])
ONB_ROW = '<div style="width: 390px; margin: 0 -16px;">%s%s</div>' % (cap_('Calendars'), card([plain_row('Connect a calendar', 'Connected · choose calendars in Settings', last=True)]))

# ---------------------------------------------------------------- 3 · App lock (Settings › Data and privacy › Privacy)
LOCK_GROUP = cap_('APP LOCK') + card([plain_row('Lock Dottoday', 'Ask for your face, fingerprint or passcode').replace('</span></div>', '</span>%s</div>' % ios_switch(True), 1), plain_row('Lock after', val='1 minute', last=True)])
I_LOCKSET = withbar(ipage('Privacy', 'Data and privacy', LOCK_GROUP + PRIV_TOP))
LOCK_SHEET = ('<div style="display: flex; align-items: center; justify-content: space-between; margin: 10px 0 12px;"><span style="font: 400 17px %s; color: #11615C;">Cancel</span><span style="font: 600 17px %s;">Lock after</span><span style="width: 54px;"></span></div>%s') % (
    IOSF, IOSF, '<div style="border-radius: 18px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s</div>' % ''.join(
        '<div role="radio" aria-checked="%s" style="min-height: 50px; display: flex; align-items: center; padding: 0 16px; font: 400 17px %s;%s"><span style="flex: 1;">%s</span>%s</div>' % (
            'true' if o == '1 minute' else 'false', IOSF, '' if o == '15 minutes' else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', o, ('<span style="color: #11615C;">%s</span>' % sv(CHECK, 18, 2.6)) if o == '1 minute' else '') for o in ['Right away', '1 minute', '5 minutes', '15 minutes']))
I_LOCKAFTER = big_sheet(I_LOCKSET, LOCK_SHEET, 520)


def lockscreen(android=False):
    f = ANF if android else IOSF
    inner = ('<div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 22px;">'
             '<span aria-hidden="true" style="width: 96px; height: 96px; border-radius: 50%%; background: #11615C;"></span><div style="font: 800 24px Manrope;">Dottoday is locked</div>'
             '<span role="button" style="height: 52px; padding: 0 40px; border-radius: 26px; background: #11615C; color: #fff; display: flex; align-items: center; font: 700 17px %s;">Unlock</span></div>') % f
    return phone(inner, android)


I_LOCK = lockscreen()
A_LOCK = lockscreen(True)
COVER = phone('<div style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;"><span aria-hidden="true" style="width: 96px; height: 96px; border-radius: 50%; background: #11615C;"></span></div>')
WEBLOCK = '<div style="width: 390px; margin: 0 -16px;">%s%s</div>' % (cap_('APP LOCK'), card([plain_row('Uses your computer&#39;s lock', 'In a browser, Dottoday is as locked as your computer. Lock your screen when you step away; tasks stay encrypted in this browser.', color='#6A6273', last=True)]))

# ---------------------------------------------------------------- 4 · Help and about
I_HA = withbar(ipage('Help and about', 'Settings', igroup([irow('teal', HELP_I, 'Help'), irow('indigo', MIC_I, 'Siri &amp; Shortcuts', sub='Ask Siri about your day'),
                                                          irow('grey', INFO_I, 'About Dottoday'), irow('teal', MAIL_I, 'Send feedback')])))
QS = ['How do I move a task?', 'I&#39;m running late. Can everything move?', 'How do repeating tasks work?', 'Can I add many tasks at once?', 'Are there keyboard shortcuts?', 'How does Wake Up work?']
def qrow(q, a=None, last=False):
    return ('<div style="padding: 12px 14px;%s"><div style="display: flex; align-items: center; gap: 8px;"><span style="flex: 1; font: 600 16px -apple-system, system-ui;">%s</span><span style="color: #6A6273;">%s</span></div>%s</div>') % (
        '' if last else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', q, sv(DOWN_I if not a else '<path d="M6 15l6-6 6 6"></path>', 16),
        ('<div style="margin-top: 6px; font: 400 15px/21px -apple-system, system-ui; color: #4E4757;">%s</div>' % a) if a else '')
I_HELP = withbar(ipage('Help', 'Help and about', '<div style="height: 10px;"></div>' + card([qrow(q, 'Drag it along the thread, or drag its edges to change how long it is. Long-press to pick several.' if i == 0 else None, i == len(QS) - 1) for i, q in enumerate(QS)]) + btn_fill('Send feedback'),
                       'Quick answers. Anything else? Send feedback below.'))
DIAG = ('{"app":"1.2.0 (120)","platform":"ios 26.1","locale":"en_GB","schema":17,"sync":{"state":"synced","pending":0,"conflicts":0},"counts":{"tasks":214,"inbox":3,"done":1187,"repeats":12,"trash":4,"calendarEvents":56}}')
FEED = ('<div style="display: flex; align-items: center; justify-content: space-between; margin: 10px 0 12px;"><span style="font: 400 17px %s; color: #11615C;">Cancel</span><span style="font: 600 17px %s;">Send feedback</span><span style="width: 54px;"></span></div>'
        '<div style="font: 400 15px/21px %s; color: #4E4757;">Opens a draft in your mail app, and you send it from there. Nothing your tasks say is included.</div>'
        '<div style="margin-top: 14px; border-radius: 18px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.06); padding: 8px 14px;"><div style="display: flex; align-items: center; min-height: 44px;"><span style="flex: 1; font: 400 16px %s;">Add diagnostics</span>%s</div>'
        '<div style="font: 400 13px/18px %s; color: #6A6273; padding-bottom: 6px;">App version, device type, sync state and how many tasks you have — never what they say.</div></div>'
        '<div style="margin-top: 12px; font: 600 13px %s; color: #6A6273;">Added to the end of your email:</div><div style="margin-top: 6px; border-radius: 14px; background: #ECE5DC; padding: 10px 12px; font: 400 12px/17px ui-monospace, Menlo, monospace; color: #241F2B; word-break: break-all;">%s</div>'
        '<span role="button" style="display: flex; margin-top: 16px; height: 50px; border-radius: 25px; background: #11615C; color: #fff; align-items: center; justify-content: center; font: 700 16px %s;">Write email</span>') % (
    IOSF, IOSF, IOSF, IOSF, ios_switch(True), IOSF, IOSF, DIAG, IOSF)
I_FEED = big_sheet(I_HA, FEED, 230)
I_ABOUT = withbar(ipage('About Dottoday', 'Help and about', igroup([irow('grey', INFO_I, 'Version', value='1.2.0', chev=False), irow('teal', '<path d="M12 3l2.5 5.5L20 9.5l-4 4 1 6-5-3-5 3 1-6-4-4 5.5-1z"></path>', 'What&#39;s new'), irow('grey', DOC_I, 'Open-source licences')], 'About')))
NOTES = ['Wake Up alarm: turn it on in Settings › Day shape and your Wake Up time rings on days you&#39;ve planned …',
         'Sounds: 48 reminder sounds made to sit well together. …', 'Just the next dot: a minimal layout you can choose any time, with nothing lost. …',
         'Drag a task anywhere on the day, even onto another one: overlapping tasks tie a small knot in the thread.', 'Bedtime is now Wind Down. …']
I_NEW = withbar(ipage('What&#39;s new', 'About Dottoday', cap_('Version 1.2.0 · on this device') + card(['<div style="display: flex; gap: 10px; padding: 10px 14px;%s"><span style="width: 8px; height: 8px; margin-top: 7px; border-radius: 50%%; background: #11615C; flex: none;"></span><span style="font: 400 15px/21px -apple-system, system-ui;">%s</span></div>' % (
    '' if i == len(NOTES) - 1 else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', n) for i, n in enumerate(NOTES)]) + cap_('Version 1.1.0'), 'What changed in each version of Dottoday.'))
NEWBANNER = bstrip('Dottoday 1.2.0 is here', ['See what&#39;s new', 'Not now'])

# ---------------------------------------------------------------- 5 · Web: install
INSTALL = ('<div role="status" style="display: flex; align-items: center; gap: 12px; padding: 8px 8px 8px 14px; border-radius: 16px; background: #E2EFEC; margin: 12px 16px 0;"><span style="color: #0B4642;">%s</span>'
           '<span style="flex: 1; font: 600 14.5px system-ui; color: #241F2B;">Install Dottoday: opens like an app and works offline</span>'
           '<span role="button" style="height: 36px; padding: 0 14px; border-radius: 18px; background: #FFFDF9; display: flex; align-items: center; font: 700 14px system-ui; color: #0B4642;">Install</span>'
           '<span role="button" style="height: 36px; padding: 0 12px; display: flex; align-items: center; font: 700 14px system-ui; color: #0B4642;">Not now</span></div>') % sv(DL_I, 18)
W_INSTALL = ('<div role="img" aria-label="Web: the install strip" style="width: 900px; height: 300px; border-radius: 14px; overflow: hidden; background: #FBF7F1; box-shadow: 0 0 0 1px rgba(36,31,43,.14), 0 20px 50px rgba(36,31,43,.12);">'
             '<div style="height: 38px; display: flex; align-items: center; gap: 8px; padding: 0 14px; background: #ECE5DC;"><span style="width: 12px; height: 12px; border-radius: 50%%; background: #EC6A5E;"></span><span style="width: 12px; height: 12px; border-radius: 50%%; background: #F4BF4F;"></span><span style="width: 12px; height: 12px; border-radius: 50%%; background: #61C554;"></span>'
             '<span style="margin-left: 16px; flex: 1; height: 24px; border-radius: 12px; background: #FBF7F1; font: 500 12px system-ui; color: #6A6273; display: flex; align-items: center; padding-left: 12px;">app.dottoday.example/#/today</span></div>%s'
             '<div style="padding: 20px 28px; opacity: .55;">%s</div></div>') % (INSTALL, wide_day())

# ---------------------------------------------------------------- 6 · German and French: longest strings in place
NAV = EP_TODAY[EP_TODAY.index('<nav aria-label="Main"'):EP_TODAY.index('</nav>') + 6]
def tabbar(labels):
    n = NAV
    for a, b in zip(['Today</a>', 'Inbox<span', 'Calendar</a>', 'Search</a>'], labels):
        n = n.replace('>' + a, '>' + b, 1)
    return ('<div style="position: relative; width: 390px; height: 100px; border-radius: 22px; overflow: hidden; background: linear-gradient(180deg, #E8E7FA, #FBF7F1);">%s'
            '<span aria-hidden="true" style="position: absolute; right: 21px; bottom: 21px; width: 63px; height: 63px; border-radius: 50%%; background: #11615C;"></span></div>') % n


TB_DE = tabbar(['Heute</a>', 'Eingang<span', '<span style="color: #9A5A0E;">Calendar?</span></a>', 'Suche</a>'])
TB_FR = tabbar(['Aujourd&#39;hui</a>', 'Boîte de réception<span', '<span style="color: #9A5A0E;">Calendar?</span></a>', 'Recherche</a>'])


def actions4(labels, f=IOSF):
    return '<div style="width: 358px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px;">%s</div>' % ''.join(
        '<span role="button" style="min-height: 56px; border-radius: 16px; background: %s; color: %s; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px; font: 600 12px/14px %s; text-align: center; padding: 4px;">%s%s</span>' % (
            '#11615C' if i == 0 else '#ECE5DC', '#fff' if i == 0 else '#241F2B', f, sv(ic, 18), t) for i, (t, ic) in enumerate(zip(labels, [CHECK, CLOCK, '<path d="M4 12h12M12 6l6 6-6 6M20 5v14"></path>', FOCUSI])))


def pfoot(acc, dis, note, f=IOSF):
    return ('<div style="width: 358px;"><span role="button" style="display: flex; height: 54px; border-radius: 27px; background: #11615C; color: #fff; align-items: center; justify-content: center; font: 800 17px Manrope;">%s</span>'
            '<div style="text-align: center; margin-top: 6px; font: 700 15px %s; color: #11615C;">%s</div><div style="text-align: center; margin-top: 4px; font: 600 12.5px %s; color: #6A6273;">%s</div></div>') % (acc, f, dis, f, note)


def carry_l(ask, place, inbox, f=IOSF):
    return ('<div style="width: 358px; box-sizing: border-box; border-radius: 18px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 12px 14px;"><div style="font: 600 15px %s;">%s</div>'
            '<div style="display: flex; gap: 8px; margin-top: 10px; flex-wrap: wrap;"><span role="button" style="height: 40px; padding: 0 18px; border-radius: 20px; background: #11615C; color: #fff; display: flex; align-items: center; font: 700 14px %s;">%s</span>'
            '<span role="button" style="height: 40px; padding: 0 14px; border-radius: 20px; display: flex; align-items: center; font: 700 14px %s; color: #0B4642;">%s</span></div></div>') % (f, ask, f, place, f, inbox)


LANG = {
    'de': dict(tb=TB_DE, act=['Erledigt', 'Verlegen', 'Rest verschieben', 'Fokus'], foot=('Übernehmen', 'Verwerfen', 'Nichts wird gespeichert, bevor du übernimmst'),
               toasts=[('3 Aufgaben in den Eingang gelegt', 'Rückgängig'), ('Dottoday 1.2.0 ist da', None)], carry=('3 offen · in die nächste Woche legen?', 'Einplanen', 'In den Eingang'),
               install='Dottoday installieren: öffnet sich wie eine App und funktioniert offline'),
    'fr': dict(tb=TB_FR, act=['Fait', 'Déplacer', 'Décaler la suite', 'Concentration'], foot=('Accepter', 'Ignorer', 'Rien n&#39;est enregistré avant d&#39;accepter'),
               toasts=[('3 tâches envoyées dans la boîte de réception', 'Annuler'), ('Dottoday 1.2.0 est arrivé', None)], carry=('3 pas finies · les placer la semaine prochaine ?', 'Placer', 'Laisser dans la boîte de réception'),
               install='Installer Dottoday : s&#39;ouvre comme une app et fonctionne hors ligne'),
}

# ---------------------------------------------------------------- page
def fcol(w, lab, fr, *n): return col(w, label(lab), fr, notes(*n))
def scaled(fr, w, h, sc): return '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>' % (w * sc + 14, h * sc + 14, w, h, sc, fr)
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start;">%s</div>' % ''.join(c)
stack = lambda *c: '<div style="display: flex; flex-direction: column; gap: 18px;">%s</div>' % ''.join(c)
s1 = (row(fcol(390, 'iPhone · Wind Down on the week’s last day', I_PROMPT, B('Built') + ' After bedtime on the last day of the week (by Week starts), when the day review is not showing; also Today ⋯ › This week at any time', B('Built') + ' Show less: “See your week as seven dots?” from day 14'),
          fcol(390, 'iPhone · This week', I_WEEK1, B('Built') + ' Seven dots with done/total; tap a day for its first three tasks; the chips; one sentence about pace and load', B('Rule') + ' Never compared with other weeks; no streaks'),
          fcol(390, 'iPhone · scrolled: carry and share', I_WEEK2, B('Built') + ' Unfinished tasks: Place (a proposal) or Leave in Inbox (with Undo)', B('Built') + ' The share image: seven dots, the dates, “dottoday”; titles only if you switch them on', D('Design-only') + ' The E card and dots'),
          fcol(390, 'iPhone · Place → the proposal', I_CARRY, B('Built') + ' Each in the first free time that fits; nothing moves before Place them'))
      + row(col(358, label('The share image, titles on'), share_card(True, 358), notes(B('Built') + ' A PNG to the share sheet; the web downloads it when it cannot share')),
            col(420, label('Toasts'), '<div style="display: flex; flex-direction: column; gap: 10px;">%s</div>' % ''.join(toast(t, a, 420) for t, a in W_TOASTS), notes()),
            col(520, label('Elsewhere'), notes(B('Built') + ' A sheet on phones, a popover from medium width (tablets, Mac, web)', B('Built') + ' The learning reveal lives on Today and in Learn my day (R2-23), not in the week'))))
s2 = (row(fcol(390, 'iPhone · Calendars, not asked yet', I_CAL0, B('Built') + ' One OS prompt, then you choose; Google and Microsoft need an account'),
          fcol(390, 'iPhone · connected', I_CAL1, B('Built') + ' One group per account, a switch per calendar in its own colour; Read-only marked', B('Built') + ' Under them: “Connected once, they show on every device you sign in on. If a calendar is also on this device, switch one of the two off.”', B('Example') + ' The account and calendar names'),
          fcol(390, 'iPhone · scrolled: send back, shifting, travel', I_CAL2, B('Built') + ' Send changes back appears once a writable calendar is on; each one starts off'),
          fcol(390, 'iPhone · Disconnect', I_DISC, B('Built') + ' Its events leave every device; ones with your steps or notes go to Trash')))
s2b = row(fcol(390, 'iPhone · access off', I_CAL_DENIED, B('Built') + ' Open settings; if that fails, a toast says where to go'),
          col(420, label('Strips above every screen'), BANNERS, notes(B('Built') + ' A clash, a change not sent yet, an account to reconnect')),
          col(390, label('Onboarding · the optional row'), ONB_ROW, notes(B('Built') + ' On the reminders step; the web says “Connect Google or Microsoft in Settings › Calendars.”')),
          col(420, label('Web, Mac, Android'), notes(B('Built') + ' Android: the device calendars; Mac: its own calendar access; web: Google and Microsoft only', P('Not built') + ' CalDAV has no screen and is not drawn')))
s3 = row(fcol(390, 'iPhone · Privacy with App lock', I_LOCKSET, B('Built') + ' At the top of Privacy (Settings › Data and privacy › Privacy, ED-324); off by default, this device only', B('Built') + ' “This device has no passcode, so Dottoday can’t lock.” when it can’t'),
         fcol(390, 'iPhone · Lock after', I_LOCKAFTER, B('Built') + ' Right away, 1, 5 or 15 minutes'),
         fcol(390, 'iPhone · locked', I_LOCK, B('Built') + ' Face ID or the passcode opens it by itself; Unlock asks again', D('Design-only') + ' The big teal dot'),
         stack(col(390 * .5 + 14, label('App switcher cover'), scaled(COVER, 390, 844, .5), notes(B('Built') + ' No tasks show while Dottoday is in the background')),
               col(390, label('Web · no switch'), WEBLOCK, notes(B('Built') + ' Android and Mac lock like iPhone'))))
s4 = (row(fcol(390, 'iPhone · Settings › Help and about', I_HA, B('Built') + ' Help, Siri &amp; Shortcuts (iPhone), About Dottoday, Send feedback; Privacy now lives in Data and privacy (ED-324)'),
          fcol(390, 'iPhone · Help', I_HELP, B('Built') + ' Six questions, then Send feedback', Q('Flag') + ' The answer still says “drag its edges”: edge resize was removed (ADR-0015); the string needs an update'),
          fcol(390, 'iPhone · Send feedback', I_FEED, B('Built') + ' A draft in your mail app; diagnostics only if you add them, and you see them first', B('Rule') + ' Nothing your tasks say is included'),
          fcol(390, 'iPhone · What’s new (from About Dottoday)', I_NEW, B('Built') + ' Newest first; opening it marks the notes seen', Q('Flag') + ' 1.2.0’s first line says “Settings › Day shape”, which no longer exists (ED-321)'))
      + row(fcol(390, 'iPhone · About Dottoday', I_ABOUT, B('Built') + ' Version, What’s new, Open-source licences'),
            col(420, label('After an update · the strip'), NEWBANNER, notes(B('Built') + ' Once, after an update with notes; never on a first install')),
            col(900, label('Web · Install (Chrome, Edge)'), W_INSTALL, notes(B('Built') + ' From the second visit, when the browser offers it; Not now hides it for good', B('Built') + ' Safari never offers it, so nothing shows there; no “Add to Home Screen” help is built'))))


def lang_col(code, name):
    L_ = LANG[code]
    return col(390, label(name), stack(L_['tb'], actions4(L_['act']), pfoot(*L_['foot']), carry_l(*L_['carry']),
                                       '<div style="display: flex; flex-direction: column; gap: 10px;">%s</div>' % ''.join(toast(t, a, 358) for t, a in L_['toasts']),
                                       '<div style="width: 358px; border-radius: 16px; background: #E2EFEC; padding: 10px 14px; font: 600 14px/19px system-ui;">%s</div>' % L_['install']))


FINDINGS = notes(Q('Needs a string') + ' The Calendar tab (ED-069, ED-075) has no built label: it shows English in every language. A new key with German and French text is new copy, for your OK',
                 Q('Wraps') + ' French “Boîte de réception” cannot fit the tab at 10 pt: two lines, or the shorter “Boîte” as a tab-only string (new copy). “Aujourd’hui” just fits the selected pill',
                 B('Fits') + ' The four sheet buttons wrap to two lines in German and French (“Rest verschieben”, “Décaler la suite”, “Concentration”) inside the 56 pt tile, as built',
                 B('Fits') + ' Accept, Discard and the footnote; the carry buttons wrap to a second line in French; toasts grow to two lines',
                 Q('Flag') + ' German and French release notes (“Tagesform”, “Forme de la journée”) and the move answer (“Rändern”, “bords”) carry the same out-of-date wording as English')
s5 = row(lang_col('de', 'Deutsch'), lang_col('fr', 'Français'), col(700, label('What the pass found'), FINDINGS))
RULES = [('Proposals before writes', 'Place them (carry to next week) is a proposal: nothing moves before you accept. Leave in Inbox and Disconnect ask or offer Undo.'),
         ('No shame', '“No streaks here — just what happened.” The week is never compared with another week, and unfinished is never red.'),
         ('Yours to share', 'The share image shows no titles unless you switch them on; feedback never includes what your tasks say.'),
         ('On this device', 'App lock and Help with thinking are per device; calendar access is asked once.'),
         ('Same everywhere (R-13)', 'Every screen on every platform; the web has no device calendars or lock switch, and says so.'),
         ('Text from the app', 'Every string is built (app_en, app_de, app_fr). Three flags: the Calendar tab has no string, and two built texts are out of date.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 · R2-24</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">The rest of the app</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">This week, Calendars, App lock, Help and about, installing on the web, and a German and French long-string pass. Every platform; only what is built is drawn. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed · ED-325 · 14 Nov 2026'), tag('tn', 'iPhone, Android, iPad, Mac, web'), tag('tn', '@@THEME@@'))
page_body = (body + section('1 · This week', s1) + section('2 · Calendars', s2 + s2b) + section('3 · App lock', s3) + section('4 · Help and about, and installing on the web', s4)
             + section('5 · German and French', s5) + section('Rules', rules))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-24 · The rest of the app</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-24-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-24.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-24.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('class="blk-d', 'class="blk').replace('<title>E · R2-24 · The rest of the app</title>', '<title>E · R2-24 · The rest of the app · Dark</title>')
open('project/E-R2-24-Dark.dc.html', 'w', encoding='utf-8').write(dk)
print('ok')
