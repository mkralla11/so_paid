# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pay_me/version'

Gem::Specification.new do |spec|
  spec.name          = "pay_me"
  spec.version       = PayMe::VERSION
  spec.authors       = ["mkralla11"]
  spec.email         = ["mike.mkrallaproductions@gmail.com"]
  spec.description   = %q{A no-nonsense, fully configurable Rails credit card/payment vendor gem.}
  spec.summary       = %q{There was a need to consolidate all credit card processing vendors for our web apps, but configuration needed to be at the forefront of the consolidated gem. So I built PayMe which allows for easy extension, and a generous amount of options...and should work out of the box, if you're the plug-and-play type. Examine how the code is written to see how easy it is to extend and make your own payment_vendor class that inherits from Hop.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "ruby-hmac"
  spec.add_development_dependency "rspec"
end
