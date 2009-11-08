require "flickr"
FLICKR_API_KEY = "YOUR_API_KEY"
FLICKR_SECRET = "YOUR_SECRET"
FLICKR_DEBUG = true

def flickr_client
  Flickr.new FLICKR_API_KEY
end
