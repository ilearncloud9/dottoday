# Adds the localised InfoPlist.strings (OS permission prompts, docs/09
# M8.3b) to the Runner target of ios/ and macos/ as one variant group, and
# de/fr/es to the projects' known regions. Idempotent. Run from app/:
#   GEM_HOME=$(brew --prefix cocoapods)/libexec $(brew --prefix ruby)/bin/ruby \
#     tool/xcode_add_infoplist_strings.rb
require 'xcodeproj'

LANGUAGES = %w[de fr es].freeze

%w[ios macos].each do |platform|
  project = Xcodeproj::Project.open("#{platform}/Runner.xcodeproj")
  runner = project.targets.find { |t| t.name == 'Runner' }
  group = project.main_group['Runner']
  variant = group.children.find { |c| c.display_name == 'InfoPlist.strings' } ||
            group.new_variant_group('InfoPlist.strings')
  LANGUAGES.each do |lang|
    next if variant.children.any? { |c| c.name == lang }

    ref = variant.new_reference("#{lang}.lproj/InfoPlist.strings")
    ref.name = lang
    ref.last_known_file_type = 'text.plist.strings'
  end
  unless runner.resources_build_phase.files_references.include?(variant)
    runner.resources_build_phase.add_file_reference(variant)
  end
  regions = project.root_object.known_regions
  project.root_object.known_regions = regions | LANGUAGES
  project.save
end
