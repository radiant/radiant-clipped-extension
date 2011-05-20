class Admin::PageAttachmentsController < Admin::ResourceController
  helper 'admin/assets'
  
  def new
    render :partial => 'admin/page_attachments/attachment', :object => @page_attachment
  end
  
  def load_model
    @page = Page.find(params[:page_id])
    @asset = Asset.find(params[:asset_id])
    self.model = @page.page_attachments.build(:asset => @asset)
  end
  
end
