# Dentivara

## Frontend and API Update (May 6, 2026)

### Conversion Direction

- Web frontend stack is standardized on Hotwire + TailwindCSS.
- External clients (mobile/web/desktop) should integrate through `/api/v1` JSON APIs.
- Public pages (home/login) and authenticated app shell are separated for clearer multiplatform flows.

### Implemented in This Update

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
- `GET /appointments?date=YYYY-MM-DD` -> filtered day view within appointments index

## Multiplatform API Access

- Base path: `/api/v1`
- Auth header: `Authorization: Bearer <API_V1_TOKEN>`
- CORS origins: `API_CORS_ORIGINS` (default `*`)
