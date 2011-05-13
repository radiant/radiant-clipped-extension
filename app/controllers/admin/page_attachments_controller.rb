class Admin::PageAttachmentsController < Admin::ResourceController
  
  def new
    if params[:asset_ids] && params[:asset_ids].any?            
      @page_attachments = params[:asset_ids].collect{ |aid| @page.page_attachments.build(:asset_id => aid) }
      render :partial => 'admin/page_attachments/new_attachment', :collection => @page_attachments
    else
      render :partial => 'admin/page_attachments/new_attachment', :object => @page_attachment
    end
  end
  
  def create
    @page_attachment.update_attributes!(params[:page_attachment])
    @page = @page_attachment.page
    render :partial => 'admin/page_attachments/attachment_list' 
  end
  
  def destroy
    @page = @page_attachment.page
    @page_attachment.destroy
    render :partial => 'admin/page_attachments/attachment_list' 
  end
  
  def load_model
    @page = Page.find_by_id(params[:page_id]) || Page.new
    self.model = if params[:id]
      @page.page_attachments.find(params[:id])
    elsif params[:asset_id]
      @page.page_attachments.build(:asset_id => params[:asset_id])
    end
  end
  
  # Saves (presumably revised) attachment order.
  def reorder
    params[:page_attachments].each_with_index do |id,idx| 
      page_attachment = PageAttachment.find(id)
      page_attachment.position = idx+1
      page_attachment.save
    end
    clear_model_cache
    render :nothing => true
  end

end
