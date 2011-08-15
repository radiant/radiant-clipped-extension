require File.dirname(__FILE__) + '/../spec_helper'

describe AssetTags do
  dataset :assets
  let(:page) { pages(:pictured) }
  let(:asset) { assets(:test2) }
  
  context "Asset tags" do
    %w{width height caption asset_file_name asset_content_type asset_file_size id filename image flash url link extension page:title page:url}.each do |name|
      it "should have the new singular 'asset:#{name}' tag and method" do
        page.tags.include?("asset:#{name}").should be_true
        page.respond_to?("tag:asset:#{name}".to_sym).should be_true
      end
    
      it "should have the old plural 'assets:#{name}' tag and method" do
        page.tags.include?("assets:#{name}").should be_true
        page.respond_to?("tag:assets:#{name}".to_sym).should be_true
      end
      
      it "should deprecate the old plural 'assets:#{name}' tag" do
        ActiveSupport::Deprecation.should_receive(:warn).at_least(:once)
        page.should render("<r:assets:first><r:assets:#{name} /></r:assets:first>")
      end
    end
  end  
  
  context "rendering tag" do
    before do
      Radiant.config['assets.create_image_thumbnails?'] = true
    end
    
    it "assets:each" do
      page.should render('<r:assets:each><r:asset:id />,</r:assets:each>').as( "#{asset_id(:test2)},#{asset_id(:test1)}," )
    end

    it "assets:first" do
      page.should render('<r:assets:first><r:asset:id /></r:assets:first>').as( "#{asset_id(:test2)}" )
    end

    it "should retreive an asset by name" do
      page.should render('<r:asset:id name="video" />').as( "#{asset_id(:video)}" )
    end
    
    it "asset:name" do
      page.should render('<r:assets:first><r:asset:name /></r:assets:first>').as( asset.title )
    end
    
    it "asset:filename" do
      page.should render('<r:assets:first><r:asset:filename /></r:assets:first>').as( asset.asset_file_name )
    end
    
    it "asset:url" do
      page.should render('<r:assets:first><r:asset:url /></r:assets:first>').as( asset.thumbnail )
      page.should render('<r:assets:first><r:asset:url size="icon" /></r:assets:first>').as( asset.thumbnail('icon') )
    end
    
    it "asset:link" do
      page.should render('<r:assets:first><r:asset:link /></r:assets:first>').as( %{<a href="#{asset.thumbnail}">#{asset.title}</a>} )
      page.should render('<r:assets:first><r:asset:link size="icon" /></r:assets:first>').as( %{<a href="#{asset.thumbnail('icon')}">#{asset.title}</a>} )
    end
    
    it "asset:image" do
      page.should render('<r:assets:first><r:asset:image /></r:assets:first>').as( %{<img src="#{asset.thumbnail}" alt='#{asset.title}' />} )
      page.should render('<r:assets:first><r:asset:image size="icon" /></r:assets:first>').as( %{<img src="#{asset.thumbnail('icon')}" alt='#{asset.title}' />} )
    end

    it "asset:caption" do
      page.should render('<r:assets:first><r:asset:caption /></r:assets:first>').as( asset.caption )
    end    
    
    it "asset:top_padding" do
      page.should render('<r:assets:first><r:asset:top_padding container="500" /></r:assets:first>').as( "229" )
    end    

    it "asset:top_padding for a specified style" do
      page.should render('<r:assets:first><r:asset:top_padding container="500" size="thumbnail" /></r:assets:first>').as( "200" )
    end    

    it "asset:width" do
      page.should render('<r:assets:first><r:asset:width /></r:assets:first>').as( "400" )
      page.should render('<r:assets:first><r:asset:width size="icon" /></r:assets:first>').as( "42" )
    end

    it "asset:height" do
      page.should render('<r:assets:first><r:asset:height /></r:assets:first>').as( "200" )      
      page.should render('<r:assets:first><r:asset:height size="icon" /></r:assets:first>').as( "42" )
    end

    it "asset:orientation" do
      page.should render('<r:assets:first><r:asset:orientation /></r:assets:first>').as( "horizontal" )      
      page.should render('<r:assets:first><r:asset:orientation size="icon" /></r:assets:first>').as( "square" )      
    end
    
    it "asset:aspect" do
      page.should render('<r:assets:first><r:asset:aspect /></r:assets:first>').as( 2.to_f.to_s )
      page.should render('<r:assets:first><r:asset:aspect size="icon" /></r:assets:first>').as( 1.to_f.to_s )
    end
    
  end
  
end
