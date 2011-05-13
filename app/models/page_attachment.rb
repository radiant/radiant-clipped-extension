class PageAttachment < ActiveRecord::Base
  belongs_to :asset
  belongs_to :page
  attr_accessor :selected

  accepts_nested_attributes_for :asset
  
  acts_as_list :scope => :page_id
  
  def selected?
    !!selected
  end
  
end