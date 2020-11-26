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

ActiveRecord::Schema.define(version: 2020_11_26_005205) do

  create_table "agendas", force: :cascade do |t|
    t.integer "meeting_id"
    t.string "title"
    t.integer "duration"
    t.string "sentence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meetings", force: :cascade do |t|
    t.string "meeting_id"
    t.integer "start_time"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "zoom_id"
    t.string "zoom_pass"
    t.integer "agenda_now", default: 0, null: false
    t.string "email"
    t.boolean "join", default: false, null: false
  end

end
