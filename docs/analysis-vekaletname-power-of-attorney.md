# Vekaletname (Power of Attorney) - Analiz Dokumani

**Tarih:** 2026-03-31
**Versiyon:** 1.0
**Hazırlayan:** Minion Development Team

---

## 1. Ozet

Bu dokuman, Minion platformuna "Vekaletname / Power of Attorney / Fullmakt" ozelliginin eklenmesine iliskin teknik analizi icerir. Mevcut `DelegationDocument` ve `DelegationDocumentTemplate` altyapisi uzerine insa edilecek, BankID ile imzalanabilir, QR ile dogrulanabilir ve WhatsApp/Email ile paylasilabilir bir vekaletname modulu tasarlanmistir.

---

## 2. Mevcut Altyapi Analizi

### 2.1 Kullanilabilecek Mevcut Yapilar

| Bilesen | Mevcut Durum | Vekaletname Icin Uygunluk |
|---------|-------------|---------------------------|
| `DelegationDocumentTemplate` | HTML sablonlar, `{{placeholder}}` destegi, coklu dil, versiyon takibi | **Dogrudan kullanilabilir** - Vekaletname sablonu yeni bir template olarak eklenebilir |
| `DelegationDocument` | Render edilmis HTML, cift tarafli BankID imza, QR kod, durum takibi | **Dogrudan kullanilabilir** - Mevcut entity yeterli |
| `DelegationDocumentLog` | Audit trail (Created, Viewed, Shared, Approved, ThirdPartyVerified) | **Dogrudan kullanilabilir** |
| `DocumentService` | Sablon render, BankID imza, QR uretimi, paylasim | **Genisletilecek** |
| `BankIdService` | Auth + Sign (InitSignAsync, CollectAsync, QR uretimi) | **Dogrudan kullanilabilir** |
| `IEmailService` | SMTP email gonderimi, HTML sablonlar | **Dogrudan kullanilabilir** |
| `IWhatsAppService` | Twilio WhatsApp, ImageCard + PlainText formati | **Dogrudan kullanilabilir** |
| `VerificationController` | Public dogrulama endpoint'i (QR tarama) | **Genisletilecek** |
| i18n (Flutter) | 7 dil destegi (en, sv, tr, de, es, fr) | **Yeni key'ler eklenecek** |
| i18n (Next.js) | 2 dil (en, sv) | **Yeni key'ler eklenecek** |
| Admin Panel | CRUD operasyonlari, audit log, ayarlar yonetimi | **Sablon yonetimi eklenecek** |

### 2.2 Eksik / Eklenecek Yapilar

| Bilesen | Durum | Aksiyon |
|---------|-------|---------|
| PDF Uretimi | Yok | QuestPDF veya SkiaSharp ile PDF export eklenecek |
| Vekaletname Sablonu (EN/SV) | Yok | Iki dilli HTML sablon olusturulacak |
| Public Dokuman Goruntuleme Sayfasi | Kismi | Mevcut verify sayfasi genisletilecek |
| 3. Parti Paylasim UI (WhatsApp/Email) | Kismi | QR sonrasi paylasim butonlari eklenecek |

---

## 3. Vekaletname Dokuman Sablonu Yapisi

### 3.1 Cift Dilli (EN/SV) Sablon

Sablon `DelegationDocumentTemplate` tablosunda iki kayit olarak saklanacak:
- `Language: "en"` - Ingilizce versiyon
- `Language: "sv"` - Isvecc versiyon

Kullanicinin uygulama dili (`Accept-Language` header veya profil ayari) otomatik olarak uygun sablonu sectirecek.

### 3.2 Template Placeholder'lari

```
{{GrantorName}}              -> Asil (Vekalet Veren) adi
{{GrantorPersonalNumber}}    -> Asil kimlik/org numarasi (maskelenmis)
{{DelegateName}}             -> Vekil (Yetkili Temsilci) adi
{{DelegatePersonalNumber}}   -> Vekil kimlik numarasi (maskelenmis)
{{OrganizationName}}         -> Sirket adi (ornek: Minion AB)
{{OrganizationNumber}}       -> Sirket sicil numarasi
{{Operations}}               -> Yetki alanlari listesi
{{ValidFrom}}                -> Gecerlilik baslangic tarihi
{{ValidTo}}                  -> Gecerlilik bitis tarihi
{{Notes}}                    -> Ek notlar
{{VerificationCode}}         -> Dogrulama kodu
{{QrCodeUrl}}                -> QR dogrulama linki
{{CreatedAt}}                -> Olusturma tarihi
{{DocumentVersion}}          -> Dokuman versiyonu
{{GrantorSignatureTimestamp}} -> Asil imza zamani (BankID)
{{DelegateSignatureTimestamp}}-> Vekil imza zamani (BankID)
{{GrantorBankIdVerification}}-> Asil BankID dogrulama kodu
{{DelegateBankIdVerification}}-> Vekil BankID dogrulama kodu
{{SignatureLocation}}        -> Imza yeri
```

### 3.3 Vekaletname Maddeleri (Dinamik)

Mevcut `OperationType` entity'si uzerinden vekaletname maddeleri dinamik olarak belirlenir:

| Madde | OperationType Karsiligi |
|-------|------------------------|
| Belge Imzalama | `DOCUMENT_SIGNING` |
| Onay ve Basvuru Islemleri | `APPROVAL_APPLICATION` |
| Finansal Islemler | `FINANCIAL_TRANSACTIONS` |
| Sozlesme Yonetimi | `CONTRACT_MANAGEMENT` |
| Personel Islemleri | `PERSONNEL_MANAGEMENT` |

Admin panelinden organizasyona ozel operation type'lar tanimlanabilir.

---

## 4. Kullanici Akislari

### 4.1 Vekaletname Olusturma Akisi (Admin/Asil)

```
Admin/Asil Login (BankID)
    |
    v
Delegation Olustur
    |-- Vekil sec (personnummer ile)
    |-- Yetki alanlari sec (OperationTypes)
    |-- Gecerlilik suresi belirle
    |-- Dil sec (EN/SV/TR)
    |
    v
Dokuman Uret (DocumentService.GenerateDocumentAsync)
    |-- Template yukle (secilen dil)
    |-- Placeholder'lari doldur
    |-- QR kodu uret
    |-- Status: PendingGrantorApproval
    |
    v
Asil BankID ile Imzala (InitSignAsync)
    |-- Imzalanacak metin: Vekaletname ozeti (base64)
    |-- BankID uygulama acilir
    |-- Imza ve zaman damgasi kaydedilir
    |-- Status: PendingDelegateApproval
    |
    v
Vekile Bildirim Gonder
    |-- Push notification (FCM)
    |-- Email (opsiyonel)
    |-- WhatsApp (opsiyonel)
    |
    v
Vekil BankID ile Imzala
    |-- Imza ve zaman damgasi kaydedilir
    |-- Status: FullyApproved
    |
    v
Vekaletname Hazir
    |-- QR kod aktif
    |-- PDF indirilebilir
    |-- Paylasilabilir
```

### 4.2 QR ile Dogrulama Akisi (3. Parti)

```
3. Parti QR Kodu Tarar (telefonla)
    |
    v
Public Dogrulama Sayfasi Acilir
    |-- URL: {AppBaseUrl}/verify/{verificationCode}/document
    |-- Kullanicinin dil tercihine gore icerik gosterilir
    |
    v
Dokuman Bilgileri Gosterilir
    |-- Asil bilgileri
    |-- Vekil bilgileri
    |-- Yetki alanlari
    |-- Gecerlilik suresi
    |-- Imza durumlari (BankID dogrulama)
    |-- Dogrulama kodu
    |
    v
Paylasim Secenekleri
    |-- "WhatsApp ile Gonder" butonu
    |     |-- Kendi numarasina
    |     |-- Baska bir numaraya
    |-- "Email ile Gonder" butonu
    |     |-- Kendi adresine
    |     |-- Baska bir adrese
    |-- "PDF Indir" butonu
    |
    v
Audit Log Kaydi
    |-- ThirdPartyVerified (IP, zaman, isim)
```

### 4.3 Admin Sablon Yonetimi Akisi

```
Admin Login
    |
    v
Admin Panel > Dokuman Sablonlari
    |
    v
Sablon Listesi
    |-- Dile gore filtreleme (EN/SV/TR...)
    |-- Aktif/Pasif durumu
    |-- Versiyon bilgisi
    |
    v
Sablon Duzenleme
    |-- HTML editor (zengin metin)
    |-- Placeholder listesi (yardim paneli)
    |-- Onizleme (ornek veri ile render)
    |-- Kaydet / Aktif Et / Pasif Et
```

---

## 5. Teknik Tasarim

### 5.1 Backend Degisiklikleri

#### 5.1.1 Yeni Placeholder'lar Icin DocumentService Guncellemesi

`RenderTemplate` metoduna yeni placeholder'lar eklenecek:

```csharp
// Mevcut placeholder'lara ek olarak:
.Replace("{{GrantorSignatureTimestamp}}", doc.GrantorApprovedAt?.ToString("yyyy-MM-dd HH:mm:ss UTC") ?? "[Pending]")
.Replace("{{DelegateSignatureTimestamp}}", doc.DelegateApprovedAt?.ToString("yyyy-MM-dd HH:mm:ss UTC") ?? "[Pending]")
.Replace("{{GrantorBankIdVerification}}", doc.GrantorSignature != null ? "[Verified]" : "[Pending]")
.Replace("{{DelegateBankIdVerification}}", doc.DelegateSignature != null ? "[Verified]" : "[Pending]")
.Replace("{{SignatureLocation}}", "Sweden")
```

#### 5.1.2 PDF Export Servisi (Yeni)

```
IDocumentPdfService
    |-- Task<byte[]> GeneratePdfAsync(Guid documentId, CancellationToken ct)
    |-- HTML -> PDF donusumu (QuestPDF veya SkiaSharp)
    |-- QR kod gorseli PDF'e gomulecek
    |-- BankID imza bilgileri PDF'e yazilacak
```

**Paket Secenekleri:**
- **QuestPDF** (onerilen) - .NET native, acik kaynak, fluent API
- **SkiaSharp** (mevcut) - Zaten projede var, ancak PDF icin daha cok is gerektirir
- **iTextSharp** - Lisans maliyeti yuksek (AGPL)

#### 5.1.3 Public Paylasim API (VerificationController Genisletmesi)

```
POST /api/verify/{verificationCode}/share
{
    "method": "whatsapp" | "email",
    "recipientPhone": "+46...",      // WhatsApp icin
    "recipientEmail": "x@y.com",     // Email icin
    "senderName": "John Doe"         // Gonderen adi
}
```

Bu endpoint rate-limit uygulanacak (ornegin: 5 paylasim/saat/IP).

#### 5.1.4 PDF Download API

```
GET /api/verify/{verificationCode}/document/pdf
    -> Response: application/pdf binary
    -> Rate-limited, audit logged
```

#### 5.1.5 Admin Template CRUD API

```
GET    /api/admin/document-templates              -> Tum sablonlari listele
GET    /api/admin/document-templates/{id}          -> Sablon detayi
POST   /api/admin/document-templates               -> Yeni sablon olustur
PUT    /api/admin/document-templates/{id}          -> Sablon guncelle
PUT    /api/admin/document-templates/{id}/activate -> Aktif et
PUT    /api/admin/document-templates/{id}/deactivate -> Pasif et
POST   /api/admin/document-templates/{id}/preview  -> Ornek veri ile onizleme
```

### 5.2 Frontend Degisiklikleri

#### 5.2.1 Flutter (Mobil + Web)

**Yeni Sayfalar:**
- `DocumentTemplateListPage` - Admin: sablon listesi
- `DocumentTemplateEditPage` - Admin: sablon duzenleme (HTML editor)
- `DocumentPreviewPage` - Vekaletname onizleme
- `DocumentSignPage` - BankID imza akisi
- `DocumentSharePage` - QR gosterimi + paylasim butonlari

**i18n Eklemeleri (app_en.arb, app_sv.arb, app_tr.arb):**
```json
{
  "powerOfAttorney": "Power of Attorney",
  "powerOfAttorneySv": "Fullmakt",
  "signWithBankId": "Sign with BankID",
  "documentReady": "Document is ready",
  "shareViaWhatsApp": "Share via WhatsApp",
  "shareViaEmail": "Share via Email",
  "downloadPdf": "Download PDF",
  "scanQrToVerify": "Scan QR code to verify",
  "documentTemplates": "Document Templates",
  "editTemplate": "Edit Template",
  "previewTemplate": "Preview Template"
}
```

#### 5.2.2 Next.js (Public Dogrulama Sayfasi)

Mevcut `/verify/[code]` sayfasi genisletilecek:

- Dokuman detay gorunumu (responsive)
- WhatsApp paylasim butonu (`whatsapp://send?text=...` veya API uzerinden)
- Email paylasim formu
- PDF indirme butonu
- Dil secici (EN/SV otomatik, kullanici degistirebilir)

### 5.3 Veritabani Degisiklikleri

**Mevcut tablolarda degisiklik yok.** Mevcut `DelegationDocumentTemplate`, `DelegationDocument`, `DelegationDocumentLog` tablolari yeterli.

Ek olarak vekaletname sablonlarinin `TemplateContent` alani icin iki yeni kayit (EN + SV) seed data olarak eklenecek.

---

## 6. Vekaletname HTML Sablon Ornegi (EN + SV Cift Dilli)

Sablon hem Ingilizce hem Isvecce metni ayni dokumanda icerecek:

```
Section headers:   POWER OF ATTORNEY / FULLMAKT
Paragraphs:        English text first, Swedish (italic) below
Signature block:   Bilingual labels
Legal disclaimer:  Bilingual
```

Alternatif olarak: Admin panelinden dile gore ayri sablonlar yonetilebilir (mevcut yapiyla uyumlu).

---

## 7. Guvenlik Hususlari

| Husus | Cozum |
|-------|-------|
| Dokuman erisimi | Sadece taraflar (grantor, delegate) ve QR ile dogrulayanlar gorebilir |
| BankID imza butunlugu | Imza verisi (signature + OCSP) veritabaninda saklanir |
| QR kod guvenligi | Verification code UUID formatinda, tahmin edilemez |
| Rate limiting | Public endpoint'lerde IP bazli rate limit |
| Kisisel veri maskeleme | Personnummer son 4 hane maskelenir (199001-****) |
| Audit trail | Her islem (olusturma, goruntuleme, paylasim, dogrulama) loglanir |
| HTTPS | Tum iletisim TLS uzerinden |
| PDF imza | BankID imza bilgileri PDF'e gomulur (dogrulanabilir) |

---

## 8. Is Plani ve Oncelikler

### Faz 1 - Temel Altyapi (1-2 hafta)
- [ ] EN + SV vekaletname HTML sablonlarini olustur
- [ ] `DocumentService.RenderTemplate` metoduna yeni placeholder'lari ekle
- [ ] Admin template CRUD API endpoint'lerini olustur
- [ ] Flutter admin panel: sablon yonetimi sayfalari
- [ ] Seed data: varsayilan EN + SV sablonlari

### Faz 2 - BankID Imzalama (1 hafta)
- [ ] Vekaletname icin `BankIdService.InitSignAsync` entegrasyonu
- [ ] Cift tarafli imza akisi (grantor + delegate)
- [ ] Imza sonrasi dokuman durumu guncelleme
- [ ] Flutter: BankID imza sayfasi (QR + same-device)

### Faz 3 - QR ve Public Dogrulama (1 hafta)
- [ ] Public dogrulama sayfasini genislet (Next.js)
- [ ] QR kod gosterim ve tarama akisi
- [ ] Dil otomatik secimi (browser language)
- [ ] Responsive tasarim (mobil tarayici oncelikli)

### Faz 4 - Paylasim (WhatsApp + Email) (1 hafta)
- [ ] Public paylasim API endpoint'i
- [ ] WhatsApp paylasim entegrasyonu (mevcut TwilioWhatsAppService)
- [ ] Email paylasim entegrasyonu (mevcut EmailService)
- [ ] Next.js: paylasim butonlari ve formu
- [ ] Rate limiting ve guvenlik

### Faz 5 - PDF Export (1 hafta)
- [ ] QuestPDF NuGet paketi entegrasyonu
- [ ] `IDocumentPdfService` implementasyonu
- [ ] QR kod gomulusu
- [ ] BankID imza bilgilerinin PDF'e yazilmasi
- [ ] PDF download endpoint'i

### Faz 6 - Test ve Iyilestirme (1 hafta)
- [ ] Unit testler (DocumentService, PDF, template rendering)
- [ ] Integration testler (BankID sign flow)
- [ ] E2E testler (Flutter + API)
- [ ] Performans testi (PDF uretimi)
- [ ] Kullanici kabul testi (UAT)

---

## 9. Bagimliliklar

| Paket | Amac | Lisans |
|-------|------|--------|
| QuestPDF | PDF uretimi | MIT (ucretsiz) |
| QRCoder | QR kod gorseli uretimi (PDF icin) | MIT |
| (Mevcut) SkiaSharp | Gorsel islemleri | MIT |
| (Mevcut) MailKit | Email gonderimi | MIT |
| (Mevcut) Twilio | WhatsApp gonderimi | Commercial |

---

## 10. Mimari Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      KULLANICI KATMANI                       │
├──────────────┬──────────────────┬───────────────────────────┤
│ Flutter App  │  Flutter Web     │  Next.js (Public Verify)  │
│ (iOS/Android)│  (Admin Panel)   │  (QR Tarama Sayfasi)      │
└──────┬───────┴────────┬─────────┴─────────────┬─────────────┘
       │                │                       │
       ▼                ▼                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      API KATMANI (.NET 8)                    │
├─────────────────────────────────────────────────────────────┤
│ DelegationsController  │ DocumentsController                │
│ AdminController        │ VerificationController             │
└──────────┬─────────────┴──────────────┬─────────────────────┘
           │                            │
           ▼                            ▼
┌─────────────────────┐  ┌────────────────────────────────────┐
│   UYGULAMA KATMANI  │  │        ALTYAPI KATMANI              │
│ (MediatR Handlers)  │  ├────────────────────────────────────┤
│                      │  │ DocumentService    (sablon render)  │
│ GenerateDocument     │  │ BankIdService      (imzalama)      │
│ ApproveDocument      │  │ DocumentPdfService (PDF export)    │
│ ShareDocument        │  │ EmailService       (email)         │
│ VerifyDocument       │  │ WhatsAppService    (whatsapp)      │
└──────────┬───────────┘  │ NotificationService(bildirim)      │
           │              └──────────┬─────────────────────────┘
           ▼                         │
┌──────────────────────┐             ▼
│   DOMAIN KATMANI     │  ┌──────────────────────┐
├──────────────────────┤  │   HARICI SERVISLER   │
│ DelegationDocument   │  ├──────────────────────┤
│ DelegDocTemplate     │  │ BankID API v6.0      │
│ DelegDocLog          │  │ Twilio (WhatsApp)    │
│ Delegation           │  │ SMTP (Email)         │
│ OperationType        │  │ FCM (Push)           │
└──────────┬───────────┘  └──────────────────────┘
           │
           ▼
┌──────────────────────┐
│   PostgreSQL DB      │
└──────────────────────┘
```

---

## 11. Sonuc

Mevcut Minion altyapisi, vekaletname ozelliginin buyuk bolumunu desteklemektedir. `DelegationDocument` + `DelegationDocumentTemplate` yapisi, BankID imzalama servisi, QR dogrulama mekanizmasi ve WhatsApp/Email paylasim servisleri halihazirda mevcut.

**Ana eklentiler:**
1. EN/SV cift dilli vekaletname HTML sablonlari
2. Admin panel uzerinden sablon yonetimi (CRUD)
3. PDF export servisi (QuestPDF)
4. Public dogrulama sayfasinda paylasim butonlari (WhatsApp + Email)
5. Yeni imza placeholder'lari (zaman damgasi, BankID dogrulama kodu)

Tahmini toplam sure: **5-6 hafta** (paralel calisma ile kisaltilabilir).
