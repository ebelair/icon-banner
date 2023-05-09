lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/icon_banner/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-icon_banner'
  spec.version       = Fastlane::IconBanner::VERSION
  spec.author        = 'Émile Bélair'
  spec.email         = 'ebelair@me.com'

  spec.summary       = 'Banners for your app icons'
  spec.description   = 'IconBanner adds custom nice-looking banners over your mobile app icons'
  spec.homepage      = 'https://github.com/ebelair/icon-banner'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*'] + %w(README.md LICENSE)
  spec.require_paths = ['lib']

  spec.add_dependency 'icon-banner', '~> 0.2.3'

  spec.add_development_dependency 'fastlane', '~> 2.100'
  spec.add_development_dependency 'rspec', '~> 3.4'
end
