class PhotoCache < ActiveRecord::Base
  has_many :similar, :class_name => "Similar", :foreign_key => "similar_id"
  
  def self.create_if_not_exists(options)
    find_by_photo_id(options[:photo_id]) or create(options)
  end
end
