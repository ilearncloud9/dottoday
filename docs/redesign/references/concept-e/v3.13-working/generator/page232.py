# R2-32 · Owner answers (ED-336): permanent delete and Empty Trash, Today opening at now, the two "After" labels,
# and missions on tablets without movement. Built strings except the flagged new copy.
_p = open(os.path.join(HERE, '..', 'r231', 'page231.py'), encoding='utf-8').read()
exec(_p[:_p.rindex('# ---------------------------------------------------------------- page')])
_q = open(os.path.join(HERE, '..', 'r221', 'page221.py'), encoding='utf-8').read()
exec(_q[_q.index('# ---------------------------------------------------------------- 1 · Settings › Data and privacy'):_q.rindex('# ---------------------------------------------------------------- page')])
sys.path.insert(0, os.path.join(HERE, '..', 'iconaudit'))
import settings_icons as SI
ICONS = SI.canonical(os.path.join(HERE, '..', 'iconaudit', 'tiles.json'))
def stile(t, size=30, r=8, icon=18): return SI.tile(*ICONS[t], False, size, r, icon) if t in ICONS else SI.tile('teal', M_IC.get(t, ''), False, size, r, icon) if False else (SI.tile(*ICONS[t], False, size, r, icon) if t in ICONS else '<span aria-hidden="true" style="width: 30px; height: 30px; border-radius: 8px; background: #E2EFEC; color: #0B4642; display: flex; align-items: center; justify-content: center; flex: none;">%s</span>' % sv('<path d="%s"></path>' % M_IC[t], 18))
NEW = lambda t: '<span title="new copy" style="box-shadow: inset 0 -2px 0 #D9A23A;">%s</span>' % t   # new copy is underlined amber on the board


# ---------------------------------------------------------------- 1 · Permanent delete and Empty Trash
TR4 = [('Pick up parcel', GRN, 'Deleted today · 30 days left'), ('Dentist', GRY, 'Deleted yesterday · 29 days left'), ('Old: book flights', BLU, 'Deleted 12 Oct · 8 days left'), ('Call the bank', AMB, 'Deleted 9 Oct · 5 days left')]


def trash_rows(f, android=False):
    rows = ''
    for i, (t, c, sub) in enumerate(TR4):
        rows += ('<div style="min-height: 60px; display: flex; align-items: center; gap: 12px; padding: 8px 14px;%s"><span aria-hidden="true" style="width: 22px; height: 22px; border-radius: 50%%; box-shadow: inset 0 0 0 3px %s; flex: none;"></span>'
                 '<span style="flex: 1; min-width: 0;"><span style="display: block; font: 600 16px %s;">%s</span><span style="display: block; font: 400 13px %s; color: #6A6273;">%s</span></span>'
                 '<span role="button" style="font: 600 15px %s; color: #4E4757; padding: 0 4px;">%s</span><span role="button" style="font: 600 15px %s; color: #11615C; padding: 0 4px;">Restore</span></div>') % (
            '' if i == len(TR4) - 1 else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', c, f, t, f, sub, f, NEW('Delete now'), f)
    return ('<div style="border-radius: 18px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s</div>'
            '<div style="display: flex; justify-content: center; margin-top: 16px;"><span role="button" style="height: 44px; padding: 0 20px; border-radius: 22px; box-shadow: inset 0 0 0 1.5px rgba(36,31,43,.18); display: flex; align-items: center; font: 600 15px %s; color: #241F2B;">%s</span></div>'
            '<div style="text-align: center; font: 400 13px %s; color: #6A6273; margin-top: 10px;">Deleted tasks stay 30 days</div>') % (rows, f, NEW('Empty Trash'), f)


I_TR2 = sheet(IDP, 'Trash', trash_rows(IOSF), 330)
A_TR2 = sheet(ADP, 'Trash', trash_rows(AF, True), 330, True, 28)
DEL_T, DEL_B = 'Delete “Pick up parcel” now?', 'It can&#39;t be restored after this.'
EMP_T, EMP_B = 'Empty Trash?', '4 tasks will be deleted. They can&#39;t be restored after this.'
def over2(fr, inner, top, w):
    o = over(fr, inner, top, w)
    k = o.rindex('z-index: 40;"></div>')
    o = o[:k] + 'z-index: 50;"></div>' + o[k + len('z-index: 40;"></div>'):]
    k = o.rindex('z-index: 41;">')
    return o[:k] + 'z-index: 51;">' + o[k + len('z-index: 41;">'):]


I_DEL = over2(I_TR2, ios_alert(DEL_T, DEL_B, 'Cancel', 'Delete'), 360, 270)
A_EMP = over2(A_TR2, m3_dialog(EMP_T, EMP_B, 'Cancel', 'Empty Trash'), 340, 312)
I_DONE = with_toast(sheet(IDP, 'Trash', '<div style="font: 400 16px %s; color: #6A6273; padding: 8px 0;">Trash is empty</div>' % IOSF, 330), NEW('Trash emptied'))

# ---------------------------------------------------------------- 2 · Today opens at now
def short(fr, h=700): return fr.replace('height: 892px;', 'height: %dpx;' % h, 1)


def scrolled(fr, dy):
    i = fr.index('<div role="list" aria-label="Tuesday timeline"')
    lst = _frame(fr, i)
    j = lst.index('>') + 1
    new = lst[:j] + '<div style="transform: translateY(-%dpx);">' % dy + lst[j:-len('</div>')] + '</div></div>'
    return fr.replace(lst, new, 1)


T_TOP = short(EP_ATODAY)
T_NOW = short(scrolled(EP_ATODAY, 150))

# ---------------------------------------------------------------- 3 · The two "After" labels (Settings › Wake Up options)
I_AFTER = withbar(ipage('Wake Up options', 'Wake Up and Wind Down',
                        igroup([irow('amber', '<path d="M3 18h18M6 14a6 6 0 0 1 12 0M12 4v3M5 8l1.5 1.5M19 8l-1.5 1.5"></path>', 'Morning card', sub='Your day on one screen when you&#39;re up', sw=True),
                                irow('amber', '<path d="M3 12h14M13 7l5 5-5 5M21 5v14"></path>', 'Offer to shift the day when I&#39;m up after plan', sw=True),
                                irow('teal', '<circle cx="12" cy="12" r="8.5"></circle><path d="M12 7.5V12l3 2"></path>', NEW('Offer after'), value='20 min')], 'Morning card')
                        + igroup([irow('green', '<path d="M5 12.5l4.5 4.5L19 7.5"></path>', 'Check I&#39;ve started', sub='One nudge if nothing has started a few minutes after I&#39;m up', sw=True),
                                  irow('teal', '<circle cx="12" cy="12" r="8.5"></circle><path d="M12 7.5V12l3 2"></path>', NEW('Check after'), value='10 min'),
                                  irow('teal', '<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4zM10 20a2 2 0 0 0 4 0"></path>', 'As', value='Gentle ping')], 'Check I&#39;ve started')))

# ---------------------------------------------------------------- 4 · Missions on tablets (no movement)
MOVE = ['Stand up', 'Walk', 'Light']
def tab_missions():
    def mr(t, sel=False, off=False, last=False):
        ic = stile(t) if t in M_IC else ''
        return ('<div role="radio" aria-checked="%s" aria-disabled="%s" style="min-height: 52px; display: flex; align-items: center; gap: 12px; padding: 6px 16px;%s%s">%s<span style="flex: 1;"><span style="display: block; font: 400 16px %s;">%s</span>%s</span>%s</div>') % (
            'true' if sel else 'false', 'true' if off else 'false', '' if last else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.10);', ' opacity: .5;' if off else '', ic, IOSF, t,
            ('<span style="display: block; font: 400 13px %s; color: #6A6273;">%s</span>' % (IOSF, NEW('On your phone; it needs you to move'))) if off else '',
            ('<span style="color: #11615C;">%s</span>' % sv(CHECK, 18, 2.6)) if sel else '')
    rows = ''.join(mr(t, sel=(t == 'Breathe')) for t in ['Breathe', 'Catch the dot', 'Pick today&#39;s one thing']) + ''.join(mr(t, off=True, last=(t == 'Light')) for t in MOVE)
    pane = ('<div style="padding: 24px 32px; font-family: %s;"><div style="font: 700 28px %s;">Missions</div><div style="font: 400 15px %s; color: #4E4757; margin: 6px 0 16px;">On this iPad</div>'
            '<div style="border-radius: 18px; background: #FFFDF9; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s</div></div>') % (IOSF, IOSF, IOSF, rows)
    return ('<div style="position: relative; width: 1180px; height: 820px; border-radius: 30px; background: #F3ECE2; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 12px #241F2B, 0 0 0 13px rgba(36,31,43,.35);">'
            '<div style="position: absolute; left: 0; top: 0; bottom: 0; width: 380px; background: #ECE5DC; padding: 60px 20px; box-sizing: border-box; font: 400 16px %s;"><div style="font: 700 28px %s; margin-bottom: 14px;">Settings</div>%s</div>'
            '<div style="position: absolute; left: 380px; right: 0; top: 30px; bottom: 0; background: #FBF7F1;">%s</div></div>') % (
        IOSF, IOSF, ''.join('<div style="height: 44px; display: flex; align-items: center; gap: 12px; padding: 0 10px; border-radius: 10px;%s">%s%s</div>' % (' background: rgba(17,97,92,.12); font-weight: 600;' if g == 'Your day' else '', stile(g), g) for g in ['Your day', 'Planning', 'Reminders', 'Appearance', 'Data and privacy', 'Help and about']), pane)


T_MISS = tab_missions()

# ---------------------------------------------------------------- page
def f2(lab, fr, w, h, s, *n): return col(round(w * s) + 4, label(lab), scaled(fr, w, h, s), notes(*n))
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
NC = lambda t: tag('th', 'New copy') + ' ' + t
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start; flex-wrap: wrap;">%s</div>' % ''.join(c)
s1 = row(f2('iPhone · Trash with Delete now and Empty Trash', I_TR2, 390, 844, 0.62, D('Design-only') + ' Delete now on every row, beside Restore; Empty Trash under the list (ED-336, PRD F7.6)', NC('Delete now, Empty Trash')),
         f2('iPhone · Delete now confirm', I_DEL, 390, 844, 0.62, NC('“Delete “…” now?”, “It can’t be restored after this.”, Delete'), D('Design-only') + ' The confirm button is ink, never red'),
         f2('Android · Empty Trash confirm', A_EMP, 412, 892, 0.6, NC('“Empty Trash?”, “4 tasks will be deleted. They can’t be restored after this.”'), D('Design-only') + ' Mac and web: the same as a centred dialog (R2-30)'),
         f2('iPhone · after Empty Trash', I_DONE, 390, 844, 0.62, B('Built') + ' “Trash is empty”', NC('Trash emptied'), D('Design-only') + ' No Undo: the confirm said it can’t be restored'))
s2 = row(f2('Android, short screen · before: Today opens at the top', T_TOP, 412, 700, 0.62, B('Built') + ' Today opens at Wake Up; on short screens the current task sits under Day and Add'),
         f2('Android, short screen · Today opens at now', T_NOW, 412, 700, 0.62, D('Design-only') + ' Today opens scrolled so the current task is in view, on today only, every platform (ED-336)', D('Design-only') + ' With Reduce Motion it jumps; other days open at their first task'),
         f2('iPhone · Settings › Wake Up options', I_AFTER, 390, 844, 0.62, NC('Offer after and Check after replace the two “After” rows (ED-336); the pickers take the same titles'), B('Built') + ' Everything else on the page'))
s3 = row(f2('iPad · Settings › Missions (tablets)', T_MISS, 1180, 820, 0.62, D('Design-only') + ' On tablets only the missions without movement: Breathe, Catch the dot, Pick today’s one thing (ED-336)', NC('“On your phone; it needs you to move” under Stand up, Walk and Light'), D('Design-only') + ' Android tablets the same in Material; the mission screens are on R2-19-B'))
APPLIED = notes(B('Applied') + ' Mac context menus say Move to Trash ⌘⌫: E-FullA-v2, E-Minimal, E-G4-3-Narrow, E-DF3',
                B('Applied') + ' “Pull from inbox · 3” on the Full empty day: E-Phones, E-G4-7-States',
                B('Applied') + ' “Check after 10 min” on E-Phones’ Wake Up and Wind Down page',
                B('Applied') + ' Catch the dot: no red, “Tap the blue circle”; tablet missions labelled offered or phones only: E-R2-19-B, E-R2-19-B-2',
                B('Applied') + ' Onboarding prototype: the 13+ note on the last step, “Skip for now”, “Five is plenty to start with.”',
                P('No drawing') + ' The sync heading is read once by screen readers; web storage line dropped; Simulator only for CR-121')
RULES = [('Calm and clear', 'Delete now and Empty Trash ask once and say plainly that it can’t be undone; the button is ink, never red.'),
         ('Only on Accept', 'Nothing is deleted before the confirm; Restore stays one tap away until then.'),
         ('Now first', 'Today opens where you are in the day, never under the floating controls.'),
         ('Say which', 'Two settings never share one label; screen readers and pickers say which one they change.'),
         ('Tablets stay put', 'Missions that ask you to move stay on the phone.'),
         ('Copy', 'New copy is underlined amber on this board and needs the owner’s review; the rest is built.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 · R2-32</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Your answers, drawn</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">The close-out decisions (ED-336): permanent delete and Empty Trash, Today opening at now, two clear “After” labels, and missions on tablets without movement. Smaller answers are applied on their own boards. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed'), tag('tn', 'iPhone, Android, iPad'), tag('tn', '@@THEME@@'))
page_body = (body + section('1 · Permanent delete and Empty Trash', s1) + section('2 · Today opens at now, and the two “After” labels', s2)
             + section('3 · Missions on tablets', s3) + section('Applied on other boards', APPLIED) + section('Rules', rules))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-32 · Your answers</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-32-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-32.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-32.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B')
open('project/E-R2-32-Dark.dc.html', 'w', encoding='utf-8').write(dk.replace('<title>E · R2-32 · Your answers</title>', '<title>E · R2-32 · Your answers · Dark</title>'))
print('ok')
