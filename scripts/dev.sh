#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Minion — Tek komutla dev ortamı başlatma
#  Kullanım: ./scripts/dev.sh
# ─────────────────────────────────────────────────────────────
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "🚀 Minion dev ortamı başlatılıyor..."
echo ""

# 1. Docker servisleri
cd "$ROOT"
docker compose up -d
echo "✅  PostgreSQL  → localhost:5433"
echo "✅  MailHog     → smtp://localhost:1025  |  http://localhost:8025"
echo ""

# 2. Backend — yeni Terminal sekmesinde
echo "▶  Backend başlatılıyor → http://localhost:5131"
osascript 2>/dev/null <<EOF
tell application "Terminal"
  do script "cd '$ROOT/backend' && dotnet run --project src/Minion.Api"
end tell
EOF
echo ""

# 3. Flutter Web — yeni Terminal sekmesinde
echo "▶  Flutter web başlatılıyor → http://localhost:8101"
osascript 2>/dev/null <<EOF
tell application "Terminal"
  do script "cd '$ROOT/frontend/minion_app' && flutter run -d chrome --web-port=8101 --dart-define=API_URL=http://localhost:5131/api"
end tell
EOF

echo ""
echo "────────────────────────────────────────"
echo "  Minion servis adresleri:"
echo "  API      → http://localhost:5131"
echo "  Swagger  → http://localhost:5131/swagger"
echo "  Flutter  → http://localhost:8101"
echo "  MailHog  → http://localhost:8025"
echo "────────────────────────────────────────"
