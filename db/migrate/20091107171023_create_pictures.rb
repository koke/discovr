class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :photo_id, :null => false
      t.string :title
      t.integer :farm
      t.integer :server
      t.string :secret
      t.string :photo_url

      t.timestamps
    end
    
    add_index :pictures, :photo_id, :unique => true
  end

  def self.down
    remove_index :pictures, :column => :photo_id
    drop_table :pictures
  end
end
