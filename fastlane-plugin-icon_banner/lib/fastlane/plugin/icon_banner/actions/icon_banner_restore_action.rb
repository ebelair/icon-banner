require 'fastlane/action'
require_relative '../helper/icon_banner_helper'

module Fastlane
  module Actions
    class IconBannerRestoreAction < Action
      def self.run(params)
        Actions.verify_gem!('icon-banner')
        Helper::IconBannerHelper.restore
      end

      def self.description
        'Restores the original app icons (can be used after build to clean up the repository)'
      end

      def self.authors
        ['ebelair']
      end

      def self.example_code
        [
            'icon_banner_restore()'
        ]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
