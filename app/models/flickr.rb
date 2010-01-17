require 'cgi'
require 'net/http'
require 'xmlsimple'
require 'digest/md5'

class Flickr
  attr_accessor :auth_token
  
  # Replace this API key with your own (see http://www.flickr.com/services/api/misc.api_keys.html)
  def initialize(api_key=nil, secret=nil)
    @api_key = api_key
    @secret = secret
    @host = 'http://api.flickr.com'
    @api = '/services/rest'
    @auth_token = nil
  end

  def auth_link(perms)
    url = "#{@host}/services/auth?"
    url += signed_params("perms" => perms)
  end
  
  def auth_getToken(params)
    @force_auth = true
    response = request("auth.getToken", params)
    @force_auth = false
    
    response
  end

  def signed_params(options)
    options["api_key"] = @api_key
    tosign = @secret
    tosign+= options.keys.sort.map {|k| "#{k}#{options[k]}"}.join
    puts "Flickr#signed_params tosign: #{tosign}" if FLICKR_DEBUG
    options[:api_sig] = Digest::MD5.hexdigest(tosign)
    
    options.map{|k,v| "#{k}=" + CGI::escape(v)}.join("&")
  end
  
  def request(method, params)
    puts "Flickr request: #{method} (#{params.inspect})" if FLICKR_DEBUG
    if @auth_token or @force_auth
      url = signed_request_url(method, params)
    else
      url = unsigned_request_url(method, params)
    end
    response = XmlSimple.xml_in(http_get(url), { 'ForceArray' => false })
    raise response['err']['msg'] if response['stat'] != 'ok'
    response
  end

  def signed_request_url(method, params)
    params["method"] = "flickr.#{method}"
    params["auth_token"] = @auth_token unless @force_auth and @auth_token.nil?
    url = "#{@host}#{@api}/?"
    url+= signed_params(params)
    url
  end

  def unsigned_request_url(method, params)
    url = "#{@host}#{@api}/?api_key=#{@api_key}&method=flickr.#{method}"
    params.each do |key,value| url += "&#{key}=" + CGI::escape(value) end if params
    url
  end
  
  # Does an HTTP GET on a given URL and returns the response body
  def http_get(url)
    puts "GET: #{url}" if FLICKR_DEBUG
    Net::HTTP.get_response(URI.parse(url)).body.to_s
  end

  def method_missing(method_id, *params)
    params = params[0]
    params ||= {}
    request(method_id.id2name.gsub(/_/, '.'), params)
  end
  
  # TODO
  def explored
    
  end
  
  def user(lookup)
    user = people_getInfo('user_id'=>lookup)["person"] rescue nil
    user ||= people_findByUsername('username'=>lookup)['user'] rescue nil
    user ||= people_findByEmail('find_email'=>lookup)['user'] rescue nil

    if user
      User.new(self, user['id'], user['username'], user['photosurl'], user['iconfarm'], user['iconserver'])
    end
  end
  
  def photo(photo_id)
    photo = photos_getInfo('photo_id'=>photo_id)["photo"]
    Photo.new(self, photo_id, photo)
  end
  
  # TODO
  # Needs
  #   * Create
  #   * Thumbnail \_ getSizes
  #   * Medium    /
  #   * URL
  #   * Favorited by
  class Photo
    attr_accessor :id, :title
    
    def initialize(flickr, photo_id, photo)
      @flickr = flickr
      @id = photo_id
      @farm = photo['farm']
      @server = photo['server']
      @secret = photo['secret']
      @title = photo['title']
      if photo['owner']
        if photo['owner'].is_a?(Hash)
          @owner = photo['owner']['nsid']
        else
          @owner = photo['owner']
        end
      end
    end
    
    def source(size='Medium')
      size_map = {
        'Square'    => '_s',
        'Thumbnail' => '_t',
        'Small'     => '_m',
        'Medium'    => '',
        'Large'     => '_b',
        'Original'  => '_o'
      }
      s = size_map[size]

      return sizes(size)['source'] if @farm.nil? or @server.nil? or @secret.nil? or s.nil?
      if size == 'Original'
        return sizes(size)['source'] if @originalsecret.nil? or @originalformat.nil?

        return "http://farm#{@farm}.static.flickr.com/#{@server}/#{@id}_#{@originalsecret}_o.#{@originalformat}"
      end
      
      "http://farm#{@farm}.static.flickr.com/#{@server}/#{@id}_#{@secret}#{s}.jpg"
    end
    
    def thumbnail
      source('Square')
    end
    
    def favorites
      result = @flickr.photos_getFavorites('photo_id'=>@id)
      users = result['photo']['person']
      
      return [] unless users

      users = [users] unless users.kind_of?(Array)
      faves = users.map { |user| User.new(@flickr, user['nsid'], user['username']) }
      
      faves
    end
    
    def eql?(photo)
      photo.is_a?(Photo) and @id.eql?(photo.id)
    end
    
    def url
      "http://flickr.com/photos/#{@owner}/#{@id}"
    end
  end
  
  # TODO
  # Needs
  #   * Create
  #   * Thumbnail url
  #   * Favorites
  #   * Profile link
  class User
    attr_reader :username, :nsid
    
    def initialize(flickr, nsid, username, profile=nil, farm=nil, server=nil)
      @flickr = flickr
      @nsid = nsid
      @username = username
      @profile = profile
      @farm = farm
      @server = server
    end
    
    # Substitutes @ to _, since @ character is not allowed in a html id
    def safe_nsid
      nsid.gsub('@','_')
    end
    
    def update_info
      user = @flickr.people_getInfo('user_id' => @nsid)["person"]
      @farm = user['iconfarm']
      @server = user['iconserver']
      @profile = user['photosurl']
    end
    
    def url
      update_info if @profile.nil?
      
      @profile || "http://flickr.com/photos/#{@nsid}"
    end

    def server
      update_info if @server.nil?
      
      @server
    end

    def farm
      update_info if @farm.nil?
      
      @farm
    end
    
    def avatar
      if farm != "0"
        "http://farm#{farm}.static.flickr.com/#{server}/buddyicons/#{@nsid}.jpg"
      else
        "http://www.flickr.com/images/buddyicon.jpg"
      end
    end
    
    def favorites
      if @flickr.auth_token
        result = @flickr.favorites_getList('user_id'=>@nsid)
      else
        result = @flickr.favorites_getPublicList('user_id'=>@nsid)
      end
      photos = result['photos']['photo']
      
      return [] unless photos

      photos = [photos] unless photos.kind_of?(Array)
      faves = photos.to_a.reject{|photo| photo['id'].blank?}.map { |photo| Photo.new(@flickr,photo['id'], photo) };
      
      faves
      
    end
    
    def eql?(user)
      user.is_a?(User) and @nsid.eql?(user.nsid)
    end
  end
end
