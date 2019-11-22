require 'icon_banner/process'
require 'icon_banner/ic_launcher_base'

require 'fastlane_core'
require 'ox'
require 'text2svg'

module IconBanner
  class IcLauncherVector < IcLauncherBase
    BASE_ICON_PATH = '/**/ic_launcher{,_round}.xml'
    PLATFORM = 'Android (Adaptive)'

    NORMAL_SIZE = 108.0
    NORMAL_PADDING = 18.0

    LINE_HEIGHT = 0.7
    BANNER_HEIGHT = 20.0

    MAX_LABEL_HEIGHT = 12.0
    MAX_LABEL_WIDTH = 46.0

    LABEL_BOTTOM_PADDING = 1.0

    def generate_banner(path, label, color, font)
      text_svg = Text2svg(label, font: font, text_align: :center, scale: 0.1)
      text_xml = Ox.parse(text_svg.to_s)
      text_path = text_xml.locate('g')[0]
      text_frame = text_xml['viewBox'].split(' ').map  { |i| i.to_f }
      text_width = text_frame[2]
      text_height = text_frame[3]
      text_base_scale = (text_width / text_height) > (MAX_LABEL_WIDTH / MAX_LABEL_HEIGHT) ?
                       MAX_LABEL_WIDTH / text_width : MAX_LABEL_HEIGHT / text_height

      launcher_xml = Ox.load_file(path, mode: :generic)

      foreground_item = launcher_xml.locate('*/foreground')[0]
      background_item = launcher_xml.locate('*/background')[0]

      if foreground_item.nil? || background_item.nil?
        UI.error "Cannot process #{path}: malformed XML (foreground and background unavailable)"
        return
      end

      foreground_filename = foreground_item['android:drawable'].gsub(/@drawable\/(.*)/, '\1.xml')
      foreground_files = find_files(path, foreground_filename)

      foreground_files.each do |foreground_file|
        $adaptive_processed_files = [] if $adaptive_processed_files.nil?
        break if $adaptive_processed_files.include?(foreground_file)
        $adaptive_processed_files.push(foreground_file)

        restore_backup(foreground_file)
        create_backup(foreground_file)

        foreground_icon = Ox.load_file(foreground_file, mode: :generic)

        width = foreground_icon['android:viewportWidth'].to_f
        height = foreground_icon['android:viewportHeight'].to_f
        scale = height / NORMAL_SIZE

        if width == 0 || height == 0
          UI.message "Skipped #{foreground_file}: viewportWidth and/or viewportHeight are missing"
          break
        end

        banner_ln_y = height * (1 - (NORMAL_PADDING + BANNER_HEIGHT + LINE_HEIGHT) / NORMAL_SIZE)
        banner_bg_y = height * (1 - (NORMAL_PADDING + BANNER_HEIGHT) / NORMAL_SIZE)
        banner_ln_path = "M 0 #{banner_ln_y} L 0 #{banner_bg_y} L #{width} #{banner_bg_y} L #{width} #{banner_ln_y}z"
        banner_bg_path = "M 0 #{banner_bg_y} L 0 #{height} L #{width} #{height} L #{width} #{banner_bg_y}z"

        banner_ln_object = Ox::Element.new('path')
        banner_ln_object['android:fillColor'] = color
        banner_ln_object['android:pathData'] = banner_ln_path
        foreground_icon << banner_ln_object

        banner_bg_object = Ox::Element.new('path')
        banner_bg_object['android:fillColor'] = '#FAFFFFFF'
        banner_bg_object['android:pathData'] = banner_bg_path
        foreground_icon << banner_bg_object

        text_scale = text_base_scale * scale
        banner_text_x = (width - text_width * text_scale) * 0.5
        banner_text_y = banner_ln_y + ((BANNER_HEIGHT - LABEL_BOTTOM_PADDING) * scale - text_height * text_scale) * 0.5

        if text_path['transform']
          banner_text_x += text_scale * text_path['transform'].gsub(/[^\d,-]/,'').split(',')[-2].to_f
          banner_text_y += text_scale * text_path['transform'].gsub(/[^\d,-]/,'').split(',')[-1].to_f
        end

        banner_text_object = Ox::Element.new('group')
        banner_text_object['android:scaleX'] = text_scale.to_s
        banner_text_object['android:scaleY'] = text_scale.to_s
        banner_text_object['android:translateX'] = banner_text_x.to_s
        banner_text_object['android:translateY'] = banner_text_y.to_s

        text_path.nodes.each do |letter_path|
          letter_group = Ox::Element.new('group')
          if letter_path['transform']
            letter_group['android:translateX'] = letter_path['transform'].gsub(/[^\d,-]/,'').split(',')[-2]
            letter_group['android:translateY'] = letter_path['transform'].gsub(/[^\d,-]/,'').split(',')[-1]
          end
          letter_object = Ox::Element.new('path')
          letter_object['android:fillColor'] = color
          letter_object['android:pathData'] = letter_path['d']
          letter_group << letter_object
          banner_text_object << letter_group
        end

        foreground_icon << banner_text_object

        Ox.to_file(foreground_file, foreground_icon, indent: 4)

        UI.verbose "Added banner to #{foreground_file}"
      end

      icon_background_path = background_item['android:drawable']

      # TODO: Complete generation
    end

    def find_files(path, filename)
      current_path = File.dirname(path)
      until current_path.empty? do
        files = Dir.glob("#{current_path}/**/#{filename}")
        return files unless files.empty?
        current_path = current_path.split(File::SEPARATOR)[0...-1].join(File::SEPARATOR)
      end
    end

    def find_base_color(path)
      # TODO: extraire du ic_launcher.xml
    end
  end
end
