class Admin::PageAttachmentsController < Admin::ResourceController
  helper 'admin/assets'
    
  def new
    render :partial => 'attachment', :object => model
  end
  
  def load_model
    begin
      @asset = Asset.find(params[:asset_id])
      @page = params[:page_id].blank? ? Page.new : Page.find_by_id(params[:page_id])
    rescue ActiveRecord::RecordNotFound
      render :nothing => true, :layout => false
    end
    self.model = PageAttachment.new(:asset => @asset, :page => @page)
  end
  
end
