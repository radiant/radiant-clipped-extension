module PageAssetAssociations
  
  #TODO: Turn page_attachments into a generic, polymorphic asset-attachment mechanism
  
  def self.included(base)
    base.class_eval {
      has_many :page_attachments, :order => "position ASC"
      has_many :assets, :through => :page_attachments, :order => "page_attachments.position ASC", :uniq => true
    }
  end
  
end