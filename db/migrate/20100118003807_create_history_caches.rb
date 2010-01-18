class CreateHistoryCaches < ActiveRecord::Migration
  def self.up
    create_table :history_caches do |t|
      t.string :cached_type, :null => false
      t.string :cached_id, :null => false
      t.text :who

      t.timestamps
    end
  end

  def self.down
    drop_table :history_caches
  end
end
