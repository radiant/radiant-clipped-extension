class Admin::PageAttachmentsController < Admin::ResourceController
  before_filter :get_page
  
  # Attaches an asset to a page
  def create
    @attachment = @page.asset_attachments.create!(:asset => @asset)
    render :partial => 'admin/page_attachments/attachment', :object => @attachment
  end
  
  # Detaches asset from a page.
  def destroy    
    @page.assets.delete(@asset)
    render :nothing => true
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

  def get_page_and_asset
    @page = Page.find(params[:page_id])
    @asset = Asset.find(params[:asset_id]) if params[:asset_id]
  end
  
end
