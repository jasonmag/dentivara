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

ActiveRecord::Schema[8.0].define(version: 2026_05_02_160206) do
  create_table "appointments", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "user_id", null: false
    t.string "source"
    t.string "booking_type"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "treatment_record_id", null: false
    t.string "status"
    t.decimal "total_amount"
    t.decimal "balance_amount"
    t.date "issued_on"
    t.datetime "approved_by_dentist_at"
    t.datetime "approved_by_admin_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_invoices_on_patient_id"
    t.index ["treatment_record_id"], name: "index_invoices_on_treatment_record_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.string "channel"
    t.string "category"
    t.datetime "scheduled_for"
    t.datetime "sent_at"
    t.string "status"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_notifications_on_patient_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "birth_date"
    t.string "phone"
    t.string "email"
    t.string "emergency_contact_name"
    t.string "emergency_contact_phone"
    t.text "medical_history"
    t.datetime "consented_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.decimal "amount"
    t.date "paid_on"
    t.string "method"
    t.string "reference_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
  end

  create_table "treatment_records", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "user_id", null: false
    t.integer "appointment_id", null: false
    t.string "service_type"
    t.text "clinical_notes"
    t.decimal "cost"
    t.date "performed_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_treatment_records_on_appointment_id"
    t.index ["patient_id"], name: "index_treatment_records_on_patient_id"
    t.index ["user_id"], name: "index_treatment_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "role", default: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "users"
  add_foreign_key "invoices", "patients"
  add_foreign_key "invoices", "treatment_records"
  add_foreign_key "notifications", "patients"
  add_foreign_key "payments", "invoices"
  add_foreign_key "treatment_records", "appointments"
  add_foreign_key "treatment_records", "patients"
  add_foreign_key "treatment_records", "users"
end
