# ─────────────────────────────────────────────────────────────
#  Minion — Dev Port Haritası
#  PostgreSQL : localhost:5433
#  Backend    : http://localhost:5131  (HTTPS: 7222)
#  Flutter Web: http://localhost:8101
#  MailHog    : smtp://localhost:1025  Web: http://localhost:8025
# ─────────────────────────────────────────────────────────────
.PHONY: start stop backend flutter flutter-web logs ps clean help

start: ## Docker servislerini başlat (PostgreSQL + MailHog)
	docker compose up -d
	@echo ""
	@echo "✅  PostgreSQL  → localhost:5433"
	@echo "✅  MailHog     → smtp://localhost:1025  |  http://localhost:8025"

stop: ## Docker servislerini durdur
	docker compose down

backend: ## Backend'i başlat → http://localhost:5131
	cd backend && dotnet run --project src/Minion.Api

flutter-web: ## Flutter web'i başlat → http://localhost:8101
	cd frontend/minion_app && flutter run -d chrome \
		--web-port=8101 \
		--dart-define=API_URL=http://localhost:5131/api

flutter: ## Flutter mobil (emulator/device)
	cd frontend/minion_app && flutter run

logs: ## Docker log'larını takip et
	docker compose logs -f

ps: ## Çalışan container'ları göster
	docker compose ps

clean: ## Container'ları ve volume'ları sil
	docker compose down -v

help: ## Bu yardım mesajını göster
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
