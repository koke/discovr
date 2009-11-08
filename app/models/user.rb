class User < ActiveRecord::Base
  has_and_belongs_to_many :favorite_pictures, :join_table => "favorites", :foreign_key => "user_id", :class_name => "Picture"
  
  
  attr_accessor :flickr
  
  def flickr
    return nil if nsid.nil?
    
    @flickr ||= Flickr::User.new(nsid, username, nil, nil, FLICKR_API_KEY)
  end
  
  def favorites(force = false)
    if force or favorite_pictures.empty?
      update_favorites
    end
    
    favorite_pictures
  end
  
  def update_favorites
    return if last_favorited and Time.now.gmtime.to_i - last_favorited.to_i < 2.hour
    new_favorites = self.favorite_pictures + flickr.favorites(last_favorited).collect do |fpicture|
      Picture.find_or_create_from_flickr(fpicture)
    end
    new_favorites.uniq!
    self.favorite_pictures = new_favorites
    
    self.last_favorited = Time.now.gmtime
    save
    
    favorite_pictures
  end
  
  def similar_pictures(force_update=true)
    similar = {}
    
    count = 0
    favorites(force_update).each do |favorite|
      count+=1
      bm = Time.now.to_f
      favorite.similar_pictures(force_update,self,true,count, favorites.size).each do |k,v|
        puts "#{k.inspect} => #{v.inspect}" if v.nil?
        next if v.nil?
        
        similar[k] ||= {:weight => 0, :picture => v[:picture]}
        similar[k][:weight] += v[:weight]
      end
      bm = Time.now.to_f - bm
      puts "[#{count}/#{favorites.size}] BM: #{bm} user.favorites[]:[#{favorite.photo_id} | #{favorite.title}]"
      # sleep(2)
    end
    
    similar.values.sort {|a,b| b[:weight] <=> a[:weight]}.select {|v| v[:weight] > 1}
  end
  
  def self.lookup(name_or_email)
    user = find_by_username(name_or_email)
    return user if user
    
    fuser = flickr_client.users(name_or_email)
    if !fuser.nil? and fuser.kind_of?(Flickr::User)
      # Find again, just in case is email search
      user = find(:first, :conditions => ["nsid = ?", fuser.id])
      user ||= create(:nsid => fuser.id, :username => fuser.username)
      user.flickr = fuser
      
      user
    else
      return nil
    end
  end
  
  def self.find_or_create_from_flickr(fuser)
    user = find(:first, :conditions => ["nsid = ?", fuser.id])
    return user if user
    
    user = User.create :nsid => fuser.id, :username => fuser.username
  end
  
end
