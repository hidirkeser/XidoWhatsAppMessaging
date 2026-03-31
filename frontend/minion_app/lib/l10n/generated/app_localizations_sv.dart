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
  String get loginWithBankIdOtherDevice => 'Logga in med BankID (annan enhet)';

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
  String get creditHistory => 'Kredittransaktioner';

  @override
  String get currentBalance => 'Aktuellt saldo';

  @override
  String get noTransactions => 'Inga transaktioner ännu.';

  @override
  String get txPurchase => 'Kreditköp';

  @override
  String get txDelegationDeduction => 'Delegationsanvändning';

  @override
  String get txRefund => 'Återbetalning';

  @override
  String get txManualAdjustment => 'Manuell justering';

  @override
  String get balance => 'Saldo';

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

  @override
  String get clear => 'Rensa';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nej';

  @override
  String get dialogSuccess => 'Lyckades';

  @override
  String get dialogWarning => 'Varning';

  @override
  String get dialogInfo => 'Information';

  @override
  String get dialogConfirm => 'Bekräfta';

  @override
  String get areYouSure => 'Är du säker?';

  @override
  String get confirmAction => 'Är du säker på att du vill utföra denna åtgärd?';

  @override
  String get revokeConfirm =>
      'Är du säker på att du vill återkalla denna delegering?';

  @override
  String get rejectConfirm =>
      'Är du säker på att du vill avvisa denna delegering?';

  @override
  String get acceptConfirm =>
      'Är du säker på att du vill acceptera denna delegering?';

  @override
  String get deleteConfirm => 'Är du säker på att du vill ta bort detta?';

  @override
  String get errCannotDelegateToSelf => 'Du kan inte delegera till dig själv.';

  @override
  String get errInvalidOperationTypes =>
      'En eller flera åtgärdstyper är ogiltiga.';

  @override
  String get errOnlyGrantorCanRevoke =>
      'Endast beviljaren kan återkalla denna delegering.';

  @override
  String get errOnlyDelegateCanReject =>
      'Endast delegaten kan avvisa denna delegering.';

  @override
  String get errOnlyDelegateCanAccept =>
      'Endast delegaten kan acceptera denna delegering.';

  @override
  String get errDelegationInvalidStatus =>
      'Delegeringen kan inte utföra denna åtgärd i nuvarande status.';

  @override
  String get errUserAlreadyInOrg =>
      'Användaren är redan tilldelad denna organisation.';

  @override
  String get errDelegateUserRequired => 'Delegatanvändare krävs.';

  @override
  String get errOrganizationRequired => 'Organisation krävs.';

  @override
  String get errOperationTypesRequired => 'Minst en åtgärdstyp krävs.';

  @override
  String get errDurationTypeRequired => 'Varaktighetstyp krävs.';

  @override
  String get errDurationValueInvalid =>
      'Varaktighetsvärde måste vara större än 0.';

  @override
  String get errStartDateRequired => 'Startdatum krävs för datumintervall.';

  @override
  String get errEndDateRequired => 'Slutdatum krävs för datumintervall.';

  @override
  String get errEndDateBeforeStart => 'Slutdatum måste vara efter startdatum.';

  @override
  String get errOrgNameRequired => 'Organisationsnamn krävs (max 200 tecken).';

  @override
  String get errOrgNumberRequired => 'Organisationsnummer krävs.';

  @override
  String get errInvalidEmail => 'Ogiltigt e-postformat.';

  @override
  String get errInvalidPhone => 'Ogiltigt telefonnummerformat.';

  @override
  String get errCreditPackageRequired => 'Kreditpaket krävs.';

  @override
  String get errInvalidPaymentProvider =>
      'Betalningsleverantör måste vara Swish, PayPal eller Klarna.';

  @override
  String get errOperationNameRequired =>
      'Åtgärdstypsnamn krävs (max 200 tecken).';

  @override
  String get errCreditCostInvalid => 'Kreditkostnad måste vara 0 eller mer.';

  @override
  String get errNotFound => 'Posten hittades inte.';

  @override
  String get errInsufficientCredits => 'Otillräckliga poäng. Vänligen köp mer.';

  @override
  String get errForbidden => 'Du har inte behörighet att utföra denna åtgärd.';

  @override
  String get errUnauthorized =>
      'Sessionen har gått ut. Vänligen logga in igen.';

  @override
  String get errInternalError => 'Ett oväntat fel inträffade. Försök igen.';

  @override
  String get errValidationError => 'Åtgärda formulärfelen och försök igen.';

  @override
  String get gdprTitle => 'Integritet och dataanvändning';

  @override
  String get gdprSubtitle =>
      'Vänligen läs följande information och godkänn innan du använder appen.';

  @override
  String get gdprDataProcessingTitle => 'Dina personuppgifter';

  @override
  String get gdprDataProcessingBody =>
      'Dina BankID-autentiseringsdata behandlas för att hantera auktoriseringstransaktioner. Ditt personnummer lagras krypterat.';

  @override
  String get gdprSecurityTitle => 'Datasäkerhet';

  @override
  String get gdprSecurityBody =>
      'Dina uppgifter lagras på krypterade Azure-servrar och skyddas mot obehörig åtkomst. Signerade dokument arkiveras i 7 år enligt lag.';

  @override
  String get gdprRightsTitle => 'Dina rättigheter';

  @override
  String get gdprRightsBody =>
      'Du har rätt att begära tillgång, korrigering och radering av dina uppgifter via profilsidan.';

  @override
  String get gdprRequiredConsentLabel =>
      'Jag godkänner behandling av mina personuppgifter för ovanstående ändamål. (Obligatorisk)';

  @override
  String get gdprMarketingConsentLabel =>
      'Jag godkänner att ta emot kommunikation via WhatsApp, e-post och notiser. (Valfri)';

  @override
  String get gdprAcceptButton => 'Jag godkänner och fortsätter';

  @override
  String get gdprFootnote =>
      'Detta samtycke krävs enligt GDPR och svensk PDPL.';

  @override
  String get bankIdSignTitle => 'Signera med BankID';

  @override
  String get bankIdSignWaiting =>
      'BankID-appen öppnas. Vänligen bekräfta åtgärden i din BankID-app.';

  @override
  String get bankIdSignCompleting => 'Signatur slutförs...';

  @override
  String get bankIdSignError => 'Signering misslyckades';

  @override
  String get signAndGrantDelegation => 'Signera med BankID och bevilja';

  @override
  String get retry => 'Försök igen';

  @override
  String get notifSettingsTitle => 'Aviseringsinställningar';

  @override
  String get notifSettingsDesc =>
      'Välj vilka kanaler du vill ta emot aviseringar från.';

  @override
  String get notifChannelInApp => 'I appen';

  @override
  String get notifChannelInAppDesc => 'Aviseringar visas inuti appen';

  @override
  String get notifChannelPush => 'Push-avisering';

  @override
  String get notifChannelPushDesc => 'Direktaviseringar skickas till din enhet';

  @override
  String get notifChannelEmail => 'E-post';

  @override
  String get notifChannelEmailDesc =>
      'Skickas till e-postadressen i din profil';

  @override
  String get notifChannelWhatsApp => 'WhatsApp';

  @override
  String get notifChannelWhatsAppDesc => 'WhatsApp-meddelande via Twilio';

  @override
  String get notifChannelSms => 'SMS';

  @override
  String get notifChannelSmsDesc => 'SMS-meddelande via Twilio';

  @override
  String get notifChannelInactiveLabel => 'INAKTIV';

  @override
  String get notifChannelInactiveDesc =>
      'Den här kanalen är inte konfigurerad än.';

  @override
  String get notifRequiresEmail => 'En e-postadress måste anges i din profil.';

  @override
  String get notifRequiresPhone =>
      'Ett telefonnummer måste anges i din profil.';

  @override
  String get notifSaveSuccess => 'Aviseringsinställningar sparade.';

  @override
  String get products => 'Planer och priser';

  @override
  String get individual => 'Individuell';

  @override
  String get corporate => 'Företag';

  @override
  String get noProductsAvailable => 'Inga planer tillgängliga';

  @override
  String get corporateApiAccess => 'Företags-API-åtkomst';

  @override
  String get corporateApiDescription =>
      'Registrera ditt företag för API-åtkomst och företagsfunktioner.';

  @override
  String get applyNow => 'Ansök nu';

  @override
  String get free => 'Gratis';

  @override
  String get month => 'mån';

  @override
  String get unlimited => 'Obegränsat';

  @override
  String get operationsPerMonth => 'operationer/månad';

  @override
  String get activateFree => 'Aktivera gratisplan';

  @override
  String get subscribe => 'Prenumerera';

  @override
  String get subscriptionActivated => 'Prenumeration aktiverad!';

  @override
  String get selectPaymentMethod => 'Välj betalningsmetod';

  @override
  String get confirmPurchase => 'Bekräfta köp';

  @override
  String get productNotFound => 'Produkten hittades inte';

  @override
  String get swishPayment => 'Swish-betalning';

  @override
  String get waitingForPayment => 'Väntar på betalningsbekräftelse...';

  @override
  String get quotaExhausted => 'Kvoten är slut';

  @override
  String get quotaExhaustedMessage =>
      'Du har förbrukat alla dina operationer denna månad.';

  @override
  String get upgradeYourPlan => 'Uppgradera din plan för att fortsätta.';

  @override
  String get later => 'Senare';

  @override
  String get viewPlans => 'Visa planer';

  @override
  String get corporateApplication => 'Företagsansökan';

  @override
  String get corporateApplyInfo =>
      'Fyll i dina företagsuppgifter. Vårt team granskar din ansökan och återkommer via e-post och SMS.';

  @override
  String get companyInformation => 'Företagsinformation';

  @override
  String get companyName => 'Företagsnamn';

  @override
  String get contactInformation => 'Kontaktinformation';

  @override
  String get contactName => 'Kontaktperson';

  @override
  String get contactEmail => 'Kontakt-e-post';

  @override
  String get contactPhone => 'Kontakttelefon';

  @override
  String get required => 'Detta fält är obligatoriskt';

  @override
  String get submitApplication => 'Skicka ansökan';

  @override
  String get applicationSubmitted => 'Ansökan skickad!';

  @override
  String get applicationSubmittedMessage =>
      'Din företagsansökan har skickats. Vi granskar den och meddelar dig via e-post och SMS.';

  @override
  String get applicationError => 'Misslyckades med att skicka ansökan.';

  @override
  String get backToHome => 'Tillbaka till startsidan';

  @override
  String get productManagement => 'Produkthantering';

  @override
  String get corporateApplications => 'Företagsansökningar';

  @override
  String get newProduct => 'Ny produkt';

  @override
  String get editProduct => 'Redigera produkt';

  @override
  String get productName => 'Produktnamn';

  @override
  String get monthlyQuota => 'Månadskvot';

  @override
  String get productType => 'Produkttyp';

  @override
  String get confirmDelete => 'Bekräfta radering';

  @override
  String get confirmDeleteProduct => 'Vill du inaktivera denna produkt?';

  @override
  String get noApplications => 'Inga ansökningar hittades';

  @override
  String get approved => 'Godkänd';

  @override
  String get reviewNote => 'Granskningsnotering';

  @override
  String get optional => 'Valfritt';

  @override
  String get approveApplication => 'Godkänn ansökan';

  @override
  String get rejectApplication => 'Avvisa ansökan';

  @override
  String get approveConfirmMessage =>
      'Detta skapar en organisation och meddelar sökanden.';

  @override
  String get rejectConfirmMessage => 'Sökanden meddelas via e-post och SMS.';

  @override
  String get approve => 'Godkänn';
}
