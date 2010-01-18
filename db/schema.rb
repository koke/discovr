# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100118003807) do

  create_table "favorites", :force => true do |t|
    t.string   "nsid"
    t.string   "photo_id"
    t.datetime "favorited_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["nsid", "photo_id"], :name => "index_favorites_on_nsid_and_photo_id", :unique => true

  create_table "history_caches", :force => true do |t|
    t.string   "cached_type", :null => false
    t.string   "cached_id",   :null => false
    t.text     "who"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_caches", :force => true do |t|
    t.string   "photo_id"
    t.integer  "farm"
    t.integer  "server"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photo_caches", ["photo_id"], :name => "index_photo_caches_on_photo_id", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "similars", :force => true do |t|
    t.string   "photo_id"
    t.string   "similar_id"
    t.string   "proxy_user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "similars", ["photo_id", "proxy_user"], :name => "index_similars_on_photo_id_and_proxy_user"
  add_index "similars", ["photo_id", "similar_id", "proxy_user"], :name => "index_similars_on_photo_id_and_similar_id_and_proxy_user", :unique => true

  create_table "user_caches", :force => true do |t|
    t.string   "nsid"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_caches", ["nsid"], :name => "index_user_caches_on_nsid", :unique => true

end
