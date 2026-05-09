# Dentivara AWS Deployment (Kamal)

This guide deploys Dentivara to AWS EC2 using Kamal.

## 1. Prerequisites

1. Local machine:
- Ruby/Bundler installed
- Docker installed and running
- SSH key available

2. AWS:
- EC2 Ubuntu server (recommended: Ubuntu 22.04+)
- Elastic IP or stable public IP
- Domain DNS (A record) pointing to server IP (for SSL)

3. Repo setup:
- `config/deploy.yml` configured
- `.kamal/secrets` created locally (do not commit)

## 2. EC2 Security Group

Allow inbound:
- `22` (SSH) from your IP
- `80` (HTTP) from `0.0.0.0/0`
- `443` (HTTPS) from `0.0.0.0/0`

## 3. Prepare Server

SSH into EC2:

```bash
ssh ubuntu@<EC2_PUBLIC_IP>
```

Install Docker:

```bash
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
```

Log out and reconnect after group change:

```bash
exit
ssh ubuntu@<EC2_PUBLIC_IP>
docker ps
```

## 4. Configure `config/deploy.yml`

Update these fields in [`config/deploy.yml`](../config/deploy.yml):

1. `servers.web`:
- replace with EC2 host/IP (or SSH host alias)

2. `proxy.host`:
- set to your domain (example: `app.example.com`)

3. `registry`:
- set correct registry username/server/password secret key

4. `ssh.user`:
- use `ubuntu` (or your EC2 user)

## 5. Configure Kamal Secrets

Create/edit `.kamal/secrets`:

```bash
KAMAL_REGISTRY_PASSWORD=...
RAILS_MASTER_KEY=...
API_V1_TOKEN=...
ADMIN_EMAIL=admin@yourclinic.com
ADMIN_PASSWORD=YourStrongPass123!
ADMIN_NAME=System Admin
```

Notes:
- `API_V1_TOKEN` is required for `/api/v1` auth in production.
- `ADMIN_EMAIL` + `ADMIN_PASSWORD` bootstrap the system admin via `admin:bootstrap`.

## 6. First Deploy

From project root:

```bash
bin/kamal setup
bin/kamal deploy
```

If setup already ran:

```bash
bin/kamal deploy
```

## 7. Post-Deploy Checks

1. App health:

```bash
curl -I https://<your-domain>/up
```

2. API auth behavior:

```bash
curl -i https://<your-domain>/api/v1/patients
curl -i -H "Authorization: Bearer <API_V1_TOKEN>" https://<your-domain>/api/v1/patients
```

Expected:
- first call: `401 Unauthorized`
- second call: `200 OK`

3. Confirm admin bootstrap:

```bash
bin/kamal app exec --reuse "bin/rails admin:bootstrap"
```

## 8. Useful Kamal Commands

Logs:

```bash
bin/kamal app logs -f
```

Rails console:

```bash
bin/kamal app exec --interactive --reuse "bin/rails console"
```

Shell in container:

```bash
bin/kamal app exec --interactive --reuse "bash"
```

Run migrations manually:

```bash
bin/kamal app exec --reuse "bin/rails db:migrate"
```

## 9. Common Issues

1. `API_V1_TOKEN must be set in production`
- ensure `API_V1_TOKEN` exists in `.kamal/secrets`
- redeploy

2. Docker build permission errors for `bin/rails`
- ensure executable bit:
```bash
chmod +x bin/rails bin/rake bin/dev
```

3. SSL cert not issuing
- verify domain A record points to EC2 public IP
- ensure port `80/443` open

## 10. Recommended Production Improvements

1. Move Active Storage from local volume to S3.
2. Add automated backups for DB and uploads.
3. Add monitoring/alerts (CPU, memory, container restarts, app errors).
4. Rotate `API_V1_TOKEN` and registry credentials periodically.

## 11. Initial Resources and Estimated Spend

These are practical starting points for Dentivara on AWS Lightsail.

### Option A: Lightsail VM (recommended for this repo today)

Current app setup uses:
- Kamal + Docker
- SQLite
- local volume (`/rails/storage`)

So the fastest path is a single Lightsail Linux instance.

Suggested initial size:
- **4 GB RAM plan (~$24/month)** for better Rails/Docker headroom
- You can start at **2 GB (~$12/month)** for low traffic, but it is tighter

Expected monthly spend (starter):
1. Lightsail instance:
- $12 to $24
2. Snapshot backups:
- typically ~$1 to $5 (depends on disk usage; snapshots are billed by stored GB)
3. Data transfer overage:
- $0 if within included transfer
- overage starts around $0.09/GB (region-dependent)

Typical total starter range:
- **~$15 to $35/month**

Safer baseline for clinic production:
- **~$25 to $60/month** (4 GB instance + snapshots + small overage buffer)

### Option B: Lightsail Containers

If you prefer managed container service:
- starts around $7/month (nano)
- practical baseline often $10 to $15/month per node
- each container service includes 500 GB monthly transfer quota

### When to scale up

Upgrade from 2 GB -> 4 GB or 8 GB when:
- memory pressure/restarts appear
- average response time climbs during clinic hours
- background jobs (notifications/reports) start queuing heavily

Move to EC2 + RDS + S3 when:
- multi-branch/multi-tenant growth starts
- higher compliance/backup requirements are needed
- you need managed database durability and easier horizontal scaling

## 12. SMS Notification Cost (PHP)

Estimated SMS cost depends on provider and route quality. For planning, use:

- **$0.01 to $0.05 USD per SMS**
- Approx conversion baseline: **1 USD ≈ PHP 56**
- Equivalent: **PHP 0.56 to PHP 2.80 per SMS**

### Monthly formula

Monthly SMS Cost (PHP) =
- `patients_reminded_per_month x sms_per_patient x cost_per_sms_php`

### Example budgets (PHP)

1. 500 reminders/month
- at PHP 1.12/SMS (~$0.02): **PHP 560/month**

2. 1,500 reminders/month
- at PHP 1.12/SMS (~$0.02): **PHP 1,680/month**

3. 3,000 reminders/month
- at PHP 1.68/SMS (~$0.03): **PHP 5,040/month**

### Practical planning range

- Small clinic: **PHP 560 to PHP 2,240 / month**
- Mid-size clinic: **PHP 2,240 to PHP 6,720 / month**

### Notes

1. Real cost depends on destination carrier, sender type, and provider pricing tier.
2. Some providers may require sender registration or add regulatory pass-through fees.
3. Re-check FX rate and provider price sheet before final budgeting.
