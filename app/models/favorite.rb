class Favorite < ActiveRecord::Base
  belongs_to :user, :class_name => "UserCache", :foreign_key => "nsid", :primary_key => "nsid"
  
  def self.create_if_not_exists(options)
    find(:first, :conditions => ["nsid = ? AND photo_id = ?", options[:nsid], options[:photo_id]]) or create(options)
  end
end
