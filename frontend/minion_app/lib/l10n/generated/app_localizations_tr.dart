// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppL10nTr extends AppL10n {
  AppL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Minion';

  @override
  String get bankIdAuthSystem => 'BankID Yetkilendirme Sistemi';

  @override
  String get loginWithBankId => 'BankID ile Giriş Yap';

  @override
  String get thisDevice => 'Bu cihaz';

  @override
  String get otherDevice => 'Başka cihaz';

  @override
  String get scanQrCode => 'BankID uygulamanızla\nQR kodu tarayın';

  @override
  String get openingBankIdApp => 'BankID uygulaması açılıyor...';

  @override
  String get openBankIdApp => 'BankID Uygulamasını Aç';

  @override
  String get waitingForApproval => 'BankID onayınız bekleniyor...';

  @override
  String get cancel => 'İptal';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get dashboard => 'Kontrol Paneli';

  @override
  String get delegations => 'Yetkiler';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get profile => 'Profil';

  @override
  String get creditBalance => 'Kredi Bakiyesi';

  @override
  String get buyCredits => 'Kredi Satın Al';

  @override
  String remainingCredits(int count) {
    return 'Kalan kredi: $count';
  }

  @override
  String thisOperationCosts(int count) {
    return 'Bu işlem: $count kredi';
  }

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get grantDelegation => 'Yetki Ver';

  @override
  String get myDelegations => 'Yetkilerim';

  @override
  String get recentDelegations => 'Son Yetkiler';

  @override
  String get noDelegationsYet => 'Henüz yetki yok';

  @override
  String grantedDelegations(int count) {
    return 'Verilen ($count)';
  }

  @override
  String receivedDelegations(int count) {
    return 'Alınan ($count)';
  }

  @override
  String get noGrantedDelegations => 'Henüz yetki vermediniz';

  @override
  String get noReceivedDelegations => 'Size verilen yetki yok';

  @override
  String get all => 'Tümü';

  @override
  String get active => 'Aktif';

  @override
  String get pending => 'Beklemede';

  @override
  String get rejected => 'Reddedildi';

  @override
  String get revoked => 'İptal Edildi';

  @override
  String get expired => 'Süresi Doldu';

  @override
  String get personSelection => 'Kişi Seçimi';

  @override
  String get searchByPersonnummer => 'Kişisel numara, ad veya e-posta ile ara';

  @override
  String get organization => 'Kuruluş';

  @override
  String get selectOrganization => 'Kuruluş seçin';

  @override
  String get operationTypes => 'İşlem Türleri';

  @override
  String get duration => 'Süre';

  @override
  String get selectDateRange => 'Tarih aralığı seçin';

  @override
  String get start => 'Başlangıç';

  @override
  String get end => 'Bitiş';

  @override
  String get minutes => 'Dakika';

  @override
  String get hours => 'Saat';

  @override
  String get days => 'Gün';

  @override
  String get value => 'Değer';

  @override
  String get noteOptional => 'Not (isteğe bağlı)';

  @override
  String grantDelegationBtn(int cost) {
    return 'Yetki Ver ($cost kredi)';
  }

  @override
  String get sending => 'Gönderiliyor...';

  @override
  String get delegationDetail => 'Yetki Detayı';

  @override
  String get status => 'Durum';

  @override
  String get credits => 'Kredi';

  @override
  String get grantor => 'Yetki Veren';

  @override
  String get delegatePerson => 'Yetkili Kişi';

  @override
  String get validityPeriod => 'Geçerlilik Süresi';

  @override
  String get note => 'Not';

  @override
  String get accept => 'Kabul Et';

  @override
  String get reject => 'Reddet';

  @override
  String get revokeDelegation => 'Yetkiyi İptal Et';

  @override
  String get delegationAccepted => 'Yetki kabul edildi';

  @override
  String get delegationRejected => 'Yetki reddedildi';

  @override
  String get delegationRevoked => 'Yetki iptal edildi';

  @override
  String get delegationCreated => 'Yetki başarıyla verildi!';

  @override
  String get purchaseCredits => 'Kredi Satın Al';

  @override
  String get paymentMethod => 'Ödeme Yöntemi';

  @override
  String get creditPackages => 'Kredi Paketleri';

  @override
  String get noPackagesFound => 'Paket bulunamadı';

  @override
  String get payWithSwish => 'Swish ile Öde';

  @override
  String get payWithPaypal => 'PayPal ile Öde';

  @override
  String get payWithKlarna => 'Klarna ile Öde';

  @override
  String get redirectingToPayment => 'Ödeme sayfasına yönlendiriliyor...';

  @override
  String get paymentInitiated => 'Ödeme başlatıldı';

  @override
  String get creditHistory => 'Kredi Geçmişi';

  @override
  String get noTransactionsYet => 'Henüz işlem yok';

  @override
  String get noNotifications => 'Henüz bildirim yok';

  @override
  String get markAllRead => 'Tümünü Okundu İşaretle';

  @override
  String get justNow => 'Az önce';

  @override
  String minutesAgo(int count) {
    return '$count dakika önce';
  }

  @override
  String hoursAgo(int count) {
    return '$count saat önce';
  }

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get language => 'Dil';

  @override
  String get english => 'İngilizce';

  @override
  String get swedish => 'İsveççe';

  @override
  String get turkish => 'Türkçe';

  @override
  String get german => 'Almanca';

  @override
  String get spanish => 'İspanyolca';

  @override
  String get french => 'Fransızca';

  @override
  String get appLanguage => 'Uygulama Dili';

  @override
  String get fullName => 'Tam Ad';

  @override
  String get personnummer => 'Kişisel Numara';

  @override
  String get email => 'E-posta';

  @override
  String get phone => 'Telefon';

  @override
  String get notSpecified => 'Belirtilmemiş';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String get profileUpdated => 'Profil başarıyla güncellendi';

  @override
  String get profileUpdateFailed => 'Profil güncellenemedi';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get editInfo => 'Bilgileri Düzenle';

  @override
  String get theme => 'Tema';

  @override
  String get adminPanel => 'Yönetim Paneli';

  @override
  String get users => 'Kullanıcılar';

  @override
  String get organizations => 'Kuruluşlar';

  @override
  String get organizationManagement => 'Kuruluş Yönetimi';

  @override
  String get operationTypeManagement => 'İşlem Türleri';

  @override
  String get userOrgMapping => 'Kullanıcı-Kuruluş';

  @override
  String get creditPackageManagement => 'Kredi Paketleri';

  @override
  String get auditLog => 'Denetim Günlüğü';

  @override
  String get management => 'Yönetim';

  @override
  String get totalUsers => 'Toplam Kullanıcı';

  @override
  String get totalOrganizations => 'Toplam Kuruluş';

  @override
  String get activeDelegations => 'Aktif Yetkiler';

  @override
  String get pendingCount => 'Beklemede';

  @override
  String get totalCredits => 'Toplam Kredi';

  @override
  String get revenueSEK => 'Gelir (SEK)';

  @override
  String get newOrganization => 'Yeni Kuruluş';

  @override
  String get editOrganization => 'Kuruluşu Düzenle';

  @override
  String get deleteOrganization => 'Kuruluşu Sil';

  @override
  String get deleteOrgConfirm =>
      'Bu kuruluşu silmek istediğinizden emin misiniz?';

  @override
  String get orgName => 'Kuruluş Adı';

  @override
  String get orgNumber => 'Org Numarası';

  @override
  String get city => 'Şehir';

  @override
  String get create => 'Oluştur';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get newPackage => 'Yeni Paket';

  @override
  String get editPackage => 'Paketi Düzenle';

  @override
  String get packageName => 'Paket Adı';

  @override
  String get creditAmount => 'Kredi Miktarı';

  @override
  String get priceSEK => 'Fiyat (SEK)';

  @override
  String get description => 'Açıklama';

  @override
  String get error => 'Hata';

  @override
  String errorOccurred(String message) {
    return 'Bir hata oluştu: $message';
  }

  @override
  String get networkError => 'Ağ hatası. Bağlantınızı kontrol edin.';

  @override
  String get sessionExpired =>
      'Oturum süresi doldu. Lütfen tekrar giriş yapın.';

  @override
  String get insufficientCredits =>
      'Yetersiz kredi. Lütfen daha fazla satın alın.';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get fieldRequired => 'Bu alan zorunludur';

  @override
  String get invalidEmail => 'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get invalidPhone => 'Lütfen geçerli bir telefon numarası girin';

  @override
  String minLength(int count) {
    return 'En az $count karakter olmalıdır';
  }

  @override
  String get invalidPersonnummer => 'Lütfen geçerli bir kişisel numara girin';

  @override
  String get amountMustBePositive => 'Miktar 0\'dan büyük olmalıdır';

  @override
  String get selectAtLeastOneOperation => 'Lütfen en az bir işlem türü seçin';

  @override
  String get selectPerson => 'Lütfen bir kişi seçin';

  @override
  String get selectOrg => 'Lütfen bir kuruluş seçin';

  @override
  String get endDateAfterStart =>
      'Bitiş tarihi başlangıç tarihinden sonra olmalıdır';
}
