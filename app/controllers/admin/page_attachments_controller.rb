class Admin::PageAttachmentsController < Admin::ResourceController
  # only accessible as a nested route of page.

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
    @page = Page.find(params[:page_id])
    self.model = if params[:id]
      @page.page_attachments.find(params[:id])
    else
      @page.page_attachments.build
    end
  end
  
  # Saves (presumably revised) attachment order.
  def reorder
    params[:attachments].each_with_index do |id,idx| 
      page_attachment = PageAttachment.find(id)
      page_attachment.position = idx+1
      page_attachment.save
    end
    clear_model_cache
    render :nothing => true
  end

end
