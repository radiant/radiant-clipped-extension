require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PageAttachmentsController do
  dataset :users, :home_page, :assets
  integrate_views
  
  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end
  
  it "should handle PageAttachments" do
    controller.class.model_class.should == PageAttachment
    controller.send(:model_symbol).should == :page_attachment
  end

  describe "on call to new" do
    before :each do
      login_as :existing
      @asset = assets(:video)
    end

    describe "with valid asset id" do
      it "should return a nested form for asset-attachment" do
        xhr :get, :new, :page_id => page_id(:home), :asset_id => @asset.id
        response.should be_success
        response.should render_template('admin/page_attachments/_attachment')
        response.body.should =~ /attachment_#{@asset.uuid}/
        response.body.should =~ /page_page_attachments_attributes_#{@asset.uuid}/
        response.body.should =~ /<input class="attacher"/
      end
    end

    describe "without asset id" do
      it "should respond blankly" do
        get :new, :format => :js
        response.should be_success
        response.body.should be_blank
      end
    end
    
    describe "with invalid asset id" do
      it "should respond blankly" do
        get :new, :asset_id => 'foo', :format => :js
        response.should be_success
        response.body.should be_blank
      end
    end
  end

end
