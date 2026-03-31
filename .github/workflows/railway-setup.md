# Railway CI/CD Setup Guide

## 1. Railway Projesi Oluştur

1. [railway.app](https://railway.app) → **New Project**
2. **Deploy from GitHub repo** → `hidirkeser/XidoWhatsAppMessaging` seç
3. Her environment için ayrı service oluştur:
   - **production** (main branch)
   - **staging** (staging branch)
   - **dev** (dev branch)

## 2. PostgreSQL Ekle

Her environment'ta:
- **+ New Service** → **Database** → **PostgreSQL**
- Railway otomatik `DATABASE_URL` environment variable'ı inject eder

## 3. Environment Variables (Railway Dashboard → Variables)

Her service için şu değişkenleri ekle:

```
# Database (Railway otomatik ekler)
DATABASE_URL=<Railway PostgreSQL bağlantı string>

# JWT
JWT_SECRET=<openssl rand -base64 64 ile üret>

# App
APP_BASE_URL=https://<railway-domain>.railway.app

# BankID
BANKID_BASE_URL=https://appapi2.test.bankid.com/rp/v6.0/
BANKID_CERT_BASE64=<sertifika base64>
BANKID_CERT_PASSWORD=<sertifika şifresi>

# WhatsApp
WHATSAPP_ENABLED=true
AISENSY_API_KEY=<key>
AISENSY_CAMPAIGN_NAME=<campaign>

# Email
EMAIL_ENABLED=true
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=<sendgrid key>
EMAIL_FROM=noreply@yourdomain.com

# Firebase (opsiyonel)
FIREBASE_ENABLED=false
```

## 4. GitHub Secrets Ekle

**Repo → Settings → Secrets → Actions → New repository secret**

| Secret | Değer | Nasıl Bulunur |
|--------|-------|---------------|
| `RAILWAY_TOKEN` | Railway API token | Railway → Account Settings → Tokens |
| `RAILWAY_SERVICE_ID_PROD` | Production service ID | Railway → Service → Settings → Service ID |
| `RAILWAY_SERVICE_ID_STAGING` | Staging service ID | Railway → Service → Settings → Service ID |
| `RAILWAY_SERVICE_ID_DEV` | Dev service ID | Railway → Service → Settings → Service ID |
| `RAILWAY_PROD_URL` | `https://xxx.railway.app` | Railway → Service → Domain |
| `RAILWAY_STAGING_URL` | `https://xxx-staging.railway.app` | Railway → Service → Domain |
| `RAILWAY_DEV_URL` | `https://xxx-dev.railway.app` | Railway → Service → Domain |

## 5. Railway Auto-Deploy'u Kapat

Railway'in kendi otomatik deploy'u ile CI/CD çakışmaması için:

- Railway Dashboard → Service → Settings → **Source** → **Disable GitHub Autodeploy**
- Böylece deploy sadece GitHub Actions tamamlandıktan sonra tetiklenir.

## 6. CI/CD Akışı

```
git push → GitHub Actions
    ├── build-and-test    (dotnet test)
    ├── docker            (GHCR'a image push)
    └── deploy-railway    (railway up → health check)
```

- `main` push → **production** environment'a deploy
- `staging` push → **staging** environment'a deploy
- `dev` push → **dev** environment'a deploy
- PR açıldığında sadece testler çalışır, deploy olmaz
