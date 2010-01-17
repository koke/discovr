require 'cgi'
require 'net/http'
require 'xmlsimple'
require 'digest/md5'

class FlickrClient
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
    response = request("flickr.auth.getToken", params)
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
    Net::HTTP.get_response(URI.parse(url)).body.to_s
  end

  def method_missing(method_id, *params)
    params = params[0]
    params ||= {}
    request(method_id.id2name.gsub(/_/, '.'), params)
  end
end
