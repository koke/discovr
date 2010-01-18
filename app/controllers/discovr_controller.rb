class DiscovrController < ApplicationController
  def index
    # @explored = @flickr.interestingness_getList
    if @nsid
      @user = @flickr.user(@nsid)
      @history.add(@user)
    end

    if params[:frob]
      @token = @flickr.auth_getToken('frob'=>params[:frob])
      session[:auth_token] = @token["auth"]["token"]
      session[:nsid] = @token["auth"]["user"]["nsid"]
      session[:user] = @token["auth"]["user"]
      
      redirect_to root_path
    end    
  end
  
  def photo
    @photo = @flickr.photo(params[:id])
    @users = @photo.favorites
    @selected = @users.first
    @similar = @photo.similar(@selected.nsid)
    @next = @users.second
    @history.add(@photo)
  end
  
  def similar
    @photo = @flickr.photo(params[:id])
    if params[:user_id]
      @photos = @photo.similar(params[:user_id])
      @users = @photo.favorites
      current = @users.select {|u| u.nsid == params[:user_id]}
      @next = @users.at(@users.index(current.first) + 1)
    else
      @photos = @photo.similar(@users.first.nsid)
    end
    respond_to do |wants|
      wants.html { @history.add(@photo) }
      wants.js
    end
  end
  
  def user
    @user = @flickr.user(params[:id])
    @photos = @user.favorites
    @history.add(@user)
    
    respond_to do |wants|
      wants.html
      wants.js
    end
  end
    
  def show
    user = User.lookup(params[:id])
    
    @pictures = Picture.find_by_sql("
      select 
        count(distinct favorite_user_id) weight, 
        p.* 
      from similar_to_user s 
        JOIN pictures p 
        ON s.similar_id = p.id 
      WHERE original_user_id = #{user.id} 
      GROUP BY original_user_id,similar_id 
      HAVING weight > 1
      ORDER BY weight desc 
    ")
    @pictures.reject! {|p| p.photo_url.nil?}
  end
end
