# Dentivara

## Frontend and API Update (May 6, 2026)

### Conversion Direction

- Web frontend stack is standardized on Hotwire + TailwindCSS.
- External clients (mobile/web/desktop) should integrate through `/api/v1` JSON APIs.
- Public pages (home/login) and authenticated app shell are separated for clearer multiplatform flows.

### Implemented in This Update

- Implemented clinic workflow-aligned patient care features:
  - structured dental chart entries per patient with:
    - tooth code
    - chart entry type (exam/diagnosis/procedure/periodontal/restorative/notes)
    - notes
    - optional marked dental chart image upload (assistant/dentist annotated image)
    - in-browser annotation canvas (mouse/touch drawing) that saves the marked chart image to patient records
    - default preloaded chart image for direct annotation when no upload is provided
    - localized default chart asset (`app/assets/images/default_odontogram.png`) to avoid cross-origin canvas save issues
    - annotation tools: brush color picker, brush size, eraser, and clear
    - recorded date
    - recorded-by user traceability
  - prescription workflow per patient:
    - `draft` creation by assistant/dentist roles
    - `finalized` state before signature
    - `signed` state with digital signature metadata (`signed_by_user`, `signed_at`, signature snapshot)
  - patient page now includes:
    - dental charting section with add-entry form and history table
    - prescriptions section with quick create/list/view actions
- Expanded patient profile capture for dental clinic workflows:
  - charting notes (`dental_chart`)
  - chief complaint
  - allergies, medications, and relevant medical conditions
  - last dental visit date
  - preferred contact method
  - address fields
  - insurance provider and policy number
- Added CORS support for API routes via `rack-cors`.
- Added API CORS initializer at `config/initializers/cors.rb`.
- API requests under `/api/*` now force JSON format in `Api::V1::BaseController`.
- Added environment-driven origin configuration:
  - `API_CORS_ORIGINS=*` for dev
  - Comma-separated origins for staging/production
- Added shared Hotwire flash frame rendering:
  - `app/views/shared/_flash.html.erb`
  - turbo frame `flash` in main layout for both public and authenticated shells
- Added Stimulus flash auto-dismiss controller:
  - `app/javascript/controllers/flash_controller.js`
- Standardized all CRUD form validation blocks into shared partial:
  - `app/views/shared/_form_errors.html.erb`
  - applied to appointments, clinic services, document templates, invoices, notifications, patients, payments, treatment records, and users
- Added explicit `format.turbo_stream` branches for CRUD lifecycle responses in controllers:
  - appointments, clinic services, document templates, invoices, notifications, patients, payments, treatment records, and users

### Bundle Install Notes (May 6, 2026)

- `bundle install` completed successfully:
  - `Bundle complete! 25 Gemfile dependencies, 125 gems now installed.`
- Warning observed:
  - unresolved or ambiguous `psych` specs during `Gem::Specification.reset`
  - this did not block dependency resolution
- Optional cleanup command if needed later:
  - `gem cleanup psych`

### UI Flow Update

- Public Home page is now at `/` with:
  - Login call-to-action link
  - Product/news highlights about the app
- Login page at `/login` is now standalone:
  - No sidebar menus
  - Refined card-based styling
- Authenticated Dashboard moved to `/dashboard`:
  - Sidebar and app shell are shown only after login
  - Monthly calendar grid is now rendered using month data from the dashboard controller
  - `Prev` / `Next` month controls now visibly update the displayed month grid
  - Each calendar day is clickable and links to filtered appointments day view

## Routes

- `GET /` -> `home#index` (public landing page)
- `GET /login` -> `sessions#new` (standalone login page)
- `POST /login` -> `sessions#create`
- `DELETE /logout` -> `sessions#destroy`
- `GET /dashboard` -> `home#dashboard` (authenticated app dashboard)
- `GET /patients` -> `patients#index` (patient directory)
  - Search: `GET /patients?search=<name_or_keyword>` -> filtered patient results
- `GET /users` -> `users#index` (settings user management)
  - Search: `GET /users?search=<name_or_email_or_role>` -> filtered users list in Settings
- `GET /appointments?date=YYYY-MM-DD` -> filtered day view within appointments index
- `POST /patients/:patient_id/dental_chart_entries` -> add patient chart entry (assistant/dentist/admin roles)
- `GET /patients/:patient_id/prescriptions` -> list patient prescriptions
- `GET /patients/:patient_id/prescriptions/new` -> create prescription draft
- `POST /patients/:patient_id/prescriptions` -> save prescription draft
- `PATCH /patients/:patient_id/prescriptions/:id/finalize` -> finalize draft
- `PATCH /patients/:patient_id/prescriptions/:id/sign` -> digitally sign finalized prescription (dentist/admin roles)

## Multiplatform API Access

- Base path: `/api/v1`
- Create session/token: `POST /api/v1/session`
  - body: `{ "session": { "email": "user@example.com", "password": "password", "device_name": "Next.js server" } }`
  - response includes a one-time bearer token, expiry, and user permissions.
- Revoke current token: `DELETE /api/v1/session`
- Auth header for protected endpoints: `Authorization: Bearer <api_access_token>`
- Legacy shared-token auth via `API_V1_TOKEN` is accepted in development/test. In staging/production it requires `API_V1_LEGACY_TOKEN_ENABLED=true`; user-scoped `ApiAccessToken` records are preferred.
- List responses use `{ "data": [...], "meta": { "pagination": ... } }`.
- Resource responses use `{ "data": { ... } }`.
- Error responses use `{ "error": { "code": "...", "message": "...", "details": ... } }`.
- Common list params: `page`, `per_page` (max 100), plus resource filters such as `search`, `patient_id`, `status`, date ranges, and invoice/payment filters.
- CORS origins: `API_CORS_ORIGINS` (default `*`; set explicit Next.js/mobile gateway origins in staging/production).
