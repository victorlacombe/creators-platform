# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_05_30_131304) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.string "content"
    t.datetime "published_at"
    t.boolean "is_pinned", default: false
    t.string "top_level_comment_id_youtube"
    t.bigint "video_id"
    t.bigint "fan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comment_id_youtube"
    t.index ["fan_id"], name: "index_comments_on_fan_id"
    t.index ["video_id"], name: "index_comments_on_video_id"
  end

  create_table "fans", force: :cascade do |t|
    t.string "youtube_username"
    t.string "channel_id_youtube"
    t.string "profile_picture_url"
    t.bigint "memo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["memo_id"], name: "index_fans_on_memo_id"
  end

  create_table "memos", force: :cascade do |t|
    t.string "content", default: ""
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_memos_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "first_name"
    t.string "last_name"
    t.string "token"
    t.datetime "token_expiry"
    t.string "channel_name"
    t.string "channel_thumbnail"
    t.string "channel_id_youtube"
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.string "video_id_youtube"
    t.string "title"
    t.string "thumbnail"
    t.integer "likes"
    t.integer "dislikes"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comment_count"
    t.index ["user_id"], name: "index_videos_on_user_id"
  end

  add_foreign_key "comments", "fans"
  add_foreign_key "comments", "videos"
  add_foreign_key "fans", "memos"
  add_foreign_key "memos", "users"
  add_foreign_key "videos", "users"
end
