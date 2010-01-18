class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.string :nsid
      t.string :photo_id
      t.timestamp :favorited_at

      t.timestamps
    end
    
    add_index :favorites, [:nsid, :photo_id], :unique => true
  end

  def self.down
    remove_index :favorites, :column => [:nsid, :photo_id]
    drop_table :favorites
  end
end
