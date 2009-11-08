class CreateSimilarViews < ActiveRecord::Migration
  def self.up
    execute "CREATE VIEW similar_to_picture AS 
      select 
        f1.picture_id AS original_id,
        f2.picture_id AS similar_id,
        f2.user_id AS user_id 
      from 
        favorites f1 
        join favorites f2 
          on f1.user_id = f2.user_id
            and f1.picture_id <> f2.picture_id"
    
    execute "CREATE VIEW similar_to_user AS 
      select 
        f.user_id AS original_user_id,
        s.similar_id AS similar_id,
        s.original_id AS favorite_picture_id,
        s.user_id AS favorite_user_id 
      from 
        favorites f 
        join similar_to_picture s 
          on f.picture_id = s.original_id 
            and s.user_id <> f.user_id
            and s.similar_id not in (
              select fi.picture_id AS picture_id 
              from favorites fi 
              where fi.user_id = f.user_id
            )"
  end

  def self.down
    execute "DROP VIEW similar_to_user"
    execute "DROP VIEW similar_to_picture"
  end
end
