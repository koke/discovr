class DiscovrController < ApplicationController
  def index
    @pictures = Picture.find_by_sql("
      select 
        count(distinct favorite_user_id) weight, 
        p.* 
      from similar_to_user s 
        JOIN pictures p 
        ON s.similar_id = p.id 
      WHERE original_user_id = 1 
      GROUP BY original_user_id,similar_id 
      ORDER BY weight desc 
      limit 119
    ")
  end

end
