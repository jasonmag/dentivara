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

ActiveRecord::Schema[8.0].define(version: 2026_05_08_123000) do
  create_table "access_logs", force: :cascade do |t|
    t.integer "user_id"
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "action", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_access_logs_on_action"
    t.index ["resource_type", "resource_id", "created_at"], name: "idx_access_logs_resource"
    t.index ["user_id"], name: "index_access_logs_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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
    t.string "operatory"
    t.index ["operatory", "starts_at"], name: "index_appointments_on_operatory_and_starts_at"
    t.index ["patient_id", "starts_at"], name: "index_appointments_on_patient_id_and_starts_at"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["user_id", "starts_at"], name: "index_appointments_on_user_id_and_starts_at"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.integer "user_id"
    t.string "action", null: false
    t.string "auditable_type", null: false
    t.bigint "auditable_id", null: false
    t.json "changeset", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_hash"
    t.string "previous_hash"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["event_hash"], name: "index_audit_logs_on_event_hash"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "clinic_services", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "base_price", precision: 12, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.integer "duration_minutes", default: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_clinic_services_on_name", unique: true
  end

  create_table "dental_chart_entries", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "user_id", null: false
    t.string "tooth_code"
    t.string "entry_type", null: false
    t.text "notes", null: false
    t.date "recorded_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "surface_marks", default: [], null: false
    t.index ["entry_type"], name: "index_dental_chart_entries_on_entry_type"
    t.index ["patient_id", "recorded_on"], name: "index_dental_chart_entries_on_patient_id_and_recorded_on"
    t.index ["patient_id"], name: "index_dental_chart_entries_on_patient_id"
    t.index ["user_id"], name: "index_dental_chart_entries_on_user_id"
  end

  create_table "document_templates", force: :cascade do |t|
    t.string "name", null: false
    t.string "kind", null: false
    t.text "header_text"
    t.text "body_template"
    t.text "footer_text"
    t.string "digital_signature_name"
    t.string "digital_signature_title"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default_for_prescription", default: false, null: false
    t.text "information_header_text"
    t.index ["kind", "active"], name: "index_document_templates_on_kind_and_active"
    t.index ["kind", "default_for_prescription"], name: "idx_doc_templates_kind_default"
  end

  create_table "intake_form_submissions", force: :cascade do |t|
    t.integer "patient_id"
    t.integer "submitted_by_user_id"
    t.string "source", default: "online", null: false
    t.string "status", default: "submitted", null: false
    t.json "payload", default: {}, null: false
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_intake_form_submissions_on_patient_id"
    t.index ["source"], name: "index_intake_form_submissions_on_source"
    t.index ["status"], name: "index_intake_form_submissions_on_status"
    t.index ["submitted_by_user_id"], name: "index_intake_form_submissions_on_submitted_by_user_id"
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
    t.string "source_record_type"
    t.integer "source_record_id"
    t.index ["patient_id"], name: "index_notifications_on_patient_id"
    t.index ["source_record_type", "source_record_id"], name: "index_notifications_on_source_record_type_and_source_record_id"
  end

  create_table "patient_consents", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "user_id", null: false
    t.string "document_version", null: false
    t.string "consent_type", null: false
    t.datetime "consented_at", null: false
    t.json "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "consent_type", "consented_at"], name: "idx_patient_consents_lookup"
    t.index ["patient_id"], name: "index_patient_consents_on_patient_id"
    t.index ["user_id"], name: "index_patient_consents_on_user_id"
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
    t.integer "user_id"
    t.text "dental_chart"
    t.text "chief_complaint"
    t.text "known_allergies"
    t.text "current_medications"
    t.text "medical_conditions"
    t.date "last_dental_visit_on"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "preferred_contact_method"
    t.string "insurance_provider"
    t.string "insurance_policy_number"
    t.string "country"
    t.index ["user_id"], name: "index_patients_on_user_id", unique: true
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

  create_table "prescriptions", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "document_template_id"
    t.integer "drafted_by_user_id", null: false
    t.integer "signed_by_user_id"
    t.string "status", default: "draft", null: false
    t.date "issued_on", null: false
    t.datetime "signed_at"
    t.text "body", null: false
    t.text "signature_snapshot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_template_id"], name: "index_prescriptions_on_document_template_id"
    t.index ["drafted_by_user_id"], name: "index_prescriptions_on_drafted_by_user_id"
    t.index ["patient_id", "issued_on"], name: "index_prescriptions_on_patient_id_and_issued_on"
    t.index ["patient_id"], name: "index_prescriptions_on_patient_id"
    t.index ["signed_by_user_id"], name: "index_prescriptions_on_signed_by_user_id"
    t.index ["status"], name: "index_prescriptions_on_status"
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
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "access_logs", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "users"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "dental_chart_entries", "patients"
  add_foreign_key "dental_chart_entries", "users"
  add_foreign_key "intake_form_submissions", "patients"
  add_foreign_key "intake_form_submissions", "users", column: "submitted_by_user_id"
  add_foreign_key "invoices", "patients"
  add_foreign_key "invoices", "treatment_records"
  add_foreign_key "notifications", "patients"
  add_foreign_key "patient_consents", "patients"
  add_foreign_key "patient_consents", "users"
  add_foreign_key "patients", "users"
  add_foreign_key "payments", "invoices"
  add_foreign_key "prescriptions", "document_templates"
  add_foreign_key "prescriptions", "patients"
  add_foreign_key "prescriptions", "users", column: "drafted_by_user_id"
  add_foreign_key "prescriptions", "users", column: "signed_by_user_id"
  add_foreign_key "treatment_records", "appointments"
  add_foreign_key "treatment_records", "patients"
  add_foreign_key "treatment_records", "users"
end
