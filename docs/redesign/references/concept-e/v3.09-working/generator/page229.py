# R2-29 · Android parity (gap pass): Minimal Settings, Reality and learning, launcher shortcuts, Help and about,
# Calendars, App lock and Duplicate day, drawn on Android where only iPhone was drawn. Built behaviour and strings only.
_p = open(os.path.join(HERE, '..', 'r228', 'page228.py'), encoding='utf-8').read()
exec(_p[:_p.rindex('# ---------------------------------------------------------------- page')])
AF = 'Roboto, system-ui, sans-serif'
AW, AH = 412, 892


def a56(t, sub=None, sw=None, lead=None):
    r = arow(t, sub, sw, lead=lead)
    return r if sub else r.replace('min-height: 72px', 'min-height: 56px', 1)


def acard(rows): return '<div style="margin: 0 16px; border-radius: 20px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s</div>' % ''.join(rows)
def afoot(t): return '<div style="padding: 8px 32px 0; font: 400 13px/18px %s; color: #4E4757;">%s</div>' % (AF, t)
def aintro(t): return '<div style="padding: 0 16px 6px; font: 400 14px/20px %s; color: #4E4757;">%s</div>' % (AF, t)


# The approved minimal NavigationBar (G1-5, ED-068): Now, Today, Inbox 3.
_now_tab = ('<a href="#" style="display: flex; flex-direction: column; align-items: center; gap: 4px; text-decoration: none; color: #4E4757; font: 500 12px Roboto, system-ui, sans-serif;"><span style="width: 64px; height: 32px; display: flex; align-items: center; justify-content: center;">'
            '<svg class="i" width="22" height="22" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="5" fill="currentColor"></circle></svg></span>Now</a>\n   ')
_ba = BAR_A.replace('repeat(4, minmax(0, 1fr))', 'repeat(3, minmax(0, 1fr))', 1)
_k = _ba.index('<a href="#"'); _ba = _ba[:_k] + _now_tab + _ba[_k:]
_c = _ba.index('<a href="#" style', _ba.index('Inbox</a>')); _ba = _ba[:_c] + _ba[_ba.index('</nav>'):]
BAR_AMIN = _ba


def withbar_min(fr):
    k = fr.rindex('</div>'); return fr[:k] + BAR_AMIN + fr[k:]


def snack(fr, t, act=None, bottom=110):
    a = ('<span role="button" style="height: 40px; padding: 0 8px; display: flex; align-items: center; font: 500 14px %s; color: #A3E2D9;">%s</span>' % (AF, act)) if act else ''
    s = ('<div role="status" style="position: absolute; left: 16px; right: 16px; bottom: %dpx; z-index: 40; min-height: 48px; border-radius: 8px; background: #322F37; color: #F5EFF7; display: flex; align-items: center; gap: 8px; padding: 6px 8px 6px 16px; box-sizing: border-box; box-shadow: 0 3px 8px rgba(36,31,43,.2);">'
         '<span style="flex: 1; font: 400 14px/20px %s;">%s</span>%s</div>') % (bottom, AF, t, a)
    k = fr.rindex('</div>'); return fr[:k] + s + fr[k:]


def asheet(fr, inner, top):
    s = ('<div style="position: absolute; inset: 0; background: rgba(36,31,43,.32); z-index: 30;"></div>'
         '<div role="dialog" style="position: absolute; left: 0; right: 0; top: %dpx; bottom: 0; z-index: 31; border-radius: 28px 28px 0 0; background: #F6F1EA; padding: 10px 20px 0; font-family: %s;">'
         '<div aria-hidden="true" style="width: 32px; height: 4px; border-radius: 2px; background: #7A7280; margin: 6px auto 14px;"></div>%s</div>') % (top, AF, inner)
    k = fr.rindex('</div>'); return fr[:k] + s + fr[k:]


# ---------------------------------------------------------------- 1 · Minimal Settings
SYNCL = '<div style="padding: 0 16px 10px; font: 400 14px %s; color: #4E4757; display: flex; align-items: center; gap: 6px;"><span style="width: 8px; height: 8px; border-radius: 50%%; background: #1D6436;"></span>Synced · 10:42</div>' % AF
A_MIN = withbar_min(apage('Settings', SYNCL + acard([a56('Layout', 'Minimal'), a56('Wake Up', '7:00 AM'), a56('Wake Up alarm', 'On'), a56('Wake Up options'), a56('Wind Down', '11:00 PM'),
                                                      a56('Remind me when a dot starts', sw=True), a56('Calendars'), a56('Account and sync'), a56('Everything else…')])
                          + asec('Check it works') + acard([a56('Send me a test alarm', 'Check that a reminder really reaches you')])))
ROOT = [('Your day', 'Wake Up and Wind Down, learning'), ('Planning', 'Durations, snap, shifting, nudges, Routines'), ('Reminders', 'Alerts, sounds, quiet hours, health'),
        ('Appearance', 'Theme, accent, language, time, week start'), ('Data and privacy', 'Calendars, export and backups, Trash, app lock'), ('Help and about', 'Help, what&#39;s new, feedback')]
A_EVERY = withbar_min(apage('Everything else…', acard([a56('Search', lead=('#4E4757', sv(SEARCH_I, 22)))]) + '<div style="height: 12px;"></div>' + acard([a56(t, s) for t, s in ROOT])))

# ---------------------------------------------------------------- 2 · Reality and learning (Settings › Your day › Learning)
def add_end(r, h): k = r.rindex('</div>'); return r[:k] + h + r[k:]


A_LEARN0 = withbar(apage('Learning', asec('Learning')
                         + acard([add_end(a56('Reality thread', 'Dottoday is learning how your days really go. Your reality thread appears after about 10 finished tasks.'), '<span class="num" style="font: 500 14px %s; color: #4E4757; flex: none;">6/10</span>' % AF),
                                  a56('Task lengths', 'Ready for 12 tasks'), a56('Step lengths', 'Ready for 5 steps'),
                                  add_end(a56('Energy suggestions', 'After 20 finished high-energy tasks · 7 so far'), '<span aria-disabled="true" style="opacity: .38; display: flex; flex: none;">%s</span>' % and_switch(False))])
                         + afoot('Learning happens on your device. Your actual start and end times sync with your account like the rest of your plan; the learned numbers themselves are never uploaded.')), True)
_atip = EP_ATODAY[EP_ATODAY.index('<!-- tip (M3 filled card) -->'):EP_ATODAY.index('<!-- thread')]
A_CAPTION = ('<!-- tip -->\n  <div style="position: absolute; top: 204px; left: 16px; right: 16px; min-height: 44px; border-radius: 18px; background: #F3ECE2; display: flex; align-items: center; padding-left: 16px; gap: 6px; font: 400 14px/19px %s; color: #241F2B;">'
             '<span style="flex: 1; padding: 6px 0;">Your reality thread appears after about 10 finished tasks · 6 so far</span><button aria-label="Hide until tomorrow" style="width: 48px; height: 48px; border: 0; background: transparent; color: #4E4757; display: flex; align-items: center; justify-content: center;">%s</button></div>\n  ') % (AF, sv(X_I, 16))
A_PENDING = EP_ATODAY.replace(_atip, A_CAPTION, 1)
A_SEG = ('<!-- tip -->\n  <div style="position: absolute; top: 204px; left: 16px; height: 44px; display: flex; align-items: center;"><div role="radiogroup" aria-label="Plan or reality" style="display: flex; height: 40px; border-radius: 20px; box-shadow: inset 0 0 0 1px #7A7280; overflow: hidden; font: 500 14px %s;">'
         '<span role="radio" aria-checked="false" style="width: 96px; display: flex; align-items: center; justify-content: center; color: #241F2B; box-shadow: inset -1px 0 0 #7A7280;">Plan</span>'
         '<span role="radio" aria-checked="true" style="width: 112px; display: flex; align-items: center; justify-content: center; gap: 6px; background: #CFE8E4; color: #062F2C;">%sReality</span></div></div>\n  ') % (AF, sv(CHECK, 16, 2.6))
A_REALROWS = [('6:45–7:30 AM</div>', '6:50–7:40 AM · planned 6:45 AM · took 50 min</div>'), ('>7:30–7:45 AM</div>', '>7:40–7:55 AM · planned 7:30 AM · took 15 min</div>'),
              ('8:00–8:15 AM <svg', '8:00–8:20 AM · took 20 min <svg'),
              ('9:00–11:00 AM · <span style="color: #11615C; font-weight: 700;">Now, 18 min left</span>', '9:05 AM – now · 1 h 37 in · <span role="button" style="color: #11615C; font-weight: 700; text-decoration: underline dotted;">usually 2 h 20</span>'),
              ('>10:30–11:00 AM</div>', '>10:30–11:00 AM · not started yet</div>')]


def a_reality():
    fr = EP_ATODAY.replace(_atip, A_SEG, 1)
    for a, b in A_REALROWS:
        assert fr.count(a) == 1, a
        fr = fr.replace(a, b, 1)
    ins = ('<div role="status" style="position: absolute; left: 16px; right: 16px; bottom: 170px; z-index: 30; border-radius: 16px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08), 0 6px 18px rgba(36,31,43,.14); padding: 10px 8px 10px 16px; display: flex; align-items: center; gap: 10px;">'
           '<span style="flex: 1; font: 500 14px/19px %s; color: #241F2B;">Deep work: roadmap usually takes you 2 h 20 · Add will suggest it</span>'
           '<span role="button" style="height: 40px; padding: 0 12px; display: flex; align-items: center; font: 500 14px %s; color: #11615C;">OK</span></div>') % (AF, AF)
    k = fr.rindex('</div>'); return fr[:k] + ins + fr[k:]


A_REAL = a_reality()

# ---------------------------------------------------------------- 3 · Launcher shortcuts; Help and about
APPICON = ('<span aria-hidden="true" style="width: 56px; height: 56px; border-radius: 50%; background: #11615C; display: flex; align-items: center; justify-content: center; flex: none;">'
           '<span style="width: 34px; height: 34px; border-radius: 50%; box-shadow: inset 0 0 0 4px #FEFEFE; display: flex; align-items: center; justify-content: center;"><span style="width: 12px; height: 12px; border-radius: 50%; background: #FEFEFE;"></span></span></span>')
SMALLICON = APPICON.replace('56px', '32px').replace('34px', '20px').replace('4px #FEFEFE', '2.5px #FEFEFE').replace('12px; height: 12px', '7px; height: 7px')


def a_shortcuts():
    def other(c): return '<span aria-hidden="true" style="width: 56px; height: 56px; border-radius: 50%%; background: %s; flex: none; opacity: .9;"></span>' % c
    grid = ''.join('<div style="display: flex; flex-direction: column; align-items: center; gap: 6px; width: 72px; font: 400 12px %s; color: #FEFEFE;">%s<span>%s</span></div>' % (AF, ic, n)
                   for ic, n in [(other('@@I1@@'), 'Clock'), (other('@@I2@@'), 'Photos'), (APPICON, 'Dottoday'), (other('@@I3@@'), 'Maps')])
    sc = ''.join('<div role="menuitem" style="height: 52px; display: flex; align-items: center; gap: 14px; padding: 0 16px; font: 500 15px %s; color: #241F2B;">%s%s</div>' % (AF, SMALLICON, t) for t in ['Add task', 'What&#39;s next'])
    menu = ('<div role="menu" aria-label="Dottoday shortcuts" style="position: absolute; left: 76px; top: 548px; width: 240px; border-radius: 24px; background: #F6F1EA; padding: 6px 0; box-shadow: 0 8px 24px rgba(0,0,0,.28); z-index: 5;">%s'
            '<div style="display: flex; gap: 6px; padding: 8px 12px 6px;"><span role="button" style="height: 36px; padding: 0 14px; border-radius: 18px; background: #ECE5DC; display: flex; align-items: center; font: 500 13px %s; color: #4E4757;">App info</span>'
            '<span role="button" style="height: 36px; padding: 0 14px; border-radius: 18px; background: #ECE5DC; display: flex; align-items: center; font: 500 13px %s; color: #4E4757;">Widgets</span></div></div>') % (sc, AF, AF)
    inner = ('<div style="position: absolute; inset: 0; background: linear-gradient(170deg, @@A1@@, @@A2@@ 60%, @@A3@@);"></div>'
             '<div style="position: absolute; inset: 0; background: rgba(0,0,0,.18);"></div>'
             + abs_(24, 440, 364, '<div style="display: flex; justify-content: space-between;">%s</div>' % grid) + menu)
    return phone(inner, android=True)


A_SHORT = a_shortcuts()
A_HA = withbar(apage('Help and about', acard([a56('Help'), a56('About Dottoday', '1.2.0'), a56('Send feedback')])), True)


def aq(q, a=None, last=False):
    return ('<div style="padding: 14px 16px;%s"><div style="display: flex; align-items: center; gap: 8px;"><span style="flex: 1; font: 400 16px/22px %s;">%s</span><span style="color: #4E4757;">%s</span></div>%s</div>') % (
        '' if last else ' box-shadow: inset 0 -1px 0 rgba(36,31,43,.08);', AF, q, sv('<path d="M6 15l6-6 6 6"></path>' if a else DOWN_I, 18),
        ('<div style="margin-top: 6px; font: 400 14px/20px %s; color: #4E4757;">%s</div>' % (AF, a)) if a else '')


WAKE_A = ('Wake Up rings at the start of your day, like an alarm where your phone allows it. When you stop it, a card shows your day and starts it with one tap. If nothing has started a few minutes later, one gentle check asks. '
          'Each has its own switch in Settings › Day shape › Wake Up options.<br><span style="display: block; margin-top: 6px; color: #9A5A0E;">Wake Up rings as a notification for now, so Do Not Disturb and silent mode can quiet it. Allow Alarms &amp; reminders to ring it like an alarm.</span>')
A_HELP = withbar(apage('Help', aintro('Quick answers. Anything else? Send feedback below.') + acard([aq('How do I move a task?'), aq('I&#39;m running late. Can everything move?'), aq('How do repeating tasks work?'),
                                                                                                    aq('Can I add many tasks at once?'), aq('Are there keyboard shortcuts?'), aq('How does Wake Up work?', WAKE_A, True)])), True)
A_ABOUT = withbar(apage('About Dottoday', asec('About') + acard([a56('Version', '1.2.0 (4)'), a56('What&#39;s new'), a56('Open-source licences')])), True)

# ---------------------------------------------------------------- 4 · Calendars and App lock
def crow(c, t, sub=None, on=True): return arow(t, sub, on, lead=(c, '<span style="width: 14px; height: 14px; border-radius: 50%%; background: %s; display: block;"></span>' % c))


A_CAL1 = withbar(apage('Calendars', aintro('Your calendar events on the timeline, next to your tasks. Free, always.')
                       + asec('On this device') + acard([crow(BLU, 'Work'), crow(GRN, 'Family'), crow(GRY, 'Holidays', 'Read-only', False)])
                       + asec(ACCT) + acard([crow(VIO, 'Personal'), crow(PNK, 'Birthdays', 'Read-only', False), a56('<span style="color: #11615C; font-weight: 500;">Disconnect</span>')])
                       + asec('Google and Microsoft') + acard([a56('<span style="color: #11615C; font-weight: 500;">Connect Microsoft Outlook</span>')])), True)
A_CALDEN = snack(withbar(apage('Calendars', aintro('Your calendar events on the timeline, next to your tasks. Free, always.')
                               + anotice('Calendar access is off', 'Dottoday can&#39;t show your events until calendar access is allowed in your device settings.', 'Open settings')
                               + asec('Google and Microsoft') + acard([a56('Sign in to connect Google or Microsoft')])), True),
                 'Open your device&#39;s Settings, find Dottoday and allow access to Calendars.')
A_DISC = over(A_CAL1, m3_dialog('Disconnect %s?' % ACCT, 'Its events leave your timeline on every device. Events with your subtasks or notes go to Trash.', 'Cancel', 'Disconnect'), 300, 312)
A_LOCKSET = withbar(apage('Privacy', asec('APP LOCK') + acard([arow('Lock Dottoday', 'Ask for your face, fingerprint or passcode', True), a56('Lock after', '1 minute')])), True)
FP_I = '<path d="M12 11v4M8 13c0-2.2 1.8-4 4-4s4 1.8 4 4v1M5.5 12a6.5 6.5 0 0 1 13 0v2M9 18c.6-1 1-2.4 1-4M15 15.5c0 1.6-.4 3-1 4"></path>'


def a_prompt():
    sh = ('<div style="position: absolute; inset: 0; background: rgba(0,0,0,.4); z-index: 30;"></div>'
          '<div role="dialog" aria-label="System unlock prompt" style="position: absolute; left: 0; right: 0; bottom: 0; z-index: 31; border-radius: 28px 28px 0 0; background: #ECE5DC; padding: 28px 24px 36px; font-family: %s; text-align: center; color: #241F2B;">'
          '<div style="display: flex; justify-content: center;">%s</div><div style="font: 400 22px/28px %s; margin-top: 14px;">Authentication required</div><div style="font: 400 14px/20px %s; color: #4E4757; margin-top: 6px;">Unlock Dottoday</div>'
          '<div style="display: flex; justify-content: center; margin: 26px 0 22px; color: #11615C;">%s</div>'
          '<div style="display: flex; justify-content: space-between;"><span role="button" style="height: 40px; padding: 0 12px; display: flex; align-items: center; font: 500 14px %s; color: #11615C;">Use PIN</span>'
          '<span role="button" style="height: 40px; padding: 0 12px; display: flex; align-items: center; font: 500 14px %s; color: #11615C;">Cancel</span></div></div>') % (
        AF, SMALLICON, AF, AF, sv(FP_I, 56), AF, AF)
    fr = A_LOCK; k = fr.rindex('</div>'); return fr[:k] + sh + fr[k:]


A_PROMPT = a_prompt()


def a_recents():
    card = lambda x, inner, lab: ('<div style="position: absolute; left: %dpx; top: 150px; width: 300px;"><div style="display: flex; align-items: center; gap: 8px; margin-bottom: 10px; font: 500 14px %s; color: #FEFEFE;">%s%s</div>'
                                  '<div style="height: 560px; border-radius: 24px; overflow: hidden; %s"></div></div>') % (x, AF, SMALLICON if lab == 'Dottoday' else '<span style="width: 32px; height: 32px; border-radius: 50%; background: @@I2@@;"></span>', lab, inner)
    inner = ('<div style="position: absolute; inset: 0; background: linear-gradient(170deg, @@A1@@, @@A2@@ 60%, @@A3@@);"></div><div style="position: absolute; inset: 0; background: rgba(0,0,0,.35);"></div>'
             + card(-232, 'background: @@I1@@;', 'Photos') + card(56, 'background: #FBF7F1;', 'Dottoday') + card(372, 'background: @@I3@@;', 'Maps'))
    return phone(inner, android=True)


A_RECENTS = a_recents()

# ---------------------------------------------------------------- 5 · Duplicate day
MENU = ['Show less', 'Running late…', 'Review the day', 'Brain dump', 'Pick today&#39;s one thing…', 'Low-energy mode', 'This week', 'Duplicate day…', 'Copy day as text', 'Routines…']


def a_menu():
    items = ''.join('<div role="menuitem" style="height: 48px; display: flex; align-items: center; padding: 0 16px; font: 400 15px %s; color: #241F2B;%s">%s</div>' % (AF, ' background: rgba(17,97,92,.12);' if t == 'Duplicate day…' else '', t) for t in MENU)
    m = ('<div style="position: absolute; inset: 0; z-index: 29;"></div><div role="menu" aria-label="Day menu" style="position: absolute; left: 16px; bottom: 166px; width: 236px; z-index: 30; border-radius: 4px; background: #F6F1EA; padding: 8px 0; box-shadow: 0 4px 12px rgba(36,31,43,.2), 0 1px 3px rgba(36,31,43,.14);">%s</div>') % items
    fr = EP_ATODAY; k = fr.rindex('</div>'); return fr[:k] + m + fr[k:]


A_MENU = a_menu()


def a_month(sel=6, today=3):
    head = ''.join('<span style="text-align: center; font: 500 12px %s; color: #4E4757;">%s</span>' % (AF, d) for d in 'MTWTFSS')
    cells = ['<span></span>'] * 6  # Nov 2026 starts on a Sunday
    for d in range(1, 31):
        st = 'background: #11615C; color: #fff;' if d == sel else ('box-shadow: inset 0 0 0 1.5px #11615C; color: #0B4642;' if d == today else ('color: #241F2B; opacity: .5;' if d < today else 'color: #241F2B;'))
        cells.append('<span role="button" aria-label="%d November%s" class="num" style="height: 44px; border-radius: 22px; display: flex; align-items: center; justify-content: center; font: 500 15px %s; %s">%d</span>' % (d, ', selected' if d == sel else '', AF, st, d))
    return ('<div style="font: 400 22px/28px %s; color: #241F2B; margin-bottom: 12px;">Copy to which day?</div>'
            '<div style="display: flex; justify-content: space-between; align-items: center; margin: 0 0 8px;"><span style="font: 500 15px %s;">November 2026</span><span style="color: #4E4757; display: flex; gap: 22px;">%s%s</span></div>'
            '<div style="display: grid; grid-template-columns: repeat(7, 1fr); gap: 4px;">%s%s</div>') % (AF, AF, sv('<path d="M15 6l-6 6 6 6"></path>', 20), sv(CHEV, 20), head, ''.join(cells))


A_DUP = asheet(EP_ATODAY, a_month(), 420)
A_DUPDONE = snack(EP_ATODAY, 'Copied 8 tasks', 'Undo', 176)

# ---------------------------------------------------------------- page
SC = 0.78


def sc(fr): return '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>' % (round(AW * SC) + 8, round(AH * SC) + 8, AW, AH, SC, fr)


CW = round(AW * SC) + 8
def fc(lab, fr, *n): return col(CW, label(lab), sc(fr), notes(*n))


B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 32px; align-items: flex-start;">%s</div>' % ''.join(c)
s1 = row(fc('Android · minimal Settings', A_MIN, B('Built') + ' The nine minimal rows, Layout first, and Check it works below; Material rows and switch', B('Built') + ' Layout is a choice: Minimal or Full'),
         fc('Android · Everything else…', A_EVERY, B('Built') + ' Search first, then the whole Settings tree', D('Design-only') + ' The approved root groups (G2-4, ED-084)'),
         fc('Android · Settings › Learning', A_LEARN0, B('Built') + ' Status rows, no switch: learning always runs', B('Built') + ' Energy suggestions is the one switch, off until 20 high-energy tasks'),
         fc('Android · before the reveal', A_PENDING, B('Built') + ' The caption in the tip slot; × hides it until tomorrow'),
         fc('Android · Reality on', A_REAL, B('Built') + ' A Material segmented button, Plan | Reality, on today only', B('Built') + ' planned, took, … in, not started yet; the insight with OK'))
s2 = row(fc('Android · long-press the app icon', A_SHORT, B('Built') + ' Two static shortcuts: Add task (Quick Add over Today) and What’s next (Today)', B('Built') + ' Both use the app icon; App info and Widgets are the launcher’s own', P('Not built') + ' iPhone has no Home Screen quick actions; it has Siri and Shortcuts (R2-24)'),
         fc('Android · Help and about', A_HA, B('Built') + ' Help, About Dottoday, Send feedback', B('Built') + ' No Siri &amp; Shortcuts row on Android'),
         fc('Android · Help', A_HELP, B('Built') + ' The six questions as expanding rows', B('Built') + ' Wake Up adds Android’s own line when alarms aren’t allowed', P('Copy') + ' The answer still says “Day shape”: stale text, for the separate copy PR'),
         fc('Android · About Dottoday', A_ABOUT, B('Built') + ' Version with its build number; licences open the system page', B('Built') + ' Send feedback is the iPhone sheet in Material (R2-24)'))
s3 = row(fc('Android · Calendars', A_CAL1, B('Built') + ' Device calendars and Google/Microsoft accounts, each with a switch; Read-only where it applies', B('Built') + ' Device calendars have no Disconnect: switch them off'),
         fc('Android · calendar access off', A_CALDEN, B('Built') + ' Open settings can’t open the page on Android, so a line says where to go'),
         fc('Android · Disconnect', A_DISC, B('Built') + ' A Material dialog; Disconnect is the filled button'),
         fc('Android · Settings › Privacy', A_LOCKSET, B('Built') + ' Lock Dottoday and Lock after, as on iPhone'),
         fc('Android · unlocking', A_PROMPT, B('Built') + ' The system sheet with “Unlock Dottoday”; it falls back to PIN, pattern or password', B('Built') + ' Cancel or a failed try leaves the locked screen with Unlock; no message', D('Design-only') + ' System text is the phone’s own'))
s4 = row(fc('Android · Recents while locked', A_RECENTS, B('Built') + ' With the lock on, Recents shows a blank card and screenshots are blocked'),
         fc('Android · Day menu', A_MENU, B('Built') + ' The Day button opens the menu; Duplicate day… and Copy day as text sit together', B('Built') + ' Full layout only'),
         fc('Android · Copy to which day?', A_DUP, B('Built') + ' A month in a sheet; tap a day and it copies at once, no confirm step'),
         fc('Android · copied', A_DUPDONE, B('Built') + ' “Copied 8 tasks” with Undo; or “That day has nothing to copy”', B('Built') + ' One-off tasks only (Team standup repeats, so it stays), fresh and not done'))
RULES = [('Same features (R-13)', 'Everything drawn on iPhone is on Android in Material controls; only Siri &amp; Shortcuts and Home Screen quick actions differ.'),
         ('Material, not a copy', 'Rows, switches, dialogs, menus and snackbars are Material 3; time pickers stay the same wheel everywhere.'),
         ('Privacy', 'Learning stays on the device; with App lock on, nothing shows in Recents or screenshots.'),
         ('Calm', 'A failed unlock and a denied permission show no error, just the way back.'),
         ('Undo', 'Duplicate day copies at once and offers Undo; it writes nothing else.'),
         ('Text from the app', 'Every string is built (app_en.arb and the Android shortcut labels). Tasks and dates are examples. No new copy.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 GAP PASS · R2-29</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Android parity</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">The Android screens that were only described in notes: minimal Settings, learning and the Reality thread, launcher shortcuts, Help and about, Calendars, App lock and Duplicate day. As built. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed · gap pass'), tag('tn', 'Android phone'), tag('tn', '@@THEME@@'))
page_body = (body + section('1 · Minimal Settings, learning and the Reality thread', s1) + section('2 · Launcher shortcuts, Help and about', s2)
             + section('3 · Calendars and App lock', s3) + section('4 · Recents, and Duplicate day', s4) + section('Rules', rules))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-29 · Android parity</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-29-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-29.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-29.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('class="blk-d', 'class="blk').replace('<title>E · R2-29 · Android parity</title>', '<title>E · R2-29 · Android parity · Dark</title>')
open('project/E-R2-29-Dark.dc.html', 'w', encoding='utf-8').write(dk)
print('ok')
