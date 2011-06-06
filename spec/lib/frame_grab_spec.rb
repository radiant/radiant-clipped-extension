require File.dirname(__FILE__) + '/../spec_helper'

describe Paperclip::FrameGrab do
  dataset :assets
  let(:file) { File.new(File.join( File.dirname(__FILE__), "..", "fixtures", "test.flv")) }
  let(:asset) { assets(:video) }

  if Radiant.config['assets.create_video_thumbnails?']
    context "processing video attachment" do
      it "should create png icon and thumbnail"
      it "should create jpeg file at configured size"
      it "should squish if configured size is specific"
      it "should preserve aspect ratio if configured size is >"
      it "should resize then crop if configured size is #"
    end
  end
end
