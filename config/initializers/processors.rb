require 'paperclip'

if Radiant.config.table_exists?
  if Radiant.config['assets.create_image_thumbnails?']
    # Check that we can run convert
    begin
      output = Paperclip.run('convert', '-version')
      Rails.logger.info %{[Clipped] Using image thumbnailer: #{output.split("\n").first.sub(/^Version: /i, '')}}
    rescue Cocaine::CommandNotFoundError
      Radiant.config['assets.create_image_thumbnails?'] = false
      Radiant.config['assets.create_pdf_thumbnails?'] = false
      Rails.logger.warn "ImageMagick 'convert' executable not found: image and pdf thumbnailing disabled."
    rescue Cocaine::ExitStatusError => e
      Rails.logger.warn "ImageMagick is present but calling 'convert -version' returns an error: #{e}"
    end
  end

  if Radiant.config['assets.create_pdf_thumbnails?']
    # Check that we can run ghostscript
    begin
     output = Paperclip.run('gs', '-v')
     Rails.logger.info %{[Clipped] Using PDF thumbnailer: #{output.split("\n").first}}
    rescue Cocaine::CommandNotFoundError
      Radiant.config['assets.create_pdf_thumbnails?'] = false
      Rails.logger.warn "Ghostscript 'gs' executable not found: pdf thumbnailing disabled."
    rescue Cocaine::ExitStatusError => e
      Rails.logger.warn "Ghostscript is present but calling 'gs -v' returns an error: #{e}"
    end
  end

  if Radiant.config['assets.create_video_thumbnails?']
    # Check that we can run ffmpeg
    begin
      output = Paperclip.run('ffmpeg', '-version 2> /dev/null')
      Rails.logger.info %{[Clipped] Using video frame grabber: #{output.split("\n").first}}
    rescue Cocaine::CommandNotFoundError
      Radiant.config['assets.create_video_thumbnails?'] = false
      Rails.logger.warn "FFmpeg executable not found: video thumbnailing disabled."
    rescue Cocaine::ExitStatusError => e
      Rails.logger.warn "FFmpeg is present but calling 'ffmpeg -L' returns an error: #{e}"
    end
  end
end