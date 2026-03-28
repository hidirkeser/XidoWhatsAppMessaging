// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppL10nSv extends AppL10n {
  AppL10nSv([String locale = 'sv']) : super(locale);

  @override
  String get appName => 'Minion';

  @override
  String get bankIdAuthSystem => 'BankID Behörighetssystem';

  @override
  String get loginWithBankId => 'Logga in med BankID';

  @override
  String get thisDevice => 'Den här enheten';

  @override
  String get otherDevice => 'Annan enhet';

  @override
  String get scanQrCode => 'Skanna QR-koden med din\nBankID-app';

  @override
  String get openingBankIdApp => 'Öppnar BankID-appen...';

  @override
  String get openBankIdApp => 'Öppna BankID-appen';

  @override
  String get waitingForApproval => 'Väntar på ditt BankID-godkännande...';

  @override
  String get cancel => 'Avbryt';

  @override
  String get logout => 'Logga ut';

  @override
  String get dashboard => 'Översikt';

  @override
  String get delegations => 'Behörigheter';

  @override
  String get notifications => 'Notiser';

  @override
  String get profile => 'Profil';

  @override
  String get creditBalance => 'Kontosaldo';

  @override
  String get buyCredits => 'Köp kontör';

  @override
  String remainingCredits(int count) {
    return 'Kvarvarande kontör: $count';
  }

  @override
  String thisOperationCosts(int count) {
    return 'Denna åtgärd: $count kontör';
  }

  @override
  String get quickActions => 'Snabbåtgärder';

  @override
  String get grantDelegation => 'Ge behörighet';

  @override
  String get myDelegations => 'Mina behörigheter';

  @override
  String get recentDelegations => 'Senaste behörigheter';

  @override
  String get noDelegationsYet => 'Inga behörigheter ännu';

  @override
  String grantedDelegations(int count) {
    return 'Givna ($count)';
  }

  @override
  String receivedDelegations(int count) {
    return 'Mottagna ($count)';
  }

  @override
  String get noGrantedDelegations => 'Du har inte gett några behörigheter';

  @override
  String get noReceivedDelegations => 'Inga behörigheter givna till dig';

  @override
  String get all => 'Alla';

  @override
  String get active => 'Aktiv';

  @override
  String get pending => 'Väntande';

  @override
  String get rejected => 'Avvisad';

  @override
  String get revoked => 'Återkallad';

  @override
  String get expired => 'Utgången';

  @override
  String get personSelection => 'Välj person';

  @override
  String get searchByPersonnummer => 'Sök med personnummer, namn eller e-post';

  @override
  String get organization => 'Organisation';

  @override
  String get selectOrganization => 'Välj organisation';

  @override
  String get operationTypes => 'Åtgärdstyper';

  @override
  String get duration => 'Varaktighet';

  @override
  String get selectDateRange => 'Välj datumintervall';

  @override
  String get start => 'Start';

  @override
  String get end => 'Slut';

  @override
  String get minutes => 'Minuter';

  @override
  String get hours => 'Timmar';

  @override
  String get days => 'Dagar';

  @override
  String get value => 'Värde';

  @override
  String get noteOptional => 'Anteckning (valfritt)';

  @override
  String grantDelegationBtn(int cost) {
    return 'Ge behörighet ($cost kontör)';
  }

  @override
  String get sending => 'Skickar...';

  @override
  String get delegationDetail => 'Behörighetsdetalj';

  @override
  String get status => 'Status';

  @override
  String get credits => 'Kontör';

  @override
  String get grantor => 'Behörighetsgivare';

  @override
  String get delegatePerson => 'Behörig person';

  @override
  String get validityPeriod => 'Giltighetsperiod';

  @override
  String get note => 'Anteckning';

  @override
  String get accept => 'Acceptera';

  @override
  String get reject => 'Avvisa';

  @override
  String get revokeDelegation => 'Återkalla behörighet';

  @override
  String get delegationAccepted => 'Behörighet accepterad';

  @override
  String get delegationRejected => 'Behörighet avvisad';

  @override
  String get delegationRevoked => 'Behörighet återkallad';

  @override
  String get delegationCreated => 'Behörighet har getts!';

  @override
  String get purchaseCredits => 'Köp kontör';

  @override
  String get paymentMethod => 'Betalningsmetod';

  @override
  String get creditPackages => 'Kontörpaket';

  @override
  String get noPackagesFound => 'Inga paket hittades';

  @override
  String get payWithSwish => 'Betala med Swish';

  @override
  String get payWithPaypal => 'Betala med PayPal';

  @override
  String get payWithKlarna => 'Betala med Klarna';

  @override
  String get redirectingToPayment => 'Omdirigerar till betalningssidan...';

  @override
  String get paymentInitiated => 'Betalning initierad';

  @override
  String get creditHistory => 'Kontörhistorik';

  @override
  String get noTransactionsYet => 'Inga transaktioner ännu';

  @override
  String get noNotifications => 'Inga notiser ännu';

  @override
  String get markAllRead => 'Markera alla som lästa';

  @override
  String get justNow => 'Nyss';

  @override
  String minutesAgo(int count) {
    return '$count min sedan';
  }

  @override
  String hoursAgo(int count) {
    return '$count timmar sedan';
  }

  @override
  String daysAgo(int count) {
    return '$count dagar sedan';
  }

  @override
  String get language => 'Språk';

  @override
  String get english => 'Engelska';

  @override
  String get swedish => 'Svenska';

  @override
  String get turkish => 'Turkiska';

  @override
  String get german => 'Tyska';

  @override
  String get spanish => 'Spanska';

  @override
  String get french => 'Franska';

  @override
  String get appLanguage => 'Appspråk';

  @override
  String get fullName => 'Fullständigt namn';

  @override
  String get personnummer => 'Personnummer';

  @override
  String get email => 'E-post';

  @override
  String get phone => 'Telefon';

  @override
  String get notSpecified => 'Ej angivet';

  @override
  String get editProfile => 'Redigera profil';

  @override
  String get firstName => 'Förnamn';

  @override
  String get lastName => 'Efternamn';

  @override
  String get profileUpdated => 'Profilen har uppdaterats';

  @override
  String get profileUpdateFailed => 'Det gick inte att uppdatera profilen';

  @override
  String get saveChanges => 'Spara ändringar';

  @override
  String get editInfo => 'Redigera information';

  @override
  String get theme => 'Tema';

  @override
  String get adminPanel => 'Adminpanel';

  @override
  String get users => 'Användare';

  @override
  String get organizations => 'Organisationer';

  @override
  String get organizationManagement => 'Organisationshantering';

  @override
  String get operationTypeManagement => 'Åtgärdstyper';

  @override
  String get userOrgMapping => 'Användare-Organisation';

  @override
  String get creditPackageManagement => 'Kontörpaket';

  @override
  String get auditLog => 'Granskningslogg';

  @override
  String get management => 'Hantering';

  @override
  String get totalUsers => 'Totala användare';

  @override
  String get totalOrganizations => 'Totala organisationer';

  @override
  String get activeDelegations => 'Aktiva behörigheter';

  @override
  String get pendingCount => 'Väntande';

  @override
  String get totalCredits => 'Totala kontör';

  @override
  String get revenueSEK => 'Intäkter (SEK)';

  @override
  String get newOrganization => 'Ny organisation';

  @override
  String get editOrganization => 'Redigera organisation';

  @override
  String get deleteOrganization => 'Ta bort organisation';

  @override
  String get deleteOrgConfirm =>
      'Är du säker på att du vill ta bort denna organisation?';

  @override
  String get orgName => 'Organisationsnamn';

  @override
  String get orgNumber => 'Org-nummer';

  @override
  String get city => 'Stad';

  @override
  String get create => 'Skapa';

  @override
  String get save => 'Spara';

  @override
  String get delete => 'Ta bort';

  @override
  String get newPackage => 'Nytt paket';

  @override
  String get editPackage => 'Redigera paket';

  @override
  String get packageName => 'Paketnamn';

  @override
  String get creditAmount => 'Antal kontör';

  @override
  String get priceSEK => 'Pris (SEK)';

  @override
  String get description => 'Beskrivning';

  @override
  String get error => 'Fel';

  @override
  String errorOccurred(String message) {
    return 'Ett fel uppstod: $message';
  }

  @override
  String get networkError => 'Nätverksfel. Kontrollera din anslutning.';

  @override
  String get sessionExpired => 'Sessionen har gått ut. Logga in igen.';

  @override
  String get insufficientCredits => 'Otillräckliga kontör. Köp fler.';

  @override
  String get loading => 'Laddar...';

  @override
  String get fieldRequired => 'Detta fält är obligatoriskt';

  @override
  String get invalidEmail => 'Ange en giltig e-postadress';

  @override
  String get invalidPhone => 'Ange ett giltigt telefonnummer';

  @override
  String minLength(int count) {
    return 'Måste vara minst $count tecken';
  }

  @override
  String get invalidPersonnummer => 'Ange ett giltigt personnummer';

  @override
  String get amountMustBePositive => 'Beloppet måste vara större än 0';

  @override
  String get selectAtLeastOneOperation => 'Välj minst en åtgärdstyp';

  @override
  String get selectPerson => 'Välj en person';

  @override
  String get selectOrg => 'Välj en organisation';

  @override
  String get endDateAfterStart => 'Slutdatum måste vara efter startdatum';
}
