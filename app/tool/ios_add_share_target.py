#!/usr/bin/env python3
# Usage (from app/): python3 tool/ios_add_share_target.py ios/Runner.xcodeproj/project.pbxproj
# Plain Python (no xcodeproj gem): clones the DottodayWidgets target's settings.
# Adds the DottodayShare app extension to app/ios/Runner.xcodeproj,
# modelled on the DottodayWidgets target (docs/09 M12.4). Idempotent.
import re, secrets, sys
P = sys.argv[1]
s = open(P).read()
if 'DottodayShare' in s:
    sys.exit('already there')
def nid(): return secrets.token_hex(12).upper()
ids = {k: nid() for k in ['src_ref','plist_ref','ent_ref','appex_ref','src_bf','store_bf','embed_bf','group','target','sources','frameworks','resources','proxy','dep','cfg_rel','cfg_dbg','cfg_prof','cfglist']}
STORE_REF = '81DCE2F7DB27897A1C8F948D'
def section_append(name, text):
    global s
    end = f'/* End {name} section */'
    assert end in s, name
    s = s.replace(end, text + end, 1)
section_append('PBXBuildFile',
 f"\t\t{ids['src_bf']} /* ShareViewController.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {ids['src_ref']} /* ShareViewController.swift */; }};\n"
 f"\t\t{ids['store_bf']} /* DotStore.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {STORE_REF} /* DotStore.swift */; }};\n"
 f"\t\t{ids['embed_bf']} /* DottodayShare.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {ids['appex_ref']} /* DottodayShare.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};\n")
section_append('PBXContainerItemProxy',
 f"\t\t{ids['proxy']} /* PBXContainerItemProxy */ = {{\n\t\t\tisa = PBXContainerItemProxy;\n\t\t\tcontainerPortal = 97C146E61CF9000F007C117D /* Project object */;\n\t\t\tproxyType = 1;\n\t\t\tremoteGlobalIDString = {ids['target']};\n\t\t\tremoteInfo = DottodayShare;\n\t\t}};\n")
section_append('PBXFileReference',
 f"\t\t{ids['src_ref']} /* ShareViewController.swift */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = ShareViewController.swift; sourceTree = \"<group>\"; }};\n"
 f"\t\t{ids['plist_ref']} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};\n"
 f"\t\t{ids['ent_ref']} /* DottodayShare.entitlements */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.plist.entitlements; path = DottodayShare.entitlements; sourceTree = \"<group>\"; }};\n"
 f"\t\t{ids['appex_ref']} /* DottodayShare.appex */ = {{isa = PBXFileReference; explicitFileType = \"wrapper.app-extension\"; includeInIndex = 0; path = DottodayShare.appex; sourceTree = BUILT_PRODUCTS_DIR; }};\n")
section_append('PBXFrameworksBuildPhase',
 f"\t\t{ids['frameworks']} /* Frameworks */ = {{\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n")
section_append('PBXGroup',
 f"\t\t{ids['group']} /* DottodayShare */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t{ids['src_ref']} /* ShareViewController.swift */,\n\t\t\t\t{ids['plist_ref']} /* Info.plist */,\n\t\t\t\t{ids['ent_ref']} /* DottodayShare.entitlements */,\n\t\t\t);\n\t\t\tname = DottodayShare;\n\t\t\tpath = DottodayShare;\n\t\t\tsourceTree = \"<group>\";\n\t\t}};\n")
section_append('PBXNativeTarget',
 f"\t\t{ids['target']} /* DottodayShare */ = {{\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = {ids['cfglist']} /* Build configuration list for PBXNativeTarget \"DottodayShare\" */;\n\t\t\tbuildPhases = (\n\t\t\t\t{ids['sources']} /* Sources */,\n\t\t\t\t{ids['frameworks']} /* Frameworks */,\n\t\t\t\t{ids['resources']} /* Resources */,\n\t\t\t);\n\t\t\tbuildRules = (\n\t\t\t);\n\t\t\tdependencies = (\n\t\t\t);\n\t\t\tname = DottodayShare;\n\t\t\tproductName = DottodayShare;\n\t\t\tproductReference = {ids['appex_ref']} /* DottodayShare.appex */;\n\t\t\tproductType = \"com.apple.product-type.app-extension\";\n\t\t}};\n")
section_append('PBXResourcesBuildPhase',
 f"\t\t{ids['resources']} /* Resources */ = {{\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n")
section_append('PBXSourcesBuildPhase',
 f"\t\t{ids['sources']} /* Sources */ = {{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\t{ids['src_bf']} /* ShareViewController.swift in Sources */,\n\t\t\t\t{ids['store_bf']} /* DotStore.swift in Sources */,\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n")
section_append('PBXTargetDependency',
 f"\t\t{ids['dep']} /* PBXTargetDependency */ = {{\n\t\t\tisa = PBXTargetDependency;\n\t\t\tname = DottodayShare;\n\t\t\ttarget = {ids['target']} /* DottodayShare */;\n\t\t\ttargetProxy = {ids['proxy']} /* PBXContainerItemProxy */;\n\t\t}};\n")
# build configurations cloned from the widget target's three
def clone_cfg(old, new):
    m = re.search(r'\t\t' + old + r' /\* (\w+) \*/ = \{.*?\n\t\t\};\n', s, re.S)
    block = m.group(0)
    block = block.replace(old, new)
    block = block.replace('DottodayWidgets/DottodayWidgets.entitlements', 'DottodayShare/DottodayShare.entitlements')
    block = block.replace('DottodayWidgets/Info.plist', 'DottodayShare/Info.plist')
    block = block.replace('app.dottoday.planner.widgets', 'app.dottoday.planner.share')
    return block
cfgs = ''.join([clone_cfg('23BD0895148E2A6B9DEC88E2', ids['cfg_rel']), clone_cfg('FBBD31CC5451AFAB4A8DF377', ids['cfg_dbg']), clone_cfg('F0EC815C872D4EF18072E8F5', ids['cfg_prof'])])
section_append('XCBuildConfiguration', cfgs)
section_append('XCConfigurationList',
 f"\t\t{ids['cfglist']} /* Build configuration list for PBXNativeTarget \"DottodayShare\" */ = {{\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n\t\t\t\t{ids['cfg_rel']} /* Release */,\n\t\t\t\t{ids['cfg_dbg']} /* Debug */,\n\t\t\t\t{ids['cfg_prof']} /* Profile */,\n\t\t\t);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t}};\n")
# wire into existing lists
def after(anchor, add):
    global s
    assert anchor in s, anchor
    s = s.replace(anchor, anchor + add, 1)
after("\t\t\t\t3796BB58BA2860D6030DD397 /* DottodayWidgets.appex in Embed Foundation Extensions */,\n", f"\t\t\t\t{ids['embed_bf']} /* DottodayShare.appex in Embed Foundation Extensions */,\n")
after("\t\t\t\t3AFC64CF5CC45F760CCDE295 /* DottodayWidgets */,\n", f"\t\t\t\t{ids['group']} /* DottodayShare */,\n")
after("\t\t\t\t9BD896D8A8380B424F050F63 /* DottodayWidgets.appex */,\n", f"\t\t\t\t{ids['appex_ref']} /* DottodayShare.appex */,\n")
after("\t\t\t\t10E2CB2C4A7B305A172E0DC1 /* DottodayWidgets */,\n\t\t\t);\n\t\t};\n/* End PBXProject section */", "")
s = s.replace("\t\t\t\t10E2CB2C4A7B305A172E0DC1 /* DottodayWidgets */,\n\t\t\t);\n\t\t};\n/* End PBXProject section */", f"\t\t\t\t10E2CB2C4A7B305A172E0DC1 /* DottodayWidgets */,\n\t\t\t\t{ids['target']} /* DottodayShare */,\n\t\t\t);\n\t\t}};\n/* End PBXProject section */")
# the Runner target depends on the extension, as on the widgets
after("\t\t\t\tC1FD5212D8798EB6912FA658 /* PBXTargetDependency */,\n", f"\t\t\t\t{ids['dep']} /* PBXTargetDependency */,\n")
open(P, 'w').write(s)
print('added', ids['target'])
