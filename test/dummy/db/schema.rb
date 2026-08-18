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

ActiveRecord::Schema[8.1].define(version: 2025_08_18_030305) do
  create_table "admins", force: :cascade do |t|
    t.string "authentication_token"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.string "name"
    t.string "otp_auth_secret"
    t.datetime "otp_challenge_expires", precision: nil
    t.boolean "otp_enabled", default: false, null: false
    t.datetime "otp_enabled_on", precision: nil
    t.integer "otp_failed_attempts", default: 0, null: false
    t.boolean "otp_mandatory", default: false, null: false
    t.string "otp_persistence_seed"
    t.integer "otp_recovery_counter", default: 0, null: false
    t.string "otp_recovery_secret"
    t.string "otp_session_challenge"
    t.integer "otp_time_drift", default: 0, null: false
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0
    t.string "unlock_token"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authentication_token"], name: "index_admins_on_authentication_token", unique: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["otp_challenge_expires"], name: "index_admins_on_otp_challenge_expires"
    t.index ["otp_session_challenge"], name: "index_admins_on_otp_session_challenge", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "lockable_users", force: :cascade do |t|
    t.string "authentication_token"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.string "name"
    t.string "otp_auth_secret"
    t.datetime "otp_challenge_expires", precision: nil
    t.boolean "otp_enabled", default: false, null: false
    t.datetime "otp_enabled_on", precision: nil
    t.integer "otp_failed_attempts", default: 0, null: false
    t.boolean "otp_mandatory", default: false, null: false
    t.string "otp_persistence_seed"
    t.integer "otp_recovery_counter", default: 0, null: false
    t.string "otp_recovery_secret"
    t.string "otp_session_challenge"
    t.integer "otp_time_drift", default: 0, null: false
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0
    t.string "unlock_token"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authentication_token"], name: "index_lockable_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_lockable_users_on_email", unique: true
    t.index ["otp_challenge_expires"], name: "index_lockable_users_on_otp_challenge_expires"
    t.index ["otp_session_challenge"], name: "index_lockable_users_on_otp_session_challenge", unique: true
    t.index ["reset_password_token"], name: "index_lockable_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_lockable_users_on_unlock_token", unique: true
  end

  create_table "non_otp_users", force: :cascade do |t|
    t.string "authentication_token"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.string "name"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0
    t.string "unlock_token"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authentication_token"], name: "index_non_otp_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_non_otp_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_non_otp_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_non_otp_users_on_unlock_token", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "rememberable_users", force: :cascade do |t|
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "otp_auth_secret"
    t.datetime "otp_challenge_expires"
    t.boolean "otp_enabled", default: false, null: false
    t.datetime "otp_enabled_on"
    t.integer "otp_failed_attempts", default: 0, null: false
    t.boolean "otp_mandatory", default: false, null: false
    t.string "otp_persistence_seed"
    t.integer "otp_recovery_counter", default: 0, null: false
    t.string "otp_recovery_secret"
    t.string "otp_session_challenge"
    t.integer "otp_time_drift", default: 0, null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0
    t.index ["email"], name: "index_rememberable_users_on_email", unique: true
    t.index ["otp_challenge_expires"], name: "index_rememberable_users_on_otp_challenge_expires"
    t.index ["otp_session_challenge"], name: "index_rememberable_users_on_otp_session_challenge", unique: true
    t.index ["reset_password_token"], name: "index_rememberable_users_on_reset_password_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "authentication_token"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.string "name"
    t.string "otp_auth_secret"
    t.datetime "otp_challenge_expires", precision: nil
    t.boolean "otp_enabled", default: false, null: false
    t.datetime "otp_enabled_on", precision: nil
    t.integer "otp_failed_attempts", default: 0, null: false
    t.boolean "otp_mandatory", default: false, null: false
    t.string "otp_persistence_seed"
    t.integer "otp_recovery_counter", default: 0, null: false
    t.string "otp_recovery_secret"
    t.string "otp_session_challenge"
    t.integer "otp_time_drift", default: 0, null: false
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0
    t.string "unlock_token"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["otp_challenge_expires"], name: "index_users_on_otp_challenge_expires"
    t.index ["otp_session_challenge"], name: "index_users_on_otp_session_challenge", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end
end
