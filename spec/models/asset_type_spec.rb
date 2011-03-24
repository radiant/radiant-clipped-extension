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
AssetType.new :complex, :mime_types => %w[test/complex], :processors => [:dummy], :styles => {:something => "uh oh"}

describe AssetType do

  context 'a simple asset type' do
    subject{ AssetType.find(:simple) }
    its(:plural) { should == "simples" }
    its(:mime_types) { should == ["test/this", "test/that"] }
    its(:condition) { should == ["asset_content_type IN (?,?)", "test/this", "test/that"] }
    its(:non_condition) { should == ["NOT asset_content_type IN (?,?)", "test/this", "test/that"] }
    its(:paperclip_processors) { should be_empty}
    its(:paperclip_styles) { should be_empty}
  end
  
  context 'a more complex asset type' do
    subject{ AssetType.find(:complex) }
    its(:paperclip_processors) { should_not be_empty }
    its(:paperclip_styles) { should_not be_empty }
  end

  context 'AssetType class methods' do
    describe '.from' do
      AssetType.from('test/this').should == AssetType.find(:simple)
      AssetType.from('test/complex').should == AssetType.find(:complex)
    end
  end
  
end
