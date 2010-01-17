require 'test_helper'
require "digest/md5"

class FlickrClientTest < ActiveSupport::TestCase
  def setup
    @flickr = FlickrClient.new(FLICKR_API_KEY, FLICKR_SECRET)
  end
  test "signed params creates a valid signature" do
    @flickr.auth_token = '1234567890'
    
    expect = "api_sig=" + Digest::MD5.hexdigest("#{FLICKR_SECRET}api_key#{FLICKR_API_KEY}methodflickr.auth.getToken")
    expect+= "&method=flickr.auth.getToken&api_key=#{FLICKR_API_KEY}"
    assert_equal expect, @flickr.signed_params('method' => 'flickr.auth.getToken', 'api_key' => FLICKR_API_KEY)
  end
end
