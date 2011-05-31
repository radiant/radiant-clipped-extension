require 'paperclip'

Paperclip.options[:command_path] = IMAGE_MAGICK_PATH if defined? IMAGE_MAGICK_PATH

begin
  Paperclip.run('ffmpeg', '-L')
rescue Paperclip::CommandNotFoundError
  Radiant.config['assets.create_video_thumbnails?'] = false
  Rails.logger.warn "FFmpeg executable not found: video thumbnailing disabled."
rescue Paperclip::PaperclipCommandLineError => e
  Rails.logger.warn "FFmpeg is present but returns an error: #{e}"
end
