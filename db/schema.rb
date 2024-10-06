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

ActiveRecord::Schema[7.2].define(version: 2024_10_05_210157) do
  create_table "assignments", force: :cascade do |t|
    t.string "assignment_name"
    t.string "repository_name"
    t.string "repository_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assignments_users", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "assignment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_assignments_users_on_assignment_id"
    t.index ["user_id"], name: "index_assignments_users_on_user_id"
  end

  create_table "tests", force: :cascade do |t|
    t.string "name"
    t.float "points"
    t.string "type"
    t.string "target"
    t.text "include"
    t.string "number"
    t.boolean "show_output"
    t.boolean "skip"
    t.float "timeout"
    t.string "visibility"
    t.integer "assignment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_tests_on_assignment_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
  end

  add_foreign_key "assignments_users", "assignments"
  add_foreign_key "assignments_users", "users"
  add_foreign_key "tests", "assignments"
end
