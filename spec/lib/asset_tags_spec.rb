require File.dirname(__FILE__) + '/../spec_helper'

describe AssetTags do
  dataset :assets
  let(:page) { pages(:pictured) }
  
  context "Asset tags" do
    %w{top_padding width height caption asset_file_name asset_content_type asset_file_size id filename image flash thumbnail url link extension if_content_type page:title page:url}.each do |name|
      it "should have the new singular 'asset:#{name}' tag and method" do
        page.tags.include?("asset:#{name}").should be_true
        page.respond_to?("tag:asset:#{name}".to_sym).should be_true
      end
    
      it "should have the old plural 'assets:#{name}' tag and method" do
        page.tags.include?("assets:#{name}").should be_true
        page.respond_to?("tag:assets:#{name}".to_sym).should be_true
      end
    end
  end  
  
  context "substituting new tags for old" do
    it "should call the right substitute tag" do
      AssetTags.deprecated_tag 'mither', :substitute => 'assets:filename', :deadline => '3.0.0'
      ActiveSupport::Deprecation.should_receive(:warn).at_least(:once)
      page.should render("<r:assets:first><r:mither /></r:assets:first>").as( 'asset.jpg' )
    end    
  end
  
  context "rendering a valid but deprecated tag" do
    it "should not err" do
      lambda{ 
        page.should render("<r:assets:first><r:assets:id /></r:assets:first>").as( asset_id(:tester).to_s )
      }.should_not raise_error
    end
  end
  
end
