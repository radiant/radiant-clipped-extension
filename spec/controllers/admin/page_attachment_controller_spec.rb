require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PageAttachmentsController do
  dataset :users, :assets

  before :each do
    ActionController::Routing::Routes.reload
    login_as :designer
  end
  
  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle PageAttachments" do
    controller.class.model_class.should == PageAttachment
    controller.send(:model_symbol).should == :page_attachment
  end

  describe "create" do
    before do
      post :create, :format => :js, :page_id => page_id(:pictured), :page_attachment => {:asset_id => asset_id(:document)}
    end

    it "should attach the asset to the page" do
      assets(:document).attached_to?(pages(:pictured)).should be_true
    end

    it "should render the attached-asset list" do
      response.should be_success
      response.should render_template('admin/page_attachments/_attachment_list')
    end
  end

  describe "destroy" do
    before do
      delete :destroy, :format => :js, :page_id => page_id(:pictured), :id => page_attachment_id(:tester_attachment)
    end

    it "should render the attached-asset list" do
      response.should be_success
      response.should render_template('admin/page_attachments/_attachment_list')
    end

    it "should detach the asset from the page" do
      assets(:tester).attached_to?(pages(:pictured)).should be_false
    end
  end

end
