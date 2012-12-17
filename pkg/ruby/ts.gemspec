# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ts/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Simon Chiang"]
  gem.email         = ["simon.a.chiang@gmail.com"]
  gem.description   = %q{Ruby package of ts - a shell test script}
  gem.summary       = %q{Ruby package of ts - a shell test script}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ts"
  gem.require_paths = ["lib"]
  gem.version       = Ts::VERSION
end
