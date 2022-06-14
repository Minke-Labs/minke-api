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

ActiveRecord::Schema[7.0].define(version: 2022_06_08_140042) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_users", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "referral_codes", force: :cascade do |t|
    t.string "wallet"
    t.string "device_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_referral_codes_on_code"
    t.index ["wallet"], name: "index_referral_codes_on_wallet"
  end

  create_table "referrals", force: :cascade do |t|
    t.bigint "referral_code_id", null: false
    t.string "wallet"
    t.string "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referral_code_id"], name: "index_referrals_on_referral_code_id"
  end

  add_foreign_key "referrals", "referral_codes"
end
