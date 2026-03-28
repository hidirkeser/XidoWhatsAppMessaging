#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Minion — Hetzner Server First-Time Setup
# Run once as root on a fresh Ubuntu 24.04 server:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/YOUR_REPO/main/deploy/setup-server.sh | bash
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

DEPLOY_DIR=/opt/minion
DEPLOY_USER=deploy

echo "═══════════════════════════════════════"
echo "  Minion Server Setup"
echo "═══════════════════════════════════════"

# ── System updates ────────────────────────────────────────────────────────────
apt-get update -qq && apt-get upgrade -y -qq

# ── Docker CE ─────────────────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
fi

# ── Docker Compose plugin ─────────────────────────────────────────────────────
if ! docker compose version &>/dev/null; then
    apt-get install -y docker-compose-plugin
fi

# ── Firewall (UFW) ────────────────────────────────────────────────────────────
apt-get install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP (redirect to HTTPS)
ufw allow 443/tcp   # HTTPS
ufw --force enable
echo "Firewall configured."

# ── Deploy user ───────────────────────────────────────────────────────────────
if ! id -u $DEPLOY_USER &>/dev/null; then
    useradd -m -s /bin/bash $DEPLOY_USER
    usermod -aG docker $DEPLOY_USER
    echo "Created user: $DEPLOY_USER"
fi

# ── App directory ─────────────────────────────────────────────────────────────
mkdir -p $DEPLOY_DIR/nginx
mkdir -p $DEPLOY_DIR/certs       # Place BankID .pfx here
chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR

# ── Auto-renew SSL certs (Let's Encrypt) ──────────────────────────────────────
(crontab -l 2>/dev/null; echo "0 3 * * * cd $DEPLOY_DIR && docker compose -f docker-compose.prod.yml --profile certbot run --rm certbot && docker compose -f docker-compose.prod.yml exec nginx nginx -s reload") | crontab -

echo ""
echo "═══════════════════════════════════════"
echo "  Setup complete! Next steps:"
echo ""
echo "  1. Upload files to $DEPLOY_DIR:"
echo "     scp deploy/docker-compose.prod.yml $DEPLOY_USER@SERVER:$DEPLOY_DIR/"
echo "     scp deploy/nginx/default.conf      $DEPLOY_USER@SERVER:$DEPLOY_DIR/nginx/"
echo "     scp your_bankid.pfx                $DEPLOY_USER@SERVER:$DEPLOY_DIR/certs/bankid.pfx"
echo ""
echo "  2. Create the .env file:"
echo "     cp deploy/.env.example $DEPLOY_DIR/.env"
echo "     nano $DEPLOY_DIR/.env   # fill in real values"
echo ""
echo "  3. Update nginx/default.conf — replace REPLACE_WITH_YOUR_DOMAIN"
echo ""
echo "  4. Issue SSL certificate (first time only):"
echo "     cd $DEPLOY_DIR"
echo "     docker compose -f docker-compose.prod.yml up -d nginx"
echo "     docker compose -f docker-compose.prod.yml --profile certbot run --rm certbot"
echo "     docker compose -f docker-compose.prod.yml restart nginx"
echo ""
echo "  5. Start everything:"
echo "     docker compose -f docker-compose.prod.yml up -d"
echo ""
echo "  6. Add GitHub secrets (repo → Settings → Secrets → Actions):"
echo "     HETZNER_HOST        = <server IP>"
echo "     HETZNER_USER        = deploy"
echo "     HETZNER_SSH_KEY     = <private SSH key>"
echo "     GHCR_TOKEN          = <GitHub PAT with read:packages>"
echo "═══════════════════════════════════════"
