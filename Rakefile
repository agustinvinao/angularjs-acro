require './acro_app'
require './acro_api'
require 'sinatra/activerecord/rake'
require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  # do not run integration tests, doesn't work on TravisCI
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec