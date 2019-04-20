require 'fastlane/action'
require_relative '../helper/icon_banner_helper'

module Fastlane
  module Actions
    class IconBannerAction < Action
      def self.run(params)
        Actions.verify_gem!('icon-banner')
        Helper::IconBannerHelper.generate(params)
      end

      def self.description
        'Adds custom nice-looking banners over your mobile app icons'
      end

      def self.authors
        ['ebelair']
      end

      def self.available_options
        Helper::IconBannerHelper.available_options
      end

      def self.example_code
        [
            'icon_banner(label: "Staging")'
        ]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
