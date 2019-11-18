require 'icon_banner'
require 'icon_banner/ic_launcher_png'
require 'mini_magick'

RSpec.describe IconBanner::IcLauncherPng do
  SAMPLE_ICONSET = 'ic_launcher_icons' # Icons from http://www.iconarchive.com/show/android-lollipop-icons-by-dtafalonso.html
  REFERENCE_ICONSET = 'ic_launcher_reference'
  
  LABELS = %w{Daily QA Staging Production}

  it 'test icons' do
    app_icon_set = IconBanner::IcLauncherPng.new
    path = icon_path
    options = FastlaneCore::Configuration.create(IconBanner::IconBanner.available_options, Hash.new)

    expect(options[:backup]).to be_truthy

    icons = Dir.glob(File.join(path, '/**/ic_launcher*.png'))

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
        # begin
        #   FileUtils.copy icon, reference
        # end
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
