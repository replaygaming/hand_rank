# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hand_rank/version'

Gem::Specification.new do |spec|
  spec.name          = "hand_rank"
  spec.version       = HandRank::VERSION
  spec.authors       = "Jonas Schubert Erlandsson"
  spec.email         = "jonas.schubert.erlandsson@my-codeworks.com"
  spec.summary       = "Implements fast poker hand ranking algorithms in C and exposes them through a Ruby API."
  spec.description   = "This gem implements the Two Plus Two forum algorithm for ranking \"normal\" poker hands, such that are used in Texas Hold'em for example. Support for more hand types, such as high/low hands, will be added in future versions."
  spec.homepage      = "https://github.com/replaygaming/hand_rank"
  spec.license       = "MIT"

  spec.required_ruby_version = '~> 2.3'

  spec.files         = `git ls-files -z`.split("\x0")

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  spec.extensions    = ["ext/hand_rank/extconf.rb"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rake-compiler", "~> 0.9"
  spec.add_development_dependency "rspec", "~> 3.0"
end
