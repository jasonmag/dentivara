# Dentivara SaaS Readiness and Roadmap

Dentivara is currently a **single-clinic dental management system with SaaS-ready foundations**. It is not yet a full SaaS product because it does not yet include multi-tenant isolation, subscription billing, clinic onboarding, and platform administration.

## Current Status

Dentivara already has several SaaS-friendly foundations:

- Web-based application
- User login and roles
- Role-based permissions
- API namespace under `/api/v1`
- Docker/Kamal deployment support
- Clinic settings
- Patient management
- Appointment scheduling
- Billing and payments
- Queue board
- Audit/compliance foundations
- Production deployment documentation

These make the product a strong base for a future SaaS version, but more work is needed before selling it as a multi-clinic SaaS platform.

## Required Features to Become a SaaS Product

## 1. Multi-Tenant Architecture

Required:

- Add `Clinic` or `Organization` model
- Add `clinic_id` / `tenant_id` to core tables:
  - users
  - patients
  - appointments
  - treatment records
  - invoices
  - payments
  - services
  - settings
  - audit logs
  - notifications
- Enforce tenant scoping in all queries
- Prevent cross-clinic data access
- Add tenant-aware authorization rules

Why it matters:

Without tenant isolation, one clinic's data can mix with another clinic's data. This is the biggest blocker to becoming SaaS.

## 2. Clinic Onboarding

Required:

- Clinic signup flow
- Create clinic account
- Create first clinic owner/admin
- Configure default clinic settings
- Optional onboarding checklist
- Sample service catalog setup
- Invite staff members

Recommended:

- Guided setup wizard:
  - clinic profile
  - operating hours
  - dentists
  - services/pricing
  - billing currency
  - notification preferences

## 3. Subscription Billing

Required:

- Subscription plans
- Plan limits
- Payment provider integration
- Trial period support
- Billing portal
- Invoice/receipt for SaaS subscription charges
- Failed-payment handling
- Subscription status:
  - trialing
  - active
  - past_due
  - cancelled
  - suspended

Possible providers:

- Stripe
- Paddle
- PayMongo
- Xendit

## 4. Plan Limits and Feature Flags

Required:

- Define feature plans:
  - Starter
  - Clinic
  - Pro
  - Enterprise
- Enforce limits:
  - users per clinic
  - dentists per clinic
  - patients per clinic
  - storage usage
  - SMS volume
  - branch count
- Feature flags:
  - patient portal
  - advanced reports
  - SMS integration
  - insurance claims
  - multi-branch support

## 5. Platform Admin Console

Required:

- Super admin dashboard
- List all clinics
- View clinic subscription status
- Suspend/reactivate clinic
- Impersonation with audit logging
- Usage monitoring
- Support tools
- Billing issue visibility

Why it matters:

A SaaS operator needs a way to manage customers, resolve support issues, and monitor usage.

## 6. Multi-Branch Support

Required for larger clinics:

- Branch model
- Branch-specific staff
- Branch-specific schedules
- Branch-specific rooms/chairs
- Branch-specific billing/currency if needed
- Branch-level reports

Important distinction:

- Multi-tenant = multiple clinic customers
- Multi-branch = one clinic customer with multiple locations

## 7. Tenant-Aware Security and Compliance

Required:

- Tenant-scoped audit logs
- Tenant-scoped access logs
- Tenant-scoped file storage paths
- Per-clinic data export
- Per-clinic data deletion/anonymization
- Data retention policies per clinic
- Support for Data Privacy Act workflows

Recommended:

- MFA for clinic admins
- Strong password policies
- Session timeout
- Device/session management
- IP allowlist for enterprise plans

## 8. Production File Storage

Required:

- Move Active Storage from local disk to S3 or compatible object storage
- Tenant-aware storage paths
- Private file access
- Signed URLs
- Backup and lifecycle rules
- Malware scanning for uploads

Why it matters:

Patient files, payment proofs, prescriptions, and dental chart images need durable and private storage.

## 9. Background Jobs and Messaging Infrastructure

Required:

- Dedicated job worker process
- Queue monitoring
- Retry policies
- Failed job dashboard
- SMS/email delivery tracking

Recommended:

- Separate web and worker containers
- Provider webhooks for SMS/email delivery status

## 10. Monitoring, Backups, and Reliability

Required:

- Error monitoring
- Uptime monitoring
- Database backups
- File storage backups
- Restore process
- Health checks
- Resource usage dashboards

Recommended:

- Incident response playbook
- Backup restore drills
- RTO/RPO targets

## 11. Public Marketing and Sales Pages

Required for commercial SaaS:

- Landing page
- Pricing page
- Signup CTA
- Terms of service
- Privacy policy
- Data processing policy
- Contact/support page

## 12. Customer Support Operations

Required:

- Support email or ticketing system
- Clinic account support workflow
- Admin activity logs
- Support access audit trail
- FAQ/help center

## Suggested SaaS Roadmap

## Phase 1: SaaS Foundation

- Add `Clinic` model
- Add tenant scoping to all core records
- Add clinic onboarding
- Add clinic owner role scoping
- Add tenant-safe authorization

## Phase 2: Subscription and Plans

- Add subscription plans
- Add payment provider
- Add plan limits
- Add feature flags
- Add billing portal

## Phase 3: Platform Operations

- Add platform admin console
- Add usage dashboard
- Add clinic suspension/reactivation
- Add support tools
- Add support impersonation with audit logs

## Phase 4: SaaS Production Hardening

- Move files to S3
- Add backup/restore automation
- Add error monitoring
- Add worker separation
- Add SMS/email provider webhooks
- Add compliance export/delete workflows

## Phase 5: Growth Features

- Multi-branch support
- Advanced reports
- Patient self-booking
- Online payments
- Insurance claims
- Enterprise security controls

## Readiness Verdict

Current state:

- MVP clinic app: **yes**
- Production single-clinic app: **partially, with hardening**
- SaaS-ready foundation: **yes**
- Full SaaS product: **not yet**

Recommended label today:

> Dentivara is a single-clinic dental management platform with SaaS-ready foundations.

Recommended label after tenant/subscription work:

> Dentivara is a multi-tenant SaaS dental clinic management platform.
