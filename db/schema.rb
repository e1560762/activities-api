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

ActiveRecord::Schema.define(version: 20180413204457) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.string "storable_type"
    t.bigint "storable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["storable_type", "storable_id"], name: "index_activities_on_storable_type_and_storable_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "activity_histories", force: :cascade do |t|
    t.bigint "user_id"
    t.string "activities"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "size"
    t.index ["created_at"], name: "index_activity_histories_on_created_at"
    t.index ["user_id"], name: "index_activity_histories_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "post_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contest_participant", id: false, force: :cascade do |t|
    t.bigint "contest_id", null: false
    t.bigint "user_id", null: false
    t.serial "id", null: false
  end

  create_table "contests", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "followers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "followee_id"
    t.bigint "user_id"
    t.index ["user_id", "followee_id"], name: "index_followers_on_user_id_and_followee_id", unique: true
  end

  create_table "platforms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "platforms_users", id: false, force: :cascade do |t|
    t.bigint "platform_id", null: false
    t.bigint "user_id", null: false
    t.serial "id", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "project_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_posts_on_project_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "respects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "project_id"
    t.index ["user_id", "project_id"], name: "index_respects_on_user_id_and_project_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "activity_histories", "users"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "posts", "projects"
  add_foreign_key "posts", "users"
  add_foreign_key "respects", "projects"
  add_foreign_key "respects", "users"
end
