class PageAttachment < ActiveRecord::Base
  belongs_to :asset
  belongs_to :page

  accepts_nested_attributes_for :asset
  
  acts_as_list :scope => :page_id
  
end