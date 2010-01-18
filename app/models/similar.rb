class Similar < ActiveRecord::Base
  belongs_to :photo, :class_name => "PhotoCache", :foreign_key => "photo_id", :primary_key => "photo_id"
  belongs_to :similar, :class_name => "PhotoCache", :foreign_key => "similar_id", :primary_key => "photo_id"
end
