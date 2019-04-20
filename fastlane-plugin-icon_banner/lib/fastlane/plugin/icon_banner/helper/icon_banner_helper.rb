module IconBannerBridge
  class Bridge
    require 'icon_banner'

    def self.available_options
      IconBanner::IconBanner.available_options
    end

    def self.generate(options)
      IconBanner::IconBanner.generate('.', options)
    end

    def self.restore
      IconBanner::IconBanner.restore('.')
    end
  end
end

module Fastlane
  module Helper
    class IconBannerHelper
      def self.available_options
        IconBannerBridge::Bridge.available_options
      end

      def self.generate(options)
        IconBannerBridge::Bridge.generate(options)
      end

      def self.restore
        IconBannerBridge::Bridge.restore
      end
    end
  end
end
