class AssetsDataset < Dataset::Base
  uses :home_page
  
  def load
    create_page "pictured", :slug => 'pictured' do
      create_asset "test1", :caption => "testing"
      create_asset "test2", :caption => "also testing"
    end
    create_asset "video", :asset_content_type => 'video/mpeg', :asset_file_name => 'asset.mpg'
    create_asset "audio", :asset_content_type => 'audio/mp3', :asset_file_name => 'asset.mp3'
    create_asset "document", :asset_content_type => 'application/msword', :asset_file_name => 'asset.doc'
  end
  
  helpers do
    def create_asset(name, attributes={})
      create_record :asset, name.symbolize, {
        :title => name,
        :asset_file_name =>  'asset.jpg',
        :asset_content_type =>  'image/jpeg',
        :asset_file_size => '46248',
        :original_height => 200,
        :original_width => 400,
        :uuid => UUIDTools::UUID.timestamp_create.to_s
      }.merge(attributes)
      if @current_page_id
        create_record :page_attachment, "#{name}_attachment".symbolize, {
          :page_id => @current_page_id,
          :asset_id => asset_id(name.symbolize)
        }
      end
    end
  end
  
end