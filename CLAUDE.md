# OpenClaw Job Search Agent - Terraform Deployment

Automated deployment of OpenClaw as a fully autonomous job search agent for mental health and SEN roles, powered by Terraform and Hostinger VPS.

## Overview

This project provisions a production-ready OpenClaw instance configured as **JobSeeker Lobster v4.0** - an autonomous agent that:

- 🔍 Searches job boards every 6 hours (LinkedIn, Indeed, NHS Jobs, charity sites)
- 🎯 Filters opportunities with 80%+ match threshold
- 📊 Tracks applications in CSV format
- 📧 Sends email digests for high-fit roles
- 🔒 Privacy-first: notification-only email mode, no personal inbox access
- 🚫 Never auto-applies - user maintains full control

### Target Role Focus

Entry-level positions in:
- Mental health support
- Special educational needs (SEN)
- Therapy assistant roles (art, occupational, play, talking therapies)
- Healthcare assistant (mental health)
- Youth support work
- Rehabilitation assistance

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Hostinger VPS (KVM 2: 2 vCPU, 8GB RAM, 100GB NVMe)    │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────┐    │
│ │ OpenClaw Container                               │    │
│ │ - Dashboard (port 18789)                        │    │
│ │ - Gateway                                       │    │
│ └─────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─────────────────────────────────────────────────┐    │
│ │ Workspace (/root/workspace/)                    │    │
│ │ - SOUL.md (agent personality)                   │    │
│ │ - HEARTBEAT.md (autonomous schedule)            │    │
│ │ - applications_tracker.csv                      │    │
│ │ - cv_latest.md                                  │    │
│ │ - SECURITY.md (tool policies)                   │    │
│ └─────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─────────────────────────────────────────────────┐    │
│ │ Watchtower (auto-updates daily)                 │    │
│ └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Hostinger VPS Account**
   - Sign up: https://hostinger.com/vps-hosting
   - Generate API token: Account Settings → API Access

2. **Terraform** (>= 1.10)
   ```bash
   brew install terraform  # macOS
   # or download from https://terraform.io/downloads
   ```

3. **SSH Key Pair**
   ```bash
   ssh-keygen -t ed25519 -C "openclaw-vps" -f ~/.ssh/openclaw_vps
   ```

4. **LLM API Key** (at least one required)
   - Anthropic Claude: https://console.anthropic.com/
   - OpenAI: https://platform.openai.com/

5. **SMTP Email** (for sending notifications)
   - Gmail App Password: https://myaccount.google.com/apppasswords (lobsterjob32@gmail.com)
   - Or any SMTP provider

## Quick Start

### Option 1: Local Testing (No Cloud Deployment)

Test the agent locally before deploying to VPS:

```bash
# 1. Run local test setup
./scripts/local-test.sh

# 2. Edit configuration
nano local_workspace/.env          # Add API keys
nano local_workspace/cv_latest.md  # Add your CV

# 3. Access dashboard
open http://localhost:18789

# 4. View logs
docker compose -f docker/docker-compose.local.yml logs -f

# 5. Stop when done
docker compose -f docker/docker-compose.local.yml down
```

### Option 2: Deploy to Hostinger VPS

```bash
# 1. Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Add your values

# 2. Initialize Terraform
terraform init

# 3. Review deployment plan
terraform plan

# 4. Deploy!
terraform apply

# 5. SSH into VPS (output provides command)
ssh root@<VPS_IP>

# 6. Customize configuration on VPS
nano /root/workspace/cv_latest.md  # Add your CV
nano /root/workspace/SOUL.md       # Customize preferences

# 7. Restart to apply changes
docker compose restart gateway
```

## Configuration

### Required Variables (terraform.tfvars)

```hcl
# Hostinger API
hostinger_api_token = "your_hostinger_api_token"

# SSH Access
ssh_public_key = "ssh-ed25519 AAAA... your_key_here"

# User Configuration
user_email = "notifications@example.com"  # Dedicated email for job alerts
user_full_name = "Your Name"

# LLM Provider (choose at least one)
anthropic_api_key = "sk-ant-..."
# OR
openai_api_key = "sk-..."

# SMTP Configuration (for email digests)
smtp_host = "smtp.gmail.com"
smtp_port = 587
smtp_user = "your_email@gmail.com"
smtp_password = "your_app_password"
smtp_from = "jobseeker@yourdomain.com"
```

### Optional Variables

```hcl
# VPS Configuration
data_center_id = "eu-central"  # us-west, asia-singapore, etc.
hostname = "openclaw-jobseeker"

# Job Search Preferences
target_location = "Central London"
target_roles = "Mental Health Support Worker,SEN Support Assistant,Therapy Assistant"
min_salary = "£22000"
max_commute_minutes = 60

# Messaging (optional)
telegram_bot_token = "..."
telegram_chat_id = "..."
```

## Project Structure

```
claw_job_bot/
├── main.tf                    # Main Terraform resources
├── variables.tf               # Input variables
├── outputs.tf                 # Outputs (IP, URLs, SSH command)
├── versions.tf                # Provider versions
├── terraform.tfvars.example   # Example configuration
├── .gitignore                 # Protect secrets
│
├── scripts/
│   ├── post-install.sh        # VPS bootstrap script
│   └── local-test.sh          # Local testing script
│
├── templates/
│   ├── SOUL.md                # Agent personality
│   ├── HEARTBEAT.md           # Autonomous schedule
│   ├── SECURITY.md            # Tool policies
│   ├── applications_tracker.csv
│   ├── cv_latest.md
│   ├── MEMORY.md
│   └── .env.example
│
└── docker/
    └── docker-compose.local.yml
```

## Agent Configuration Files

### SOUL.md - Agent Personality
Defines JobSeeker Lobster's mission, target roles, search parameters, and safety rules.

**Customize:**
- Target job categories
- Location preferences
- Salary requirements
- Search frequency

**Location:** `/root/workspace/SOUL.md` (VPS) or `local_workspace/SOUL.md` (local)

### HEARTBEAT.md - Autonomous Schedule
Configures when and how often the agent runs job searches.

**Default Schedule:**
- Every 6 hours: Job board search
- Daily 3am: Maintenance tasks
- Weekly Monday 8am: Deep analysis

**Location:** `/root/workspace/HEARTBEAT.md`

### SECURITY.md - Tool Policies
Defines which actions require approval vs. autonomous execution.

**Key Policies:**
- ✅ Allowed: Web scraping (read-only), workspace file access
- ⚠️ Approval Required: Email sending (first 5), external APIs
- 🚫 Never: Auto-apply, personal inbox access, PHI access

**Location:** `/root/workspace/SECURITY.md`

## Usage

### Monitor Job Search Activity

```bash
# SSH into VPS
ssh root@<VPS_IP>

# View OpenClaw logs
docker compose logs -f

# Check sent email log
tail -f /root/workspace/sent_emails.log

# Review agent memory
cat /root/workspace/MEMORY.md

# Check job tracker
cat /root/workspace/applications_tracker.csv
```

### Access Dashboard

```bash
# Open in browser
http://<VPS_IP>:18789
```

### Customize CV

```bash
# Edit CV on VPS
nano /root/workspace/cv_latest.md

# Or locally
nano local_workspace/cv_latest.md

# Restart to reload
docker compose restart gateway
```

### Adjust Search Parameters

```bash
# Edit agent personality
nano /root/workspace/SOUL.md

# Edit schedule
nano /root/workspace/HEARTBEAT.md

# Restart gateway
docker compose restart gateway
```

## Security & Privacy

### Privacy Protections
- ✅ **Notification email only** - Agent cannot access your personal inbox
- ✅ **No PHI access** - Health information never exposed
- ✅ **No auto-apply** - User maintains full control
- ✅ **Workspace isolation** - Agent confined to `/root/workspace/`
- ✅ **Approval-based email** - First 5 emails require confirmation

### Email Sending Workflow
1. Agent finds high-fit jobs (80%+ match)
2. Compiles digest email
3. **First 5 emails:** Requests approval in dashboard
4. User approves/denies
5. Email sent to notification address
6. After 5 approvals: Autonomous (within daily limit of 10)

### Monitoring
- All email sends logged: `sent_emails.log`
- All actions logged: `MEMORY.md`
- Dashboard access: `http://<VPS_IP>:18789`

## Troubleshooting

### OpenClaw not starting
```bash
# Check Docker status
docker compose ps

# View logs
docker compose logs -f

# Restart containers
docker compose restart
```

### Email notifications not sending
```bash
# Verify SMTP credentials in .env
cat /root/openclaw/.env | grep SMTP

# Test SMTP manually
curl -v --ssl-reqd \
  --url 'smtp://smtp.gmail.com:587' \
  --user 'your_email@gmail.com:your_app_password' \
  --mail-from 'your_email@gmail.com' \
  --mail-rcpt 'test@example.com' \
  --upload-file - <<< "Subject: Test"
```

### Job searches not running
```bash
# Check HEARTBEAT.md configuration
cat /root/workspace/HEARTBEAT.md

# Verify agent is active
docker compose logs gateway | grep -i "job search"

# Restart gateway
docker compose restart gateway
```

### API rate limits
```bash
# Check API key validity
cat /root/openclaw/.env | grep API_KEY

# Review error logs
docker compose logs gateway | grep -i "error"

# Adjust search frequency in HEARTBEAT.md
nano /root/workspace/HEARTBEAT.md
```

## Maintenance

### Update OpenClaw

Watchtower automatically updates containers daily. To update manually:

```bash
docker compose pull
docker compose up -d
```

### Backup Configuration

```bash
# Backup workspace
tar -czf workspace_backup_$(date +%Y%m%d).tar.gz /root/workspace/

# Download to local machine
scp root@<VPS_IP>:~/workspace_backup_*.tar.gz ./backups/
```

### Destroy Infrastructure

```bash
# WARNING: This deletes the VPS and all data
terraform destroy
```

## Cost Estimate

**Hostinger VPS KVM 2:**
- 2 vCPU, 8GB RAM, 100GB NVMe
- ~$12-15/month

**LLM API Costs:**
- Anthropic Claude: ~$0.01-0.05/day (depends on search volume)
- OpenAI GPT-4: ~$0.02-0.10/day

**Total:** ~$15-20/month for fully autonomous job search agent

## Support

- OpenClaw Docs: https://github.com/openclaw/openclaw
- Hostinger Support: https://hostinger.com/support
- Terraform Docs: https://terraform.io/docs

## License

This Terraform configuration is provided as-is. OpenClaw is licensed under its respective license.

---

**Built by InfraLobster** 🦞 | Powered by OpenClaw & Terraform
