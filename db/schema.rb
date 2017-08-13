# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170813115845) do

  create_table "bids", force: true do |t|
    t.integer  "amount"
    t.integer  "user_id"
    t.integer  "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bids", ["player_id"], name: "index_bids_on_player_id"
  add_index "bids", ["user_id"], name: "index_bids_on_user_id"

  create_table "fixtures", force: true do |t|
    t.integer  "matchday"
    t.integer  "hteam",      limit: 255
    t.integer  "ateam",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "haflag"
    t.string   "finalscore"
  end

  create_table "matchdays", force: true do |t|
    t.integer  "matchday_number"
    t.string   "haflag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "matchday_count"
  end

  create_table "players", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teams_id"
    t.string   "position"
  end

  add_index "players", ["teams_id"], name: "index_players_on_teams_id"

  create_table "results", force: true do |t|
    t.integer  "user_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teamsheets", force: true do |t|
    t.integer  "user_id"
    t.integer  "player_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.boolean  "played"
    t.boolean  "scored"
    t.integer  "scorenum"
    t.boolean  "conceded"
    t.integer  "concedednum"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "access",            default: "user"
    t.integer  "budget",            default: 1000000
  end

end
