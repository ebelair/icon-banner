require 'icon_banner'
require 'icon_banner/appiconset'
require 'mini_magick'

RSpec.describe IconBanner::AppIconSet do
  REFERENCE_ICONSET = 'Reference'
  SAMPLE_ICONSET = 'Sample.appiconset'
  LABELS = %w{Daily QA Staging Production}

  it 'test icons' do
    app_icon_set = IconBanner::AppIconSet.new
    path = current_path
    options = FastlaneCore::Configuration.create(IconBanner::IconBanner.available_options, Hash.new)

    app_icon_set.restore path # just make sure

    expect(options[:backup]).to be_truthy

    icons = Dir.glob(File.join(icon_path, '*.{png,PNG}'))

    LABELS.each do |label|
      options[:label] = label
      app_icon_set.generate path, options

      icons.each do |icon|
        reference = icon.sub(SAMPLE_ICONSET, REFERENCE_ICONSET)
                        .sub('.png', "_#{label}.png")

        begin
          compare = `compare -metric PSNR #{icon} #{reference} NULL: 2>&1`
          expect(compare).to eq('inf')
        end
        # To regenerate images, replace this block with:
        #begin
        #  FileUtils.copy icon, reference
        #end
      end

      app_icon_set.restore path
    end
  end

  def current_path
    File.dirname __FILE__
  end

  def icon_path
    File.join current_path, SAMPLE_ICONSET
  end
end
