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

ActiveRecord::Schema.define(version: 20150721192338) do

  create_table "participants", force: :cascade do |t|
    t.integer  "pool_id",    limit: 4, null: false
    t.integer  "user_id",    limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "pools", force: :cascade do |t|
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "group_id",       limit: 4,                    null: false
    t.string   "bot_id",         limit: 255,                  null: false
    t.integer  "start_price",    limit: 4,   default: 100,    null: false
    t.integer  "start_cash",     limit: 4,   default: 100000, null: false
    t.boolean  "started",        limit: 1,   default: false,  null: false
    t.datetime "started_at"
    t.integer  "minimum_person", limit: 4,   default: 7,      null: false
    t.integer  "daily_plus",     limit: 4,   default: 10,     null: false
    t.integer  "daily_minus",    limit: 4,   default: 5,      null: false
    t.integer  "message_count",  limit: 4,   default: 0,      null: false
    t.integer  "length",         limit: 4,   default: 3,      null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.integer  "owner_id",       limit: 4,             null: false
    t.integer  "participant_id", limit: 4
    t.integer  "amount",         limit: 4, default: 0, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "sender_id",   limit: 4, null: false
    t.integer  "receiver_id", limit: 4, null: false
    t.integer  "amount",      limit: 4, null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",    limit: 4,   null: false
    t.string   "name",       limit: 255
  end

end
