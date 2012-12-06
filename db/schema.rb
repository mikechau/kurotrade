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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121206210524) do

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "market_data", :force => true do |t|
    t.date     "market_date"
    t.string   "ticker"
    t.float    "close_price"
    t.float    "adj_close",   :limit => 255
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "portfolios", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "stock_prices", :force => true do |t|
    t.string   "symbol"
    t.date     "date"
    t.float    "close_price"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "stock_tickers", :force => true do |t|
    t.string   "symbol"
    t.string   "name"
    t.string   "exchange"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "transactions", :force => true do |t|
    t.integer  "group_id"
    t.string   "trade_id"
    t.string   "stock_symbol"
    t.date     "trade_date"
    t.date     "settle_date"
    t.integer  "quantity"
    t.float    "price"
    t.float    "commission"
    t.float    "fees"
    t.float    "interest"
    t.float    "total_value"
    t.string   "description"
    t.string   "broker"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "action_type"
    t.integer  "action_id"
    t.string   "record_type"
    t.integer  "user_id"
    t.string   "input_method"
    t.string   "cusip"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password_digest"
    t.string   "email"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
