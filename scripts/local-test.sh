#!/bin/bash
set -euo pipefail

echo "================================================"
echo "OpenClaw Job Search Agent - Local Test Setup"
echo "================================================"
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed"
    echo "Please install Docker Desktop: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check for Docker Compose
if ! docker compose version &> /dev/null; then
    echo "❌ Error: Docker Compose is not available"
    echo "Please ensure Docker Compose plugin is installed"
    exit 1
fi

echo "✅ Docker found: $(docker --version)"
echo "✅ Docker Compose found: $(docker compose version)"
echo ""

# Create local workspace
echo "[1/6] Creating local workspace directory..."
mkdir -p ./local_workspace/skills
mkdir -p ./local_workspace/logs

# Copy template files to local workspace
echo "[2/6] Copying template files to local workspace..."
cp templates/SOUL.md ./local_workspace/
cp templates/HEARTBEAT.md ./local_workspace/
cp templates/SECURITY.md ./local_workspace/
cp templates/MEMORY.md ./local_workspace/
cp templates/applications_tracker.csv ./local_workspace/
cp templates/cv_latest.md ./local_workspace/
touch ./local_workspace/sent_emails.log

# Create .env for local testing if it doesn't exist
if [ ! -f "./local_workspace/.env" ]; then
    echo "[3/6] Creating local .env file..."
    cp templates/.env.example ./local_workspace/.env
    echo ""
    echo "⚠️  IMPORTANT: Edit ./local_workspace/.env with your API keys and email settings"
    echo "   Required:"
    echo "   - ANTHROPIC_API_KEY or OPENAI_API_KEY"
    echo "   - SMTP settings (if you want email notifications)"
    echo "   - NOTIFICATION_EMAIL (where to send job alerts)"
    echo ""
else
    echo "[3/6] Using existing ./local_workspace/.env"
fi

# Create local docker-compose with workspace mounted
echo "[4/6] Setting up Docker Compose configuration..."
if [ ! -f "./docker/docker-compose.local.yml" ]; then
    echo "❌ Error: docker/docker-compose.local.yml not found"
    echo "This file should have been created. Please check your project structure."
    exit 1
fi

# Clone OpenClaw repository locally (if not already cloned)
if [ ! -d "./openclaw" ]; then
    echo "[5/6] Cloning OpenClaw repository..."
    git clone https://github.com/openclaw/openclaw.git
else
    echo "[5/6] OpenClaw repository already exists, pulling latest changes..."
    cd openclaw
    git pull
    cd ..
fi

# Start OpenClaw locally
echo "[6/6] Starting OpenClaw in local mode..."
cd openclaw
cp ../local_workspace/.env .env
docker compose -f ../docker/docker-compose.local.yml up -d

echo ""
echo "================================================"
echo "✅ OpenClaw is running locally!"
echo "================================================"
echo ""
echo "Dashboard: http://localhost:18789"
echo "Workspace: ./local_workspace/"
echo ""
echo "Next steps:"
echo "1. Edit ./local_workspace/.env with your API keys"
echo "2. Edit ./local_workspace/cv_latest.md with your CV"
echo "3. Customize ./local_workspace/SOUL.md if needed"
echo "4. Restart to apply changes: docker compose -f docker/docker-compose.local.yml restart"
echo ""
echo "View logs: docker compose -f docker/docker-compose.local.yml logs -f"
echo "Stop: docker compose -f docker/docker-compose.local.yml down"
echo ""
echo "⚠️  Remember: This is LOCAL testing only. No VPS is provisioned."
echo "================================================"
