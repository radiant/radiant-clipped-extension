require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::AssetsController do
  dataset :users, :assets

  before :each do
    ActionController::Routing::Routes.reload
    login_as :designer
  end
  
  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Assets" do
    controller.class.model_class.should == Asset
  end

  describe "index" do
    describe "before filtration" do
      before do
        get :index
      end

      it "should render the index view" do
        response.should be_success
        response.should render_template('index')
      end
    end

    describe "on ajax filtration" do
      before do
        xml_http_request :get, :index, :filter => ['video']
      end

      it "should render the table partial" do
        response.body.should_not have_text('<head>')
        response.content_type.should == 'text/javascript'
        response.should_not render_template('index')
        response.should render_template('admin/assets/_asset_table')
        assigns(:assets).should include(assets(:video))
      end
    end

  end




end
