module PageAssetAssociations
  
  #TODO: Turn page_attachments into a generic, polymorphic asset-attachment mechanism
  
  def self.included(base)
    base.class_eval {
      has_many :page_attachments, :order => "position ASC"
      has_many :assets, :through => :page_attachments, :order => "page_attachments.position ASC", :uniq => true

      # DISCUSS: since there's a save button, I feel we shouldn't save attachment decisions until it is pressed.
      # I'm using the javascript to build a form, rather than updating the attachment set in a separate 
      # operation, which is what used to happen in the paperclipped bucket.
      # The direct, incremental approach is still supported. You just make direct calls to PageAttachmentController#create and #destroy.
      # Apart from consistency with the rest of the page editing process, the big advantage of the batched approach is 
      # that assets can be attached to new pages while they are created. If a page doesn't exist yet it's difficult to 
      # create associations for it. Inconsistent behaviour results.

      accepts_nested_attributes_for :page_attachments, :allow_destroy => true
    }
  end
  
end