module Paperclip
  class FrameGrab < Processor

    # taken from http://thewebfellas.com/blog/2009/2/22/video-thumbnails-with-ffmpeg-and-paperclip

    attr_accessor :time_offset, :geometry, :whiny, :format

    def initialize(file, options = {}, attachment = nil)
      super
      @time_offset = options[:time_offset] || '-4'
      unless options[:geometry].nil? || (@geometry = Geometry.parse(options[:geometry])).nil?
        @geometry.width = (@geometry.width / 2.0).floor * 2.0
        @geometry.height = (@geometry.height / 2.0).floor * 2.0
        @geometry.modifier = ''
      end
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @format = options[:format] || 'jpg'
      @current_format = File.extname(@file.path)
      @basename = File.basename(@file.path, @current_format)
    end

    def make
      dst = Tempfile.new([ @basename, @format ].compact.join("."))
      dst.binmode

      cmd = %Q[-itsoffset #{time_offset} -i "#{File.expand_path(file.path)}" -y -vcodec mjpeg -vframes 1 -an -f rawvideo  ]
      cmd << "-s #{geometry.to_s} " unless geometry.nil?
      cmd << %{pipe: | composite -dissolve 80 -gravity center #{AssetType.find(:video).icon_path} - #{File.expand_path(dst.path)} }

      begin
        Paperclip.run('ffmpeg', cmd)
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}: #{e}" if whiny
      end
      
      dst
    end
  end
end
