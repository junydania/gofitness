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

ActiveRecord::Schema.define(version: 20181021140634) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_details", force: :cascade do |t|
    t.datetime "subscribe_date"
    t.datetime "expiry_date"
    t.datetime "pause_start_date"
    t.datetime "pause_cancel_date"
    t.integer "amount"
    t.integer "loyalty_points_used"
    t.integer "loyalty_points_balance"
    t.string "gym_plan"
    t.boolean "recurring_billing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_id"
    t.integer "member_status"
    t.datetime "unsubscribe_date"
    t.integer "pause_permit_count", default: 0
    t.integer "gym_attendance_status", default: 0
    t.integer "visitation_count", default: 0
    t.index ["member_id"], name: "index_account_details_on_member_id"
  end

  create_table "attendance_histories", force: :cascade do |t|
    t.datetime "checkin_datetime"
    t.string "status_checking_in"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendance_records", force: :cascade do |t|
    t.datetime "checkin_date"
    t.datetime "checkout_date"
    t.integer "membership_status"
    t.string "membership_plan"
    t.string "staff_on_duty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_id"
    t.index ["member_id"], name: "index_attendance_records_on_member_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "cash_transactions", force: :cascade do |t|
    t.integer "amount_received"
    t.string "cash_received_by"
    t.string "service_paid_for"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_id"
    t.index ["member_id"], name: "index_cash_transactions_on_member_id"
  end

  create_table "charges", force: :cascade do |t|
    t.string "service_plan"
    t.integer "amount"
    t.string "payment_method"
    t.string "duration"
    t.string "gofit_transaction_id"
    t.bigint "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_charges_on_member_id"
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

  create_table "general_transactions", force: :cascade do |t|
    t.string "member_fullname"
    t.integer "transaction_type"
    t.datetime "subscribe_date"
    t.datetime "expiry_date"
    t.string "staff_responsible"
    t.integer "loyalty_earned"
    t.integer "loyalty_redeemed"
    t.string "membership_plan"
    t.integer "membership_status"
    t.bigint "customer_code"
    t.string "member_email"
    t.integer "loyalty_type"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_method"
  end

  create_table "health_conditions", force: :cascade do |t|
    t.string "condition_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "login_activities", force: :cascade do |t|
    t.string "scope"
    t.string "strategy"
    t.string "identity"
    t.boolean "success"
    t.string "failure_reason"
    t.string "user_type"
    t.bigint "user_id"
    t.string "context"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "city"
    t.string "region"
    t.string "country"
    t.datetime "created_at"
    t.index ["identity"], name: "index_login_activities_on_identity"
    t.index ["ip"], name: "index_login_activities_on_ip"
    t.index ["user_type", "user_id"], name: "index_login_activities_on_user_type_and_user_id"
  end

  create_table "loyalties", force: :cascade do |t|
    t.integer "loyalty_type"
    t.integer "loyalty_points_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loyalty_histories", force: :cascade do |t|
    t.integer "points_earned"
    t.integer "points_redeemed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "loyalty_balance"
    t.integer "loyalty_transaction_type"
    t.bigint "member_id"
    t.index ["loyalty_balance"], name: "index_loyalty_histories_on_loyalty_balance"
    t.index ["loyalty_transaction_type"], name: "index_loyalty_histories_on_loyalty_transaction_type"
    t.index ["member_id"], name: "index_loyalty_histories_on_member_id"
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
    t.string "first_name"
    t.string "last_name"
    t.string "next_of_kin_name"
    t.string "next_of_kin_email"
    t.string "address"
    t.string "email"
    t.date "date_of_birth"
    t.string "referal_name"
    t.string "voucher_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "fitness_goal_id"
    t.bigint "payment_method_id"
    t.bigint "subscription_plan_id"
    t.text "image_data"
    t.bigint "customer_code"
    t.bigint "phone_number"
    t.bigint "next_of_kin_phone"
    t.bigint "referring_customer_id"
    t.string "paystack_subscription_code"
    t.string "paystack_email_token"
    t.string "paystack_auth_code"
    t.string "paystack_cust_code"
    t.index ["customer_code"], name: "index_members_on_customer_code", unique: true
    t.index ["email"], name: "index_members_on_email"
    t.index ["fitness_goal_id"], name: "index_members_on_fitness_goal_id"
    t.index ["payment_method_id"], name: "index_members_on_payment_method_id"
    t.index ["phone_number"], name: "index_members_on_phone_number", unique: true
    t.index ["referring_customer_id"], name: "index_members_on_referring_customer_id"
    t.index ["subscription_plan_id"], name: "index_members_on_subscription_plan_id"
  end

  create_table "pause_histories", force: :cascade do |t|
    t.datetime "pause_start_date"
    t.datetime "pause_cancel_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "paused_by"
    t.bigint "member_id"
    t.datetime "pause_actual_cancel_date"
    t.index ["member_id"], name: "index_pause_histories_on_member_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "payment_system"
    t.integer "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plutus_accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.boolean "contra", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "type"], name: "index_plutus_accounts_on_name_and_type"
  end

  create_table "plutus_amounts", id: :serial, force: :cascade do |t|
    t.string "type"
    t.integer "account_id"
    t.integer "entry_id"
    t.decimal "amount", precision: 20, scale: 10
    t.index ["account_id", "entry_id"], name: "index_plutus_amounts_on_account_id_and_entry_id"
    t.index ["entry_id", "account_id"], name: "index_plutus_amounts_on_entry_id_and_account_id"
    t.index ["type"], name: "index_plutus_amounts_on_type"
  end

  create_table "plutus_entries", id: :serial, force: :cascade do |t|
    t.string "description"
    t.date "date"
    t.integer "commercial_document_id"
    t.string "commercial_document_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commercial_document_id", "commercial_document_type"], name: "index_entries_on_commercial_doc"
    t.index ["date"], name: "index_plutus_entries_on_date"
  end

  create_table "pos_transactions", force: :cascade do |t|
    t.boolean "transaction_success"
    t.string "transaction_reference"
    t.string "processed_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_id"
    t.integer "amount_received"
    t.index ["member_id"], name: "index_pos_transactions_on_member_id"
  end

  create_table "subscription_histories", force: :cascade do |t|
    t.datetime "subscribe_date"
    t.datetime "expiry_date"
    t.string "subscription_plan"
    t.integer "amount"
    t.string "payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_id"
    t.integer "subscription_type"
    t.integer "member_status"
    t.integer "subscription_status"
    t.index ["member_id"], name: "index_subscription_histories_on_member_id"
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
    t.boolean "recurring"
    t.string "paystack_plan_code"
    t.string "allowed_visitation_count", default: "unlimited"
    t.integer "organization_package", default: 0
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
    t.integer "role", default: 2
    t.bigint "phone_number"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallet_details", force: :cascade do |t|
    t.integer "current_balance"
    t.integer "amount_last_funded"
    t.datetime "wallet_expiry_date"
    t.integer "member_id"
    t.datetime "date_last_funded"
    t.integer "wallet_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_amount_funded"
    t.integer "total_amount_used"
  end

  create_table "wallet_histories", force: :cascade do |t|
    t.integer "amount_paid_in"
    t.integer "wallet_previous_balance"
    t.integer "amount_used"
    t.string "processed_by"
    t.integer "wallet_new_balance"
    t.integer "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "wallet_fund_method"
  end

  add_foreign_key "charges", "members"
  add_foreign_key "member_health_conditions", "health_conditions"
  add_foreign_key "member_health_conditions", "members"
  add_foreign_key "members", "fitness_goals"
  add_foreign_key "members", "payment_methods"
  add_foreign_key "members", "subscription_plans"
  add_foreign_key "subscription_plan_features", "features"
  add_foreign_key "subscription_plan_features", "subscription_plans"
end
