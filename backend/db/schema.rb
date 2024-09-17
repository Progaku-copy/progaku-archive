# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 0) do
  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "memo_id", null: false, comment: "メモID"
    t.string "content", limit: 1024, null: false, comment: "内容"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["memo_id"], name: "index_comments_on_memo_id"
  end

  create_table "memo_tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "memo_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["memo_id", "tag_id"], name: "index_memo_tags_on_memo_id_and_tag_id", unique: true
    t.index ["memo_id"], name: "index_memo_tags_on_memo_id"
    t.index ["tag_id"], name: "index_memo_tags_on_tag_id"
  end

  create_table "memos", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false, comment: "メモのタイトル"
    t.text "content", null: false, comment: "メモの本文"
    t.string "poster", limit: 50, null: false, comment: "Slackのユーザー名"
    t.timestamp "created_at", null: false
    t.timestamp "updated_at", null: false
  end

  create_table "tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 30, null: false, comment: "タグ名"
    t.integer "priority", null: false, comment: "タグの順番"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["priority"], name: "index_tags_on_priority"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "account_name", limit: 60, null: false, comment: "ユーザーの名前"
    t.string "password_digest", limit: 60, null: false, comment: "ユーザーのpassword"
    t.boolean "admin", default: false, null: false, comment: "管理者フラグ"
    t.timestamp "created_at", null: false
    t.timestamp "updated_at", null: false
    t.index ["account_name"], name: "index_users_on_account_name", unique: true
  end

  add_foreign_key "comments", "memos", name: "fk_comments_memo_id"
  add_foreign_key "memo_tags", "memos", name: "fk_memo_tags_memo_id"
  add_foreign_key "memo_tags", "tags", name: "fk_memo_tags_tag_id"
end
