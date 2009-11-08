class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :nsid, :null => false
      t.string :username
      t.timestamp :last_favorited

      t.timestamps
    end
    
    add_index :users, :nsid, :unique => true
  end

  def self.down
    remove_index :users, :column => :nsid
    drop_table :users
  end
end
