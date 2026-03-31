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
  String get loginWithBankIdOtherDevice => 'BankID ile Giriş Yap (Başka Cihaz)';

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
  String get creditHistory => 'Kredi Hareketleri';

  @override
  String get currentBalance => 'Güncel Bakiye';

  @override
  String get noTransactions => 'Henüz işlem yok.';

  @override
  String get txPurchase => 'Kredi Satın Alma';

  @override
  String get txDelegationDeduction => 'Yetki Kullanımı';

  @override
  String get txRefund => 'İade';

  @override
  String get txManualAdjustment => 'Manuel Düzenleme';

  @override
  String get balance => 'Bakiye';

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

  @override
  String get clear => 'Temizle';

  @override
  String get ok => 'Tamam';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get dialogSuccess => 'Başarılı';

  @override
  String get dialogWarning => 'Uyarı';

  @override
  String get dialogInfo => 'Bilgi';

  @override
  String get dialogConfirm => 'Onay';

  @override
  String get areYouSure => 'Emin misiniz?';

  @override
  String get confirmAction => 'Bu işlemi yapmak istediğinizden emin misiniz?';

  @override
  String get revokeConfirm =>
      'Yetkiyi iptal etmek istediğinizden emin misiniz?';

  @override
  String get rejectConfirm => 'Yetkiyi reddetmek istediğinizden emin misiniz?';

  @override
  String get acceptConfirm =>
      'Yetkiyi kabul etmek istediğinizden emin misiniz?';

  @override
  String get deleteConfirm => 'Silmek istediğinizden emin misiniz?';

  @override
  String get errCannotDelegateToSelf => 'Kendinize yetki veremezsiniz.';

  @override
  String get errInvalidOperationTypes =>
      'Bir veya daha fazla işlem türü geçersiz.';

  @override
  String get errOnlyGrantorCanRevoke =>
      'Yetkiyi yalnızca yetki veren iptal edebilir.';

  @override
  String get errOnlyDelegateCanReject =>
      'Yetkiyi yalnızca yetkili kişi reddedebilir.';

  @override
  String get errOnlyDelegateCanAccept =>
      'Yetkiyi yalnızca yetkili kişi kabul edebilir.';

  @override
  String get errDelegationInvalidStatus =>
      'Yetki mevcut durumda bu işlem için uygun değil.';

  @override
  String get errUserAlreadyInOrg => 'Kullanıcı zaten bu kuruluşa atanmış.';

  @override
  String get errDelegateUserRequired => 'Yetkili kişi seçimi zorunludur.';

  @override
  String get errOrganizationRequired => 'Kuruluş seçimi zorunludur.';

  @override
  String get errOperationTypesRequired => 'En az bir işlem türü seçilmelidir.';

  @override
  String get errDurationTypeRequired => 'Süre türü zorunludur.';

  @override
  String get errDurationValueInvalid => 'Süre değeri 0\'dan büyük olmalıdır.';

  @override
  String get errStartDateRequired =>
      'Tarih aralığı için başlangıç tarihi zorunludur.';

  @override
  String get errEndDateRequired =>
      'Tarih aralığı için bitiş tarihi zorunludur.';

  @override
  String get errEndDateBeforeStart =>
      'Bitiş tarihi başlangıç tarihinden sonra olmalıdır.';

  @override
  String get errOrgNameRequired =>
      'Kuruluş adı zorunludur (maks. 200 karakter).';

  @override
  String get errOrgNumberRequired => 'Kuruluş numarası zorunludur.';

  @override
  String get errInvalidEmail => 'Geçersiz e-posta formatı.';

  @override
  String get errInvalidPhone => 'Geçersiz telefon numarası formatı.';

  @override
  String get errCreditPackageRequired => 'Kredi paketi seçimi zorunludur.';

  @override
  String get errInvalidPaymentProvider =>
      'Ödeme sağlayıcısı Swish, PayPal veya Klarna olmalıdır.';

  @override
  String get errOperationNameRequired =>
      'İşlem türü adı zorunludur (maks. 200 karakter).';

  @override
  String get errCreditCostInvalid =>
      'Kredi maliyeti 0 veya daha fazla olmalıdır.';

  @override
  String get errNotFound => 'Kayıt bulunamadı.';

  @override
  String get errInsufficientCredits =>
      'Yetersiz kredi. Lütfen daha fazla satın alın.';

  @override
  String get errForbidden => 'Bu işlem için yetkiniz yok.';

  @override
  String get errUnauthorized =>
      'Oturum süresi doldu. Lütfen tekrar giriş yapın.';

  @override
  String get errInternalError =>
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get errValidationError => 'Lütfen form hatalarını düzeltin.';

  @override
  String get gdprTitle => 'Gizlilik ve Veri Kullanımı';

  @override
  String get gdprSubtitle =>
      'Uygulamayı kullanmadan önce lütfen aşağıdaki bilgileri okuyun ve onaylayın.';

  @override
  String get gdprDataProcessingTitle => 'Kişisel Verileriniz';

  @override
  String get gdprDataProcessingBody =>
      'BankID kimlik doğrulama verileriniz, yetkilendirme işlemlerini yönetmek amacıyla işlenmektedir. Personnummer\'ınız şifreli olarak saklanır.';

  @override
  String get gdprSecurityTitle => 'Veri Güvenliği';

  @override
  String get gdprSecurityBody =>
      'Verileriniz şifreli Azure sunucularında saklanmakta ve yetkisiz erişime karşı korunmaktadır. İmzalı belgeler yasal zorunluluk gereği 7 yıl arşivlenmektedir.';

  @override
  String get gdprRightsTitle => 'Haklarınız';

  @override
  String get gdprRightsBody =>
      'Verilerinize erişim, düzeltme ve silme talep etme hakkına sahipsiniz. Profil sayfanızdan veri dışa aktarma veya hesap silme işlemlerini gerçekleştirebilirsiniz.';

  @override
  String get gdprRequiredConsentLabel =>
      'Kişisel verilerimin yukarıda belirtilen amaçlar doğrultusunda işlenmesini kabul ediyorum. (Zorunlu)';

  @override
  String get gdprMarketingConsentLabel =>
      'WhatsApp, e-posta ve uygulama içi bildirimler yoluyla iletişim almayı kabul ediyorum. (İsteğe bağlı)';

  @override
  String get gdprAcceptButton => 'Kabul Ediyorum ve Devam Ediyorum';

  @override
  String get gdprFootnote =>
      'Bu onay GDPR ve İsveç PDPL kapsamında gereklidir.';

  @override
  String get bankIdSignTitle => 'BankID ile İmzala';

  @override
  String get bankIdSignWaiting =>
      'BankID uygulamanız açılıyor. Lütfen BankID uygulamanızda işlemi onaylayın.';

  @override
  String get bankIdSignCompleting => 'İmza tamamlanıyor...';

  @override
  String get bankIdSignError => 'İmzalama başarısız';

  @override
  String get signAndGrantDelegation => 'BankID ile İmzala ve Yetki Ver';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get notifSettingsTitle => 'Bildirim Ayarları';

  @override
  String get notifSettingsDesc =>
      'Bildirimleri hangi kanallardan almak istediğinizi seçin.';

  @override
  String get notifChannelInApp => 'Uygulama İçi';

  @override
  String get notifChannelInAppDesc => 'Bildirimler uygulama içinde görünür';

  @override
  String get notifChannelPush => 'Push Bildirimi';

  @override
  String get notifChannelPushDesc => 'Telefona anlık bildirim gönderilir';

  @override
  String get notifChannelEmail => 'E-posta';

  @override
  String get notifChannelEmailDesc =>
      'Profildeki e-posta adresinize gönderilir';

  @override
  String get notifChannelWhatsApp => 'WhatsApp';

  @override
  String get notifChannelWhatsAppDesc =>
      'Twilio üzerinden WhatsApp mesajı gönderilir';

  @override
  String get notifChannelSms => 'SMS';

  @override
  String get notifChannelSmsDesc => 'Twilio üzerinden SMS gönderilir';

  @override
  String get notifChannelInactiveLabel => 'PASİF';

  @override
  String get notifChannelInactiveDesc => 'Bu kanal henüz yapılandırılmamıştır.';

  @override
  String get notifRequiresEmail => 'Profilde e-posta adresi tanımlı olmalıdır.';

  @override
  String get notifRequiresPhone =>
      'Profilde telefon numarası tanımlı olmalıdır.';

  @override
  String get notifSaveSuccess => 'Bildirim ayarları kaydedildi.';

  @override
  String get products => 'Planlar ve Fiyatlandırma';

  @override
  String get individual => 'Bireysel';

  @override
  String get corporate => 'Kurumsal';

  @override
  String get noProductsAvailable => 'Mevcut plan bulunamadı';

  @override
  String get corporateApiAccess => 'Kurumsal API Erişimi';

  @override
  String get corporateApiDescription =>
      'API ve kurumsal özelliklere erişmek için şirketinizi kaydedin.';

  @override
  String get applyNow => 'Şimdi Başvur';

  @override
  String get free => 'Ücretsiz';

  @override
  String get month => 'ay';

  @override
  String get unlimited => 'Sınırsız';

  @override
  String get operationsPerMonth => 'işlem/ay';

  @override
  String get activateFree => 'Ücretsiz Planı Etkinleştir';

  @override
  String get subscribe => 'Abone Ol';

  @override
  String get subscriptionActivated => 'Abonelik başarıyla etkinleştirildi!';

  @override
  String get selectPaymentMethod => 'Ödeme Yöntemini Seçin';

  @override
  String get confirmPurchase => 'Satın Almayı Onayla';

  @override
  String get productNotFound => 'Ürün bulunamadı';

  @override
  String get swishPayment => 'Swish Ödeme';

  @override
  String get waitingForPayment => 'Ödeme onayı bekleniyor...';

  @override
  String get quotaExhausted => 'Kota Tükendi';

  @override
  String get quotaExhaustedMessage =>
      'Bu ay için tüm işlem hakkınızı kullandınız.';

  @override
  String get upgradeYourPlan => 'Devam etmek için planınızı yükseltin.';

  @override
  String get later => 'Sonra';

  @override
  String get viewPlans => 'Planları Görüntüle';

  @override
  String get corporateApplication => 'Kurumsal Başvuru';

  @override
  String get corporateApplyInfo =>
      'Aşağıya şirket bilgilerinizi doldurun. Ekibimiz başvurunuzu inceleyip e-posta ve SMS ile size dönüş yapacaktır.';

  @override
  String get companyInformation => 'Şirket Bilgileri';

  @override
  String get companyName => 'Şirket Adı';

  @override
  String get contactInformation => 'İletişim Bilgileri';

  @override
  String get contactName => 'İletişim Kişisi';

  @override
  String get contactEmail => 'İletişim E-posta';

  @override
  String get contactPhone => 'İletişim Telefon';

  @override
  String get required => 'Bu alan zorunludur';

  @override
  String get submitApplication => 'Başvuruyu Gönder';

  @override
  String get applicationSubmitted => 'Başvuru Gönderildi!';

  @override
  String get applicationSubmittedMessage =>
      'Kurumsal başvurunuz gönderildi. İnceledikten sonra e-posta ve SMS ile bilgilendireceğiz.';

  @override
  String get applicationError =>
      'Başvuru gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get backToHome => 'Ana Sayfaya Dön';

  @override
  String get productManagement => 'Ürün Yönetimi';

  @override
  String get corporateApplications => 'Kurumsal Başvurular';

  @override
  String get newProduct => 'Yeni Ürün';

  @override
  String get editProduct => 'Ürünü Düzenle';

  @override
  String get productName => 'Ürün Adı';

  @override
  String get monthlyQuota => 'Aylık Kota';

  @override
  String get productType => 'Ürün Tipi';

  @override
  String get confirmDelete => 'Silme Onayı';

  @override
  String get confirmDeleteProduct =>
      'Bu ürünü devre dışı bırakmak istediğinizden emin misiniz?';

  @override
  String get noApplications => 'Başvuru bulunamadı';

  @override
  String get approved => 'Onaylandı';

  @override
  String get reviewNote => 'İnceleme Notu';

  @override
  String get optional => 'İsteğe bağlı';

  @override
  String get approveApplication => 'Başvuruyu Onayla';

  @override
  String get rejectApplication => 'Başvuruyu Reddet';

  @override
  String get approveConfirmMessage =>
      'Bu işlem bir organizasyon oluşturacak ve başvuru sahibine bildirim gönderecektir.';

  @override
  String get rejectConfirmMessage =>
      'Başvuru sahibine e-posta ve SMS ile bildirim yapılacaktır.';

  @override
  String get approve => 'Onayla';
}
