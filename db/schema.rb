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

ActiveRecord::Schema[8.0].define(version: 2026_05_14_143000) do
  create_table "access_logs", force: :cascade do |t|
    t.integer "user_id"
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "action", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clinic_id", null: false
    t.index ["action"], name: "index_access_logs_on_action"
    t.index ["clinic_id"], name: "index_access_logs_on_clinic_id"
    t.index ["resource_type", "resource_id", "created_at"], name: "idx_access_logs_resource"
    t.index ["user_id"], name: "index_access_logs_on_user_id"
  end

  create_table "account_memberships", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "user_id", null: false
    t.string "role", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "user_id"], name: "index_account_memberships_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_account_memberships_on_account_id"
    t.index ["role"], name: "index_account_memberships_on_role"
    t.index ["user_id"], name: "index_account_memberships_on_user_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "billing_email"
    t.string "subscription_plan", default: "starter", null: false
    t.string "subscription_status", default: "trialing", null: false
    t.date "trial_ends_on"
    t.datetime "suspended_at"
    t.json "plan_limits", default: {}, null: false
    t.json "feature_flags", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "subscription_starts_on"
    t.date "subscription_ends_on"
    t.index ["slug"], name: "index_accounts_on_slug", unique: true
    t.index ["subscription_ends_on"], name: "index_accounts_on_subscription_ends_on"
    t.index ["subscription_plan"], name: "index_accounts_on_subscription_plan"
    t.index ["subscription_starts_on"], name: "index_accounts_on_subscription_starts_on"
    t.index ["subscription_status"], name: "index_accounts_on_subscription_status"
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

  create_table "api_access_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.string "token_digest", null: false
    t.json "scopes", default: [], null: false
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "last_used_at"
    t.string "last_used_ip"
    t.string "last_used_user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "impersonated_by_user_id"
    t.string "impersonation_reason"
    t.index ["expires_at"], name: "index_api_access_tokens_on_expires_at"
    t.index ["impersonated_by_user_id"], name: "index_api_access_tokens_on_impersonated_by_user_id"
    t.index ["token_digest"], name: "index_api_access_tokens_on_token_digest", unique: true
    t.index ["user_id", "revoked_at"], name: "index_api_access_tokens_on_user_id_and_revoked_at"
    t.index ["user_id"], name: "index_api_access_tokens_on_user_id"
  end

  create_table "api_idempotency_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "http_method", null: false
    t.string "path", null: false
    t.string "request_hash", null: false
    t.integer "response_code", null: false
    t.text "response_body", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_api_idempotency_keys_on_expires_at"
    t.index ["key", "http_method", "path"], name: "idx_api_idempotency_unique_scope", unique: true
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
    t.integer "clinic_service_id"
    t.integer "duration_minutes"
    t.integer "buffer_minutes", default: 10, null: false
    t.integer "preferred_user_id"
    t.string "time_preference"
    t.string "cancellation_reason"
    t.datetime "cancelled_at"
    t.integer "rescheduled_from_appointment_id"
    t.integer "clinic_id", null: false
    t.index ["cancelled_at"], name: "index_appointments_on_cancelled_at"
    t.index ["clinic_id"], name: "index_appointments_on_clinic_id"
    t.index ["clinic_service_id"], name: "index_appointments_on_clinic_service_id"
    t.index ["operatory", "starts_at"], name: "index_appointments_on_operatory_and_starts_at"
    t.index ["patient_id", "starts_at"], name: "index_appointments_on_patient_id_and_starts_at"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["preferred_user_id"], name: "index_appointments_on_preferred_user_id"
    t.index ["rescheduled_from_appointment_id"], name: "index_appointments_on_rescheduled_from_appointment_id"
    t.index ["starts_at"], name: "index_appointments_on_starts_at"
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
    t.integer "clinic_id", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["clinic_id"], name: "index_audit_logs_on_clinic_id"
    t.index ["event_hash"], name: "index_audit_logs_on_event_hash"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "clinic_closures", force: :cascade do |t|
    t.date "date", null: false
    t.string "reason"
    t.boolean "emergency_only", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clinic_id", null: false
    t.index ["clinic_id", "date"], name: "index_clinic_closures_on_clinic_id_and_date", unique: true
    t.index ["clinic_id"], name: "index_clinic_closures_on_clinic_id"
  end

  create_table "clinic_memberships", force: :cascade do |t|
    t.integer "clinic_id", null: false
    t.integer "user_id", null: false
    t.string "role", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clinic_id", "user_id"], name: "index_clinic_memberships_on_clinic_id_and_user_id", unique: true
    t.index ["clinic_id"], name: "index_clinic_memberships_on_clinic_id"
    t.index ["role"], name: "index_clinic_memberships_on_role"
    t.index ["user_id"], name: "index_clinic_memberships_on_user_id"
  end

  create_table "clinic_schedules", force: :cascade do |t|
    t.integer "day_of_week", null: false
    t.time "opens_at"
    t.time "closes_at"
    t.boolean "closed", default: false, null: false
    t.boolean "emergency_only", default: false, null: false
    t.integer "max_concurrent_appointments", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clinic_id", null: false
    t.index ["clinic_id", "day_of_week"], name: "index_clinic_schedules_on_clinic_id_and_day_of_week", unique: true
    t.index ["clinic_id"], name: "index_clinic_schedules_on_clinic_id"
  end

  create_table "clinic_services", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "base_price", precision: 12, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.integer "duration_minutes", default: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "preparation_minutes", default: 0, null: false
    t.string "color", default: "#2a9d8f", null: false
    t.integer "clinic_id", null: false
    t.index ["clinic_id", "name"], name: "index_clinic_services_on_clinic_id_and_name", unique: true
    t.index ["clinic_id"], name: "index_clinic_services_on_clinic_id"
  end

  create_table "clinic_settings", force: :cascade do |t|
    t.string "time_zone", default: "Asia/Manila", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency_code", default: "USD", null: false
    t.string "currency_locale", default: "en-US", null: false
    t.integer "queue_eta_minutes_default", default: 20, null: false
    t.integer "queue_eta_minutes_scheduled", default: 20, null: false
    t.integer "queue_eta_minutes_walk_in", default: 25, null: false
    t.integer "queue_eta_minutes_emergency", default: 10, null: false
    t.integer "queue_eta_minutes_priority", default: 15, null: false
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_clinic_settings_on_clinic_id", unique: true
  end

  create_table "clinics", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "contact_email"
    t.string "phone"
    t.string "subscription_plan", default: "starter", null: false
    t.string "subscription_status", default: "trialing", null: false
    t.date "trial_ends_on"
    t.datetime "suspended_at"
    t.json "plan_limits", default: {}, null: false
    t.json "feature_flags", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id", null: false
    t.index ["account_id"], name: "index_clinics_on_account_id"
    t.index ["slug"], name: "index_clinics_on_slug", unique: true
    t.index ["subscription_plan"], name: "index_clinics_on_subscription_plan"
    t.index ["subscription_status"], name: "index_clinics_on_subscription_status"
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
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_dental_chart_entries_on_clinic_id"
    t.index ["entry_type"], name: "index_dental_chart_entries_on_entry_type"
    t.index ["patient_id", "recorded_on"], name: "index_dental_chart_entries_on_patient_id_and_recorded_on"
    t.index ["patient_id"], name: "index_dental_chart_entries_on_patient_id"
    t.index ["user_id"], name: "index_dental_chart_entries_on_user_id"
  end

  create_table "dentist_schedule_overrides", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "date", null: false
    t.time "available_from"
    t.time "available_until"
    t.boolean "unavailable", default: false, null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clinic_id", null: false
    t.index ["clinic_id", "user_id", "date"], name: "idx_dentist_overrides_clinic_user_date", unique: true
    t.index ["clinic_id"], name: "index_dentist_schedule_overrides_on_clinic_id"
    t.index ["user_id"], name: "index_dentist_schedule_overrides_on_user_id"
  end

  create_table "dentist_schedules", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "day_of_week", null: false
    t.time "starts_at", null: false
    t.time "ends_at", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_dentist_schedules_on_clinic_id"
    t.index ["user_id", "day_of_week"], name: "index_dentist_schedules_on_user_id_and_day_of_week"
    t.index ["user_id"], name: "index_dentist_schedules_on_user_id"
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
    t.datetime "deleted_at"
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_document_templates_on_clinic_id"
    t.index ["deleted_at"], name: "index_document_templates_on_deleted_at"
    t.index ["kind", "active", "deleted_at"], name: "idx_doc_templates_kind_active_deleted_at"
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
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_intake_form_submissions_on_clinic_id"
    t.index ["patient_id"], name: "index_intake_form_submissions_on_patient_id"
    t.index ["source"], name: "index_intake_form_submissions_on_source"
    t.index ["status"], name: "index_intake_form_submissions_on_status"
    t.index ["submitted_by_user_id"], name: "index_intake_form_submissions_on_submitted_by_user_id"
  end

  create_table "intraoral_scans", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "user_id", null: false
    t.date "captured_on", null: false
    t.string "scan_type", default: "intraoral_scan", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_intraoral_scans_on_clinic_id"
    t.index ["patient_id", "captured_on"], name: "index_intraoral_scans_on_patient_id_and_captured_on"
    t.index ["patient_id"], name: "index_intraoral_scans_on_patient_id"
    t.index ["user_id"], name: "index_intraoral_scans_on_user_id"
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
    t.string "invoice_number"
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_invoices_on_clinic_id"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["issued_on"], name: "index_invoices_on_issued_on"
    t.index ["patient_id"], name: "index_invoices_on_patient_id"
    t.index ["treatment_record_id"], name: "index_invoices_on_treatment_record_id", unique: true
    t.index ["updated_at"], name: "index_invoices_on_updated_at"
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
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_notifications_on_clinic_id"
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
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_patient_consents_on_clinic_id"
    t.index ["patient_id", "consent_type", "consented_at"], name: "idx_patient_consents_lookup"
    t.index ["patient_id"], name: "index_patient_consents_on_patient_id"
    t.index ["user_id"], name: "index_patient_consents_on_user_id"
  end

  create_table "patient_links", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "user_id", null: false
    t.integer "clinic_id", null: false
    t.datetime "claimed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clinic_id", "user_id"], name: "index_patient_links_on_clinic_id_and_user_id"
    t.index ["clinic_id"], name: "index_patient_links_on_clinic_id"
    t.index ["patient_id", "user_id"], name: "index_patient_links_on_patient_id_and_user_id", unique: true
    t.index ["patient_id"], name: "index_patient_links_on_patient_id"
    t.index ["user_id"], name: "index_patient_links_on_user_id"
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
    t.integer "clinic_id", null: false
    t.string "claim_code", null: false
    t.datetime "claimed_at"
    t.index ["claim_code"], name: "index_patients_on_claim_code", unique: true
    t.index ["clinic_id"], name: "index_patients_on_clinic_id"
    t.index ["last_name", "first_name"], name: "index_patients_on_last_name_and_first_name"
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
    t.text "notes"
    t.integer "recorded_by_user_id"
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_payments_on_clinic_id"
    t.index ["invoice_id", "amount", "paid_on", "method", "reference_code"], name: "index_payments_on_dedup_fields", unique: true
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["recorded_by_user_id"], name: "index_payments_on_recorded_by_user_id"
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
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_prescriptions_on_clinic_id"
    t.index ["document_template_id"], name: "index_prescriptions_on_document_template_id"
    t.index ["drafted_by_user_id"], name: "index_prescriptions_on_drafted_by_user_id"
    t.index ["patient_id", "issued_on"], name: "index_prescriptions_on_patient_id_and_issued_on"
    t.index ["patient_id"], name: "index_prescriptions_on_patient_id"
    t.index ["signed_by_user_id"], name: "index_prescriptions_on_signed_by_user_id"
    t.index ["status"], name: "index_prescriptions_on_status"
  end

  create_table "queue_entries", force: :cascade do |t|
    t.integer "appointment_id"
    t.integer "patient_id", null: false
    t.string "queue_type", default: "scheduled", null: false
    t.integer "priority_level", default: 0, null: false
    t.string "status", default: "waiting", null: false
    t.datetime "arrived_at"
    t.datetime "called_at"
    t.datetime "served_at"
    t.integer "position", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clinic_id", null: false
    t.index ["appointment_id", "status"], name: "idx_queue_entries_active_appointment", unique: true, where: "status IN ('waiting','called')"
    t.index ["appointment_id"], name: "index_queue_entries_on_appointment_id"
    t.index ["clinic_id"], name: "index_queue_entries_on_clinic_id"
    t.index ["patient_id"], name: "index_queue_entries_on_patient_id"
    t.index ["status", "priority_level", "arrived_at"], name: "idx_queue_entries_dispatch_order"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.integer "role", null: false
    t.json "permissions", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clinic_id", null: false
    t.index ["clinic_id", "role"], name: "index_role_permissions_on_clinic_id_and_role", unique: true
    t.index ["clinic_id"], name: "index_role_permissions_on_clinic_id"
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
    t.integer "clinic_id", null: false
    t.index ["appointment_id"], name: "index_treatment_records_on_appointment_id"
    t.index ["clinic_id"], name: "index_treatment_records_on_clinic_id"
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
    t.json "permissions", default: {}, null: false
    t.integer "clinic_id", null: false
    t.index ["clinic_id"], name: "index_users_on_clinic_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "access_logs", "clinics"
  add_foreign_key "access_logs", "users"
  add_foreign_key "account_memberships", "accounts"
  add_foreign_key "account_memberships", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_access_tokens", "users"
  add_foreign_key "api_access_tokens", "users", column: "impersonated_by_user_id"
  add_foreign_key "appointments", "appointments", column: "rescheduled_from_appointment_id"
  add_foreign_key "appointments", "clinic_services"
  add_foreign_key "appointments", "clinics"
  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "users"
  add_foreign_key "appointments", "users", column: "preferred_user_id"
  add_foreign_key "audit_logs", "clinics"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "clinic_closures", "clinics"
  add_foreign_key "clinic_memberships", "clinics"
  add_foreign_key "clinic_memberships", "users"
  add_foreign_key "clinic_schedules", "clinics"
  add_foreign_key "clinic_services", "clinics"
  add_foreign_key "clinic_settings", "clinics"
  add_foreign_key "clinics", "accounts"
  add_foreign_key "dental_chart_entries", "clinics"
  add_foreign_key "dental_chart_entries", "patients"
  add_foreign_key "dental_chart_entries", "users"
  add_foreign_key "dentist_schedule_overrides", "clinics"
  add_foreign_key "dentist_schedule_overrides", "users"
  add_foreign_key "dentist_schedules", "clinics"
  add_foreign_key "dentist_schedules", "users"
  add_foreign_key "document_templates", "clinics"
  add_foreign_key "intake_form_submissions", "clinics"
  add_foreign_key "intake_form_submissions", "patients"
  add_foreign_key "intake_form_submissions", "users", column: "submitted_by_user_id"
  add_foreign_key "intraoral_scans", "clinics"
  add_foreign_key "intraoral_scans", "patients"
  add_foreign_key "intraoral_scans", "users"
  add_foreign_key "invoices", "clinics"
  add_foreign_key "invoices", "patients"
  add_foreign_key "invoices", "treatment_records"
  add_foreign_key "notifications", "clinics"
  add_foreign_key "notifications", "patients"
  add_foreign_key "patient_consents", "clinics"
  add_foreign_key "patient_consents", "patients"
  add_foreign_key "patient_consents", "users"
  add_foreign_key "patient_links", "clinics"
  add_foreign_key "patient_links", "patients"
  add_foreign_key "patient_links", "users"
  add_foreign_key "patients", "clinics"
  add_foreign_key "patients", "users"
  add_foreign_key "payments", "clinics"
  add_foreign_key "payments", "invoices"
  add_foreign_key "prescriptions", "clinics"
  add_foreign_key "prescriptions", "document_templates"
  add_foreign_key "prescriptions", "patients"
  add_foreign_key "prescriptions", "users", column: "drafted_by_user_id"
  add_foreign_key "prescriptions", "users", column: "signed_by_user_id"
  add_foreign_key "queue_entries", "appointments"
  add_foreign_key "queue_entries", "clinics"
  add_foreign_key "queue_entries", "patients"
  add_foreign_key "role_permissions", "clinics"
  add_foreign_key "treatment_records", "appointments"
  add_foreign_key "treatment_records", "clinics"
  add_foreign_key "treatment_records", "patients"
  add_foreign_key "treatment_records", "users"
  add_foreign_key "users", "clinics"
end
