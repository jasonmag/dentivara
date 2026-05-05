# Dentivara Specifications and Implementation

## Source Documents Reviewed
- `DESIGN.md`
- `dental_clinic_management_system_brainstorm.md`
- `docs/stitch_buttermilk_blue_dental_palette/clinic_dashboard/code.html`
- `docs/stitch_buttermilk_blue_dental_palette_srene_dental/stitch_buttermilk_blue_dental_palette/serene_dental/DESIGN.md`
- `docs/stitch_buttermilk_blue_dental_palette_srene_dental/stitch_buttermilk_blue_dental_palette/clinic_dashboard_serene/code.html`
- `docs/stitch_buttermilk_blue_dental_palette_srene_dental/stitch_buttermilk_blue_dental_palette/patient_management_serene/code.html`
- `docs/stitch_buttermilk_blue_dental_palette_srene_dental/stitch_buttermilk_blue_dental_palette/booking_scheduling_serene/code.html`
- `docs/stitch_buttermilk_blue_dental_palette_srene_dental/stitch_buttermilk_blue_dental_palette/billing_revenue_serene/code.html`

## Consolidated Requirements

### Product Scope
- Build a scalable dental clinic management system.
- MVP modules:
  - Patient Profile
  - Booking Calendar
  - Treatment History
  - Billing
  - Basic Notifications
  - Role-Based Access

### Clinical and Operations Domain
- Patient profile must support personal and emergency contact data and medical/dental history.
- Appointment module must support booking sources and booking types with schedule/status tracking.
- Treatment records must capture date, dentist, service type, notes, and cost.
- Billing must support invoice lifecycle statuses, balance tracking, and partial payments.
- Notifications must support reminders and status by channel.

### Security, Compliance, and SaaS Readiness
- Implement RBAC roles.
- Keep API-ready architecture for integration.
- Maintain audit/compliance-compatible structure through explicit workflow state fields.
- Add session-based login and role-aware access controls for web workflows.
- Added field-level encryption for sensitive patient data at rest (medical and emergency contact data).

### UX and Design System
- Mobile-ready responsive pages.
- Use warm-professional palette and Manrope typography.
- Clean cards, soft borders/shadows, rounded elements, readable tables/forms.
- Hotwire-enabled Rails interactions.

## Implemented in This Repo

### Stack and Foundations
- Ruby on Rails 8 app initialized.
- Hotwire enabled (`turbo-rails`, `stimulus-rails`).
- TailwindCSS integrated (`tailwindcss-rails`) and applied to app shell/dashboard views.
- Versioned API namespace: `/api/v1`.
- CI/CD workflow in `.github/workflows/ci.yml` (security scans, lint, tests).

### Domain Models Implemented
- `User` with role enum:
  - `clinic_owner`, `dentist`, `receptionist`, `billing_staff`, `patient`, `system_admin`
- `Patient`
- `Appointment`
- `TreatmentRecord`
- `Invoice`
- `Payment`
- `Notification`
- `ClinicService`
- `DocumentTemplate` (prescription/certificate/other with digital signature fields)

### Key Business Rules Implemented
- Appointment validations for source/type/status and time ordering.
- Appointment overlap validation prevents double-booking of the same dentist.
- Invoice status list including draft/approval/partial/paid/refund states.
- Payment hooks recompute invoice balance and status (`paid` / `partially_paid`).
- Notification channel/category/status validations.
- Async notification dispatch job for email/SMS/in-app pathways (email wired via mailer).

### UI and Mobile Readiness
- Dashboard root page with operational summary cards and tables.
- Dashboard schedule calendar for the current month with per-day appointment lists (time, status, patient, assigned dentist).
- SaaS-style application shell with sidebar navigation and mobile fallback header.
- Tailwind utility classes used for responsive layout, cards, tables, and navigation.
- Brand-aligned visual styling mapped from provided design guidance.
- Implemented Stitch-based dashboard structure from `docs/stitch_buttermilk_blue_dental_palette/clinic_dashboard/code.html`, adapted to Rails data:
  - left rail with icon navigation and primary CTA
  - quick stats cards
  - schedule table with appointment status chips
  - pending billing right rail
  - insight and demographics cards
- Refreshed UI to the latest Stitch **Serene Dental** pack and applied across modules:
  - global shell rethemed to serene palette with serif headlines (`Noto Serif`) + Manrope body text
  - dashboard updated to serene schedule + financial snapshot presentation
  - patient directory page rebuilt with KPI cards and structured patient table
  - booking/scheduling page rebuilt as weekly schedule with daily grouped appointments
  - billing/revenue page rebuilt with financial KPIs and richer invoice status table
  - payment ledger page aligned to billing visual language
- Completed full CRUD consistency pass across all modules:
  - rebuilt all `new/edit/show` screens with consistent serene headers, cards, and action buttons
  - standardized all forms with reusable field styling, validation blocks, and better select inputs
  - standardized all record detail partials into uniform key-value cards
  - converted remaining list pages (`users`, `notifications`, `treatment_records`) to table-based serene layouts
  - improved controller index loading for these modules with ordering and relation includes
- Added CRUD module UI for:
  - Clinic Services configuration
  - Document Templates (including preview rendering for prescription and dental certificate templates)
- Standardized professional CRUD experience across modules:
  - consistent page headers and action buttons
  - card-based detail views
  - structured forms with improved readability
  - cleaner record presentation for clinical workflows

### API Readiness (SaaS Integration Layer)
- API controllers implemented for:
  - patients
  - appointments
  - treatment_records
  - invoices
  - payments
  - notifications
- Token-based API guard in `Api::V1::BaseController` using bearer auth.
- JSON CRUD patterns ready for external client integration.

### Functional Data and Demo Readiness
- Expanded `db/seeds.rb` with functional sample data:
  - role-based users with credentials
  - services catalog
  - document templates for prescription and dental certificate
  - realistic patients, appointments, treatment records, invoices, payments, and notifications
- Seed data now respects dentist availability constraints to avoid booking conflicts.

### Phase 2 Extensions Implemented
- Patient portal baseline:
  - dedicated portal namespace routes and controllers
  - portal dashboard for patient-facing appointments, billing, notifications
  - patient self-service online intake form submission flow
- Online form capture:
  - `IntakeFormSubmission` model stores structured intake payload and source/status
  - supports online / walk-in / concierge sources
- Advanced scheduling support:
  - appointment `operatory` field added for room/chair allocation
  - dentist overlap validation retained and applied with richer seeded schedules
- Security and governance improvements:
  - session authentication with password-based login (`has_secure_password`)
  - sensitive patient fields encrypted at rest
  - `AuditLog` model and `Auditable` concern implemented for create/update/destroy trails
- Clinic configuration and document operations:
  - services module and document template module (prescription/certificate/other) fully wired
  - preview rendering for document templates with dynamic placeholders and signature metadata

### Phase 3 Compliance and Governance Implemented
- Immutable-style audit trail:
  - `AuditLog` chain fields (`event_hash`, `previous_hash`) added
  - hash chaining is generated per event for tamper-evident sequencing
  - admin audit log UI with CSV export endpoint
- Consent versioning:
  - `PatientConsent` model added with consent type, document version, timestamp, and metadata
  - consent capture UI embedded in patient detail view
- Access-review logging:
  - `AccessLog` model added for sensitive resource access events
  - access tracking hooks added for patient, treatment record, and invoice view actions
- Retention controls:
  - `data_retention:cleanup` rake task added
  - configurable retention windows via environment vars:
    - `ACCESS_LOG_RETENTION_DAYS` (default 365)
    - `AUDIT_LOG_RETENTION_DAYS` (default 2555)
- Compliance dashboard:
  - admin-only compliance overview page with:
    - consent coverage metrics
    - recent sensitive-access events
    - recent audit events
    - audit chain integrity check summary
    - direct audit CSV export and retention task guidance

### Implemented Against Requested Scope
- Patient Management:
  - Booking sources include online/social/phone/SMS/walk-in/admin
  - Booking types include scheduled/walk-in/emergency/call waiting/follow-up
  - Availability-aware scheduling guard implemented (provider overlap prevention)
  - Patient profile includes basic and medical history data
  - Treatment records include date, cost, dentist, service type, notes
  - Clinical file attachments enabled via Active Storage for photos/files/charting artifacts
- Notifications:
  - Reminder/billing notification records with channel support
  - Email dispatch pipeline implemented via mailer/job for patient notifications
- Clinic Configuration:
  - Services Available module implemented
  - Prescription and dental certificate templates with digital signature metadata implemented
- Security:
  - Session login + role checks
  - API bearer token auth
  - Encrypted sensitive patient fields at rest

### Remaining Planned Extensions (Post-MVP)
- Full authentication + tenant scoping.
- Advanced audit log trail.
- File attachments and imaging modules.
- Full patient portal and advanced charting.
- Automated messaging integrations (email/SMS provider adapters).

## How to Run
- Install gems: `bundle install`
- Setup DB: `bin/rails db:setup`
- Run app: `bin/dev` or `bin/rails server`
  - `bin/dev` now runs `bin/rails assets:clobber` and `bin/rails assets:precompile` before starting Foreman.
- Run tests: `bin/rails test`
- API auth header: `Authorization: Bearer <API_V1_TOKEN>`
