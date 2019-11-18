require 'fastlane_core'
require 'mini_magick'

module IconBanner
  class Process
    BASE_ICON_PATH = '__TO OVERRIDE__'
    PLATFORM = '__TO OVERRIDE__'
    PLATFORM_CODE = '__TO OVERRIDE__'

    BACKUP_EXTENSION = '.bak'

    def generate(path, options)
      IconBanner.validate_libs!
      return unless validate_platform(options)

      UI.message "Generating #{self.class::PLATFORM} banners..."

      restore(path) # restore in case it was already run before

      app_icons = get_app_icons(path)

      label = options[:label]
      font = options[:font] || IconBanner.font_path

      if app_icons.count > 0
        app_icons.each do |icon_path|
          UI.verbose "Processing #{icon_path}"
          create_backup icon_path if options[:backup]

          color = options[:color]
          begin
            color = find_base_color(icon_path)
            UI.verbose "Color: #{color}"
          end unless color

          banner_file = Tempfile.new %w[banner .png]
          generate_banner banner_file.path, label, color, font
          process_icon icon_path, banner_file.path
          banner_file.close

          UI.verbose "Completed processing #{File.basename icon_path}"
          UI.verbose ''
        end

        UI.message "Completed #{self.class::PLATFORM} generation."
      else
        UI.message "No #{self.class::PLATFORM} icons found."
      end
    end

    def restore(path)
      return unless validate_platform({})

      UI.message "Restoring #{self.class::PLATFORM} icons..."

      app_icons = get_app_icons(path)

      if app_icons.count > 0
        app_icons.each do |icon_path|
          UI.verbose "Restoring #{icon_path}"
          restore_backup icon_path
        end
      end

      UI.message "Completed #{self.class::PLATFORM} restore."
    end

    def get_app_icons(path)
      app_icons = Dir.glob("#{path}#{self.class::BASE_ICON_PATH}")
      app_icons.reject { |icon| should_ignore_icon(icon) }
    end

    def find_base_color(path)
      color = MiniMagick::Tool::Convert.new do |convert|
        convert << path
        convert.colors 3
        convert.background 'white'
        convert.alpha 'remove'
        convert << '-unique-colors'
        convert.format '%[pixel:u]'
        convert << 'xc:transparent'
        convert << 'info:-'
      end
      color[/rgba?\([^)]*\)/]
    end

    def process_icon(icon_path, banner_path)
      icon = MiniMagick::Image.open(icon_path)
      banner = MiniMagick::Image.open(banner_path)
      banner.resize "#{icon.width}x#{icon.height}"
      icon.composite(banner).write(icon_path)
    end

    def create_backup(icon_path)
      backup_path = backup_path(icon_path)
      FileUtils.mkdir_p(File.dirname(backup_path))
      FileUtils.cp(icon_path, backup_path)
    end

    def restore_backup(icon_path)
      restore_path = backup_path(icon_path)
      if File.exists?(restore_path)
        FileUtils.cp(restore_path, icon_path)
        File.delete restore_path
      end
    end

    def validate_platform(options)
      platform = ENV['FASTLANE_PLATFORM_NAME'] || options[:platform]
      platform.nil? || platform[/#{self.class::PLATFORM_CODE}/i] || platform == 'all'
    end

    def generate_banner(path, label, color, font)
      UI.error '`generate_banner` should not be run on base class'
    end

    def backup_path(path)
      UI.error '`backup_path` should not be run on base class'
    end

    def should_ignore_icon(icon)
      UI.error '`should_ignore_icon` should not be run on base class'
    end
  end
end
