class CreateUserCaches < ActiveRecord::Migration
  def self.up
    create_table :user_caches do |t|
      t.string :nsid
      t.string :username

      t.timestamps
    end
    
    add_index :user_caches, :nsid, :unique => true
  end

  def self.down
    remove_index :user_caches, :column => :nsid
    drop_table :user_caches
  end
end
