class HistoryCache < ActiveRecord::Base
  named_scope :recent_photos, :conditions => ["cached_type = 'PhotoCache'"], :order => 'created_at DESC', :limit => 100, :group => "cached_id"
  
  def self.cache_photo(photo, who = nil)
    create(:cached_type => 'PhotoCache', :who => who, :cached_id => photo.id)
  end

  def self.cache_user(user, who = nil)
    create(:cached_type => 'UserCache', :who => who, :cached_id => user.nsid)
  end
end