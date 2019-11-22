lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'icon_banner'

Gem::Specification.new do |spec|
  spec.name          = 'icon-banner'
  spec.version       = IconBanner::VERSION
  spec.authors       = ['Émile Bélair']
  spec.email         = ['ebelair@me.com']

  spec.summary       = 'Banners for your app icons'
  spec.description   = IconBanner::DESCRIPTION
  spec.homepage      = 'https://github.com/ebelair/icon-banner'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*'] + %w{ bin/icon-banner README.md LICENSE assets/LilitaOne.ttf }

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'chroma', '~> 0.2.0'
  spec.add_dependency 'fastlane', '~> 2.100'
  spec.add_dependency 'mini_magick', '~> 4.9.4'
  spec.add_dependency 'ox', '~> 2.11'
  spec.add_dependency 'text2svg', '~> 0.5'

  spec.add_development_dependency 'rspec', '~> 3.4'
end
