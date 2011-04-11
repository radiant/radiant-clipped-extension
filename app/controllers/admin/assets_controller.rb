class Admin::AssetsController < Admin::ResourceController
  skip_before_filter :verify_authenticity_token, :only => :create
  paginate_models
  
  def index
    assets = Asset.scoped({})

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
        render :partial => 'asset_table', :locals => {:for_attachment => true}
      }
    end
  end

  def create
    @asset.update_attributes!(params[:asset])
    respond_to do |format|
      format.html { 
        redirect_to continue_url(params)
      }
      format.js {
        # called from the upload popup in page editing
        # we only return a nested form, so page can be a new record
        @page_attachment = @asset.page_attachments.build(:page_id => params[:page_id])
        responds_to_parent do
          render :update do |page|
            page.insert_html :bottom, "new_attachments", :partial => 'admin/page_attachments/new_attachment'
          end
        end
      } 
    end
  end
    
  
  # Refreshes the paperclip thumbnails
  def refresh
    unless params[:id]
      @assets = Asset.find(:all)
      @assets.each do |asset|
        asset.asset.reprocess!
      end
      flash[:notice] = "Thumbnails successfully refreshed."
      redirect_to admin_assets_path
    else
      @asset = Asset.find(params[:id])
      @asset.asset.reprocess!
      flash[:notice] = "Thumbnail successfully refreshed."
      redirect_to edit_admin_asset_path(@asset)
    end
  end

  end
