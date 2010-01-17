# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :initialize_flickr_client
  
  def initialize_flickr_client
    @flickr = FlickrClient.new(FLICKR_API_KEY, FLICKR_SECRET)
    
    if session[:auth_token]
      @flickr.auth_token = session[:auth_token]
      @nsid = session[:nsid]
      @user = session[:user]
    else
      @auth_link = @flickr.auth_link("write")
    end
  end
end
