class AddFavoritesRelation < ActiveRecord::Migration
  def self.up
    create_table :favorites, :id => false, :force => true do |t|
      t.integer :picture_id
      t.integer :user_id

      t.timestamps
    end
    
    add_index :favorites, [:picture_id, :user_id], :unique => true
  end

  def self.down
    remove_index :favorites, :column_name
    remove_index :favorites, :column => [:picture_id, :user_id]
    drop_table :favorites
  end
end
