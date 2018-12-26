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

ActiveRecord::Schema.define(version: 20181226173335) do

  create_table "bids", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "user_id"
    t.integer  "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bids", ["player_id"], name: "index_bids_on_player_id"
  add_index "bids", ["user_id"], name: "index_bids_on_user_id"

  create_table "fixtures", force: :cascade do |t|
    t.integer  "matchday"
    t.text     "hteam",      limit: 255
    t.text     "ateam",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "haflag",     limit: 255
    t.string   "finalscore", limit: 255, default: ""
  end

  create_table "league_tables", force: :cascade do |t|
    t.string   "team",       limit: 255
    t.integer  "played",                 default: 0
    t.integer  "won",                    default: 0
    t.integer  "drawn",                  default: 0
    t.integer  "lost",                   default: 0
    t.integer  "for",                    default: 0
    t.integer  "against",                default: 0
    t.integer  "gd",                     default: 0
    t.integer  "points",                 default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "matchdays", force: :cascade do |t|
    t.integer  "matchday_number"
    t.string   "haflag",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "matchday_count"
  end

  create_table "models", force: :cascade do |t|
    t.string   "timer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "show",       limit: 255
  end

  create_table "players", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teams_id"
    t.string   "position",   limit: 255
    t.string   "taken",      limit: 255, default: "No"
    t.string   "playerteam"
  end

  add_index "players", ["teams_id"], name: "index_players_on_teams_id"

  create_table "playerstats", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "played"
    t.integer  "scored"
    t.integer  "scorenum"
    t.integer  "conceded"
    t.integer  "concedednum"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "results", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "teams" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

  create_table "teamsheets", force: :cascade do |t|
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
    t.integer  "priority"
  end

  create_table "timers", force: :cascade do |t|
    t.string   "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",        limit: 255
    t.string   "last_name",         limit: 255
    t.string   "email",             limit: 255
    t.string   "password_digest",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_digest", limit: 255
    t.boolean  "activated",                     default: false
    t.datetime "activated_at"
    t.string   "reset_digest",      limit: 255
    t.datetime "reset_sent_at"
    t.string   "access",            limit: 255, default: "user"
    t.integer  "budget",                        default: 1000000
    t.string   "canView",           limit: 255
  end

end
