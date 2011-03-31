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

    # this isn't very satisfactory: it looks like it should limit the asset collection to a particular set of page attachments
    # but really it just provides context for the 'attach' links
    @page = Page.find_by_id(params[:page_id]) if params[:page_id]

    respond_to do |format|
      format.html { render }
      format.js { 
        render :partial => 'asset_table' 
      }
    end
  end

  def create
    @asset = Asset.new(params[:asset])
    if @asset.save
      if params[:page]
        @page = Page.find(params[:page])
        @asset.pages << @page
      end
      respond_to do |format|
        format.html { 
          flash[:notice] = "Asset successfully uploaded."
          redirect_to(@page ? edit_admin_page_path(@page) : (params[:continue] ? edit_admin_asset_path(@asset) : admin_assets_path)) 
        }
        format.js {
          responds_to_parent do
            render :update do |page|
              @attachment = PageAttachment.find(:first, :conditions => { :page_id => @page.id, :asset_id => @asset.id })
              page.call('Asset.ChooseTabByName', 'page-attachments')
              page.insert_html :bottom, "attachments", :partial => 'admin/assets/asset', :locals => {:attachment => @attachment } 
              page.call('Asset.AddAsset', "attachment_#{@attachment.id}")  # we ought to reinitialise the sortable attachments too
              page.visual_effect :highlight, "attachment_#{@attachment.id}" 
              page.call('Asset.ResetForm')
            end
          end
        } 
      end
    else
      respond_to do |format|
        format.html { 
          flash[:error] = "Sorry: asset could not be saved."
          render :action => 'new'
        }
      end
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
