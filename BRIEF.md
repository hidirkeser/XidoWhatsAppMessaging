# Minion - BankID Yetkilendirme Uygulamasi Brief

## 1. Proje Ozeti

BankID entegrasyonlu bir yetkilendirme (delegation) uygulamasi. Bir kisi, baska bir kisiye belirli bir kurum icin sinirli sureli islem yapma yetkisi verebilir. Tum kimlik dogrulama islemleri Isvec BankID uzerinden yapilir.

## 2. Teknoloji Yigini

| Katman         | Teknoloji                    |
|----------------|------------------------------|
| Mobil          | Flutter (iOS + Android)      |
| Web            | Flutter Web (ayni codebase)  |
| Backend API    | C# / ASP.NET Core Web API    |
| Veritabani     | SQL Server                   |
| Hosting        | Microsoft Azure              |
| Auth           | Swedish BankID API v6        |
| Push Bildirim  | Firebase Cloud Messaging (FCM) + APNs |
| In-App Bildirim| SignalR (real-time)          |

## 3. Kimlik Dogrulama (BankID Entegrasyonu)

### 3.1 BankID API v6 Temel Bilgiler
- **API Endpoint'leri:** `/auth`, `/sign`, `/collect`, `/cancel`
- **Zorunlu:** Secure Start (QR code veya autoStartToken ile baslatma)
- **personalNumber** artik dogrudan auth/sign'da kullanilamaz, sadece `requirement` objesi icinde dogrulama amacli kullanilabilir
- **Polling:** `/collect` endpoint'i her 2 saniyede bir cagrilir (minimum 1 saniye aralik)
- BankID test sertifikasi gelistirme icin, production sertifikasi canli ortam icin gerekli

### 3.2 Login Akislari

#### Mobil Uygulama (Ayni Cihaz)
1. Kullanici "BankID ile Giris Yap" butonuna basar
2. Backend `/auth` endpoint'ini cagirir → `orderRef` + `autoStartToken` doner
3. `autoStartToken` ile BankID uygulamasi otomatik acilir
4. Backend `/collect` ile polling yapar
5. Basarili → JWT token olusturulur, kullanici giris yapar
6. Ilk giriste kullanici profili otomatik olusturulur (personnummer, isim, soyisim BankID'den alinir)

#### Web'den Mobil Onay (Cross-Device / QR Code)
1. Kullanici web uygulamasinda "BankID ile Giris Yap" butonuna basar
2. Backend `/auth` cagirir → `orderRef` + `qrStartToken` + `qrStartSecret` doner
3. Web ekraninda animated QR code gosterilir
4. Kullanici telefonundan BankID uygulamasini acip QR code'u tarar
5. Backend `/collect` ile polling yapar
6. Basarili → JWT token, kullanici giris yapar

## 4. Kullanici Yonetimi

### 4.1 Kullanici Kayit
- **Otomatik olusturma:** Ilk BankID girisinde kullanici profili otomatik olusturulur
- BankID'den gelen bilgiler: personnummer, ad, soyad
- Ek bilgiler (email, telefon) ilk giristen sonra profil sayfasindan girilebilir

### 4.2 Kullanici - Kurum Iliskisi
- Bir kullanici **birden fazla** kuruma bagli olabilir
- Kurum baglantisi admin panel uzerinden yapilir
- Kullanici giris yaptiginda bagli oldugu kurumlari gorerek islem yapar

## 5. Kurum Yonetimi

- Kurumlar **admin panel** uzerinden eklenir, duzenlenir, silinir (soft delete)
- Her kurumun: adi, org. numarasi, adresi, iletisim bilgileri bulunur
- Her kuruma ozel **islem tipleri** tanimlanabilir (dinamik yapi)

## 6. Islem Tipleri (Dinamik Yapi)

Admin panel uzerinden kurum bazli islem tipleri tanimlanabilir:

- **Belge imzalama** - Dijital belgeleri BankID ile imzalama
- **Onay/basvuru islemleri** - Kurum adina onay verme veya basvuru yapma
- **Genel temsil yetkisi** - Kurumda tum islemleri yapabilme
- **Finansal islemler** - Odeme, fatura onayi, para transferi
- **Sozlesme yonetimi** - Sozlesme olusturma, duzenleme, sonlandirma
- **Personel islemleri** - Ise alim, izin onayi, ozluk islemleri
- **Ozel islem tipleri** - Admin tarafindan serbestce tanimlanabilir

Her islem tipi icin: ad, aciklama, ikon, aktif/pasif durumu saklanir.

## 7. Yetkilendirme (Delegation) Akisi

### 7.1 Yetki Verme
1. Giris yapmis kullanici "Yetki Ver" ekranina gelir
2. Ekranda **kalan kontor bakiyesi** gosterilir
3. Yetkilendirilecek kisiyi arar: **personnummer**, **isim** veya **email** ile
4. Asagidaki bilgileri secer:
   - **Kurum:** Hangi kurum icin yetki verilecek
   - **Islem tipleri:** Hangi islemleri yapabilecek (coklu secim)
   - **Sure tipi:** Dakika / Saat / Gun / Iki tarih araligi
   - **Sure degeri:** Ornegin 30 dk, 2 saat, 3 gun veya 01.04.2026 - 15.04.2026
5. Sistem **kontor yeterliligi** kontrol eder:
   - Yeterli kontor varsa → devam
   - Yetersiz kontor → "Kontor Satin Al" ekranina yonlendirilir
6. BankID ile imzalama (`/sign`) yaparak yetkiyi onaylar
7. Kontor bakiyesinden dusulur
8. Yetki kaydi olusturulur (status: PENDING_APPROVAL)

### 7.2 Bildirim ve Onay
1. Yetkilendirilen kisiye **push notification + in-app bildirim** gider
   - Icerik: "X kisisi sizi Y kurumu icin Z islemlerine DD.MM.YYYY - DD.MM.YYYY tarihlerinde yetkilendirdi"
2. Yetkilendirilen kisi uygulamaya giris yapar
3. Yetki detayini gorur:
   - Yetki veren kisi bilgileri
   - Kurum
   - Islem tipleri
   - Gecerlilik suresi
4. **Kabul Et** veya **Reddet** butonuna basar
5. Kabul/Red durumunda yetki veren kisiye **push notification + in-app bildirim** gider
   - Kabul: "X kisisi yetkinizi kabul etti"
   - Red: "X kisisi yetkinizi reddetti"
6. Status guncellenir: ACTIVE veya REJECTED

### 7.3 Yetki Kullanimi
1. Yetkilendirilmis kisi kendi BankID'si ile uygulamaya giris yapar
2. "Yetkilerin" bolumunde aktif yetkilerini gorur
3. Ilgili yetkiyi secip izin verilen islemleri gerceklestirir
4. Her islem BankID `/sign` ile imzalanabilir (islem tipine gore)

### 7.4 Yetki Iptali
- Yetki veren kisi **istedi zaman** yetkiyi geri cekebilir
- Iptal edildiginde yetkilendirilen kisiye bildirim gider
- Status: REVOKED olarak guncellenir
- Sure doldugunda yetki otomatik EXPIRED olur (background job)

### 7.5 Yetki Durumlari (Status)
| Status           | Aciklama                                    |
|------------------|---------------------------------------------|
| PENDING_APPROVAL | Yetki verildi, onay bekleniyor              |
| ACTIVE           | Yetkilendirilen kisi kabul etti, aktif      |
| REJECTED         | Yetkilendirilen kisi reddetti               |
| REVOKED          | Yetki veren kisi geri cekti                 |
| EXPIRED          | Sure doldu, otomatik kapandi                |

## 8. Yetki Listeleme ve Filtreleme

### 8.1 Verdigim Yetkiler Listesi
- Kullanici kendisinin baskasina verdigi tum yetkileri liste halinde gorur
- Her satir: yetkilendirilen kisi adi, kurum, islem tipleri, sure, **status badge**
- Status badge renkleri: ACTIVE (yesil), PENDING (sari), REJECTED (kirmizi), REVOKED (gri), EXPIRED (gri)
- Liste detaya tiklayinca yetki detay sayfasi acilir (iptal etme imkani ile)

### 8.2 Bana Verilen Yetkiler Listesi
- Kullanici baskalarinin kendisine verdigi tum yetkileri liste halinde gorur
- Her satir: yetki veren kisi adi, kurum, islem tipleri, sure, **status badge**
- PENDING durumundaki yetkiler icin Kabul/Red butonlari dogrudan listede gosterilir
- ACTIVE yetkiler icin "Isleme Basla" butonu

### 8.3 Filtreler
Hem "Verdigim Yetkiler" hem "Bana Verilen Yetkiler" listelerinde:
- **Status filtresi:** Tumu / Aktif / Beklemede / Reddedilen / Iptal Edilen / Suresi Dolan
- **Kurum filtresi:** Tum kurumlar veya belirli bir kurum
- **Tarih araligi:** Baslangic - bitis tarihi ile filtreleme
- **Arama:** Kisi adi veya personnummer ile arama
- Varsayilan gorunum: Aktif ve Beklemede olan yetkiler

## 9. Kontor (Kredi) Sistemi

### 9.1 Genel Yapi
- Yetki verebilmek icin kullanicinin **yeterli kontoru** olmasi gerekir
- Her yetki verme islemi **1 kontor** harcar (veya islem tipine/sureye gore farkli kontor maliyeti - admin tarafindan ayarlanabilir)
- Kontoru olmayan kullanici yetki veremez, "Kontor Satin Al" ekranina yonlendirilir

### 9.2 Kontor Satin Alma
- Uygulama ici satin alma (In-App Purchase) veya harici odeme entegrasyonu
- Kontor paketleri: ornegin 10, 50, 100, 500 kontor
- Paket fiyatlari admin panelden ayarlanabilir
- Satin alma sonrasi kontor bakiyesi aninda guncellenir

### 9.3 Kontor Bakiye Gosterimi
- Ana ekranda (dashboard) kontor bakiyesi gorunur
- Yetki verme ekraninda "Kalan kontor: X" bilgisi gosterilir
- Dusuk bakiye uyarisi (ornegin 5 kontorun altinda uyari bildirimi)
- Kontor harcama gecmisi listelenebilir (tarih, islem, harcanan kontor)

### 9.4 Kontor Yonetimi (Admin)
- Kontor paket tanimlama (adet + fiyat)
- Islem tipi basina kontor maliyeti belirleme
- Kullaniciya manuel kontor ekleme/cikarma
- Kontor harcama raporlari

## 10. Bildirim Sistemi

### 10.1 Push Notification
- **Android:** Firebase Cloud Messaging (FCM)
- **iOS:** Apple Push Notification Service (APNs) via FCM
- Kullanici cihaz token'i login sirasinda kaydedilir
- Bir kullanicinin birden fazla cihazi olabilir

### 10.2 In-App Notification (Real-time)
- **SignalR** ile real-time bildirim
- Kullanici uygulamada iken aninda gosterilir
- Okundu/okunmadi durumu takibi
- Bildirim gecmisi listelenebilir

### 10.3 Bildirim Tetikleyicileri
| Olay                        | Alici                    |
|-----------------------------|--------------------------|
| Yeni yetki verildi          | Yetkilendirilen kisi     |
| Yetki kabul edildi          | Yetki veren kisi         |
| Yetki reddedildi            | Yetki veren kisi         |
| Yetki iptal edildi          | Yetkilendirilen kisi     |
| Yetki suresi dolmak uzere   | Her iki taraf             |
| Yetki suresi doldu          | Her iki taraf             |
| Dusuk kontor uyarisi        | Yetki veren kisi         |
| Kontor satin alma basarili  | Satin alan kisi          |

## 11. Admin Paneli

- Kurum CRUD (ekleme, duzenleme, silme, listeleme)
- Kurum bazli islem tipi tanimlama
- Kullanici-kurum eslestirme
- Tum yetkileri goruntuleyebilme
- Audit log goruntuleyebilme
- Sistem istatistikleri / dashboard
- Kontor paket yonetimi ve kullanici kontor islemleri

## 12. Audit Log (Detayli Denetim Kaydi)

Tum islemler loglanir:

| Log Alani       | Icerik                                      |
|-----------------|---------------------------------------------|
| Timestamp       | Islem zamani (UTC)                           |
| Actor           | Islemi yapan kullanici (personnummer + ad)   |
| Action          | Islem tipi (LOGIN, GRANT, ACCEPT, REJECT, REVOKE, EXECUTE, CREDIT_PURCHASE, CREDIT_DEDUCT, ...) |
| Target          | Etkilenen kullanici (varsa)                  |
| Organization    | Ilgili kurum                                 |
| Details         | Islem detaylari (JSON)                       |
| IP Address      | Islem yapan IP                               |
| Device Info     | Cihaz bilgisi                                |

## 13. Guvenlik Gereksinimleri

- Tum API cagrilari HTTPS uzerinden
- JWT token ile yetkilendirme (access + refresh token)
- BankID sertifika yonetimi (Azure Key Vault)
- Rate limiting (API Gateway seviyesinde)
- GDPR uyumu (kisisel veri saklama/silme politikasi)
- Input validation (tum endpoint'lerde)
- SQL injection / XSS korumalari
- Yetki kontrolleri (bir kullanici sadece kendi yetkilerini gorebilir)

## 14. Veritabani Temel Tablolar (Ozet)

- **Users** - Kullanici bilgileri (personnummer, ad, soyad, email, telefon)
- **Organizations** - Kurum bilgileri
- **UserOrganizations** - Kullanici-kurum iliskisi (many-to-many)
- **OperationTypes** - Islem tipleri (kurum bazli)
- **Delegations** - Yetkilendirme kayitlari
- **DelegationOperations** - Yetki-islem tipi iliskisi
- **Notifications** - Bildirim kayitlari
- **DeviceTokens** - Push notification cihaz token'lari
- **AuditLogs** - Denetim kayitlari
- **CreditPackages** - Kontor paket tanimlari (adet, fiyat, aktif/pasif)
- **UserCredits** - Kullanici kontor bakiyesi
- **CreditTransactions** - Kontor harcama/yukleme gecmisi (tarih, miktar, islem tipi, ilgili yetki)

## 15. Azure Servisleri

| Servis                    | Kullanim                        |
|---------------------------|----------------------------------|
| Azure App Service         | Backend API hosting              |
| Azure SQL Database        | Veritabani                       |
| Azure Key Vault           | BankID sertifikalari, secrets    |
| Azure SignalR Service     | Real-time bildirimler            |
| Azure Notification Hubs   | Push notification yonetimi       |
| Azure Blob Storage        | Belge/dosya saklama (gerekirse)  |
| Azure Application Insights| Monitoring ve loglama           |

## 16. MVP Kapsami

Ilk surum icin oncelikli ozellikler:
1. BankID ile login (mobil + web QR code)
2. Kullanici otomatik kayit
3. Kisi arama (personnummer, isim, email)
4. Kontor satin alma ve bakiye yonetimi
5. Yetki verme (kurum + islem tipi + sure secimi + kontor kontrolu)
6. Bildirim (push + in-app)
7. Yetki kabul/red
8. Verdigim yetkiler listesi (filtreli)
9. Bana verilen yetkiler listesi (filtreli)
10. Yetki goruntuleme ve kullanma
11. Yetki iptali
12. Temel admin panel (kurum + islem tipi + kontor paket yonetimi)
13. Audit log
