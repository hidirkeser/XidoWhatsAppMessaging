# Analiz: Dinamik Ürün & Abonelik Sistemi

**Tarih:** 2026-03-31
**Proje:** Minion Website + Backend
**Durum:** Analiz & Planlama

---

## 1. Mevcut Durum

### 1.1 Backend (Hazır Altyapı)

Backend'de ürün ve abonelik sistemi **zaten implement edilmiş durumda**:

| Bileşen | Durum | Konum |
|---------|-------|-------|
| `Product` Entity | Mevcut | `Domain/Entities/Product.cs` |
| `ProductType` Enum | Mevcut | `Individual`, `Corporate` |
| `UserSubscription` Entity | Mevcut | `Domain/Entities/UserSubscription.cs` |
| `ProductsController` (Public) | Mevcut | `GET /api/products` |
| `AdminProductsController` | Mevcut | `CRUD /api/admin/products` |
| `SubscriptionsController` | Mevcut | `GET/POST /api/subscriptions` |
| `CreditPackage` Entity | Mevcut | Kredi paket yönetimi |
| `PaymentTransaction` | Mevcut | Swish, PayPal, Klarna desteği |

**Product Entity Yapısı:**
```csharp
public class Product : BaseEntity
{
    public string Name { get; set; }
    public string? Description { get; set; }
    public ProductType Type { get; set; }      // Individual | Corporate
    public int MonthlyQuota { get; set; }
    public decimal PriceSEK { get; set; }
    public string? Features { get; set; }      // JSON array
    public bool IsActive { get; set; }
    public int SortOrder { get; set; }
}
```

**Admin API Endpoint'leri:**
```
GET    /api/admin/products          → Tüm ürünleri listele
POST   /api/admin/products          → Yeni ürün oluştur
PUT    /api/admin/products/{id}     → Ürün güncelle
DELETE /api/admin/products/{id}     → Ürün sil
PATCH  /api/admin/products/{id}/toggle → Aktif/pasif toggle
```

### 1.2 Website Frontend (Eksik)

Website şu anda **tamamen statik JSON** kullanıyor:

| Sayfa | Kaynak | Sorun |
|-------|--------|-------|
| `/products` | `messages/en.json`, `messages/sv.json` | Hardcoded 3 ürün |
| `/pricing` | `messages/en.json`, `messages/sv.json` | Hardcoded fiyat planları |
| Ana sayfa pricing teaser | `messages/en.json` | Hardcoded 3 kredi paketi |

**Mevcut Data Flow (Statik):**
```
messages/en.json → useTranslations('products') → JSX render
```

**Hedef Data Flow (Dinamik):**
```
Backend API → Next.js Server Component (fetch) → JSX render
               ↓ (fallback)
         messages/en.json (statik metinler: başlık, açıklama vs.)
```

---

## 2. Gereksinimler

### 2.1 Fonksiyonel Gereksinimler

| # | Gereksinim | Öncelik |
|---|-----------|---------|
| FR-1 | Products sayfası backend API'den dinamik çekilmeli | Yüksek |
| FR-2 | Pricing sayfası API planları backend'den çekilmeli | Yüksek |
| FR-3 | Kredi paketleri backend'den çekilmeli | Yüksek |
| FR-4 | Admin panelden ürün CRUD yapılabilmeli | Mevcut |
| FR-5 | Admin panelden kredi paketi CRUD yapılabilmeli | Orta |
| FR-6 | Bireysel/Kurumsal ayrımı desteklenmeli | Mevcut |
| FR-7 | Ürünler çok dilli (en/sv) olmalı | Yüksek |
| FR-8 | Ürün görselleri/ikonları yönetilebilmeli | Orta |
| FR-9 | Ana sayfa pricing teaser dinamik olmalı | Orta |
| FR-10 | SEO meta verileri dinamik ürünlere uyumlu olmalı | Orta |

### 2.2 Teknik Olmayan Gereksinimler

| # | Gereksinim |
|---|-----------|
| NFR-1 | API yanıt süresi < 200ms (ürün listesi) |
| NFR-2 | Website SSR ile ilk yüklemede SEO-uyumlu render |
| NFR-3 | API erişilemez olduğunda fallback mekanizması |
| NFR-4 | Cache stratejisi (ISR veya CDN cache) |
| NFR-5 | Admin değişiklikleri 5 dk içinde website'a yansımalı |

---

## 3. Gap Analizi

### 3.1 Backend Eksikleri

| # | Eksik | Detay | Etki |
|---|-------|-------|------|
| BG-1 | Çok dilli ürün desteği | Product entity'de sadece tek dil var (`Name`, `Description`, `Features`). `NameSv`, `DescriptionSv`, `FeaturesSv` veya ayrı bir `ProductTranslation` tablosu gerekli | Yüksek |
| BG-2 | CreditPackage admin CRUD | `AdminProductsController` mevcut ama `AdminCreditPackagesController` yok | Orta |
| BG-3 | Public product endpoint i18n | `GET /api/products` locale parametresi almıyor | Yüksek |
| BG-4 | Ürün ikon/görsel alanı | Product entity'de icon/image alanı yok | Düşük |
| BG-5 | Ürün kategori alanı | Products sayfasındaki 3 ürün ile Pricing sayfasındaki planlar farklı entity'ler. Website "product" kavramı ile backend "product" (subscription plan) kavramı farklı | Yüksek |

### 3.2 Frontend Eksikleri

| # | Eksik | Detay | Etki |
|---|-------|-------|------|
| FG-1 | API client/service katmanı | Website'da hiç API çağrısı yok, fetch utility yok | Yüksek |
| FG-2 | Products sayfası API entegrasyonu | Statik JSON'dan dinamik API'ye geçiş | Yüksek |
| FG-3 | Pricing sayfası API entegrasyonu | Hem API planları hem kredi paketleri API'den çekilmeli | Yüksek |
| FG-4 | Loading/Error state'leri | API çağrıları için skeleton loading ve error handling | Orta |
| FG-5 | Cache/revalidation stratejisi | Next.js ISR veya fetch cache konfigürasyonu | Orta |
| FG-6 | Ana sayfa pricing teaser | Hardcoded planlardan dinamiğe geçiş | Düşük |

### 3.3 Kavramsal Uyumsuzluk (Kritik)

Website'daki "Products" ile backend'deki "Product" entity'si **farklı kavramları** temsil ediyor:

| Website "Products" | Backend "Product" |
|--------------------|--------------------|
| Minion App (uygulama) | Starter Plan (abonelik) |
| Verify API (hizmet) | Professional Plan (abonelik) |
| Admin Console (araç) | Business Plan (abonelik) |

**Çözüm önerisi:** Backend'e yeni bir `WebProduct` veya `MarketingProduct` entity'si eklemek VEYA mevcut Product entity'yi genişletip `ProductCategory` eklemek.

**Önerilen Yaklaşım:** Yeni bir `WebContent` modülü oluşturmak:

```
WebContent/
├── WebProduct        → Website ürün kartları (Minion App, Verify API, Admin Console)
├── Product           → Abonelik planları (mevcut - Starter, Pro, Business)
└── CreditPackage     → Kredi paketleri (mevcut)
```

---

## 4. Önerilen Mimari

### 4.1 Backend Değişiklikleri

#### 4.1.1 Yeni Entity: `WebProduct`

```csharp
public class WebProduct : BaseEntity
{
    // Temel bilgiler
    public string Slug { get; set; }             // "minion-app", "verify-api", "admin-console"
    public string Icon { get; set; }             // "smartphone", "plug", "layout-dashboard"
    public string Color { get; set; }            // "#5B2D8E"

    // İngilizce içerik
    public string NameEn { get; set; }
    public string DescriptionEn { get; set; }
    public string FeaturesEn { get; set; }       // JSON array

    // İsveççe içerik
    public string NameSv { get; set; }
    public string DescriptionSv { get; set; }
    public string FeaturesSv { get; set; }       // JSON array

    // Yönetim
    public bool IsActive { get; set; }
    public int SortOrder { get; set; }
}
```

#### 4.1.2 Product Entity Genişletme (Çok Dilli)

```csharp
public class Product : BaseEntity
{
    // Mevcut alanlar...
    public string Name { get; set; }             // Varsayılan (EN)
    public string? Description { get; set; }

    // Yeni alanlar
    public string? NameSv { get; set; }          // İsveççe isim
    public string? DescriptionSv { get; set; }   // İsveççe açıklama
    public string? FeaturesSv { get; set; }      // İsveççe özellikler
    public string? Badge { get; set; }           // "Most Popular", "Best Value"
    public string? BadgeSv { get; set; }
}
```

#### 4.1.3 CreditPackage Entity Genişletme

```csharp
public class CreditPackage : BaseEntity
{
    // Mevcut alanlar...

    // Yeni alanlar
    public string? DescriptionSv { get; set; }
    public string? NameSv { get; set; }
    public string? Badge { get; set; }           // "Most Popular"
    public string? BadgeSv { get; set; }
    public int SortOrder { get; set; }
}
```

#### 4.1.4 Yeni API Endpoint'leri

```
# Public (AllowAnonymous) - Website için
GET /api/public/web-products?locale=en        → WebProduct listesi (aktif, sıralı)
GET /api/public/products?locale=en&type=api   → Subscription planları (aktif, sıralı)
GET /api/public/credit-packages?locale=en     → Kredi paketleri (aktif, sıralı)

# Admin - Yönetim paneli için
GET    /api/admin/web-products                → Tüm web ürünleri
POST   /api/admin/web-products                → Yeni web ürün oluştur
PUT    /api/admin/web-products/{id}           → Güncelle
DELETE /api/admin/web-products/{id}           → Sil
PATCH  /api/admin/web-products/{id}/toggle    → Aktif/pasif

# Admin - CreditPackage CRUD (yeni)
GET    /api/admin/credit-packages             → Tüm paketler
POST   /api/admin/credit-packages             → Yeni paket
PUT    /api/admin/credit-packages/{id}        → Güncelle
DELETE /api/admin/credit-packages/{id}        → Sil
PATCH  /api/admin/credit-packages/{id}/toggle → Aktif/pasif
```

#### 4.1.5 Public DTO'lar (Locale-aware)

```csharp
// Locale'e göre doğru dili dönen DTO
public record WebProductDto(
    Guid Id,
    string Slug,
    string Name,          // locale'e göre NameEn veya NameSv
    string Description,   // locale'e göre
    string[] Features,    // locale'e göre
    string Icon,
    string Color,
    int SortOrder
);

public record PublicProductDto(
    Guid Id,
    string Name,
    string? Description,
    string ProductType,    // "Individual" | "Corporate"
    int MonthlyQuota,
    decimal PriceSEK,
    string[] Features,
    string? Badge,
    int SortOrder
);

public record PublicCreditPackageDto(
    Guid Id,
    string Name,
    string? Description,
    int CreditAmount,
    decimal PriceSEK,
    string? Badge,
    int SortOrder
);
```

### 4.2 Frontend Değişiklikleri

#### 4.2.1 API Client Katmanı

```typescript
// website/lib/api.ts
const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'https://api.minion.se';

export async function fetchWebProducts(locale: string) {
  const res = await fetch(`${API_BASE}/api/public/web-products?locale=${locale}`, {
    next: { revalidate: 300 } // 5 dakika ISR cache
  });
  if (!res.ok) return null; // fallback'e düş
  return res.json();
}

export async function fetchSubscriptionPlans(locale: string, type?: string) {
  const params = new URLSearchParams({ locale });
  if (type) params.set('type', type);
  const res = await fetch(`${API_BASE}/api/public/products?${params}`, {
    next: { revalidate: 300 }
  });
  if (!res.ok) return null;
  return res.json();
}

export async function fetchCreditPackages(locale: string) {
  const res = await fetch(`${API_BASE}/api/public/credit-packages?locale=${locale}`, {
    next: { revalidate: 300 }
  });
  if (!res.ok) return null;
  return res.json();
}
```

#### 4.2.2 Products Sayfası (Dinamik)

```typescript
// website/app/[locale]/products/page.tsx
export default async function ProductsPage({ params }) {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: 'products' });

  // API'den çek, fallback olarak statik veriyi kullan
  const products = await fetchWebProducts(locale);

  return (
    <section>
      <h1>{t('title')}</h1>
      <p>{t('subtitle')}</p>

      {products ? (
        <DynamicProductGrid products={products} />
      ) : (
        <StaticProductGrid t={t} /> // Mevcut statik fallback
      )}
    </section>
  );
}
```

#### 4.2.3 Pricing Sayfası (Dinamik)

```typescript
// Hem API planları hem kredi paketleri API'den
const [apiPlans, creditPackages] = await Promise.all([
  fetchSubscriptionPlans(locale, 'api'),
  fetchCreditPackages(locale)
]);
```

#### 4.2.4 Cache Stratejisi

```
ISR (Incremental Static Regeneration):
├── revalidate: 300 (5 dakika)
├── Admin değişikliği → max 5 dk sonra yansır
├── API erişilemez → son başarılı cache serve edilir
└── İlk build'de → build-time fetch ile statik HTML oluşur
```

### 4.3 Env Konfigürasyonu

```env
# website/.env.development
NEXT_PUBLIC_API_URL=https://minion-api-dev.up.railway.app

# website/.env.staging
NEXT_PUBLIC_API_URL=https://minion-api-staging.up.railway.app

# website/.env.production
NEXT_PUBLIC_API_URL=https://api.minion.se
```

---

## 5. Uygulama Planı

### Faz 1: Backend Hazırlığı (Tahmini Efor: Orta)

| # | İş | Detay |
|---|--------|-------|
| 1.1 | `WebProduct` entity oluştur | Domain layer |
| 1.2 | Product & CreditPackage i18n alanlarını ekle | Migration |
| 1.3 | `PublicController` oluştur | `[AllowAnonymous]` public endpoint'ler |
| 1.4 | `AdminWebProductsController` oluştur | CRUD + toggle |
| 1.5 | `AdminCreditPackagesController` oluştur | CRUD + toggle |
| 1.6 | CQRS handler'ları yaz | Query + Command handler'ları |
| 1.7 | Seed data ekle | Mevcut statik verileri veritabanına migration ile aktar |
| 1.8 | CORS konfigürasyonu | Website domain'ini whitelist'e ekle |

### Faz 2: Frontend Entegrasyonu (Tahmini Efor: Orta)

| # | İş | Detay |
|---|--------|-------|
| 2.1 | API client (`lib/api.ts`) oluştur | fetch wrapper + tipleme |
| 2.2 | Products sayfasını dinamiğe çevir | API fetch + fallback |
| 2.3 | Pricing sayfasını dinamiğe çevir | API planları + kredi paketleri |
| 2.4 | Ana sayfa pricing teaser'ı güncelle | Dinamik kredi paketleri |
| 2.5 | Loading skeleton'ları ekle | UX geliştirme |
| 2.6 | Error boundary ekle | API hata yönetimi |
| 2.7 | Env dosyalarını güncelle | `NEXT_PUBLIC_API_URL` ekle |

### Faz 3: Test & Deploy (Tahmini Efor: Düşük)

| # | İş | Detay |
|---|--------|-------|
| 3.1 | Backend API testleri | Public endpoint'ler |
| 3.2 | Website E2E testleri | Products + Pricing sayfaları |
| 3.3 | Dev ortamında test | Railway dev deployment |
| 3.4 | Staging deployment | Son kontroller |
| 3.5 | Production deployment | Go-live |

---

## 6. Veri Modeli Diyagramı

```
┌─────────────────────────────────────────────────────────────────┐
│                        ADMIN YÖNETİMİ                          │
│                                                                 │
│  ┌─────────────┐   ┌──────────────┐   ┌──────────────────┐    │
│  │ WebProduct   │   │ Product      │   │ CreditPackage    │    │
│  │              │   │ (Abonelik)   │   │ (Kredi Paketi)   │    │
│  │ - NameEn/Sv  │   │ - NameEn/Sv  │   │ - NameEn/Sv      │    │
│  │ - DescEn/Sv  │   │ - DescEn/Sv  │   │ - CreditAmount   │    │
│  │ - FeatEn/Sv  │   │ - Type       │   │ - PriceSEK       │    │
│  │ - Icon       │   │   (Ind/Corp) │   │ - Badge          │    │
│  │ - Color      │   │ - Quota      │   │ - IsActive       │    │
│  │ - IsActive   │   │ - PriceSEK   │   │ - SortOrder      │    │
│  │ - SortOrder  │   │ - Badge      │   └──────────────────┘    │
│  └──────┬──────┘   │ - IsActive   │                            │
│         │          │ - SortOrder  │                            │
│         │          └──────┬───────┘                            │
└─────────┼────────────────┼────────────────────────────────────┘
          │                │
          ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     PUBLIC API (Website)                        │
│                                                                 │
│  GET /api/public/web-products?locale=en                        │
│  GET /api/public/products?locale=en&type=api                   │
│  GET /api/public/credit-packages?locale=en                     │
│                                                                 │
│  ┌──────────┐    ┌────────────┐    ┌────────────────┐         │
│  │ Products │    │  Pricing   │    │  Home Pricing  │         │
│  │  Sayfası │◄───│  Sayfası   │◄───│    Teaser      │         │
│  │          │    │            │    │                │         │
│  │ Minion   │    │ API Plans  │    │ Credit Packs   │         │
│  │  App     │    │ Credit     │    │ (Top 3)        │         │
│  │ Verify   │    │  Packages  │    │                │         │
│  │  API     │    │            │    │                │         │
│  │ Admin    │    │            │    │                │         │
│  │ Console  │    │            │    │                │         │
│  └──────────┘    └────────────┘    └────────────────┘         │
│                                                                 │
│  Cache: ISR 5 dakika | Fallback: Statik JSON                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. Risk ve Dikkat Edilecekler

| Risk | Etki | Azaltma |
|------|------|---------|
| API erişilemez olursa website boş görünür | Yüksek | ISR cache + statik JSON fallback |
| Admin yanlışlıkla tüm ürünleri pasif yapar | Orta | En az 1 aktif ürün validasyonu |
| Çeviri eksik kalırsa website kırılır | Orta | `NameSv ?? NameEn` fallback zinciri |
| SEO skoru düşer (SSR → CSR geçişi) | Düşük | Next.js Server Component + ISR ile SSR korunur |
| CORS sorunları | Düşük | Backend CORS whitelist konfigürasyonu |
| Cache stale data gösterir | Düşük | 5 dk revalidation + admin'de "cache temizle" butonu |

---

## 8. Sonuç

Backend altyapısı büyük ölçüde hazır. Ana iş kalemleri:

1. **WebProduct entity** oluşturulması (website ürün kartları için)
2. **Mevcut entity'lere i18n alanları** eklenmesi
3. **Public API endpoint'leri** oluşturulması (`[AllowAnonymous]`)
4. **Website API client** ve sayfa entegrasyonu
5. **Admin CreditPackage CRUD** eklenmesi

Toplam etkilenen dosya sayısı: ~20-25 dosya (backend ~15, frontend ~10)
