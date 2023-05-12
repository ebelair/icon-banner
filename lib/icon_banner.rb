require 'icon_banner/appiconset'
require 'icon_banner/ic_launcher'
require 'commander'

module IconBanner
  VERSION = '0.2.4'
  DESCRIPTION = 'IconBanner adds custom nice-looking banners over your mobile app icons'

  UI = FastlaneCore::UI

  class IconBanner
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :name, 'IconBanner'
      program :version, VERSION
      program :description, DESCRIPTION

      global_option('--verbose', 'Shows a more verbose output') { FastlaneCore::Globals.verbose = true }

      command :generate do |c|
        c.syntax = 'icon-banner generate [path] [options]'
        c.description = 'Generates banners and adds them to app icons'
        FastlaneCore::CommanderGenerator.new.generate(IconBanner::available_options, command: c)

        c.action do |args, options|
          path = args[0] || '.'
          options = FastlaneCore::Configuration.create(IconBanner::available_options, options.__hash__)
          IconBanner.generate(path, options)
        end
      end

      command :restore do |c|
        c.syntax = 'icon-banner restore [path]'
        c.description = 'Restores app icons without banners (if backups are available)'

        c.action do |args|
          path = args[0] || '.'
          IconBanner.restore(path)
        end
      end

      run!
    end

    def self.generate(path, options)
      AppIconSet.new.generate(path, options)
      IcLauncher.new.generate(path, options)
    end

    def self.restore(path)
      AppIconSet.new.restore(path)
      IcLauncher.new.restore(path)
    end

    def self.available_options
      [
          FastlaneCore::ConfigItem.new(key: :label,
                                       description: 'Sets the text to display inside the banner',
                                       default_value: 'BETA',
                                       optional: true),

          FastlaneCore::ConfigItem.new(key: :color,
                                       description: 'Sets the text color (when not set, the script uses the dominant icon color)',
                                       optional: true),

          FastlaneCore::ConfigItem.new(key: :font,
                                       description: 'Sets the text font with a _direct link_ to a TTF file (when not set, the script uses the embedded LilitaOne font)',
                                       optional: true),

          FastlaneCore::ConfigItem.new(key: :backup,
                                       description: 'Creates a backup of icons before applying banners (only set to `false` if you are under source-control)',
                                       is_string: false,
                                       default_value: true,
                                       optional: true),

          FastlaneCore::ConfigItem.new(key: :platform,
                                       description: 'Selects the platform to process (`ios`, `android` or `all`). Auto-inferred by lane if available',
                                       default_value: 'all',
                                       optional: true)
      ]
    end

    def self.validate_libs!
      begin
        UI.error('ImageMagick was not found on your system. To install it, run the following command:')
        UI.command('brew install imagemagick')
        UI.user_error!('IconBanner is missing requirements.')
      end unless `which convert`.include?('convert')
    end

    def self.base_path
      File.dirname __dir__ + '/../../'
    end

    def self.font_path
      File.join base_path, 'assets', 'LilitaOne.ttf'
    end
  end
end
