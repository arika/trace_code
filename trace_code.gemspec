# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trace_code/version'

Gem::Specification.new do |spec|
  spec.name          = 'trace_code'
  spec.version       = TraceCode::VERSION
  spec.authors       = ['akira yamada']
  spec.email         = ['akira@arika.org']

  spec.summary       = 'code tracing library for single method call, or tiny coverage tool'
  spec.homepage      = 'https://github.com/arika/trace_code'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
end
