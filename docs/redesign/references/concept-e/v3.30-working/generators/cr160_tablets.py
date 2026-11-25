"""E-CR160 tablet frames (ED-364): iPad landscape 1180x820 and Android
tablet expanded 1280x800. Copy is verbatim from the approved phone and
Mac/web frames (ED-222 to ED-230); tokens are the board's own."""
import json, os, sys

OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)

LIGHT = dict(ground='#FBF7F1', sidebar='#F3ECE2', selected='#D9ECE9', surface='#FFFDF9',
             sheet='#FFFDF9', ink='#241F2B', ink2='#4E4757', secondary='#6A6273',
             outline='#DDD7E0', hair='#DDD7E0', accent='#11615C', onAccent='#FFFFFF',
             accentText='#11615C', tonal='#E2EFEC', tonalInk='#0B4642',
             aTonal='#CFE8E4', aTonalInk='#062F2C', scrim='rgba(36,31,43,.30)',
             ring='#EDE7DF', ringInner='#F6F1EA', link='#11615C', sep='#E6DFE6')
DARK = dict(ground='#171416', sidebar='#1F1B1E', selected='#1E3A37', surface='#1F1B1E',
            sheet='#2F2A30', ink='#F3ECE4', ink2='#E2DAD6', secondary='#C7BEC4',
            outline='#8C838A', hair='#3E373D', accent='#5BC4B8', onAccent='#0C2523',
            accentText='#5BC4B8', tonal='#1E3A37', tonalInk='#A3E2D9',
            aTonal='#1E3A37', aTonalInk='#A3E2D9', scrim='rgba(0,0,0,.55)',
            ring='#28232A', ringInner='#1F1B1E', link='#5BC4B8', sep='#3E373D')

SYS = "-apple-system, system-ui, sans-serif"
ROB = "Roboto, sans-serif"
EMAIL = "sam@example.com"

COPY = {
    'A1': dict(title='Sign out?', body='Your tasks and settings are hidden on this device until you sign in again. Everything has synced to your account.', status='Synced'),
    'A2': dict(title='3 changes haven’t synced yet', body='They’re saved on this device for sam@example.com and haven’t reached your account yet. They can sync when you sign in again with this account. They stay on this device under this account.', status='3 changes waiting to sync'),
    'A2U': dict(title='Sync hasn’t been confirmed yet', body='Dottoday hasn’t confirmed that everything reached your account. Anything that didn’t is saved on this device for sam@example.com and can sync when you sign in again with this account. They stay on this device under this account.', status='Nothing waiting to sync'),
}
CLOUD = '<svg width="{s}" height="{s}" viewBox="0 0 22 22" fill="none" aria-hidden="true"><path d="M6 15.5h9.5a3.5 3.5 0 0 0 .4-7A5 5 0 0 0 6.3 7.6 4 4 0 0 0 6 15.5Z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"></path><path d="M11 9.5v4M9 11.5l2 2 2-2" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path></svg>'
TICK = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true"><path d="M3.5 8.5l3 3 6-7" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"></path></svg>'
SYNCING = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true"><path d="M3 8a5 5 0 0 1 8.5-3.5M13 8a5 5 0 0 1-8.5 3.5M11.5 2v2.5H9M4.5 14v-2.5H7" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"></path></svg>'
LOCK = '''<svg width="{s}" height="{s}" viewBox="0 0 96 96" fill="none" aria-hidden="true">
      <circle cx="48" cy="48" r="40" stroke="{{{{t.ring}}}}" stroke-width="10"></circle>
      <circle cx="48" cy="48" r="30" fill="{{{{t.ringInner}}}}"></circle>
      <path d="M40 46v-4a8 8 0 0 1 16 0v4" stroke="{{{{t.secondary}}}}" stroke-width="2.5" stroke-linecap="round"></path>
      <rect x="36" y="46" width="24" height="17" rx="5" stroke="{{{{t.secondary}}}}" stroke-width="2.5"></rect>
    </svg>'''
BACK = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M20 12H5M11 5l-7 7 7 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path></svg>'
CHEV_IOS = '<svg width="10" height="16" viewBox="0 0 10 16" fill="none" aria-hidden="true" style="flex: none; color: {{t.secondary}};"><path d="M2 2l6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path></svg>'
CHEV_AND = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden="true" style="flex: none; color: {{t.secondary}};"><path d="M9 6l6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path></svg>'

CUR = ' aria-current="page"'
SETTINGS_ROWS = ['Your day', 'Planning', 'Account', 'Data and privacy']


def page(title, w, h, body, android=False):
    fonts = 'family=Manrope:wght@400;500;600;700;800'
    if android:
        fonts += '&amp;family=Roboto:wght@400;500;700'
    tl = json.dumps(LIGHT)
    td = json.dumps(DARK)
    return f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{title}</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?{fonts}&amp;display=swap" rel="stylesheet">
<style>
body{{margin:0}}
</style>
</helmet>
{body}
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{{"dark":{{"editor":"boolean","default":false}},"$preview":{{"width":{w},"height":{h}}}}}'>
class Component extends DCLogic {{
  renderVals() {{
    const dark = this.props.dark ?? false;
    const t = dark
      ? {td}
      : {tl};
    return {{ t }};
  }}
}}
</script>
</body>
</html>
'''


def dark_twin(name, title, w, h):
    return f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{title}, dark</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&amp;family=Roboto:wght@400;500;700&amp;display=swap" rel="stylesheet">
<style>
body{{margin:0}}
</style>
</helmet>
<dc-import name="{name}" dark="{{{{yes}}}}" hint-size="{w}px,{h}px"></dc-import>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{{"$preview":{{"width":{w},"height":{h}}}}}'>
class Component extends DCLogic {{
  renderVals() {{ return {{ yes: true }}; }}
}}
</script>
</body>
</html>
'''

# ---------------------------------------------------------------- iPad

IW, IH = 1180, 820


def ipad_status():
    return f'''  <div style="height: 24px; padding: 0 20px; display: flex; align-items: center; justify-content: space-between; font-family: {SYS}; font-size: 13px; font-weight: 600;" aria-hidden="true">
    <span>9:41&#160;&#160;Tue Nov 17</span>
    <span style="display: flex; align-items: center; gap: 6px;"><span style="width: 24px; height: 11px; border-radius: 3px; border: 1px solid currentColor; box-sizing: border-box; padding: 1px;"><span style="display: block; width: 70%; height: 100%; border-radius: 1px; background: currentColor;"></span></span></span>
  </div>'''


def ipad_sidebar():
    rows = []
    for i, r in enumerate(SETTINGS_ROWS):
        sel = r == 'Account'
        style = f"min-height: 44px; padding: 0 14px; display: flex; align-items: center; border-radius: 10px; font-size: 17px;"
        if sel:
            style += " background: {{t.selected}}; font-weight: 600;"
        rows.append(f'      <div{CUR if sel else ""} style="{style}">{r}</div>')
    rows = '\n'.join(rows)
    return f'''  <nav aria-label="Settings" style="width: 320px; flex: none; background: {{{{t.sidebar}}}}; padding: 12px 16px; box-sizing: border-box; display: flex; flex-direction: column; gap: 4px; font-family: {SYS};">
    <div style="font-size: 34px; line-height: 41px; font-weight: 700; padding: 8px 6px 14px;">Settings</div>
{rows}
  </nav>'''


def ipad_account(status, icon, extra=''):
    return f'''  <div style="flex: 1 1 auto; padding: 20px 40px; display: flex; flex-direction: column; gap: 20px; max-width: 640px;">
    <div style="font-family: {SYS}; font-size: 34px; line-height: 41px; font-weight: 700;">Account</div>
    <div style="display: flex; flex-direction: column; gap: 8px;">
      <div style="font-size: 13px; font-weight: 700; color: {{{{t.secondary}}}}; letter-spacing: 0.4px;">SYNC</div>
      <div style="background: {{{{t.surface}}}}; border-radius: 20px; padding: 16px; display: flex; flex-direction: column; gap: 12px;">
        <div style="font-size: 15px;">Signed in as {EMAIL}</div>
        <div style="display: flex; align-items: center; gap: 8px; font-size: 14px; color: {{{{t.secondary}}}};">
          {icon}
          <span>{status}</span>
        </div>
      </div>
    </div>
{extra}
  </div>'''


def ipad_two_pane(status, icon, overlay='', extra=''):
    return f'''<div style="width: {IW}px; height: {IH}px; position: relative; overflow: hidden; display: flex; flex-direction: column; background: {{{{t.ground}}}}; color: {{{{t.ink}}}}; font-family: Manrope, sans-serif;">
{ipad_status()}
  <div style="flex: 1 1 auto; display: flex; min-height: 0;">
{ipad_sidebar()}
{ipad_account(status, icon, extra)}
  </div>
{overlay}
</div>'''


def ipad_dialog(key):
    c = COPY[key]
    head = ''
    if key == 'A1':
        buttons = '''    <div style="display: flex; gap: 10px; padding-top: 4px;">
      <button type="button" style="flex: 1 1 0; height: 52px; border-radius: 26px; border: 1.5px solid {{t.outline}}; background: transparent; color: {{t.ink}}; font-family: Manrope, sans-serif; font-size: 16px; font-weight: 700;">Cancel</button>
      <button type="button" style="flex: 1 1 0; height: 52px; border-radius: 26px; border: none; background: {{t.accent}}; color: {{t.onAccent}}; font-family: Manrope, sans-serif; font-size: 16px; font-weight: 700;">Sign out</button>
    </div>'''
    else:
        head = f'''    <div style="width: 44px; height: 44px; border-radius: 22px; background: {{{{t.tonal}}}}; color: {{{{t.tonalInk}}}}; display: flex; align-items: center; justify-content: center;">
      {CLOUD.format(s=22)}
    </div>
'''
        buttons = '''    <div style="display: flex; flex-direction: column; gap: 10px; padding-top: 4px;">
      <button type="button" style="height: 52px; border-radius: 26px; border: none; background: {{t.accent}}; color: {{t.onAccent}}; font-family: Manrope, sans-serif; font-size: 16px; font-weight: 700;">Stay signed in</button>
      <div style="font-size: 13px; line-height: 18px; color: {{t.secondary}}; text-align: center;">Dottoday tries to sync them now.</div>
      <button type="button" style="height: 52px; border-radius: 26px; border: 1.5px solid {{t.outline}}; background: transparent; color: {{t.ink}}; font-family: Manrope, sans-serif; font-size: 16px; font-weight: 700;">Sign out and keep them here</button>
    </div>'''
    k = key.lower()
    return f'''  <div style="position: absolute; inset: 0; background: {{{{t.scrim}}}};"></div>
  <div style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;">
  <div role="alertdialog" aria-modal="true" aria-labelledby="ip{k}-title" aria-describedby="ip{k}-body" style="width: 440px; box-sizing: border-box; background: {{{{t.sheet}}}}; border-radius: 28px; padding: 28px 24px 20px; display: flex; flex-direction: column; gap: 16px;">
{head}    <h2 id="ip{k}-title" style="margin: 0; font-size: 22px; line-height: 28px; font-weight: 700; letter-spacing: -0.2px;">{c['title']}</h2>
    <p id="ip{k}-body" style="margin: 0; font-size: 15px; line-height: 22px; color: {{{{t.ink2}}}};">{c['body']}</p>
{buttons}
  </div>
  </div>'''


def ipad_a3():
    return f'''<div style="width: {IW}px; height: {IH}px; display: flex; flex-direction: column; background: {{{{t.ground}}}}; color: {{{{t.ink}}}}; font-family: Manrope, sans-serif;">
{ipad_status()}
  <div style="flex: 1 1 auto; display: flex; align-items: center; justify-content: center;">
  <div style="width: 440px; display: flex; flex-direction: column; gap: 20px;">
    {LOCK.format(s=96)}
    <h1 style="margin: 0; font-size: 28px; line-height: 34px; font-weight: 800; letter-spacing: -0.5px;">You’re signed out</h1>
    <p style="margin: 0; font-size: 15px; line-height: 22px; color: {{{{t.secondary}}}};">Your tasks stay on this device under your account. They come back when you sign in again with the same account.</p>
    <div style="display: flex; flex-direction: column; gap: 10px; padding-top: 8px;">
      <button type="button" style="height: 52px; border-radius: 26px; border: none; background: {{{{t.accent}}}}; color: {{{{t.onAccent}}}}; font-family: Manrope, sans-serif; font-size: 16px; font-weight: 700;">Sign in</button>
      <button type="button" style="height: 52px; border-radius: 26px; border: 1.5px solid {{{{t.outline}}}}; background: transparent; color: {{{{t.ink}}}}; font-family: Manrope, sans-serif; font-size: 16px; font-weight: 700;">Use without an account</button>
      <div style="font-size: 13px; line-height: 18px; color: {{{{t.secondary}}}}; text-align: center; padding: 0 8px;">Opens this device’s plan without an account. Anyone who uses this device without an account can see it.</div>
    </div>
  </div>
  </div>
</div>'''


def b1_card(value, label, rows, checked, name, radio, title_size, row_font, row_gap, col_min, pad_left, radius):
    border = '{{t.accent}}' if checked else '{{t.hair}}'
    chk = ' checked="checked"' if checked else ''
    cells = '\n'.join(f'          <span style="color: {{{{t.secondary}}}};">{a}</span><span>{b}</span>' for a, b in rows)
    return f'''      <label style="flex: 1 1 280px; display: flex; flex-direction: column; gap: 12px; padding: 16px; border-radius: {radius}px; background: {{{{t.surface}}}}; border: 2px solid {border};">
        <span style="display: flex; align-items: center; gap: 12px; min-height: 44px; margin: -10px 0;">
          <input type="radio" name="{name}" value="{value}"{chk} style="width: {radio}px; height: {radio}px; margin: 0; accent-color: {{{{t.accent}}}};">
          <span style="font-size: {title_size}px; font-weight: 700;">{label}</span>
        </span>
        <span style="display: grid; grid-template-columns: minmax({col_min}px, max-content) minmax(0, 1fr); row-gap: {row_gap}px; column-gap: 8px; font-size: {row_font}px; line-height: 20px; padding-left: {pad_left}px;">
{cells}
        </span>
      </label>'''

ACC_ROWS = [('Time zone', 'Berlin'), ('Language', 'Deutsch'), ('Your day', '7:00 AM – 11:00 PM'), ('Layout', 'Full')]
DEV_ROWS = [('Time zone', 'Tokyo'), ('Language', 'English'), ('Your day', '6:30 AM – 10:30 PM'), ('Layout', 'Minimal')]


def ipad_b1():
    c1 = b1_card('account', 'Your account’s settings', ACC_ROWS, True, 'settings-ipad', 22, 17, 14, 8, 104, 34, 22)
    c2 = b1_card('device', 'This device’s settings', DEV_ROWS, False, 'settings-ipad', 22, 17, 14, 8, 104, 34, 22)
    return f'''<div style="width: {IW}px; height: {IH}px; display: flex; flex-direction: column; background: {{{{t.ground}}}}; color: {{{{t.ink}}}}; font-family: Manrope, sans-serif;">
{ipad_status()}
  <div style="flex: 1 1 auto; display: flex; align-items: center; justify-content: center;">
  <div style="width: 680px; display: flex; flex-direction: column; gap: 18px;">
    <div style="display: flex; flex-direction: column; gap: 8px;">
      <h1 style="margin: 0; font-size: 22px; line-height: 28px; font-weight: 700; letter-spacing: -0.2px;">Which settings should Dottoday use?</h1>
      <p style="margin: 0; font-size: 15px; line-height: 22px; color: {{{{t.secondary}}}};">Your account already has settings. This device had different ones before you signed in. Your tasks won’t be deleted.</p>
    </div>
    <fieldset style="margin: 0; padding: 0; border: none; display: flex; flex-wrap: wrap; gap: 12px;">
      <legend style="position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0);">Settings to use</legend>
{c1}
{c2}
    </fieldset>
    <div style="font-size: 13px; line-height: 18px; color: {{{{t.secondary}}}};">Only the settings that differ are shown.</div>
    <div style="display: flex; flex-wrap: wrap; justify-content: flex-end; gap: 10px; padding-top: 4px;">
      <button type="button" style="height: 52px; padding: 0 22px; border-radius: 26px; border: none; background: transparent; color: {{{{t.link}}}}; font-family: Manrope, sans-serif; font-size: 16px; font-weight: 700; white-space: nowrap;">Decide later</button>
      <button type="button" style="height: 52px; padding: 0 28px; border-radius: 26px; border: none; background: {{{{t.accent}}}}; color: {{{{t.onAccent}}}}; font-family: Manrope, sans-serif; font-size: 16px; font-weight: 700; white-space: nowrap;">Continue</button>
    </div>
    <div style="font-size: 13px; line-height: 18px; color: {{{{t.secondary}}}}; text-align: right;">Until you choose, your account’s settings stay. You can choose in Settings › Account.</div>
  </div>
  </div>
</div>'''


def ipad_choose_row():
    return f'''    <a href="#" style="display: flex; align-items: center; gap: 12px; min-height: 64px; padding: 12px 16px; box-sizing: border-box; border-radius: 20px; background: {{{{t.surface}}}}; color: {{{{t.ink}}}}; text-decoration: none;">
      <span style="flex: 1 1 auto; display: flex; flex-direction: column; gap: 2px;">
        <span style="font-size: 16px; line-height: 22px; font-weight: 700;">Choose settings</span>
        <span style="font-size: 14px; line-height: 20px; color: {{{{t.secondary}}}};">This device had different settings when you signed in.</span>
      </span>
      {CHEV_IOS}
    </a>'''

# ---------------------------------------------------------------- Android tablet

AW, AH = 1280, 800


def and_status():
    return f'''  <div style="height: 28px; padding: 0 24px; display: flex; align-items: center; justify-content: space-between; font-family: {ROB}; font-size: 14px; font-weight: 500;" aria-hidden="true">
    <span>9:41</span>
    <span style="width: 22px; height: 11px; border-radius: 2px; background: currentColor; opacity: .85;"></span>
  </div>'''


def and_gesture():
    return '''  <div style="height: 20px; display: flex; align-items: center; justify-content: center;" aria-hidden="true"><span style="width: 120px; height: 4px; border-radius: 2px; background: {{t.ink}}; opacity: .5;"></span></div>'''


def and_list():
    rows = []
    for r in SETTINGS_ROWS:
        sel = r == 'Account'
        style = f"min-height: 56px; padding: 0 16px; display: flex; align-items: center; border-radius: 28px; font-family: {ROB}; font-size: 16px;"
        if sel:
            style += " background: {{t.aTonal}}; color: {{t.aTonalInk}}; font-weight: 500;"
        rows.append(f'      <div{CUR if sel else ""} style="{style}">{r}</div>')
    rows = '\n'.join(rows)
    return f'''  <nav aria-label="Settings" style="width: 360px; flex: none; padding: 0 12px; box-sizing: border-box; display: flex; flex-direction: column; gap: 2px;">
    <div style="height: 64px; display: flex; align-items: center; gap: 8px; padding: 0 4px 0 0;">
      <button type="button" aria-label="Back" style="width: 48px; height: 48px; border: none; background: transparent; color: {{{{t.ink}}}}; display: flex; align-items: center; justify-content: center;">
        {BACK}
      </button>
      <div style="font-family: {ROB}; font-size: 22px; font-weight: 400;">Settings</div>
    </div>
{rows}
  </nav>'''


def and_account(status, extra=''):
    return f'''  <div style="flex: 1 1 auto; margin: 0 24px 0 0; border-radius: 28px; background: {{{{t.surface}}}}; display: flex; flex-direction: column; min-width: 0;">
    <div style="height: 64px; display: flex; align-items: center; padding: 0 24px;">
      <div style="font-family: {ROB}; font-size: 22px; font-weight: 400;">Account</div>
    </div>
    <div style="padding: 0 24px; display: flex; flex-direction: column; gap: 4px; max-width: 600px;">
      <div style="font-family: {ROB}; font-size: 14px; font-weight: 500; color: {{{{t.accentText}}}}; padding: 8px 0;">Sync</div>
      <div style="font-size: 16px; line-height: 24px;">Signed in as {EMAIL}</div>
      <div style="font-size: 14px; line-height: 20px; color: {{{{t.secondary}}}};">{status}</div>
    </div>
{extra}
  </div>'''


def and_two_pane(status, overlay='', extra=''):
    return f'''<div style="width: {AW}px; height: {AH}px; position: relative; overflow: hidden; display: flex; flex-direction: column; background: {{{{t.ground}}}}; color: {{{{t.ink}}}}; font-family: Manrope, sans-serif;">
{and_status()}
  <div style="flex: 1 1 auto; display: flex; min-height: 0; padding-bottom: 4px;">
{and_list()}
{and_account(status, extra)}
  </div>
{and_gesture()}
{overlay}
</div>'''


def and_dialog(key):
    c = COPY[key]
    k = key.lower()
    if key == 'A1':
        return f'''  <div style="position: absolute; inset: 0; background: {{{{t.scrim}}}};"></div>
  <div style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;">
  <div role="alertdialog" aria-modal="true" aria-labelledby="at{k}-title" aria-describedby="at{k}-body" style="width: 400px; box-sizing: border-box; background: {{{{t.sheet}}}}; border-radius: 28px; padding: 24px 24px 16px; display: flex; flex-direction: column; gap: 16px;">
    <h2 id="at{k}-title" style="margin: 0; font-size: 24px; line-height: 32px; font-weight: 700;">{c['title']}</h2>
    <p id="at{k}-body" style="margin: 0; font-size: 14px; line-height: 20px; color: {{{{t.ink2}}}};">{c['body']}</p>
    <div style="display: flex; justify-content: flex-end; gap: 8px; padding-top: 8px;">
      <button type="button" style="height: 48px; min-width: 48px; padding: 0 12px; border-radius: 24px; border: none; background: transparent; color: {{{{t.accentText}}}}; font-family: {ROB}; font-size: 14px; font-weight: 500;">Cancel</button>
      <button type="button" style="height: 48px; min-width: 48px; padding: 0 12px; border-radius: 24px; border: none; background: transparent; color: {{{{t.accentText}}}}; font-family: {ROB}; font-size: 14px; font-weight: 500;">Sign out</button>
    </div>
  </div>
  </div>'''
    return f'''  <div style="position: absolute; inset: 0; background: {{{{t.scrim}}}};"></div>
  <div style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;">
  <div role="alertdialog" aria-modal="true" aria-labelledby="at{k}-title" aria-describedby="at{k}-body" style="width: 440px; box-sizing: border-box; background: {{{{t.sheet}}}}; border-radius: 28px; padding: 24px; display: flex; flex-direction: column; gap: 16px; align-items: center;">
    <div style="color: {{{{t.accentText}}}};">
      {CLOUD.format(s=24)}
    </div>
    <h2 id="at{k}-title" style="margin: 0; font-size: 24px; line-height: 32px; font-weight: 700; text-align: center;">{c['title']}</h2>
    <p id="at{k}-body" style="margin: 0; font-size: 14px; line-height: 20px; color: {{{{t.ink2}}}};">{c['body']}</p>
    <div style="align-self: stretch; display: flex; flex-direction: column; gap: 8px; padding-top: 8px;">
      <button type="button" style="height: 48px; border-radius: 24px; border: none; background: {{{{t.aTonal}}}}; color: {{{{t.aTonalInk}}}}; font-family: {ROB}; font-size: 14px; font-weight: 500;">Stay signed in</button>
      <div style="font-size: 13px; line-height: 18px; color: {{{{t.secondary}}}}; text-align: center;">Dottoday tries to sync them now.</div>
      <button type="button" style="height: 48px; border-radius: 24px; border: none; background: transparent; color: {{{{t.accentText}}}}; font-family: {ROB}; font-size: 14px; font-weight: 500;">Sign out and keep them here</button>
    </div>
  </div>
  </div>'''


def and_full(inner):
    return f'''<div style="width: {AW}px; height: {AH}px; display: flex; flex-direction: column; background: {{{{t.ground}}}}; color: {{{{t.ink}}}}; font-family: Manrope, sans-serif;">
{and_status()}
  <div style="flex: 1 1 auto; display: flex; align-items: center; justify-content: center;">
{inner}
  </div>
{and_gesture()}
</div>'''


def and_a3():
    return and_full(f'''  <div style="width: 440px; display: flex; flex-direction: column; gap: 20px;">
    {LOCK.format(s=96)}
    <h1 style="margin: 0; font-size: 28px; line-height: 36px; font-weight: 800; letter-spacing: -0.5px;">You’re signed out</h1>
    <p style="margin: 0; font-size: 14px; line-height: 20px; color: {{{{t.secondary}}}};">Your tasks stay on this device under your account. They come back when you sign in again with the same account.</p>
    <div style="display: flex; flex-direction: column; gap: 8px; padding-top: 8px;">
      <button type="button" style="height: 48px; border-radius: 24px; border: none; background: {{{{t.accent}}}}; color: {{{{t.onAccent}}}}; font-family: {ROB}; font-size: 14px; font-weight: 500;">Sign in</button>
      <button type="button" style="height: 48px; border-radius: 24px; border: 1px solid {{{{t.outline}}}}; background: transparent; color: {{{{t.accentText}}}}; font-family: {ROB}; font-size: 14px; font-weight: 500;">Use without an account</button>
      <div style="font-size: 13px; line-height: 18px; color: {{{{t.secondary}}}}; text-align: center; padding: 0 8px;">Opens this device’s plan without an account. Anyone who uses this device without an account can see it.</div>
    </div>
  </div>''')


def and_b1():
    c1 = b1_card('account', 'Your account’s settings', ACC_ROWS, True, 'settings-atab', 20, 16, 14, 8, 104, 32, 20)
    c2 = b1_card('device', 'This device’s settings', DEV_ROWS, False, 'settings-atab', 20, 16, 14, 8, 104, 32, 20)
    c1 = c1.replace('min-height: 44px; margin: -10px 0;', 'min-height: 48px; margin: -12px 0;')
    c2 = c2.replace('min-height: 44px; margin: -10px 0;', 'min-height: 48px; margin: -12px 0;')
    return and_full(f'''  <div style="width: 680px; display: flex; flex-direction: column; gap: 16px;">
    <div style="display: flex; flex-direction: column; gap: 8px;">
      <h1 style="margin: 0; font-size: 24px; line-height: 32px; font-weight: 700;">Which settings should Dottoday use?</h1>
      <p style="margin: 0; font-size: 14px; line-height: 20px; color: {{{{t.secondary}}}};">Your account already has settings. This device had different ones before you signed in. Your tasks won’t be deleted.</p>
    </div>
    <fieldset style="margin: 0; padding: 0; border: none; display: flex; flex-wrap: wrap; gap: 12px;">
      <legend style="position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0);">Settings to use</legend>
{c1}
{c2}
    </fieldset>
    <div style="font-size: 13px; line-height: 18px; color: {{{{t.secondary}}}};">Only the settings that differ are shown.</div>
    <div style="display: flex; flex-wrap: wrap; justify-content: flex-end; gap: 8px; padding-top: 4px;">
      <button type="button" style="height: 48px; padding: 0 16px; border-radius: 24px; border: none; background: transparent; color: {{{{t.link}}}}; font-family: {ROB}; font-size: 14px; font-weight: 500; white-space: nowrap;">Decide later</button>
      <button type="button" style="height: 48px; padding: 0 24px; border-radius: 24px; border: none; background: {{{{t.accent}}}}; color: {{{{t.onAccent}}}}; font-family: {ROB}; font-size: 14px; font-weight: 500; white-space: nowrap;">Continue</button>
    </div>
    <div style="font-size: 13px; line-height: 18px; color: {{{{t.secondary}}}}; text-align: right;">Until you choose, your account’s settings stay. You can choose in Settings › Account.</div>
  </div>''')


def and_choose_row():
    return f'''    <a href="#" style="display: flex; align-items: center; gap: 16px; min-height: 72px; margin-top: 8px; padding: 8px 24px; box-sizing: border-box; max-width: 648px; color: {{{{t.ink}}}}; text-decoration: none;">
      <span style="flex: 1 1 auto; display: flex; flex-direction: column; gap: 2px;">
        <span style="font-size: 16px; line-height: 24px; font-weight: 600;">Choose settings</span>
        <span style="font-size: 14px; line-height: 20px; color: {{{{t.secondary}}}};">This device had different settings when you signed in.</span>
      </span>
      {CHEV_AND}
    </a>'''

# ---------------------------------------------------------------- write

BOARDS = [
    # name, title, w, h, android, body, canvas title
    ('TabletA1', 'Sign out, everything synced, iPad', IW, IH, False,
     ipad_two_pane(COPY['A1']['status'], TICK, ipad_dialog('A1')), 'A1 · iPad'),
    ('TabletA2', 'Sign out with unsynced changes, iPad', IW, IH, False,
     ipad_two_pane(COPY['A2']['status'], SYNCING, ipad_dialog('A2')), 'A2 · iPad'),
    ('TabletA2Unconfirmed', 'Sign out, sync not confirmed, iPad', IW, IH, False,
     ipad_two_pane(COPY['A2U']['status'], TICK, ipad_dialog('A2U')), 'A2 · Sync not confirmed · iPad'),
    ('TabletA3', 'Signed out, iPad', IW, IH, False, ipad_a3(), 'A3 · Signed out · iPad'),
    ('TabletB1', 'Which settings to keep, iPad', IW, IH, False, ipad_b1(), 'B1 · Settings choice · iPad'),
    ('TabletAccountChoose', 'Account, choose settings later, iPad', IW, IH, False,
     ipad_two_pane('Synced', TICK, '', ipad_choose_row()), 'B1 later · Choose settings · iPad'),
    ('AndroidTabletA1', 'Sign out, everything synced, Android tablet', AW, AH, True,
     and_two_pane(COPY['A1']['status'], and_dialog('A1')), 'A1 · Android tablet'),
    ('AndroidTabletA2', 'Sign out with unsynced changes, Android tablet', AW, AH, True,
     and_two_pane(COPY['A2']['status'], and_dialog('A2')), 'A2 · Android tablet'),
    ('AndroidTabletA2Unconfirmed', 'Sign out, sync not confirmed, Android tablet', AW, AH, True,
     and_two_pane(COPY['A2U']['status'], and_dialog('A2U')), 'A2 · Sync not confirmed · Android tablet'),
    ('AndroidTabletA3', 'Signed out, Android tablet', AW, AH, True, and_a3(), 'A3 · Signed out · Android tablet'),
    ('AndroidTabletB1', 'Which settings to keep, Android tablet', AW, AH, True, and_b1(), 'B1 · Settings choice · Android tablet'),
    ('AndroidTabletAccountChoose', 'Account, choose settings later, Android tablet', AW, AH, True,
     and_two_pane('Synced', '', and_choose_row()), 'B1 later · Choose settings · Android tablet'),
]

meta = []
for name, title, w, h, android, body, ctitle in BOARDS:
    with open(os.path.join(OUT, name + '.dc.html'), 'w') as f:
        f.write(page(title, w, h, body, android))
    with open(os.path.join(OUT, name + 'Dark.dc.html'), 'w') as f:
        f.write(dark_twin(name, title, w, h))
    meta.append((name, w, h, ctitle))
json.dump(meta, open(os.path.join(OUT, '..', 'meta.json'), 'w'))
print(len(meta) * 2, 'boards')
