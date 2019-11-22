require 'icon_banner/process'

require 'fastlane_core'
require 'mini_magick'

module IconBanner
  class AppIconSet < Process
    BASE_ICON_PATH = '/**/*.appiconset/*.png'
    PLATFORM = 'iOS'
    PLATFORM_CODE = 'ios'

    def generate_banner(path, label, color, font)
      banner_file = Tempfile.new %w[banner .png]

      MiniMagick::Tool::Convert.new do |convert|
        convert.size '1024x1024'
        convert << 'xc:transparent'
        convert << banner_file.path
      end

      banner = MiniMagick::Image.new banner_file.path

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

      icon = MiniMagick::Image.open(path)
      banner = MiniMagick::Image.open(banner_file.path)
      banner.resize "#{icon.width}x#{icon.height}"
      icon.composite(banner).write(path)

      banner_file.close
    end

    def backup_path(path)
      ext = File.extname path
      backup_path = path.gsub('\.xcassets', ".xcassets#{BACKUP_EXTENSION}")
      backup_path = append_parent_dirname(path, BACKUP_EXTENSION) if path == backup_path
      backup_path = path.gsub(ext, BACKUP_EXTENSION + ext) if path == backup_path
      backup_path
    end

    def should_ignore_icon(icon)
      icon[/\/Carthage\//] || icon[/\/Pods\//] || icon[/\/Releases\//]
    end
  end
end
