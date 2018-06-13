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

ActiveRecord::Schema.define(version: 20180613171112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_details", force: :cascade do |t|
    t.datetime "subscribe_date"
    t.datetime "expiry_date"
    t.string "member_status"
    t.datetime "pause_start_date"
    t.datetime "pause_cancel_date"
    t.integer "amount"
    t.integer "loyalty_points_used"
    t.integer "loyalty_points_balance"
    t.string "gym_plan"
    t.boolean "recurring_billing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendance_histories", force: :cascade do |t|
    t.datetime "checkin_datetime"
    t.string "status_checking_in"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "features", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fitness_goals", force: :cascade do |t|
    t.string "goal_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "health_conditions", force: :cascade do |t|
    t.string "condition_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loyalty_histories", force: :cascade do |t|
    t.integer "points_earned"
    t.integer "points_redeemed"
    t.string "loyalty_activity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "member_health_conditions", force: :cascade do |t|
    t.bigint "member_id"
    t.bigint "health_condition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_condition_id"], name: "index_member_health_conditions_on_health_condition_id"
    t.index ["member_id"], name: "index_member_health_conditions_on_member_id"
  end

  create_table "members", force: :cascade do |t|
    t.integer "customer_code"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "phone_number"
    t.string "next_of_kin_name"
    t.integer "next_of_kin_phone"
    t.string "next_of_kin_email"
    t.string "address"
    t.date "date_of_birth"
    t.string "referal_name"
    t.string "voucher_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "fitness_goal_id"
    t.bigint "payment_method_id"
    t.bigint "subscription_plan_id"
    t.index ["fitness_goal_id"], name: "index_members_on_fitness_goal_id"
    t.index ["payment_method_id"], name: "index_members_on_payment_method_id"
    t.index ["subscription_plan_id"], name: "index_members_on_subscription_plan_id"
  end

  create_table "pause_histories", force: :cascade do |t|
    t.datetime "pause_start_date"
    t.string "pause_reason"
    t.datetime "pause_cancel_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "payment_system"
    t.integer "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscription_histories", force: :cascade do |t|
    t.datetime "subscribe_date"
    t.datetime "expiry_date"
    t.string "subscription_type"
    t.string "subscription_plan"
    t.integer "amount"
    t.string "payment_method"
    t.string "member_status"
    t.string "subscription_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscription_plan_features", force: :cascade do |t|
    t.bigint "subscription_plan_id"
    t.bigint "feature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_id"], name: "index_subscription_plan_features_on_feature_id"
    t.index ["subscription_plan_id"], name: "index_subscription_plan_features_on_subscription_plan_id"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plan_name"
    t.integer "cost"
    t.string "description"
    t.integer "duration"
    t.boolean "group_plan"
    t.integer "no_of_group_members"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "phone_number"
    t.integer "role", default: 2
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "member_health_conditions", "health_conditions"
  add_foreign_key "member_health_conditions", "members"
  add_foreign_key "members", "fitness_goals"
  add_foreign_key "members", "payment_methods"
  add_foreign_key "members", "subscription_plans"
  add_foreign_key "subscription_plan_features", "features"
  add_foreign_key "subscription_plan_features", "subscription_plans"
end
