# Dentivara Specifications and Implementation

## Source Documents Reviewed
- `DESIGN.md`
- `dental_clinic_management_system_brainstorm.md`

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

### Key Business Rules Implemented
- Appointment validations for source/type/status and time ordering.
- Invoice status list including draft/approval/partial/paid/refund states.
- Payment hooks recompute invoice balance and status (`paid` / `partially_paid`).
- Notification channel/category/status validations.

### UI and Mobile Readiness
- Dashboard root page with operational summary cards and tables.
- Dashboard schedule calendar for the current month with per-day appointment lists (time, status, patient, assigned dentist).
- SaaS-style application shell with sidebar navigation and mobile fallback header.
- Tailwind utility classes used for responsive layout, cards, tables, and navigation.
- Brand-aligned visual styling mapped from provided design guidance.
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
