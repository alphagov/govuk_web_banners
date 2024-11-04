require "bundler/setup"
require "rubocop/rake_task"
require "rspec/core/rake_task"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

task default: %i[rubocop spec]
