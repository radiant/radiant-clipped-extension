class Admin::PageAttachmentsController < Admin::ResourceController
  before_filter :get_page
  
  # Attaches an asset to a page
  def create
    if @asset = Asset.find(params[:asset_id])
      @page.assets << @asset
    end
    render :partial => 'admin/page_attachments/attachment_list'
  end
  
  # Detaches asset from a page.
  def destroy
    model.destroy
    render :partial => 'admin/page_attachments/attachment_list'
  end
  
  # Saves (presumably revised) attachments order.
  def reorder
    params[:attachments].each_with_index do |id,idx| 
      page_attachment = PageAttachment.find(id)
      page_attachment.position = idx+1
      page_attachment.save
    end
    clear_model_cache
    render :nothing => true
  end

protected

  def get_page
    @page = Page.find(params[:page_id])
  end
  
end
