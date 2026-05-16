# frozen_string_literal: true

require "securerandom"
require "stringio"

load Rails.root.join("db/seeds/subscription_plans.rb")

if Rails.env.in?(%w[production staging])
  user = SystemAdminBootstrap.from_env!

  if user.present?
    puts "System admin bootstrapped from env: #{user.email}"
  else
    puts "Skipped admin bootstrap (set ADMIN_EMAIL and ADMIN_PASSWORD with at least 8 chars)."
  end

  return
end

puts "Seeding Dentivara comprehensive workflow data..."

SEED_PASSWORD = "dentivara123"

demo_clinic = Clinic.default
demo_account = demo_clinic.account
demo_account.update!(
  name: "Dentivara Demo Group",
  billing_email: "owner@dentivara.local",
  subscription_plan: "starter",
  subscription_status: "active",
  subscription_starts_on: Date.current.beginning_of_month,
  subscription_ends_on: 1.year.from_now.to_date
)
Current.clinic = demo_clinic

ClinicSetting.current.update!(time_zone: "Asia/Manila")

# 1x1 transparent PNG for attachment demo records.
SAMPLE_PNG_BASE64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Zl5kAAAAASUVORK5CYII="

def create_or_update_user!(name:, email:, role:)
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(name: name, role: role, clinic: Current.clinic)
  user.password = SEED_PASSWORD
  user.password_confirmation = SEED_PASSWORD
  user.save!
  user
end

def find_or_create_service!(name, description, price, minutes, color)
  service = ClinicService.find_or_initialize_by(name: name)
  service.assign_attributes(
    description: description,
    base_price: price,
    duration_minutes: minutes,
    preparation_minutes: [ 5, (minutes * 0.2).round ].max,
    color: color,
    active: true
  )
  service.save!
  service
end

def attach_sample_png!(record, attachment_name, filename_prefix)
  attachment = record.public_send(attachment_name)
  return if attachment.attached?

  attachment.attach(
    io: StringIO.new(Base64.decode64(SAMPLE_PNG_BASE64)),
    filename: "#{filename_prefix}-#{record.id}.png",
    content_type: "image/png"
  )
end

def seeded_appointment_start(index, visit_number)
  date = Date.current
  remaining_days = index
  while remaining_days.positive?
    date += 1.day
    remaining_days -= 1 unless date.saturday? || date.sunday?
  end
  Time.zone.local(date.year, date.month, date.day, visit_number.zero? ? 9 : 14, 0, 0)
end

users = {
  clinic_owner: create_or_update_user!(name: "Clinic Owner", email: "owner@dentivara.local", role: :clinic_owner),
  dentist_1: create_or_update_user!(name: "Dr. Maria Reyes", email: "dentist1@dentivara.local", role: :dentist),
  dentist_2: create_or_update_user!(name: "Dr. Julian Santos", email: "dentist2@dentivara.local", role: :dentist),
  receptionist: create_or_update_user!(name: "Ana Cruz", email: "reception@dentivara.local", role: :receptionist),
  billing_staff: create_or_update_user!(name: "Paolo Santos", email: "billing@dentivara.local", role: :billing_staff),
  system_admin: create_or_update_user!(name: "System Admin", email: "sysadmin@dentivara.local", role: :system_admin),
  patient_portal: create_or_update_user!(name: "Patient Portal User", email: "patientportal@dentivara.local", role: :patient)
}

users.each_value do |user|
  ClinicMembership.find_or_create_by!(clinic: demo_clinic, user: user) do |membership|
    membership.role = user.role
    membership.accepted_at = Time.current
  end

  next if user.patient?

  AccountMembership.find_or_create_by!(account: demo_account, user: user) do |membership|
    membership.role = user.clinic_owner? || user.system_admin? ? "owner" : "member"
    membership.accepted_at = Time.current
  end
end

satellite_clinic = Clinic.find_or_initialize_by(slug: "dentivara-satellite")
satellite_clinic.assign_attributes(
  account: demo_account,
  name: "Dentivara Satellite Clinic",
  contact_email: "satellite@dentivara.local",
  phone: "+639171234568",
  subscription_plan: "starter",
  subscription_status: "active",
  trial_ends_on: 30.days.from_now.to_date
)
satellite_clinic.save!

[ users[:clinic_owner], users[:dentist_1], users[:receptionist] ].each do |user|
  ClinicMembership.find_or_create_by!(clinic: satellite_clinic, user: user) do |membership|
    membership.role = user.role
    membership.accepted_at = Time.current
  end
end

if (bootstrap_admin = SystemAdminBootstrap.from_env!)
  users[:system_admin] = bootstrap_admin
  puts "System admin bootstrapped from env: #{bootstrap_admin.email}"
end

dentists = [users[:dentist_1], users[:dentist_2]]
clinical_users = [users[:dentist_1], users[:dentist_2], users[:receptionist], users[:clinic_owner], users[:system_admin]]

(1..5).each do |day_of_week|
  schedule = ClinicSchedule.find_or_initialize_by(day_of_week: day_of_week)
  schedule.assign_attributes(
    opens_at: "08:00",
    closes_at: "17:00",
    closed: false,
    emergency_only: false,
    max_concurrent_appointments: 4
  )
  schedule.save!
end

[ 0, 6 ].each do |day_of_week|
  schedule = ClinicSchedule.find_or_initialize_by(day_of_week: day_of_week)
  schedule.assign_attributes(closed: true, emergency_only: true, max_concurrent_appointments: 1)
  schedule.save!
end

dentists.each do |dentist|
  (1..5).each do |day_of_week|
    DentistSchedule.find_or_create_by!(user: dentist, day_of_week: day_of_week, starts_at: "08:30", ends_at: "16:30")
  end
end

services = [
  find_or_create_service!("Routine Checkup", "General oral check and consultation", 1200, 30, "#2a9d8f"),
  find_or_create_service!("Teeth Cleaning", "Full prophylaxis cleaning service", 2500, 45, "#0ea5e9"),
  find_or_create_service!("Root Canal", "Root canal therapy procedure", 12000, 90, "#ef4444"),
  find_or_create_service!("Braces Adjustment", "Orthodontic maintenance adjustment", 1800, 30, "#8b5cf6"),
  find_or_create_service!("Teeth Whitening", "In-clinic whitening treatment", 8500, 60, "#f59e0b"),
  find_or_create_service!("Tooth Extraction", "Simple tooth extraction", 3000, 45, "#64748b"),
  find_or_create_service!("Composite Filling", "Direct composite restoration", 3500, 40, "#22c55e")
]

prescription_template = DocumentTemplate.find_or_initialize_by(name: "Standard Prescription")
prescription_template.assign_attributes(
  kind: "prescription",
  active: true,
  default_for_prescription: true,
  header_text: DocumentTemplate::DEFAULT_PRESCRIPTION_HEADER,
  information_header_text: DocumentTemplate::DEFAULT_PRESCRIPTION_INFORMATION_HEADER,
  body_template: DocumentTemplate::DEFAULT_PRESCRIPTION_BODY,
  footer_text: DocumentTemplate::DEFAULT_PRESCRIPTION_FOOTER,
  digital_signature_name: "Dr. Maria Reyes",
  digital_signature_title: "Licensed Dentist"
)
prescription_template.save!

certificate_template = DocumentTemplate.find_or_initialize_by(name: "Dental Certificate")
certificate_template.assign_attributes(
  kind: "dental_certificate",
  active: true,
  header_text: "Dentivara Dental Clinic\\nDental Certificate",
  body_template: "This certifies that {{patient_name}} was seen on {{today}} for dental evaluation and treatment.",
  footer_text: "For clinic verification only.",
  digital_signature_name: "Dr. Julian Santos",
  digital_signature_title: "Dental Practitioner"
)
certificate_template.save!

first_names = %w[Liam Olivia Noah Emma Sophia James Lucas Mia Ava Ethan Amelia Harper Mason Charlotte Isla Henry Sofia Benjamin Zoe]
last_names = %w[Garcia Reyes Santos Cruz Mendoza Torres Flores Ramos Navarro Bautista]
cities = ["Makati", "Pasig", "Quezon City", "Taguig", "Mandaluyong"]
insurance_providers = ["PhilHealth", "Maxicare", "Intellicare", "Medicard", "Insular Health"]

patients = 30.times.map do |i|
  first = first_names[i % first_names.size]
  last = last_names[(i * 3) % last_names.size]
  email = "patient#{i + 1}@example.com"

  patient = Patient.find_or_initialize_by(email: email)
  patient.assign_attributes(
    first_name: first,
    last_name: last,
    birth_date: Date.new(1980 + (i % 25), ((i % 12) + 1), ((i % 27) + 1)),
    phone: format("09%09d", 100_000_000 + i),
    emergency_contact_name: "#{first} Contact",
    emergency_contact_phone: format("09%09d", 200_000_000 + i),
    medical_history: "Previous restorations. No known severe systemic disease.",
    consented_at: Time.current - (i + 3).days,
    chief_complaint: ["Toothache on chewing", "Bleeding gums", "Sensitivity to cold", "Routine checkup"].sample,
    known_allergies: ["None", "Penicillin", "Latex", "Ibuprofen"].sample,
    current_medications: ["None", "Amlodipine 5mg OD", "Metformin 500mg BID"].sample,
    medical_conditions: ["None", "Hypertension", "Diabetes Mellitus Type 2"].sample,
    last_dental_visit_on: Date.current - rand(20..360).days,
    address_line1: "#{100 + i} Dental Street",
    address_line2: "Barangay #{(i % 12) + 1}",
    city: cities[i % cities.size],
    state: "NCR",
    postal_code: format("1%03d", i),
    preferred_contact_method: %w[phone sms email][i % 3],
    insurance_provider: insurance_providers[i % insurance_providers.size],
    insurance_policy_number: "POL-#{(10_000 + i)}",
    dental_chart: "Baseline notes: monitor molars 16/26; prior fillings 36/46"
  )
  patient.save!
  patient
end

# Link one patient to the seeded portal user. Other patients remain claimable by code.
patients.first.update!(user: users[:patient_portal]) if patients.first.user != users[:patient_portal]
PatientLink.find_or_create_by!(patient: patients.first, user: users[:patient_portal]) do |link|
  link.clinic = patients.first.clinic
  link.claimed_at = Time.current
end

# Appointment, treatment, invoice, payment, and notifications data.
seeded_patient_ids = patients.map(&:id)
seeded_appointments = Appointment.where(patient_id: seeded_patient_ids)
Notification.where(patient_id: seeded_patient_ids).delete_all
seeded_appointments.destroy_all

patients.each_with_index do |patient, i|
  2.times do |j|
    start_at = seeded_appointment_start(i + j + 1, j)
    duration = [30, 45, 60, 90].sample.minutes
    dentist = dentists[(i + j) % dentists.size]

    appointment = Appointment.find_or_initialize_by(patient: patient, starts_at: start_at, user: dentist)
    appointment.assign_attributes(
      clinic_service: services[(i + j) % services.size],
      duration_minutes: (duration / 60).to_i,
      buffer_minutes: 10,
      source: Appointment::BOOKING_SOURCES[(i + j) % Appointment::BOOKING_SOURCES.size],
      booking_type: Appointment::BOOKING_TYPES[(i + j) % Appointment::BOOKING_TYPES.size],
      ends_at: start_at + duration,
      status: j.zero? ? "confirmed" : Appointment::STATUSES[(i + j) % Appointment::STATUSES.size],
      operatory: ["Room A", "Room B", "Chair 1", "Chair 2"][(i + j) % 4],
      notes: "Seeded visit #{j + 1} for continuity care"
    )
    appointment.save!

    treatment = TreatmentRecord.find_or_initialize_by(appointment: appointment)
    treatment.assign_attributes(
      patient: patient,
      user: dentist,
      service_type: services[(i + j) % services.size].name,
      clinical_notes: "Procedure completed, post-op instructions discussed.",
      cost: services[(i + j) % services.size].base_price,
      performed_on: appointment.starts_at.to_date
    )
    treatment.save!
    attach_sample_png!(treatment, :clinical_files, "clinical-file") if treatment.clinical_files.blank?

    total = treatment.cost.to_d
    paid = [0, total / 2, total][(i + j) % 3]
    status = if paid == total
      "paid"
    elsif paid.positive?
      "partially_paid"
    else
      "approved"
    end

    invoice = Invoice.find_or_initialize_by(treatment_record: treatment)
    invoice.assign_attributes(
      patient: patient,
      status: status,
      total_amount: total,
      balance_amount: total - paid,
      issued_on: appointment.starts_at.to_date,
      approved_by_dentist_at: appointment.starts_at,
      approved_by_admin_at: appointment.starts_at + 1.hour
    )
    invoice.save!

    if paid.positive?
      payment = Payment.find_or_initialize_by(invoice: invoice, reference_code: "PAY-#{invoice.id}-#{i}-#{j}")
      payment.assign_attributes(
        amount: paid,
        paid_on: appointment.starts_at.to_date,
        method: %w[cash credit_card bank_transfer][(i + j) % 3]
      )
      payment.save!
    end

    Notification.find_or_create_by!(
      patient: patient,
      source_record: appointment,
      channel: Notification::CHANNELS[(i + j) % Notification::CHANNELS.size],
      category: Notification::CATEGORIES[(i + j) % Notification::CATEGORIES.size],
      status: Notification::STATUSES[(i + j) % Notification::STATUSES.size],
      message: "Reminder for appointment on #{appointment.starts_at.strftime('%b %d, %Y %I:%M %p')}",
      scheduled_for: appointment.starts_at - 12.hours
    )
  end
end

# Intake forms for patient portal flow.
patients.first(8).each do |patient|
  IntakeFormSubmission.find_or_create_by!(
    patient: patient,
    submitted_by_user: patient.user,
    source: IntakeFormSubmission::SOURCES.sample,
    status: IntakeFormSubmission::STATUSES.sample
  ) do |submission|
    submission.payload = {
      "chief_concern" => patient.chief_complaint,
      "allergies" => patient.known_allergies,
      "current_medication" => patient.current_medications,
      "preferred_contact" => patient.preferred_contact_method
    }
  end
end

# Consent history.
patients.first(15).each_with_index do |patient, i|
  PatientConsent::CONSENT_TYPES.each do |consent_type|
    PatientConsent.find_or_create_by!(
      patient: patient,
      user: clinical_users[i % clinical_users.size],
      consent_type: consent_type,
      document_version: "#{consent_type.upcase}-v1.#{i % 3}",
      consented_at: Time.current - (i + 1).days
    ) do |consent|
      consent.metadata = { source: "seed", jurisdiction: "PH Data Privacy Act" }
    end
  end
end

# Dental chart entries with structured surface marks and image attachment.
fdi_upper = %w[18 17 16 15 14 13 12 11 21 22 23 24 25 26 27 28]
fdi_lower = %w[48 47 46 45 44 43 42 41 31 32 33 34 35 36 37 38]
all_teeth = fdi_upper + fdi_lower
surfaces = %w[M O D B L]

patients.first(20).each_with_index do |patient, i|
  2.times do |n|
    marks = 4.times.map do |k|
      {
        "tooth" => all_teeth[(i + n + k) % all_teeth.size],
        "surface" => surfaces[(i + k) % surfaces.size],
        "status" => DentalChartEntry::SURFACE_STATUSES[(i + n + k) % DentalChartEntry::SURFACE_STATUSES.size]
      }
    end

    entry = DentalChartEntry.find_or_initialize_by(
      patient: patient,
      user: clinical_users[(i + n) % clinical_users.size],
      recorded_on: Date.current - (i + n).days,
      tooth_code: marks.first["tooth"],
      entry_type: DentalChartEntry::ENTRY_TYPES[(i + n) % DentalChartEntry::ENTRY_TYPES.size]
    )

    entry.notes = "Chart update: #{marks.map { |m| "#{m['tooth']}-#{m['surface']} #{m['status']}" }.join(', ')}"
    entry.surface_marks = marks
    entry.save!
    attach_sample_png!(entry, :chart_image, "dental-chart")
  end
end

# Prescription lifecycle seeds (draft, finalized, signed).
patients.first(12).each_with_index do |patient, i|
  rendered = prescription_template.render_for(patient: patient, dentist: dentists[i % dentists.size], context: {
    medication: "Amoxicillin 500mg",
    instructions: "Take one capsule every 8 hours for 7 days"
  })
  body = [rendered[:header], rendered[:body], rendered[:footer]].reject(&:blank?).join("\n\n")

  draft = Prescription.find_or_initialize_by(
    patient: patient,
    issued_on: Date.current - (i + 1).days,
    drafted_by_user: users[:receptionist]
  )
  draft.assign_attributes(
    document_template: prescription_template,
    status: "draft",
    body: body,
    signed_by_user: nil,
    signed_at: nil,
    signature_snapshot: nil
  )
  draft.save!

  finalized = Prescription.find_or_initialize_by(
    patient: patient,
    issued_on: Date.current - (i + 2).days,
    drafted_by_user: users[:dentist_1]
  )
  finalized.assign_attributes(
    document_template: prescription_template,
    status: "finalized",
    body: body,
    signed_by_user: nil,
    signed_at: nil,
    signature_snapshot: nil
  )
  finalized.save!

  signed = Prescription.find_or_initialize_by(
    patient: patient,
    issued_on: Date.current - (i + 3).days,
    drafted_by_user: users[:receptionist]
  )
  signed.assign_attributes(
    document_template: prescription_template,
    status: "signed",
    body: body,
    signed_by_user: dentists[i % dentists.size],
    signed_at: Time.current - (i + 3).days,
    signature_snapshot: "Digitally signed by #{dentists[i % dentists.size].name} on #{(Time.current - (i + 3).days).strftime('%Y-%m-%d %H:%M')}"
  )
  signed.save!
end

puts "Seed complete."
puts "Login accounts use password: #{SEED_PASSWORD}"
puts "Demo owner administers clinics: #{demo_account.clinics.order(:name).pluck(:name).join(', ')}"
puts "Patient portal claim code example: #{patients.second.claim_code} (#{patients.second.full_name})"
puts "Includes seeded data for: SaaS account ownership, multi-clinic memberships, RBAC users, patient profiles, patient claim codes, appointments, treatments, billing, notifications, intake forms, consents, dental chart entries (with surface marks + images), and prescription lifecycle states."
