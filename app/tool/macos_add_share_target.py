#!/usr/bin/env python3
# Usage (from app/): python3 tool/macos_add_share_target.py macos/Runner.xcodeproj/project.pbxproj
# Adds the DottodayShare share extension, DotStore.swift and the intents
# bridge to app/macos/Runner.xcodeproj (docs/09 M12.4).
import secrets, sys
P = sys.argv[1]
s = open(P).read()
if 'DottodayShare' in s: sys.exit('already there')
def nid(): return secrets.token_hex(12).upper()
k = ['src_ref','plist_ref','ent_ref','appex_ref','store_ref','bridge_ref','src_bf','store_bf_ext','store_bf_app','bridge_bf','embed_bf','group','target','sources','frameworks','resources','embed_phase','proxy','dep','cfg_dbg','cfg_rel','cfg_prof','cfglist']
I = {x: nid() for x in k}
PROJECT = '33CC10E52044A3C60003C045'
def add(name, text):
    global s
    end = f'/* End {name} section */'
    assert end in s, name
    s = s.replace(end, text + end, 1)
def after(anchor, text):
    global s
    assert anchor in s, anchor
    s = s.replace(anchor, anchor + text, 1)
add('PBXBuildFile',
 f"\t\t{I['src_bf']} /* ShareViewController.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['src_ref']} /* ShareViewController.swift */; }};\n"
 f"\t\t{I['store_bf_ext']} /* DotStore.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['store_ref']} /* DotStore.swift */; }};\n"
 f"\t\t{I['store_bf_app']} /* DotStore.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['store_ref']} /* DotStore.swift */; }};\n"
 f"\t\t{I['bridge_bf']} /* IntentQueueBridge.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['bridge_ref']} /* IntentQueueBridge.swift */; }};\n"
 f"\t\t{I['embed_bf']} /* DottodayShare.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {I['appex_ref']} /* DottodayShare.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};\n")
add('PBXContainerItemProxy',
 f"\t\t{I['proxy']} /* PBXContainerItemProxy */ = {{\n\t\t\tisa = PBXContainerItemProxy;\n\t\t\tcontainerPortal = {PROJECT} /* Project object */;\n\t\t\tproxyType = 1;\n\t\t\tremoteGlobalIDString = {I['target']};\n\t\t\tremoteInfo = DottodayShare;\n\t\t}};\n")
add('PBXCopyFilesBuildPhase',
 f"\t\t{I['embed_phase']} /* Embed Foundation Extensions */ = {{\n\t\t\tisa = PBXCopyFilesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tdstPath = \"\";\n\t\t\tdstSubfolderSpec = 13;\n\t\t\tfiles = (\n\t\t\t\t{I['embed_bf']} /* DottodayShare.appex in Embed Foundation Extensions */,\n\t\t\t);\n\t\t\tname = \"Embed Foundation Extensions\";\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n")
add('PBXFileReference',
 f"\t\t{I['src_ref']} /* ShareViewController.swift */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = ShareViewController.swift; sourceTree = \"<group>\"; }};\n"
 f"\t\t{I['plist_ref']} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};\n"
 f"\t\t{I['ent_ref']} /* DottodayShare.entitlements */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.plist.entitlements; path = DottodayShare.entitlements; sourceTree = \"<group>\"; }};\n"
 f"\t\t{I['appex_ref']} /* DottodayShare.appex */ = {{isa = PBXFileReference; explicitFileType = \"wrapper.app-extension\"; includeInIndex = 0; path = DottodayShare.appex; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
 f"\t\t{I['store_ref']} /* DotStore.swift */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; name = DotStore.swift; path = ../../ios/Shared/DotStore.swift; sourceTree = \"<group>\"; }};\n"
 f"\t\t{I['bridge_ref']} /* IntentQueueBridge.swift */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = IntentQueueBridge.swift; sourceTree = \"<group>\"; }};\n")
add('PBXFrameworksBuildPhase',
 f"\t\t{I['frameworks']} /* Frameworks */ = {{\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n")
add('PBXGroup',
 f"\t\t{I['group']} /* DottodayShare */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t{I['src_ref']} /* ShareViewController.swift */,\n\t\t\t\t{I['plist_ref']} /* Info.plist */,\n\t\t\t\t{I['ent_ref']} /* DottodayShare.entitlements */,\n\t\t\t);\n\t\t\tpath = DottodayShare;\n\t\t\tsourceTree = \"<group>\";\n\t\t}};\n")
add('PBXNativeTarget',
 f"\t\t{I['target']} /* DottodayShare */ = {{\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = {I['cfglist']} /* Build configuration list for PBXNativeTarget \"DottodayShare\" */;\n\t\t\tbuildPhases = (\n\t\t\t\t{I['sources']} /* Sources */,\n\t\t\t\t{I['frameworks']} /* Frameworks */,\n\t\t\t\t{I['resources']} /* Resources */,\n\t\t\t);\n\t\t\tbuildRules = (\n\t\t\t);\n\t\t\tdependencies = (\n\t\t\t);\n\t\t\tname = DottodayShare;\n\t\t\tproductName = DottodayShare;\n\t\t\tproductReference = {I['appex_ref']} /* DottodayShare.appex */;\n\t\t\tproductType = \"com.apple.product-type.app-extension\";\n\t\t}};\n")
add('PBXResourcesBuildPhase',
 f"\t\t{I['resources']} /* Resources */ = {{\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n")
add('PBXSourcesBuildPhase',
 f"\t\t{I['sources']} /* Sources */ = {{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\t{I['src_bf']} /* ShareViewController.swift in Sources */,\n\t\t\t\t{I['store_bf_ext']} /* DotStore.swift in Sources */,\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n")
add('PBXTargetDependency',
 f"\t\t{I['dep']} /* PBXTargetDependency */ = {{\n\t\t\tisa = PBXTargetDependency;\n\t\t\ttarget = {I['target']} /* DottodayShare */;\n\t\t\ttargetProxy = {I['proxy']} /* PBXContainerItemProxy */;\n\t\t}};\n")
def cfg(id_, name):
    return (f"\t\t{id_} /* {name} */ = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n"
      "\t\t\t\tCODE_SIGN_ENTITLEMENTS = DottodayShare/DottodayShare.entitlements;\n"
      "\t\t\t\t\"CODE_SIGN_IDENTITY[sdk=macosx*]\" = \"Apple Development\";\n"
      "\t\t\t\tCODE_SIGN_STYLE = Automatic;\n"
      "\t\t\t\tDEVELOPMENT_TEAM = JBHAWSBYLG;\n"
      "\t\t\t\tGENERATE_INFOPLIST_FILE = NO;\n"
      "\t\t\t\tINFOPLIST_FILE = DottodayShare/Info.plist;\n"
      "\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (\n\t\t\t\t\t\"$(inherited)\",\n\t\t\t\t\t\"@executable_path/../Frameworks\",\n\t\t\t\t\t\"@executable_path/../../../../Frameworks\",\n\t\t\t\t);\n"
      "\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 12.0;\n"
      "\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = app.dottoday.planner.share;\n"
      "\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";\n"
      "\t\t\t\tSDKROOT = macosx;\n"
      "\t\t\t\tSKIP_INSTALL = YES;\n"
      "\t\t\t\tSWIFT_VERSION = 5.0;\n"
      f"\t\t\t}};\n\t\t\tname = {name};\n\t\t}};\n")
add('XCBuildConfiguration', cfg(I['cfg_dbg'],'Debug') + cfg(I['cfg_rel'],'Release') + cfg(I['cfg_prof'],'Profile'))
add('XCConfigurationList',
 f"\t\t{I['cfglist']} /* Build configuration list for PBXNativeTarget \"DottodayShare\" */ = {{\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n\t\t\t\t{I['cfg_dbg']} /* Debug */,\n\t\t\t\t{I['cfg_rel']} /* Release */,\n\t\t\t\t{I['cfg_prof']} /* Profile */,\n\t\t\t);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t}};\n")
after("\t\t\t\t331C80D6294CF71000263BE5 /* RunnerTests */,\n", f"\t\t\t\t{I['group']} /* DottodayShare */,\n")
after("\t\t\t\tE31060CD99B889FD8CFFD316 /* ThinkingBridge.swift */,\n", f"\t\t\t\t{I['store_ref']} /* DotStore.swift */,\n\t\t\t\t{I['bridge_ref']} /* IntentQueueBridge.swift */,\n")
after("\t\t\t\t5A38B0F6448DE1214CE36867 /* ThinkingBridge.swift in Sources */,\n", f"\t\t\t\t{I['store_bf_app']} /* DotStore.swift in Sources */,\n\t\t\t\t{I['bridge_bf']} /* IntentQueueBridge.swift in Sources */,\n")
after("\t\t\t\t33CC110E2044A8840003C045 /* Bundle Framework */,\n", f"\t\t\t\t{I['embed_phase']} /* Embed Foundation Extensions */,\n")
after("\t\t\t\t33CC11202044C79F0003C045 /* PBXTargetDependency */,\n", f"\t\t\t\t{I['dep']} /* PBXTargetDependency */,\n")
after("\t\t\t\t33CC111A2044C6BA0003C045 /* Flutter Assemble */,\n", f"\t\t\t\t{I['target']} /* DottodayShare */,\n")
# product into Products
import re
m = re.search(r"(33CC10EE2044A3C60003C045 /\* Products \*/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)", s)
s = s[:m.end()] + f"\t\t\t\t{I['appex_ref']} /* DottodayShare.appex */,\n" + s[m.end():]
open(P,'w').write(s)
print('ok', I['target'])
