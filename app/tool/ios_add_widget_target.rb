# Adds the DottodayWidgets WidgetKit extension to ios/Runner.xcodeproj
# (docs/09 M5.4). Idempotent. Run from app/:
#   GEM_HOME=$(brew --prefix cocoapods)/libexec $(brew --prefix ruby)/bin/ruby \
#     tool/ios_add_widget_target.rb
require 'xcodeproj'

project = Xcodeproj::Project.open('ios/Runner.xcodeproj')
exit 0 if project.targets.any? { |t| t.name == 'DottodayWidgets' }
runner = project.targets.find { |t| t.name == 'Runner' }

widgets = project.new_target(:app_extension, 'DottodayWidgets', :ios, '16.0', nil, :swift)
group = project.main_group.new_group('DottodayWidgets', 'DottodayWidgets')
sources = %w[DottodayWidgets.swift Snapshot.swift Views.swift].map { |f| group.new_file(f) }
widgets.add_file_references(sources)
group.new_file('Info.plist')
group.new_file('DottodayWidgets.entitlements')

# Only Flutter's generated settings (build name/number), not the Pods: the
# extension links no plugins.
generated = project.files.find { |f| f.path == 'Flutter/Generated.xcconfig' } ||
            project.main_group['Flutter'].new_file('Generated.xcconfig')
widgets.build_configurations.each do |config|
  config.base_configuration_reference = generated
  s = config.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'app.dottoday.planner.widgets'
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['INFOPLIST_FILE'] = 'DottodayWidgets/Info.plist'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['CODE_SIGN_ENTITLEMENTS'] = 'DottodayWidgets/DottodayWidgets.entitlements'
  s['SWIFT_VERSION'] = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['SKIP_INSTALL'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end
project.main_group['Runner'].new_file('Runner.entitlements')

runner.add_dependency(widgets)
embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
build_file = embed.add_file_reference(widgets.product_reference)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
# Before Flutter's script phases, or Xcode reports a dependency cycle.
frameworks = runner.build_phases.index(runner.frameworks_build_phase)
runner.build_phases.delete(embed)
runner.build_phases.insert(frameworks + 1, embed)

project.save
puts 'added DottodayWidgets'
