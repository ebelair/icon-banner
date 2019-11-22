require 'icon_banner/process'
require 'icon_banner/ic_launcher_base'

require 'fastlane_core'
require 'ox'
require 'text2svg'

module IconBanner
  class IcLauncherVector < IcLauncherBase
    BASE_ICON_PATH = '/**/ic_launcher{,_round}.xml'
    PLATFORM = 'Android (Adaptive)'

    def generate_banner(path, label, color, font)
      text_svg = Text2svg(label, font: font, text_align: :center, bold: true, scale: 0.1)
      text_xml = Ox.parse(text_svg.to_s)

      # TODO: Complete generation
    end

    def process_icon(icon_path, banner_path)
      # no-op
    end

    def find_base_color(path)
      # TODO: extraire du ic_launcher.xml
      'black'
    end
  end
end
