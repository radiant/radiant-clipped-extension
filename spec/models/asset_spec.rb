require File.expand_path('../../spec_helper', __FILE__)

describe Asset do

  def default_attributes
    {
      :asset_file_name =>  'asset.jpg',
      :asset_content_type =>  'image/jpeg',
      :asset_file_size => '46248'
    }
  end
  def new_asset(overrides={})
    Asset.new default_attributes.merge(overrides)
  end
  def create_asset(overrides={})
    Asset.create! default_attributes.merge(overrides)
  end

  it 'should be valid when instantiated' do
    new_asset.should be_valid
  end

  it 'should be valid when saved' do
    create_asset.should be_valid
  end

  describe '#thumbnail' do
    before(:all) do
      Radiant::Config['clipped.use_cache_buster?'] = false
    end
    describe 'without argument' do
      it 'should return paperclip asset url for image' do
        image = new_asset :asset_content_type => 'image/jpeg'
        image.stub! :asset => mock('asset', :url => '/y/z/e.jpg')
        image.thumbnail.should == '/y/z/e.jpg'
      end

      it 'should return paperclip asset url for non-image' do
        asset = new_asset :asset_content_type => 'application/pdf'
        asset.stub! :asset => mock('asset', :url => '/y/z/e.pdf')
        asset.thumbnail.should == '/y/z/e.pdf'
      end
    end

    describe 'with size=original' do
      it 'should return paperclip asset url for image' do
        image = new_asset :asset_content_type => 'image/jpeg'
        image.stub! :asset => mock('asset', :url => '/y/z/e.jpg')
        image.thumbnail('original').should == '/y/z/e.jpg'
      end

      it 'should return paperclip asset url for non-image' do
        asset = new_asset :asset_content_type => 'application/pdf'
        asset.stub! :asset => mock('asset', :url => '/y/z/e.pdf')
        asset.thumbnail('original').should == '/y/z/e.pdf'
      end
    end

    it 'should return resized image for images when given size' do
      image = new_asset :asset_content_type => 'image/jpeg'
      image.stub! :asset => mock('asset')
      image.stub! :has_style? => true
      image.asset.stub!(:content_type).and_return('image/jpeg')
      image.asset.stub!(:url).with(:thumbnail).and_return('/re/sized/image_thumbnail.jpg')
      image.thumbnail('thumbnail').should == '/re/sized/image_thumbnail.jpg'
    end

    it 'should return icon for non-image with a given size' do
      document = new_asset :asset_content_type => 'application/msword', :asset_file_name => "document.doc"
      document.thumbnail('icon').should == "/images/admin/assets/document_icon.png"
      document.thumbnail('anything_but_icon').should == "/images/admin/assets/document_icon.png"
    end
  end

  describe '#thumbnail with cache buster' do
    before(:all) do
      Radiant::Config['clipped.use_cache_buster?'] = true
    end

    describe 'without argument' do
      it 'should return paperclip asset url for image' do
        image = new_asset :asset_content_type => 'image/jpeg'
        image.stub! :asset => mock('asset', :url => '/y/z/e.jpg')
        image.thumbnail.should =~ /jpg\?[0-9]+$/
      end

      it 'should return asset url with cache buster when required' do
        image = new_asset :asset_content_type => 'image/jpeg'
        image.stub! :asset => mock('asset', :url => '/y/z/e.jpg')
        image.thumbnail.should =~ /jpg\?[0-9]+$/
      end

      it 'should return paperclip asset url for non-image' do
        asset = new_asset :asset_content_type => 'application/pdf'
        asset.stub! :asset => mock('asset', :url => '/y/z/e.pdf')
        asset.thumbnail.should =~ /pdf\?[0-9]+$/
      end
    end

    describe 'with size=original' do
      it 'should return paperclip asset url for image' do
        image = new_asset :asset_content_type => 'image/jpeg'
        image.stub! :asset => mock('asset', :url => '/y/z/e.jpg')
        image.thumbnail('original').should =~ /jpg\?[0-9]+$/
      end

      it 'should return paperclip asset url for non-image' do
        asset = new_asset :asset_content_type => 'application/pdf'
        asset.stub! :asset => mock('asset', :url => '/y/z/e.pdf')
        asset.thumbnail('original').should =~ /pdf\?[0-9]+$/
      end
    end

    it 'should return resized image for images when given size' do
      image = new_asset :asset_content_type => 'image/jpeg'
      image.stub! :asset => mock('asset')
      image.stub! :has_style? => true
      image.asset.stub!(:content_type).and_return('image/jpeg')
      image.asset.stub!(:url).with(:thumbnail).and_return('/re/sized/image_thumbnail.jpg')
      image.thumbnail('thumbnail').should =~ /jpg\?[0-9]+$/
    end

    it 'should return icon for non-image with a given size' do
      document = new_asset :asset_content_type => 'application/msword', :asset_file_name => "document.doc"
      document.thumbnail('icon').should =~ /png\?[0-9]+$/
      document.thumbnail('anything_but_icon').should =~ /png\?[0-9]+$/
    end
  end

end
