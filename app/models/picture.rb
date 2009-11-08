class Picture < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => "favorites", :foreign_key => "picture_id"
  
  attr_accessor :flickr
  
  def flickr
    return nil if photo_id.nil?
    
    @flickr ||= Flickr::Photo.new(photo_id, FLICKR_API_KEY, 'farm' => farm, 'server' => server, 'secret' => secret, 'title' => title)
  end
  
  def url
    if photo_url.nil?
      self.photo_url = flickr.url
      save
    end
    
    photo_url
  end
  
  def source(size='Medium')
    flickr.source(size)
  end
  
  def favorited_by(force=false)
    if force or users.empty?
      update_favorited_by
    end
    
    users
  end
  
  def similar_pictures(force_update=true, skip_user=nil, return_hash=false, count=nil, total=nil)
    similar = {}
    
    @cp = 0
    favorited_by(force_update).each do |user|
      next if user == skip_user
      
      # Prevent ReadOnly issues
      user = User.find(user.id)
      
      bmp = Time.now.to_f
      @cu = 0
      user.favorites(force_update).each do |favorite|
        next if skip_user.favorite_pictures.exists?(favorite)
        bmu = Time.now.to_f
        
        similar[favorite.id] ||= {:weight => 0, :picture => favorite}
        similar[favorite.id][:weight] += 1
        bmu = Time.now.to_f - bmu
        @cu += 1
        puts "[#{count}/#{total}][#{@cp}/#{users.size}][#{@cu}/#{user.favorites.size}] BM: #{bmu} picture.users.favorites:[#{favorite.photo_id} | #{favorite.title}]"
      end
      bmp = Time.now.to_f - bmp
      @cp += 1
      puts "[#{count}/#{total}][#{@cp}/#{users.size}] BM: #{bmp} picture.users:[#{user.nsid} | #{user.username}]"
    end
    
    if return_hash
      similar
    else
      similar.values.sort {|a,b| b[:weight] <=> a[:weight]}#.select {|v| v[:weight] > 1}
    end
  end
  
  def update_favorited_by
    self.users = flickr.favorites.collect do |fuser|
      User.find_or_create_from_flickr(fuser)
    end
  end
  
  def self.find_or_create_from_flickr(fpicture)
    picture = find(:first, :conditions => ["photo_id = ?", fpicture.id])
    return picture if picture
    
    picture = Picture.create :photo_id => fpicture.id,
                          :title    => fpicture.title,
                          :farm     => fpicture.farm,
                          :server   => fpicture.server,
                          :secret   => fpicture.secret
  end
end
