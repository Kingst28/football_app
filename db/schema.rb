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

ActiveRecord::Schema.define(version: 20200726085609) do

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "bid_count",         default: 1
    t.boolean  "new_results_ready", default: false
  end

  create_table "bids", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "user_id"
    t.integer  "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "bids", ["account_id"], name: "index_bids_on_account_id"
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
    t.integer  "account_id"
  end

  add_index "fixtures", ["account_id"], name: "index_fixtures_on_account_id"

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
    t.integer  "account_id"
  end

  add_index "league_tables", ["account_id"], name: "index_league_tables_on_account_id"

  create_table "matchdays", force: :cascade do |t|
    t.integer  "matchday_number"
    t.string   "haflag",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "matchday_count"
    t.integer  "account_id"
  end

  add_index "matchdays", ["account_id"], name: "index_matchdays_on_account_id"

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
    t.integer  "account_id"
    t.string   "status"
    t.string   "fname"
  end

  add_index "notifications", ["account_id"], name: "index_notifications_on_account_id"

  create_table "players", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teams_id"
    t.string   "position",   limit: 255
    t.string   "taken",      limit: 255, default: "No"
    t.string   "playerteam"
    t.integer  "account_id"
  end

  add_index "players", ["account_id"], name: "index_players_on_account_id"
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
    t.integer  "account_id"
    t.string   "playerteam"
  end

  add_index "playerstats", ["account_id"], name: "index_playerstats_on_account_id"

  create_table "results", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "results", ["account_id"], name: "index_results_on_account_id"

  create_table "results_masters", force: :cascade do |t|
    t.boolean  "played"
    t.boolean  "scored"
    t.integer  "scorenum"
    t.boolean  "conceded"
    t.integer  "concedednum"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.string   "league"
    t.string   "team"
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
    t.integer  "account_id"
    t.string   "name"
  end

  add_index "teamsheets", ["account_id"], name: "index_teamsheets_on_account_id"

  create_table "timers", force: :cascade do |t|
    t.string   "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "account_id"
  end

  add_index "timers", ["account_id"], name: "index_timers_on_account_id"

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
    t.integer  "account_id"
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id"

end
