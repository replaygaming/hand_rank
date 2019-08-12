# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/extensiontask"
require 'rspec/core/rake_task'

Rake::ExtensionTask.new "hand_rank" do |ext|
  ext.lib_dir = "lib/hand_rank"
end

RSpec::Core::RakeTask.new(:spec)

task default: :spec
