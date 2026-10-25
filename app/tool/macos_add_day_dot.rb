# Adds the menu-bar day dot (macos/Runner/DayDotStatusItem.swift, docs/09
# M9.6) to the macOS Runner and its golden tests to RunnerTests.
# Idempotent. Run from app/:
#   GEM_HOME=$(brew --prefix cocoapods)/libexec $(brew --prefix ruby)/bin/ruby \
#     tool/macos_add_day_dot.rb
require 'xcodeproj'

project = Xcodeproj::Project.open('macos/Runner.xcodeproj')
{ 'Runner' => %w[DayDotStatusItem.swift], 'RunnerTests' => %w[DayDotImageTests.swift] }.each do |name, files|
  target = project.targets.find { |t| t.name == name }
  group = project.main_group[name]
  files.each do |file|
    ref = group.files.find { |f| f.path == file } || group.new_file(file)
    target.add_file_references([ref]) unless target.source_build_phase.files_references.include?(ref)
  end
end
project.save
