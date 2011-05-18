class Admin::AssetsController < Admin::ResourceController
  paginate_models(:per_page => 20)
  
  def index
    assets = Asset.scoped({:order => "created_at DESC"})
    
    @term = params[:search] || ''
    assets = assets.matching(@term) if @term && !@term.blank?
    
    @types = params[:filter] || []
    if @types.include?('all')
      params[:filter] = nil
    elsif @types.any?
      assets = assets.of_types(@types)
    end
    
    @assets = paginated? ? assets.paginate(pagination_parameters) : assets.all
    respond_to do |format|
      format.html { render }
      format.js { 
        @page = Page.find_by_id(params[:page_id])
        render :partial => 'asset_table', :locals => {:with_pagination => true}
      }
    end
  end
  
  def create
    @asset.update_attributes!(params[:asset])
    if params[:for_attachment]
      @page_attachment = @asset.page_attachments.build(:page_id => params[:page_id])
      render :partial => 'admin/page_attachments/new_attachment'
    else 
      response_for :create
    end
  end
  
  # Refreshes the paperclip thumbnails
  def refresh
    unless params[:id]
      @assets = Asset.find(:all)
      @assets.each do |asset|
        asset.asset.reprocess!
      end
      flash[:notice] = t('assets_extension.thumbnails_refreshed')
      redirect_to admin_assets_path
    else
      @asset = Asset.find(params[:id])
      @asset.asset.reprocess!
      flash[:notice] = t('assets_extension.thumbnails_refreshed')
      redirect_to edit_admin_asset_path(@asset)
    end
  end
  
end
