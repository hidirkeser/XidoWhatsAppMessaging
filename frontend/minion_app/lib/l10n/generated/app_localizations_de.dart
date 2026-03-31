// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppL10nDe extends AppL10n {
  AppL10nDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Minion';

  @override
  String get bankIdAuthSystem => 'BankID Autorisierungssystem';

  @override
  String get loginWithBankId => 'Mit BankID anmelden';

  @override
  String get loginWithBankIdOtherDevice =>
      'Mit BankID anmelden (anderes Gerät)';

  @override
  String get thisDevice => 'Dieses Gerät';

  @override
  String get otherDevice => 'Anderes Gerät';

  @override
  String get scanQrCode => 'Scannen Sie den QR-Code\nmit Ihrer BankID-App';

  @override
  String get openingBankIdApp => 'BankID-App wird geöffnet...';

  @override
  String get openBankIdApp => 'BankID-App öffnen';

  @override
  String get waitingForApproval => 'Warte auf Ihre BankID-Bestätigung...';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get logout => 'Abmelden';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get delegations => 'Vollmachten';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get profile => 'Profil';

  @override
  String get creditBalance => 'Guthaben';

  @override
  String get buyCredits => 'Credits kaufen';

  @override
  String remainingCredits(int count) {
    return 'Verbleibende Credits: $count';
  }

  @override
  String thisOperationCosts(int count) {
    return 'Dieser Vorgang: $count Credits';
  }

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get grantDelegation => 'Vollmacht erteilen';

  @override
  String get myDelegations => 'Meine Vollmachten';

  @override
  String get recentDelegations => 'Letzte Vollmachten';

  @override
  String get noDelegationsYet => 'Noch keine Vollmachten';

  @override
  String grantedDelegations(int count) {
    return 'Erteilt ($count)';
  }

  @override
  String receivedDelegations(int count) {
    return 'Erhalten ($count)';
  }

  @override
  String get noGrantedDelegations => 'Sie haben noch keine Vollmachten erteilt';

  @override
  String get noReceivedDelegations => 'Keine Vollmachten für Sie';

  @override
  String get all => 'Alle';

  @override
  String get active => 'Aktiv';

  @override
  String get pending => 'Ausstehend';

  @override
  String get rejected => 'Abgelehnt';

  @override
  String get revoked => 'Widerrufen';

  @override
  String get expired => 'Abgelaufen';

  @override
  String get personSelection => 'Personenauswahl';

  @override
  String get searchByPersonnummer =>
      'Nach Personnummer, Name oder E-Mail suchen';

  @override
  String get organization => 'Organisation';

  @override
  String get selectOrganization => 'Organisation auswählen';

  @override
  String get operationTypes => 'Vorgangstypen';

  @override
  String get duration => 'Dauer';

  @override
  String get selectDateRange => 'Datumsbereich auswählen';

  @override
  String get start => 'Start';

  @override
  String get end => 'Ende';

  @override
  String get minutes => 'Minuten';

  @override
  String get hours => 'Stunden';

  @override
  String get days => 'Tage';

  @override
  String get value => 'Wert';

  @override
  String get noteOptional => 'Notiz (optional)';

  @override
  String grantDelegationBtn(int cost) {
    return 'Vollmacht erteilen ($cost Credits)';
  }

  @override
  String get sending => 'Wird gesendet...';

  @override
  String get delegationDetail => 'Vollmacht-Details';

  @override
  String get status => 'Status';

  @override
  String get credits => 'Credits';

  @override
  String get creditHistory => 'Kreditverlauf';

  @override
  String get currentBalance => 'Aktuelles Guthaben';

  @override
  String get noTransactions => 'Noch keine Transaktionen.';

  @override
  String get txPurchase => 'Kreditkauf';

  @override
  String get txDelegationDeduction => 'Delegationsnutzung';

  @override
  String get txRefund => 'Rückerstattung';

  @override
  String get txManualAdjustment => 'Manuelle Anpassung';

  @override
  String get balance => 'Guthaben';

  @override
  String get grantor => 'Vollmachtgeber';

  @override
  String get delegatePerson => 'Bevollmächtigter';

  @override
  String get validityPeriod => 'Gültigkeitszeitraum';

  @override
  String get note => 'Notiz';

  @override
  String get accept => 'Akzeptieren';

  @override
  String get reject => 'Ablehnen';

  @override
  String get revokeDelegation => 'Vollmacht widerrufen';

  @override
  String get delegationAccepted => 'Vollmacht akzeptiert';

  @override
  String get delegationRejected => 'Vollmacht abgelehnt';

  @override
  String get delegationRevoked => 'Vollmacht widerrufen';

  @override
  String get delegationCreated => 'Vollmacht erfolgreich erteilt!';

  @override
  String get purchaseCredits => 'Credits kaufen';

  @override
  String get paymentMethod => 'Zahlungsmethode';

  @override
  String get creditPackages => 'Credit-Pakete';

  @override
  String get noPackagesFound => 'Keine Pakete gefunden';

  @override
  String get payWithSwish => 'Mit Swish bezahlen';

  @override
  String get payWithPaypal => 'Mit PayPal bezahlen';

  @override
  String get payWithKlarna => 'Mit Klarna bezahlen';

  @override
  String get redirectingToPayment => 'Weiterleitung zur Zahlungsseite...';

  @override
  String get paymentInitiated => 'Zahlung eingeleitet';

  @override
  String get noTransactionsYet => 'Noch keine Transaktionen';

  @override
  String get noNotifications => 'Noch keine Benachrichtigungen';

  @override
  String get markAllRead => 'Alle als gelesen markieren';

  @override
  String get justNow => 'Gerade eben';

  @override
  String minutesAgo(int count) {
    return 'Vor $count Min.';
  }

  @override
  String hoursAgo(int count) {
    return 'Vor $count Std.';
  }

  @override
  String daysAgo(int count) {
    return 'Vor $count Tagen';
  }

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get swedish => 'Schwedisch';

  @override
  String get turkish => 'Türkisch';

  @override
  String get german => 'Deutsch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get french => 'Französisch';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get personnummer => 'Personnummer';

  @override
  String get email => 'E-Mail';

  @override
  String get phone => 'Telefon';

  @override
  String get notSpecified => 'Nicht angegeben';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get profileUpdated => 'Profil erfolgreich aktualisiert';

  @override
  String get profileUpdateFailed => 'Profil konnte nicht aktualisiert werden';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get editInfo => 'Informationen bearbeiten';

  @override
  String get theme => 'Thema';

  @override
  String get adminPanel => 'Admin-Panel';

  @override
  String get users => 'Benutzer';

  @override
  String get organizations => 'Organisationen';

  @override
  String get organizationManagement => 'Organisationsverwaltung';

  @override
  String get operationTypeManagement => 'Vorgangstypen';

  @override
  String get userOrgMapping => 'Benutzer-Organisation';

  @override
  String get creditPackageManagement => 'Credit-Pakete';

  @override
  String get auditLog => 'Auditprotokoll';

  @override
  String get management => 'Verwaltung';

  @override
  String get totalUsers => 'Gesamtbenutzer';

  @override
  String get totalOrganizations => 'Gesamtorganisationen';

  @override
  String get activeDelegations => 'Aktive Vollmachten';

  @override
  String get pendingCount => 'Ausstehend';

  @override
  String get totalCredits => 'Gesamte Credits';

  @override
  String get revenueSEK => 'Einnahmen (SEK)';

  @override
  String get newOrganization => 'Neue Organisation';

  @override
  String get editOrganization => 'Organisation bearbeiten';

  @override
  String get deleteOrganization => 'Organisation löschen';

  @override
  String get deleteOrgConfirm =>
      'Möchten Sie diese Organisation wirklich löschen?';

  @override
  String get orgName => 'Organisationsname';

  @override
  String get orgNumber => 'Org-Nummer';

  @override
  String get city => 'Stadt';

  @override
  String get create => 'Erstellen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get newPackage => 'Neues Paket';

  @override
  String get editPackage => 'Paket bearbeiten';

  @override
  String get packageName => 'Paketname';

  @override
  String get creditAmount => 'Credit-Betrag';

  @override
  String get priceSEK => 'Preis (SEK)';

  @override
  String get description => 'Beschreibung';

  @override
  String get error => 'Fehler';

  @override
  String errorOccurred(String message) {
    return 'Ein Fehler ist aufgetreten: $message';
  }

  @override
  String get networkError =>
      'Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung.';

  @override
  String get sessionExpired => 'Sitzung abgelaufen. Bitte erneut anmelden.';

  @override
  String get insufficientCredits => 'Unzureichende Credits. Bitte mehr kaufen.';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get fieldRequired => 'Dieses Feld ist erforderlich';

  @override
  String get invalidEmail => 'Bitte gültige E-Mail-Adresse eingeben';

  @override
  String get invalidPhone => 'Bitte gültige Telefonnummer eingeben';

  @override
  String minLength(int count) {
    return 'Muss mindestens $count Zeichen lang sein';
  }

  @override
  String get invalidPersonnummer => 'Bitte gültige Personnummer eingeben';

  @override
  String get amountMustBePositive => 'Betrag muss größer als 0 sein';

  @override
  String get selectAtLeastOneOperation =>
      'Bitte mindestens einen Vorgangstyp auswählen';

  @override
  String get selectPerson => 'Bitte eine Person auswählen';

  @override
  String get selectOrg => 'Bitte eine Organisation auswählen';

  @override
  String get endDateAfterStart => 'Enddatum muss nach dem Startdatum liegen';

  @override
  String get clear => 'Löschen';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get dialogSuccess => 'Erfolg';

  @override
  String get dialogWarning => 'Warnung';

  @override
  String get dialogInfo => 'Information';

  @override
  String get dialogConfirm => 'Bestätigen';

  @override
  String get areYouSure => 'Sind Sie sicher?';

  @override
  String get confirmAction =>
      'Sind Sie sicher, dass Sie diese Aktion ausführen möchten?';

  @override
  String get revokeConfirm =>
      'Möchten Sie diese Delegation wirklich widerrufen?';

  @override
  String get rejectConfirm => 'Möchten Sie diese Delegation wirklich ablehnen?';

  @override
  String get acceptConfirm =>
      'Möchten Sie diese Delegation wirklich akzeptieren?';

  @override
  String get deleteConfirm => 'Möchten Sie dieses Element wirklich löschen?';

  @override
  String get errCannotDelegateToSelf =>
      'Sie können nicht an sich selbst delegieren.';

  @override
  String get errInvalidOperationTypes =>
      'Ein oder mehrere Vorgangstypen sind ungültig.';

  @override
  String get errOnlyGrantorCanRevoke =>
      'Nur der Gewährende kann diese Delegation widerrufen.';

  @override
  String get errOnlyDelegateCanReject =>
      'Nur der Delegierte kann diese Delegation ablehnen.';

  @override
  String get errOnlyDelegateCanAccept =>
      'Nur der Delegierte kann diese Delegation akzeptieren.';

  @override
  String get errDelegationInvalidStatus =>
      'Die Delegation kann diese Aktion im aktuellen Status nicht ausführen.';

  @override
  String get errUserAlreadyInOrg =>
      'Benutzer ist dieser Organisation bereits zugewiesen.';

  @override
  String get errDelegateUserRequired =>
      'Delegierter Benutzer ist erforderlich.';

  @override
  String get errOrganizationRequired => 'Organisation ist erforderlich.';

  @override
  String get errOperationTypesRequired =>
      'Mindestens ein Vorgangstyp ist erforderlich.';

  @override
  String get errDurationTypeRequired => 'Dauertyp ist erforderlich.';

  @override
  String get errDurationValueInvalid => 'Dauerwert muss größer als 0 sein.';

  @override
  String get errStartDateRequired =>
      'Startdatum ist für Datumsbereich erforderlich.';

  @override
  String get errEndDateRequired =>
      'Enddatum ist für Datumsbereich erforderlich.';

  @override
  String get errEndDateBeforeStart =>
      'Enddatum muss nach dem Startdatum liegen.';

  @override
  String get errOrgNameRequired =>
      'Organisationsname ist erforderlich (max. 200 Zeichen).';

  @override
  String get errOrgNumberRequired => 'Organisationsnummer ist erforderlich.';

  @override
  String get errInvalidEmail => 'Ungültiges E-Mail-Format.';

  @override
  String get errInvalidPhone => 'Ungültiges Telefonnummernformat.';

  @override
  String get errCreditPackageRequired => 'Kreditpaket ist erforderlich.';

  @override
  String get errInvalidPaymentProvider =>
      'Anbieter muss Swish, PayPal oder Klarna sein.';

  @override
  String get errOperationNameRequired =>
      'Name des Vorgangstyps ist erforderlich (max. 200 Zeichen).';

  @override
  String get errCreditCostInvalid =>
      'Kreditkosten müssen 0 oder mehr betragen.';

  @override
  String get errNotFound => 'Datensatz nicht gefunden.';

  @override
  String get errInsufficientCredits =>
      'Nicht genügend Punkte. Bitte kaufen Sie mehr.';

  @override
  String get errForbidden =>
      'Sie haben keine Berechtigung, diese Aktion auszuführen.';

  @override
  String get errUnauthorized =>
      'Sitzung abgelaufen. Bitte melden Sie sich erneut an.';

  @override
  String get errInternalError =>
      'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get errValidationError =>
      'Bitte beheben Sie die Formularfehler und versuchen Sie es erneut.';

  @override
  String get gdprTitle => 'Datenschutz & Datenverwendung';

  @override
  String get gdprSubtitle =>
      'Bitte lesen Sie die folgenden Informationen und stimmen Sie zu, bevor Sie die App verwenden.';

  @override
  String get gdprDataProcessingTitle => 'Ihre persönlichen Daten';

  @override
  String get gdprDataProcessingBody =>
      'Ihre BankID-Authentifizierungsdaten werden zur Verwaltung von Autorisierungsvorgängen verarbeitet. Ihre Personnummer wird verschlüsselt gespeichert.';

  @override
  String get gdprSecurityTitle => 'Datensicherheit';

  @override
  String get gdprSecurityBody =>
      'Ihre Daten werden auf verschlüsselten Azure-Servern gespeichert. Unterzeichnete Dokumente werden gesetzlich 7 Jahre archiviert.';

  @override
  String get gdprRightsTitle => 'Ihre Rechte';

  @override
  String get gdprRightsBody =>
      'Sie haben das Recht, Zugang, Berichtigung und Löschung Ihrer Daten über die Profilseite zu beantragen.';

  @override
  String get gdprRequiredConsentLabel =>
      'Ich stimme der Verarbeitung meiner personenbezogenen Daten für die oben genannten Zwecke zu. (Erforderlich)';

  @override
  String get gdprMarketingConsentLabel =>
      'Ich stimme dem Empfang von Mitteilungen per WhatsApp, E-Mail und App-Benachrichtigungen zu. (Optional)';

  @override
  String get gdprAcceptButton => 'Ich akzeptiere und fahre fort';

  @override
  String get gdprFootnote =>
      'Diese Einwilligung ist gemäß DSGVO und schwedischem PDPL erforderlich.';

  @override
  String get bankIdSignTitle => 'Mit BankID signieren';

  @override
  String get bankIdSignWaiting =>
      'BankID-App wird geöffnet. Bitte bestätigen Sie den Vorgang in Ihrer BankID-App.';

  @override
  String get bankIdSignCompleting => 'Signatur wird abgeschlossen...';

  @override
  String get bankIdSignError => 'Signierung fehlgeschlagen';

  @override
  String get signAndGrantDelegation => 'Mit BankID signieren und erteilen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get notifSettingsTitle => 'Benachrichtigungseinstellungen';

  @override
  String get notifSettingsDesc =>
      'Wählen Sie, über welche Kanäle Sie Benachrichtigungen erhalten möchten.';

  @override
  String get notifChannelInApp => 'In-App';

  @override
  String get notifChannelInAppDesc =>
      'Benachrichtigungen erscheinen in der App';

  @override
  String get notifChannelPush => 'Push-Benachrichtigung';

  @override
  String get notifChannelPushDesc =>
      'Sofortige Benachrichtigungen an Ihr Gerät';

  @override
  String get notifChannelEmail => 'E-Mail';

  @override
  String get notifChannelEmailDesc =>
      'An die E-Mail-Adresse in Ihrem Profil gesendet';

  @override
  String get notifChannelWhatsApp => 'WhatsApp';

  @override
  String get notifChannelWhatsAppDesc => 'WhatsApp-Nachricht über Twilio';

  @override
  String get notifChannelSms => 'SMS';

  @override
  String get notifChannelSmsDesc => 'SMS-Nachricht über Twilio';

  @override
  String get notifChannelInactiveLabel => 'INAKTIV';

  @override
  String get notifChannelInactiveDesc =>
      'Dieser Kanal ist noch nicht konfiguriert.';

  @override
  String get notifRequiresEmail =>
      'Eine E-Mail-Adresse muss in Ihrem Profil angegeben sein.';

  @override
  String get notifRequiresPhone =>
      'Eine Telefonnummer muss in Ihrem Profil angegeben sein.';

  @override
  String get notifSaveSuccess => 'Benachrichtigungseinstellungen gespeichert.';

  @override
  String get products => 'Tarife & Preise';

  @override
  String get individual => 'Einzelperson';

  @override
  String get corporate => 'Unternehmen';

  @override
  String get noProductsAvailable => 'Keine Tarife verfügbar';

  @override
  String get corporateApiAccess => 'Unternehmens-API-Zugang';

  @override
  String get corporateApiDescription =>
      'Registrieren Sie Ihr Unternehmen, um auf unsere API und Enterprise-Funktionen zuzugreifen.';

  @override
  String get applyNow => 'Jetzt bewerben';

  @override
  String get free => 'Kostenlos';

  @override
  String get month => 'Mo.';

  @override
  String get unlimited => 'Unbegrenzt';

  @override
  String get operationsPerMonth => 'Vorgänge/Monat';

  @override
  String get activateFree => 'Kostenlosen Tarif aktivieren';

  @override
  String get subscribe => 'Abonnieren';

  @override
  String get subscriptionActivated => 'Abonnement erfolgreich aktiviert!';

  @override
  String get selectPaymentMethod => 'Zahlungsmethode auswählen';

  @override
  String get confirmPurchase => 'Kauf bestätigen';

  @override
  String get productNotFound => 'Produkt nicht gefunden';

  @override
  String get swishPayment => 'Swish-Zahlung';

  @override
  String get waitingForPayment => 'Warte auf Zahlungsbestätigung...';

  @override
  String get quotaExhausted => 'Kontingent erschöpft';

  @override
  String get quotaExhaustedMessage =>
      'Sie haben alle Ihre Vorgänge für diesen Monat aufgebraucht.';

  @override
  String get upgradeYourPlan => 'Upgraden Sie Ihren Tarif, um fortzufahren.';

  @override
  String get later => 'Später';

  @override
  String get viewPlans => 'Tarife anzeigen';

  @override
  String get corporateApplication => 'Unternehmensantrag';

  @override
  String get corporateApplyInfo =>
      'Geben Sie unten Ihre Unternehmensdaten ein. Unser Team wird Ihren Antrag prüfen und Sie per E-Mail und SMS benachrichtigen.';

  @override
  String get companyInformation => 'Unternehmensinformationen';

  @override
  String get companyName => 'Firmenname';

  @override
  String get contactInformation => 'Kontaktinformationen';

  @override
  String get contactName => 'Kontaktname';

  @override
  String get contactEmail => 'Kontakt-E-Mail';

  @override
  String get contactPhone => 'Kontakttelefon';

  @override
  String get required => 'Dieses Feld ist erforderlich';

  @override
  String get submitApplication => 'Antrag einreichen';

  @override
  String get applicationSubmitted => 'Antrag eingereicht!';

  @override
  String get applicationSubmittedMessage =>
      'Ihr Unternehmensantrag wurde eingereicht. Wir werden ihn prüfen und Sie per E-Mail und SMS benachrichtigen.';

  @override
  String get applicationError =>
      'Antrag konnte nicht eingereicht werden. Bitte versuchen Sie es erneut.';

  @override
  String get backToHome => 'Zurück zur Startseite';

  @override
  String get productManagement => 'Produktverwaltung';

  @override
  String get corporateApplications => 'Unternehmensanträge';

  @override
  String get newProduct => 'Neues Produkt';

  @override
  String get editProduct => 'Produkt bearbeiten';

  @override
  String get productName => 'Produktname';

  @override
  String get monthlyQuota => 'Monatliches Kontingent';

  @override
  String get productType => 'Produkttyp';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String get confirmDeleteProduct =>
      'Möchten Sie dieses Produkt wirklich deaktivieren?';

  @override
  String get noApplications => 'Keine Anträge gefunden';

  @override
  String get approved => 'Genehmigt';

  @override
  String get reviewNote => 'Prüfungsnotiz';

  @override
  String get optional => 'Optional';

  @override
  String get approveApplication => 'Antrag genehmigen';

  @override
  String get rejectApplication => 'Antrag ablehnen';

  @override
  String get approveConfirmMessage =>
      'Dies wird eine Organisation erstellen und den Antragsteller benachrichtigen.';

  @override
  String get rejectConfirmMessage =>
      'Der Antragsteller wird per E-Mail und SMS benachrichtigt.';

  @override
  String get approve => 'Genehmigen';
}
