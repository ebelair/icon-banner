require 'icon_banner/process'
require 'icon_banner/ic_launcher_base'

require 'fastlane_core'
require 'mini_magick'

module IconBanner
  class IcLauncherPng < IcLauncherBase
    BASE_ICON_PATH = '/**/ic_launcher*.png'
    PLATFORM = 'Android (Legacy)'

    def generate_banner(path, label, color, font)
      banner_file = Tempfile.new %w[banner .png]

      size = 1024
      font_size = 140 - ([label.length - 12, 0].max * 12)

      # Start by computing the text
      MiniMagick::Tool::Convert.new do |convert|
        convert.size '1024x1024'
        convert << 'xc:transparent'
        convert << banner_file.path
      end

      banner = MiniMagick::Image.new banner_file.path

      banner.combine_options do |combine|
        combine.font font
        combine.fill color
        combine.gravity 'Center'
        combine.pointsize font_size
        combine.draw "text 0,0 \"#{label}\""
        combine.trim
      end

      margin = 20
      padding = 60
      radius = 25
      width = banner.width + padding * 2
      height = 262

      # Then restart the image and apply the banner
      MiniMagick::Tool::Convert.new do |convert|
        convert.size "#{size}x#{size}"
        convert << 'xc:transparent'
        convert << banner_file.path
      end

      banner = MiniMagick::Image.new banner_file.path

      x_start = size - margin * 2 - width
      x_end = size - margin
      y_start = size - margin - height
      y_end = size - margin
      polygon = "roundRectangle #{x_start},#{y_start} #{x_end},#{y_end} #{radius},#{radius}"

      banner.combine_options do |combine|
        combine.fill 'rgba(0,0,0,0.25)'
        combine.draw polygon
        combine.blur '0x10'
      end

      banner.combine_options do |combine|
        combine.fill 'white'
        combine.draw polygon
      end

      x_middle = x_start + (x_end - x_start) / 2
      y_middle = y_start + (y_end - y_start) / 2
      banner.combine_options do |combine|
        combine.font font
        combine.fill color
        combine.gravity 'Center'
        combine.pointsize font_size
        combine.draw "text #{x_middle - size / 2},#{y_middle - size / 2} \"#{label}\""
      end

      banner_file.close

      icon = MiniMagick::Image.open(path)
      banner = MiniMagick::Image.open(banner_file.path)
      banner.resize "#{icon.width}x#{icon.height}"
      icon.composite(banner).write(path)
    end
  end
end
