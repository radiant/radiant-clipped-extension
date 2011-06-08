class Admin::AssetsController < Admin::ResourceController
  paginate_models(:per_page => 50)
  
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
        render :partial => 'asset_table', :locals => {:with_pagination => !!@page}
      }
    end
  end
  
  def create
    @asset.update_attributes!(params[:asset])
    if params[:for_attachment]
      @page_attachment = @asset.page_attachments.create(:page_id => params[:page_id])
      render :partial => 'admin/page_attachments/attachment'
    else 
      response_for :create
    end
  end
  
  def refresh
    if params[:id]
      @asset = Asset.find(params[:id])
      @asset.asset.reprocess!
      flash[:notice] = t('clipped_extension.thumbnails_refreshed')
      redirect_to edit_admin_asset_path(@asset)
    else
      render
    end
  end
  
  only_allow_access_to :regenerate,
    :when => [:admin],
    :denied_url => { :controller => 'admin/assets', :action => 'index' },
    :denied_message => 'You must have admin privileges to refresh the whole asset set.'

  def regenerate
    Asset.all.each { |asset| asset.asset.reprocess! }
    flash[:notice] = t('clipped_extension.all_thumbnails_refreshed')
    redirect_to admin_assets_path
  end
  
end
