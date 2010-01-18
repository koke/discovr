class CreateSimilars < ActiveRecord::Migration
  def self.up
    create_table :similars do |t|
      t.string :photo_id
      t.string :similar_id
      t.string :proxy_user

      t.timestamps
    end
    
    add_index :similars, [:photo_id, :proxy_user]
    add_index :similars, [:photo_id, :similar_id, :proxy_user], :unique => true
  end

  def self.down
    remove_index :similars, :column => [:photo_id, :similar_id, :proxy_user]
    drop_table :similars
  end
end
