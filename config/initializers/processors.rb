require 'paperclip'

begin
  Paperclip.run('ffmpeg', '-L')
rescue Paperclip::CommandNotFoundError
  Radiant.config['assets.create_video_thumbnails?'] = false
  Rails.logger.warn "FFmpeg executable not found: video thumbnailing disabled."
end
