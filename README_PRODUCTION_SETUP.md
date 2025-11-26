## Production Environment Setup

Follow these steps to deploy MenuMate QR safely in production.

### 1. Provision infrastructure
- **Database**: PostgreSQL 14+ (primary) plus optional dedicated databases for cache, queue, and cable. Create each database and grant a dedicated user with `CREATE`, `CONNECT`, and `TEMP` privileges.
- **Object storage** (recommended): Amazon S3 bucket with versioning and default encryption (SSE-S3 or SSE-KMS).
- **Email provider**: e.g., AWS SES, SendGrid, Mailgun.
- **Secrets management**: store the Rails master key and other secrets in a secure vault (1Password, AWS Secrets Manager, etc.).

### 2. Configure environment variables
1. Copy the sample file and fill in real values:
   ```bash
   cp env.example .env
   ```
2. Export the variables via your process manager (systemd, Docker, Kamal, etc.) so they are available before the app boots.
3. Never commit `.env` with real secrets.

> **Key values**  
> - `DATABASE_URL` (and optional `CACHE/QUEUE/CABLE_DATABASE_URL`)  
> - `APP_HOST`, `APP_PROTOCOL`, `ALLOWED_HOSTS`  
> - `RAILS_MASTER_KEY` (used to decrypt `config/credentials.yml.enc`)  
> - `ACTIVE_STORAGE_SERVICE` + AWS credentials (if using S3)  
> - SMTP credentials, Stripe/OpenAI keys, etc.

### 3. Install dependencies
```bash
bundle config set --local without "development test"
bundle install
```

### 4. Prepare the database
```bash
RAILS_ENV=production bundle exec rails db:prepare
```
This command runs pending migrations and creates the schema if needed.

### 5. Precompile assets
```bash
RAILS_ENV=production bundle exec rails assets:precompile
```

### 6. Run the application
- Puma reads `RAILS_MAX_THREADS`, `WEB_CONCURRENCY`, and `PORT`.
- Set `SOLID_QUEUE_IN_PUMA=1` for single-host deployments to run Solid Queue inside Puma.
- Behind a reverse proxy/ALB, terminate TLS at the proxy and forward `X-Forwarded-Proto` so Rails honors SSL redirects.

### 7. Security checklist
- Ensure `FORCE_SSL=true` to enforce HTTPS and secure cookies.
- Restrict hosts via `ALLOWED_HOSTS`.
- Rotate `SECRET_KEY_BASE`, database passwords, and API keys regularly.
- Enable CloudFront/WAF or another CDN/edge firewall for additional protection.

### 8. Backups and monitoring
- Schedule PostgreSQL base backups + WAL archiving.
- Enable S3 bucket versioning or lifecycle policies.
- Ship logs to a centralized system (CloudWatch, ELK, etc.) for auditing.
- Monitor key metrics: request rate, queue depth, Active Record connection usage, and disk/memory pressure.

With these settings, the repository is production-ready: PostgreSQL is required, secrets are loaded via environment variables, and SSL/host protections are enforced by default. Customize the sample env file for each environment (staging, production, etc.).

