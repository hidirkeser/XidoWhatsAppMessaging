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
  String get creditHistory => 'Credit-Verlauf';

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
}
