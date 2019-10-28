lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dry/lifecycle/version'

Gem::Specification.new do |spec|
  spec.name          = 'dry-lifecycle'
  spec.version       = Dry::Lifecycle::VERSION.dup
  spec.authors       = ['Brian V. Hughes']
  spec.email         = ['brianvh89@gmail.com']

  spec.summary       = 'A dry-rb "aware" State Machine implementation.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/hashrabbit/dry-lifecycle'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/hashrabbit/dry-lifecycle'
    spec.metadata['changelog_uri'] = 'https://github.com/hashrabbit/dry-lifecycle/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads files in the RubyGem that are tracked by git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-container', '~> 0.7.2'
  spec.add_dependency 'dry-matcher', '~> 0.8.2'
  spec.add_dependency 'dry-monads', '~> 1.3.1'

  spec.add_development_dependency 'bundler', '~> 2.0.2'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.8.0'
end
