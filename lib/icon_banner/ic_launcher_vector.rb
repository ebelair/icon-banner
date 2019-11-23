require 'icon_banner/process'
require 'icon_banner/ic_launcher_base'

require 'chroma'
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

    def generate_banner(icon_path, base_path, label, color, font, options)
      text_svg = generate_text_svg(label, font)

      launcher_xml = Ox.load_file(icon_path, mode: :generic)

      foreground_item = launcher_xml.locate('*/foreground')[0]
      if foreground_item.nil? || foreground_item['android:drawable'].nil?
        UI.error "Cannot process #{icon_path}: <foreground> must refer to a drawable"
        return
      end

      foreground_drawable = foreground_item['android:drawable'][/(?<=@drawable\/).*/]
      foreground_files = find_files(icon_path, base_path, "#{foreground_drawable}.xml", false)

      if foreground_files.empty?
        UI.error "Cannot process #{icon_path}: Could not find #{foreground_item['android:drawable']}"
        return
      end

      foreground_files.each do |foreground_file|
        $adaptive_processed_files = [] if $adaptive_processed_files.nil?
        if $adaptive_processed_files.include?(foreground_file)
          UI.message "Skipped #{foreground_file}: Already processed"
          break
        end
        $adaptive_processed_files.push foreground_file

        if options[:backup]
          restore_backup foreground_file
          create_backup foreground_file
        end

        foreground_icon = Ox.load_file(foreground_file, mode: :generic)

        width = foreground_icon['android:viewportWidth'].to_f
        height = foreground_icon['android:viewportHeight'].to_f
        scale = height / NORMAL_SIZE

        if width == 0 || height == 0
          UI.message "Skipped #{foreground_file}: viewportWidth and/or viewportHeight are missing"
          break
        end

        effective_color = color.paint.to_hex
        if effective_color.paint.brightness >= 220.0
          effective_color = get_drawable_main_color(foreground_icon, false)
          effective_color = '#000000' if effective_color.nil? || effective_color.paint.brightness >= 220.0
          UI.verbose "Override primary color: #{effective_color}"
        end

        banner_ln_y = height * (1 - (NORMAL_PADDING + BANNER_HEIGHT + LINE_HEIGHT) / NORMAL_SIZE)
        banner_bg_y = height * (1 - (NORMAL_PADDING + BANNER_HEIGHT) / NORMAL_SIZE)
        banner_ln_path = "M 0 #{banner_ln_y} L 0 #{banner_bg_y} L #{width} #{banner_bg_y} L #{width} #{banner_ln_y}z"
        banner_bg_path = "M 0 #{banner_bg_y} L 0 #{height} L #{width} #{height} L #{width} #{banner_bg_y}z"

        banner_ln_object = Ox::Element.new('path')
        banner_ln_object['android:fillColor'] = effective_color
        banner_ln_object['android:pathData'] = banner_ln_path
        foreground_icon << banner_ln_object

        banner_bg_object = Ox::Element.new('path')
        banner_bg_object['android:fillColor'] = '#FAFFFFFF'
        banner_bg_object['android:pathData'] = banner_bg_path
        foreground_icon << banner_bg_object

        text_scale = text_svg[:scale] * scale
        banner_text_x = (width - text_svg[:width] * text_scale) * 0.5
        banner_text_y = banner_ln_y + ((BANNER_HEIGHT - LABEL_BOTTOM_PADDING) * scale - text_svg[:height] * text_scale) * 0.5

        banner_text_x += text_scale * text_svg[:x]
        banner_text_y += text_scale * text_svg[:y]

        banner_text_object = Ox::Element.new('group')
        banner_text_object['android:scaleX'] = text_scale.to_s
        banner_text_object['android:scaleY'] = text_scale.to_s
        banner_text_object['android:translateX'] = banner_text_x.to_s
        banner_text_object['android:translateY'] = banner_text_y.to_s

        text_svg[:paths].each do |letter_path|
          letter_group = Ox::Element.new('group')
          if letter_path['transform']
            letter_group['android:translateX'] = letter_path['transform'].gsub(/[^\d,-]/,'').split(',')[-2]
            letter_group['android:translateY'] = letter_path['transform'].gsub(/[^\d,-]/,'').split(',')[-1]
          end
          letter_object = Ox::Element.new('path')
          letter_object['android:fillColor'] = effective_color
          letter_object['android:pathData'] = letter_path['d']
          letter_group << letter_object
          banner_text_object << letter_group
        end

        foreground_icon << banner_text_object

        Ox.to_file(foreground_file, foreground_icon, indent: 4)

        UI.verbose "Added banner to #{foreground_file}"
      end
    end

    def generate_text_svg(label, font)
      text_svg = Text2svg(label, font: font, text_align: :center, scale: 0.1)
      text_xml = Ox.parse(text_svg.to_s)
      text_frame = text_xml['viewBox'].split(' ').map  { |i| i.to_f }
      text_node = text_xml.locate('g')[0]
      text_x = (text_node['transform'] || '').gsub(/[^\d,-]/,'').split(',')[-2].to_f
      text_y = (text_node['transform'] || '').gsub(/[^\d,-]/,'').split(',')[-1].to_f
      text_width = text_frame[2]
      text_height = text_frame[3]

      {
        x: text_x,
        y: text_y,
        width: text_width,
        height: text_height,
        paths: text_node.nodes,
        scale: (text_width / text_height) > (MAX_LABEL_WIDTH / MAX_LABEL_HEIGHT) ?
                    MAX_LABEL_WIDTH / text_width : MAX_LABEL_HEIGHT / text_height
      }
    end

    def find_files(icon_path, base_path, filename, deep_search = true)
      current_path = File.dirname(icon_path)
      files = []
      until File.realpath(current_path) == File.realpath(base_path) || current_path.empty? do
        files |= Dir.glob("#{current_path}/**/#{filename}").reject { |file| should_ignore_icon(file) }
        return files unless files.empty? || deep_search
        current_path = current_path.split(File::SEPARATOR)[0...-1].join(File::SEPARATOR)
      end
      files
    end

    def find_base_color(icon_path, base_path)
      launcher_xml = Ox.load_file(icon_path, mode: :generic)

      background_item = launcher_xml.locate('*/background')[0]
      return if background_item.nil? || background_item['android:drawable'].nil?

      color = background_item['android:drawable'][/(?<=@color\/).*/]
      return fetch_color_in_colors(icon_path, base_path, color) if color

      drawable = background_item['android:drawable'][/(?<=@drawable\/).*/]
      return fetch_color_in_drawable(icon_path, base_path, drawable) if drawable

      nil
    end

    def fetch_color_in_colors(icon_path, base_path, color_name)
      color_files = find_files(icon_path, base_path, 'colors.xml')
      color_files |= find_files(icon_path, base_path, "#{color_name}.xml")

      color_files.each do |color_file|
        color_file_content = Ox.load_file(color_file, mode: :generic)
        colors = color_file_content.locate("*/color[@name=#{color_name}]")

        colors = colors.map { |c| c.nodes[0] }.reject { |c| c.nil? }
        colors.each do |color|
          if color[/(?<=@color\/).*/]
            return fetch_color_in_colors(icon_path, base_path, color[/(?<=@color\/).*/])
          end

          return color.paint.to_hex if color.paint.to_hex
        end
      end

      nil
    end

    def fetch_color_in_drawable(icon_path, base_path, drawable_name)
      drawable_files = find_files(icon_path, base_path, "#{drawable_name}.xml")

      drawable_files.each do |drawable_file|
        drawable_icon = Ox.load_file(drawable_file, mode: :generic)
        main_color = get_drawable_main_color(drawable_icon)
        return main_color if main_color
      end

      nil
    end

    def get_drawable_main_color(drawable_icon, merge = true)
      all_colors = drawable_icon.locate('*/?[@android:fillColor]').map { |c| c['android:fillColor'] }
      all_colors |= drawable_icon.locate('*/?[@android:color]').map { |c| c['android:color'] }

      all_colors = all_colors.map do |color|
        if color[/(?<=@color\/).*/]
          fetch_color_in_colors(icon_path, base_path, color[/(?<=@color\/).*/])
        else
          color
        end
      end

      colors = all_colors.select { |color| color.paint.rgb.a > 0.95 }

      if merge && colors.length > 1
        r = colors.inject(0.0) { |sum, color| sum + color.paint.rgb.r } / colors.length
        g = colors.inject(0.0) { |sum, color| sum + color.paint.rgb.g } / colors.length
        b = colors.inject(0.0) { |sum, color| sum + color.paint.rgb.b } / colors.length
        return "rgb(#{r},#{g},#{b})".paint.to_hex
      end

      colors[0]
    end
  end
end
