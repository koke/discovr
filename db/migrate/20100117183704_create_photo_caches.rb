class CreatePhotoCaches < ActiveRecord::Migration
  def self.up
    create_table :photo_caches do |t|
      t.string :photo_id
      t.integer :farm
      t.integer :server
      t.string :secret

      t.timestamps
    end
    
    add_index :photo_caches, :photo_id, :unique => true
  end

  def self.down
    remove_index :photo_caches, :column => :photo_id
    drop_table :photo_caches
  end
end
