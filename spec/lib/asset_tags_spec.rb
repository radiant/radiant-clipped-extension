require File.expand_path('../../spec_helper', __FILE__)

describe AssetTags do
  dataset :assets
  let(:page) { pages(:pictured) }
  let(:asset) { assets(:test1) }
  
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
      Radiant.config['assets.thumbnails.image'] = 'normal:size=640x640>|small:size=320x320>'
    end
    
    it "assets:each" do
      page.should render('<r:assets:each><r:asset:id />,</r:assets:each>').as( "#{asset_id(:test1)},#{asset_id(:test2)}," )
    end

    it "assets:first" do
      page.should render('<r:assets:first><r:asset:id /></r:assets:first>').as( asset.id.to_s )
    end

    it "should retrieve an asset by name" do
      page.should render('<r:asset:id name="video" />').as( "#{asset_id(:video)}" )
    end
    
    it "asset:name" do
      page.should render(%{<r:asset:name id="#{asset_id(:test1)}" />}).as( asset.title )
    end
    
    it "asset:filename" do
      page.should render(%{<r:asset:filename id="#{asset_id(:test1)}" />}).as( asset.asset_file_name )
    end
    
    it "asset:url" do
      page.should render(%{<r:asset:url id="#{asset_id(:test1)}" />}).as( asset.thumbnail )
      page.should render(%{<r:asset:url size="icon" id="#{asset_id(:test1)}" />}).as( asset.thumbnail('icon') )
    end
    
    it "asset:link" do
      page.should render(%{<r:asset:link id="#{asset_id(:test1)}" />}).as( %{<a href="#{asset.thumbnail}">#{asset.title}</a>} )
      page.should render(%{<r:asset:link size="icon" id="#{asset_id(:test1)}" />}).as( %{<a href="#{asset.thumbnail('icon')}">#{asset.title}</a>} )
    end
    
    it "asset:image" do
      page.should render(%{<r:asset:image id="#{asset_id(:test1)}" />}).as( %{<img src="#{asset.thumbnail}" alt="#{asset.title}" />} )
      page.should render(%{<r:asset:image size="icon" id="#{asset_id(:test1)}" />}).as( %{<img src="#{asset.thumbnail('icon')}" alt="#{asset.title}" />} )
    end

    it "asset:caption" do
      page.should render(%{<r:asset:caption id="#{asset_id(:test1)}" />}).as( asset.caption )
    end    
    
    it "asset:top_padding" do
      page.should render(%{<r:asset:top_padding id="#{asset_id(:test1)}" container="500" />}).as( "229" )
    end    

    it "asset:top_padding for a specified style" do
      page.should render(%{<r:asset:top_padding id="#{asset_id(:test1)}" container="500" size="thumbnail" />}).as( "200" )
    end    

    it "asset:width" do
      page.should render(%{<r:asset:width id="#{asset_id(:test1)}" />}).as( "400" )
      page.should render(%{<r:asset:width id="#{asset_id(:test1)}" size="icon" />}).as( "42" )
    end

    it "asset:height" do
      page.should render(%{<r:asset:height id="#{asset_id(:test1)}" container="500" />}).as( "200" )      
      page.should render(%{<r:asset:height id="#{asset_id(:test1)}" size="icon" />}).as( "42" )
    end

    it "asset:orientation" do
      page.should render(%{<r:asset:orientation id="#{asset_id(:test1)}" />}).as( "horizontal" )      
      page.should render(%{<r:asset:orientation id="#{asset_id(:test1)}" size="icon" />}).as( "square" )      
    end
    
    it "asset:aspect" do
      page.should render(%{<r:asset:aspect id="#{asset_id(:test1)}" />}).as( 2.to_f.to_s )
      page.should render(%{<r:asset:aspect id="#{asset_id(:test1)}" size="icon" />}).as( 1.to_f.to_s )
    end

    it "asset:if_image" do
      page.should render(%{<r:asset:if_image name="test1">foo</r:asset:if_image>}).as( "foo" )
      page.should render(%{<r:asset:if_image name="video">foo</r:asset:if_image>}).as( "" )
    end
    
  end
  
end
