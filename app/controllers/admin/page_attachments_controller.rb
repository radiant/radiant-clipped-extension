class Admin::PageAttachmentsController < Admin::ResourceController
  helper 'admin/assets'
  
  def new
    render :partial => 'admin/page_attachments/attachment', :object => @page_attachment
  end
  
  def load_model
    @asset = Asset.find(params[:asset_id])
    @page = Page.find(params[:page_id]) if params[:page_id]
    self.model = PageAttachment.new(:asset => @asset, :page => @page)
  end
  
end
