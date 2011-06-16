require File.dirname(__FILE__) + '/../spec_helper'

describe Asset do
  dataset :assets

  # these are here to check that paperclip and our various add-ons are all working together.
  # most of the components are also tested individually but in more abstract ways.

  let(:asset) {
    asset = assets(:test1)
    asset.asset = File.new(File.join(File.dirname(__FILE__), "..", "fixtures", "5k.png"))
    asset
  }
  
  describe "on assigning a file to an asset" do
    before do
      Radiant.config["assets.create_image_thumbnails?"] = true
    end
  
    it "should have saved the asset" do
      asset.new_record?.should be_false
    end

    it "should have calculated asset type" do
      asset.asset_type.should == AssetType[:image]
    end

    it "should have recorded width and height and original extension" do
      asset.original_width.should == 434
      asset.original_height.should == 66
      asset.original_extension.should == 'png'
    end

    it "should respond to original geometry" do
      asset.original_geometry.should == Paperclip::Geometry.new(434,66)
    end

    it "should calculate thumbnail geometry" do
      original_geometry = Paperclip::Geometry.new(434,66)
      asset.geometry.should == original_geometry
      asset.geometry(:icon).should == original_geometry * Paperclip::Geometry.parse("42x42#")
    end

    it "should respond to image dimension methods" do
      asset.width.should == 434
      asset.height.should == 66
      asset.width(:icon).should == 42
      asset.height(:icon).should == 42
    end

    it "should respond to image shape methods" do
      asset.horizontal?.should be_true
      asset.vertical?.should be_false
      asset.square?.should be_false
      asset.square?(:icon).should be_true
      asset.orientation.should == 'horizontal'
      asset.aspect.should == 434.0/66.0
    end

  end
end