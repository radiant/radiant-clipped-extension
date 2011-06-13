require File.dirname(__FILE__) + '/../spec_helper'

module Paperclip
  class Dummy < Processor
    def initialize file, options = {}, attachment = nil
      super
      something = options[:something]
    end
    def make
      @file
    end
  end
end

AssetType.new :simple, :mime_types => %w[test/this test/that]
AssetType.new :complex, :processors => [:dummy], :styles => {:something => "99x99>"}, :mime_types => %w[test/complex], :icon => 'document'
AssetType.new :configured, :processors => [:dummy], :mime_types => %w[test/configured]
AssetType.new :unstandard, :extensions => %w[unstandard nomimetype]

describe AssetType do
  context 'without thumbnails' do
    subject{ AssetType.find(:simple) }
    its(:plural) { should == "simples" }
    its(:mime_types) { should == ["test/this", "test/that"] }
    its(:condition) { should == ["asset_content_type IN (?,?)", "test/this", "test/that"] }
    its(:non_condition) { should == ["NOT asset_content_type IN (?,?)", "test/this", "test/that"] }
    its(:paperclip_processors) { should be_empty}
    its(:paperclip_styles) { should be_empty}
    its(:icon) { should == "/images/admin/assets/simple_icon.png"}
    its(:icon_path) { should == "#{RAILS_ROOT}/public/images/admin/assets/simple_icon.png"}
  end
  
  context 'with initialized thumbnail sizes' do
    before { Radiant.config["assets.create_complex_thumbnails?"] = true }
    subject{ AssetType.find(:complex) }
    its(:paperclip_processors) { should == [:dummy] }
    its(:paperclip_styles) { should_not be_empty }
    its(:paperclip_styles) { should == {:something => "99x99>"} }
    its(:icon) { should == "/images/admin/assets/document_icon.png"}
  end

  context 'with configured thumbnail sizes' do
    before { 
      Radiant.config["assets.create_configured_thumbnails?"] = true 
      Radiant.config["assets.thumbnails.configured"] = "special:size=800x800>,format=jpg|tiny:size=#10x10,format=png"
    }
    subject{ AssetType.find(:configured) }
    its(:paperclip_processors) { should == [:dummy] }
    its(:paperclip_styles) { should == {:special => ["800x800>", :jpg], :tiny => ["#10x10", :png]} }
  end

  context 'AssetType class methods' do
    describe '.slice' do
      AssetType.slice('simple', 'complex').should =~ [AssetType.find(:simple), AssetType.find(:complex)]
    end

    describe '.from_extension' do
      AssetType.from_extension('nomimetype').should == AssetType.find(:unstandard)
    end

    describe '.from_mimetype' do
      AssetType.from_mimetype('test/this').should == AssetType.find(:simple)
    end
  end

end
