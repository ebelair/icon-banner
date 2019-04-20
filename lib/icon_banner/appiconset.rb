require 'fastlane_core'
require 'mini_magick'

module IconBanner
  class AppIconSet
    BASE_ICON_PATH = '/**/*.appiconset/*.{png,PNG}'
    BACKUP_EXTENSION = '.bak'

    def generate(path, options)
      IconBanner.validate_libs!

      app_icons = get_app_icons(path)

      label = options[:label]
      font = options[:font] || IconBanner.font_path

      if app_icons.count > 0
        UI.message 'Starting banner process...'

        app_icons.each do |icon_path|
          UI.verbose "Processing #{icon_path}"
          create_backup icon_path if options[:backup]

          color = options[:color]
          begin
            color = find_base_color(icon_path)
            UI.verbose "Color: #{color}"
          end unless color

          banner_file = Tempfile.new %w[banner .png]
          generate_banner banner_file.path, color, label, font
          process_icon icon_path, banner_file.path
          banner_file.close

          UI.verbose "Completed processing #{File.basename icon_path}"
          UI.verbose ''
        end

        UI.message 'Completed banner process.'
      else
        UI.error('No icon found.')
      end
    end

    def restore(path)
      app_icons = get_app_icons(path)

      if app_icons.count > 0
        UI.message 'Starting restore...'

        app_icons.each do |icon_path|
          UI.verbose "Restoring #{icon_path}"
          restore_backup icon_path
        end

        UI.message 'Completed restore.'
      end
    end

    def get_app_icons(path)
      app_icons = Dir.glob("#{path}#{BASE_ICON_PATH}")
      app_icons.reject { |i| i[/\/Carthage\//] || i[/\/Pods\//] ||i[/\/Releases\//] }
    end

    def find_base_color(path)
      color = MiniMagick::Tool::Convert.new do |convert|
        convert << path
        convert.colors 3
        convert << '-unique-colors'
        convert.format '%[pixel:u]'
        convert << 'xc:transparent'
        convert << 'info:-'
      end
      color[/rgba?\([^)]*\)/]
    end

    def generate_banner(path, color, label, font)
      MiniMagick::Tool::Convert.new do |convert|
        convert.size '1024x1024'
        convert << 'xc:transparent'
        convert << path
      end

      banner = MiniMagick::Image.new path

      banner.combine_options do |combine|
        combine.fill 'rgba(0,0,0,0.25)'
        combine.draw 'polygon 0,306 0,590 590,0 306,0'
        combine.blur '0x10'
      end

      banner.combine_options do |combine|
        combine.fill 'white'
        combine.draw 'polygon 0,306 0,590 590,0 306,0'
      end

      banner.combine_options do |combine|
        combine.font font
        combine.fill color
        combine.gravity 'Center'
        combine.pointsize 150 - ([label.length - 8, 0].max * 8)
        combine.draw "affine 0.5,-0.5,0.5,0.5,-286,-286 text 0,0 \"#{label}\""
      end
    end

    def process_icon(icon_path, banner_path)
      icon = MiniMagick::Image.open(icon_path)
      banner = MiniMagick::Image.open(banner_path)
      banner.resize "#{icon.width}x#{icon.height}"
      icon.composite(banner).write(icon_path)
    end

    def create_backup(icon_path)
      FileUtils.cp(icon_path, backup_path(icon_path))
    end

    def restore_backup(icon_path)
      restore_path = backup_path(icon_path)
      if File.exists?(restore_path)
        FileUtils.cp(restore_path, icon_path)
        File.delete restore_path
      end
    end

    def backup_path(path)
      ext = File.extname path
      path.gsub(ext, BACKUP_EXTENSION + ext)
    end
  end
end
