class DiscovrController < ApplicationController
  def index
    @explored = @flickr.interestingness_getList
    
    if params[:frob]
      begin
        @token = @flickr.auth_getToken('frob'=>params[:frob])
        session[:auth_token] = @token["auth"]["token"]
        session[:nsid] = @token["auth"]["user"]["nsid"]
        session[:user] = @token["auth"]["user"]
      rescue
        flash[:error] = "Can't login"
      end
      
      redirect_to root_path
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
