require 'icon_banner/process'

require 'fastlane_core'
require 'mini_magick'

module IconBanner
  class IcLauncherBase < Process
    BASE_ICON_PATH = '__TO OVERRIDE__'
    PLATFORM = '__TO OVERRIDE__'
    PLATFORM_CODE = 'android'

    def generate_banner(path, label, color, font)
      UI.error '`generate_banner` should not be run on base class'
    end

    def backup_path(path)
      ext = File.extname path
      backup_path = path
      backup_path = append_parent_dirname(path, BACKUP_EXTENSION, 'res') if path.include?('/res/')
      backup_path = path.gsub('/src/', "/src#{BACKUP_EXTENSION}/") if path == backup_path
      backup_path = path.gsub('/app/', "/src#{BACKUP_EXTENSION}/") if path == backup_path
      backup_path = path.gsub('/android/', "/src#{BACKUP_EXTENSION}/") if path == backup_path
      backup_path = path.gsub(ext, BACKUP_EXTENSION + ext) if path == backup_path
      backup_path
    end

    def should_ignore_icon(icon)
      icon[/\/build\//] || icon[/\/generated\//] || icon[/#{BACKUP_EXTENSION}/]
    end
  end
end
