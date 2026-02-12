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

# Create local workspace (mounted as ~/.openclaw in the container)
echo "[1/7] Creating local workspace directory..."
mkdir -p ./local_workspace/workspace/skills
mkdir -p ./local_workspace/workspace/logs

# Copy template files to local workspace
echo "[2/7] Copying template files to local workspace..."
cp templates/SOUL.md ./local_workspace/workspace/
cp templates/HEARTBEAT.md ./local_workspace/workspace/
cp templates/SECURITY.md ./local_workspace/workspace/
cp templates/MEMORY.md ./local_workspace/workspace/
cp templates/applications_tracker.csv ./local_workspace/workspace/
cp templates/cv_latest.md ./local_workspace/workspace/
cp templates/openclaw.json ./local_workspace/
touch ./local_workspace/workspace/sent_emails.log

# Create .env for local testing if it doesn't exist
if [ ! -f "./local_workspace/workspace/.env" ]; then
    echo "[3/7] Creating local .env file..."
    cp templates/.env.example ./local_workspace/workspace/.env
    echo ""
    echo "⚠️  IMPORTANT: Edit ./local_workspace/workspace/.env with your API keys and email settings"
    echo "   Required:"
    echo "   - ANTHROPIC_API_KEY or OPENAI_API_KEY"
    echo "   - SMTP settings (if you want email notifications)"
    echo "   - NOTIFICATION_EMAIL (where to send job alerts)"
    echo ""
else
    echo "[3/7] Using existing ./local_workspace/workspace/.env"
fi

# Ensure local_workspace is writable by the container's node user (UID 1000)
chown -R 1000:1000 ./local_workspace

# Create local docker-compose with workspace mounted
echo "[4/7] Setting up Docker Compose configuration..."
if [ ! -f "./docker/docker-compose.local.yml" ]; then
    echo "❌ Error: docker/docker-compose.local.yml not found"
    echo "This file should have been created. Please check your project structure."
    exit 1
fi

# Clone OpenClaw repository locally (if not already cloned)
if [ ! -d "./openclaw" ]; then
    echo "[5/7] Cloning OpenClaw repository..."
    git clone https://github.com/openclaw/openclaw.git
else
    echo "[5/7] OpenClaw repository already exists, pulling latest changes..."
    git -C ./openclaw pull
fi

# Build the Docker image
echo "[6/7] Building OpenClaw Docker image (this may take a few minutes on first run)..."
docker build -t openclaw:local -f ./openclaw/Dockerfile ./openclaw

# Generate or reuse gateway token
PROJECT_ENV="./.env"
if [ -f "$PROJECT_ENV" ] && grep -q '^OPENCLAW_GATEWAY_TOKEN=' "$PROJECT_ENV"; then
    OPENCLAW_GATEWAY_TOKEN="$(grep '^OPENCLAW_GATEWAY_TOKEN=' "$PROJECT_ENV" | cut -d= -f2-)"
    TOKEN_SOURCE="existing (.env)"
else
    OPENCLAW_GATEWAY_TOKEN="$(openssl rand -hex 32 2>/dev/null || python3 -c 'import secrets; print(secrets.token_hex(32))')"
    echo "OPENCLAW_GATEWAY_TOKEN=$OPENCLAW_GATEWAY_TOKEN" >> "$PROJECT_ENV"
    TOKEN_SOURCE="newly generated (saved to .env)"
fi
export OPENCLAW_GATEWAY_TOKEN

# Start OpenClaw locally
echo "[7/7] Starting OpenClaw in local mode..."
docker compose -f docker/docker-compose.local.yml up -d

echo ""
echo "================================================"
echo "✅ OpenClaw is running locally!"
echo "================================================"
echo ""
echo "Dashboard: http://localhost:18789"
echo "Gateway token ($TOKEN_SOURCE): $OPENCLAW_GATEWAY_TOKEN"
echo "Workspace: ./local_workspace/workspace/"
echo ""
echo "Next steps:"
echo "1. Edit ./local_workspace/workspace/.env with your API keys"
echo "2. Edit ./local_workspace/workspace/cv_latest.md with your CV"
echo "3. Customize ./local_workspace/workspace/SOUL.md if needed"
echo "4. Restart to apply changes: docker compose -f docker/docker-compose.local.yml restart"
echo ""
echo "View logs: docker compose -f docker/docker-compose.local.yml logs -f"
echo "Stop: docker compose -f docker/docker-compose.local.yml down"
echo ""
echo "⚠️  Remember: This is LOCAL testing only. No VPS is provisioned."
echo "================================================"
