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
- Support full multi-tenant SaaS ownership:
  - purchaser/subscriber account can own one or more clinics
  - clinic owners can administer multiple clinics under the same account
  - staff access remains scoped per clinic
  - system admins retain global application access
  - system admins use a platform map view focused on accounts, owners, clinics, users, and subscriptions instead of the normal clinic operations dashboard
  - system admins can add new platform clients, update subscription windows, and impersonate clinic owners for support/review
  - clinic feature navigation is hidden from normal system-admin mode and becomes available only while impersonating a clinic owner
  - sidebar menus are role-specific:
    - system admin sees platform administration only
    - clinic owner/client admin sees client administration and clinic configuration menus
    - clinic personnel see clinic operations menus based on role
    - patient users see patient portal menus only
- Support free patient self-service:
  - patients can register/login without purchasing a subscription
  - clinics can create patient records with claim codes
  - patients can claim clinic-created records using their unique code
  - claimed patient records are exposed through the patient portal only to linked patient users

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
- API CORS middleware enabled (`rack-cors`) for cross-platform client access.
- CI/CD workflow in `.github/workflows/ci.yml` (security scans, lint, tests).

### Domain Models Implemented
- `Account` for SaaS purchaser/subscriber ownership.
- `AccountMembership` for account-level ownership/admin access.
- `Clinic` as a tenant workspace owned by an account.
- `ClinicMembership` for per-clinic staff access.
- `User` with role enum:
  - `clinic_owner`, `dentist`, `receptionist`, `billing_staff`, `patient`, `system_admin`
- `Patient`
- `PatientLink` for connecting free patient portal users to clinic patient records.
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
- Dashboard now includes a rendered monthly calendar grid (Sun-Sat) with:
  - day-level appointment counts
  - preview of upcoming appointments per date
  - previous/next month navigation bound to the rendered grid
  - click-through day cells that open appointments index filtered to the selected date
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
  - patient directory page rebuilt with KPI cards, a patient search function directly under the cards, and a structured patient table/list below
  - patient search is live (per-character with debounce), updates in the background via Turbo Frame (no full page refresh), and auto-resyncs to the latest typed query to avoid stale result flashes from overlapping requests
  - patient search uses case-insensitive contains matching across patient name, email, contact number, emergency contact name, and emergency contact number
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
- API base controller now enforces JSON request format for consistent client behavior.
- API tenant context supports `X-Clinic-ID` and rejects inaccessible clinic IDs with `403` instead of silently falling back.
- System admins can access all accounts and clinics.
- Clinic/account users are constrained to their accessible clinics.
- Patient users are constrained to linked patient records and do not require a paid subscription.
- CORS policy configured in `config/initializers/cors.rb` with `API_CORS_ORIGINS`.
- JSON CRUD patterns ready for external client integration.

### Multi-Tenant SaaS Ownership Implemented
- Added account-level SaaS ownership above clinics:
  - `accounts` stores purchaser/subscriber identity and subscription metadata.
  - `accounts.subscription_starts_on` and `accounts.subscription_ends_on` store subscription windows for system-admin review.
  - `clinics.account_id` links every clinic to its owning account.
  - `account_memberships` links users to purchaser accounts.
  - `clinic_memberships` remains the operational access control layer for individual clinics.
- Subscription readiness:
  - account-level `subscription_plan`, `subscription_status`, `trial_ends_on`, `suspended_at`, `plan_limits`, and `feature_flags` are available.
  - existing clinic-level subscription fields are retained for backward compatibility during transition.
- Access model:
  - `system_admin` can access all accounts and all clinics.
  - `system_admin` has a dedicated platform overview API and frontend page for whole-application mapping.
  - `clinic_owner` can administer clinics under their accessible account/clinic memberships.
  - staff users remain scoped to their assigned clinic memberships.
  - invalid clinic context selection is rejected by API authorization.
- Frontend integration:
  - Next.js clinic context proxy validates clinic access through Rails before setting the clinic context cookie.
  - API requests continue to pass the selected clinic through `X-Clinic-ID`.
  - System-admin login lands on `/platform`, showing account owners, clinics, assigned users, and subscription start/end dates.
  - System-admin sidebar shows only platform administration in normal mode.
  - Impersonation swaps the active API token into a short-lived clinic-owner token and stores the original system-admin token for a one-click return to `/platform`.
  - Clinic menus and clinic features are displayed only in impersonated clinic-owner mode, not under the raw system-admin identity.
  - Role-specific sidebar behavior separates system admin, client admin, dentist, receptionist, billing staff, and patient portal navigation.
  - Platform actions support:
    - creating a new client account with owner and first physical clinic
    - updating account subscription status/start/end
    - impersonating a clinic owner to inspect clinic functionality

### Patient Self-Service Implemented
- Added patient claim infrastructure:
  - `patients.claim_code` is unique and generated automatically.
  - `patients.claimed_at` records first successful claim.
  - `patient_links` connects one patient portal user to one or more clinic patient records.
- Added API endpoints:
  - `POST /api/v1/patient_registration` creates a free patient portal login and returns an API token.
  - `POST /api/v1/patient_claim` lets a patient user claim a clinic record by claim code.
  - `GET /api/v1/patient_portal` returns linked patient records, appointments, invoices, and notifications.
  - `PATCH /api/v1/clinic_context` validates and switches clinic context for authenticated users.
- Clinic-created patient records can be claimed later by code.
- Existing `patients.user_id` is retained as a legacy primary link, while `patient_links` supports a patient login linked to multiple clinic records.

### Hotwire + Tailwind + API Multiplatform Compatibility (Updated)
- Browser frontend:
  - Rails views with Turbo navigation/updates and Stimulus behavior hooks.
  - TailwindCSS as the styling system for responsive layouts and components.
  - shared turbo `flash` frame pattern for app-wide notices and alerts.
  - shared `form_errors` partial applied across all CRUD form partials for consistent validation UX.
  - Stimulus-based flash auto-dismiss controller for less manual UI state handling.
  - explicit `format.turbo_stream` CRUD branches in major web controllers (create/update/destroy).
  - dashboard calendar to appointments day-filter flow implemented via query parameter (`/appointments?date=YYYY-MM-DD`).
- Multiplatform frontend clients:
  - Native mobile, SPA, or desktop clients consume the same `/api/v1` resources.
  - Bearer-token API auth for platform-independent integration.
  - CORS-enabled API edge for browser-based clients from approved origins.
- Routing split:
  - Public experience at `/` and `/login`.
  - Authenticated dashboard at `/dashboard`.
  - API surface isolated under `/api/v1`.

### Functional Data and Demo Readiness
- Expanded `db/seeds.rb` with functional sample data:
  - role-based users with credentials
  - account-level SaaS ownership with one demo account owning multiple clinics
  - multi-clinic memberships for the demo owner and staff
  - patient claim codes and a linked patient portal user
  - services catalog
  - document templates for prescription and dental certificate
  - realistic patients, appointments, treatment records, invoices, payments, and notifications
- Seed data now respects dentist availability constraints to avoid booking conflicts.
- Seed output prints a sample patient claim code for testing patient self-service.

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

### Clinical Workflow Enhancements (May 7, 2026)
- Implemented operational flow support from intake through treatment documentation:
  - patient profiles can be created/updated by patient-facing and clinic-side workflows
  - assistant and dentist can both document chairside findings
- Added structured charting module:
  - `DentalChartEntry` with patient/user linkage
  - per-entry date, tooth code, chart type, and notes
  - chart history displayed on patient profile for continuity of care
- Added prescription lifecycle module:
  - `Prescription` model linked to patient and optional prescription template
  - status workflow: `draft` -> `finalized` -> `signed`
  - draft/finalize available to assistant/dentist/admin roles
  - digital signing restricted to dentist/admin roles
  - digital signature capture includes signer identity and timestamp snapshot
- Added prescription document template layout support:
  - prescription templates render with clinic header, optional logo, prescription information fields, Rx body watermark, signature area, and automatic clinic footer
  - template placeholders support patient, diagnosis, doctor, clinic, medication, dosage, duration, instructions, and follow-up data
  - document template preview and print output use realistic sample data and the same prescription-sheet structure used for clinic review

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
  - Prescription and dental certificate templates implemented
  - Prescription templates support logo/header/footer setup, patient information placeholders, Rx body layout, preview, and print output
- Security:
  - Session login + role checks
  - API bearer token auth
  - Encrypted sensitive patient fields at rest

### Remaining Planned Extensions (Post-MVP)
- Payment-provider integration for account-level subscription billing.
- Clinic/staff invitation emails and acceptance lifecycle.
- Patient claim-code delivery workflow via email/SMS.
- Patient portal frontend screens for registration, claim-code entry, and multi-clinic record selection.
- Full patient portal and advanced charting.
- Automated messaging integrations (email/SMS provider adapters).

## How to Run
- Install gems: `bundle install`
- Latest install run (May 6, 2026):
  - completed successfully with 25 dependencies and 125 gems installed
  - non-blocking warning observed for ambiguous `psych` specs; optional maintenance command: `gem cleanup psych`
- Setup DB: `bin/rails db:setup`
- Run app: `bin/dev` or `bin/rails server`
  - `bin/dev` now runs `bin/rails assets:clobber` and `bin/rails assets:precompile` before starting Foreman.
- Run tests: `bin/rails test`
- API clients create revocable user-scoped bearer tokens with `POST /api/v1/session`.
- API auth header: `Authorization: Bearer <api_access_token>`
