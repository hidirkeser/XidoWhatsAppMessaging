import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n? of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n);
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('sv'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Minion'**
  String get appName;

  /// No description provided for @bankIdAuthSystem.
  ///
  /// In en, this message translates to:
  /// **'BankID Authorization System'**
  String get bankIdAuthSystem;

  /// No description provided for @loginWithBankId.
  ///
  /// In en, this message translates to:
  /// **'Login with BankID'**
  String get loginWithBankId;

  /// No description provided for @loginWithBankIdOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Log in with BankID (Other Device)'**
  String get loginWithBankIdOtherDevice;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @otherDevice.
  ///
  /// In en, this message translates to:
  /// **'Other device'**
  String get otherDevice;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code with your\nBankID app'**
  String get scanQrCode;

  /// No description provided for @openingBankIdApp.
  ///
  /// In en, this message translates to:
  /// **'Opening BankID app...'**
  String get openingBankIdApp;

  /// No description provided for @openBankIdApp.
  ///
  /// In en, this message translates to:
  /// **'Open BankID App'**
  String get openBankIdApp;

  /// No description provided for @waitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your BankID approval...'**
  String get waitingForApproval;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @delegations.
  ///
  /// In en, this message translates to:
  /// **'Delegations'**
  String get delegations;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @creditBalance.
  ///
  /// In en, this message translates to:
  /// **'Credit Balance'**
  String get creditBalance;

  /// No description provided for @buyCredits.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get buyCredits;

  /// No description provided for @remainingCredits.
  ///
  /// In en, this message translates to:
  /// **'Remaining credits: {count}'**
  String remainingCredits(int count);

  /// No description provided for @thisOperationCosts.
  ///
  /// In en, this message translates to:
  /// **'This operation: {count} credits'**
  String thisOperationCosts(int count);

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @grantDelegation.
  ///
  /// In en, this message translates to:
  /// **'Grant Delegation'**
  String get grantDelegation;

  /// No description provided for @myDelegations.
  ///
  /// In en, this message translates to:
  /// **'My Delegations'**
  String get myDelegations;

  /// No description provided for @recentDelegations.
  ///
  /// In en, this message translates to:
  /// **'Recent Delegations'**
  String get recentDelegations;

  /// No description provided for @noDelegationsYet.
  ///
  /// In en, this message translates to:
  /// **'No delegations yet'**
  String get noDelegationsYet;

  /// No description provided for @grantedDelegations.
  ///
  /// In en, this message translates to:
  /// **'Granted ({count})'**
  String grantedDelegations(int count);

  /// No description provided for @receivedDelegations.
  ///
  /// In en, this message translates to:
  /// **'Received ({count})'**
  String receivedDelegations(int count);

  /// No description provided for @noGrantedDelegations.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t granted any delegations'**
  String get noGrantedDelegations;

  /// No description provided for @noReceivedDelegations.
  ///
  /// In en, this message translates to:
  /// **'No delegations granted to you'**
  String get noReceivedDelegations;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @revoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get revoked;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @personSelection.
  ///
  /// In en, this message translates to:
  /// **'Person Selection'**
  String get personSelection;

  /// No description provided for @searchByPersonnummer.
  ///
  /// In en, this message translates to:
  /// **'Search by personnummer, name or email'**
  String get searchByPersonnummer;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @selectOrganization.
  ///
  /// In en, this message translates to:
  /// **'Select organization'**
  String get selectOrganization;

  /// No description provided for @operationTypes.
  ///
  /// In en, this message translates to:
  /// **'Operation Types'**
  String get operationTypes;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRange;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @grantDelegationBtn.
  ///
  /// In en, this message translates to:
  /// **'Grant Delegation ({cost} credits)'**
  String grantDelegationBtn(int cost);

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @delegationDetail.
  ///
  /// In en, this message translates to:
  /// **'Delegation Detail'**
  String get delegationDetail;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @creditHistory.
  ///
  /// In en, this message translates to:
  /// **'Credit History'**
  String get creditHistory;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get noTransactions;

  /// No description provided for @txPurchase.
  ///
  /// In en, this message translates to:
  /// **'Credit Purchase'**
  String get txPurchase;

  /// No description provided for @txDelegationDeduction.
  ///
  /// In en, this message translates to:
  /// **'Delegation Usage'**
  String get txDelegationDeduction;

  /// No description provided for @txRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get txRefund;

  /// No description provided for @txManualAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Manual Adjustment'**
  String get txManualAdjustment;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @grantor.
  ///
  /// In en, this message translates to:
  /// **'Grantor'**
  String get grantor;

  /// No description provided for @delegatePerson.
  ///
  /// In en, this message translates to:
  /// **'Delegate'**
  String get delegatePerson;

  /// No description provided for @validityPeriod.
  ///
  /// In en, this message translates to:
  /// **'Validity Period'**
  String get validityPeriod;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @revokeDelegation.
  ///
  /// In en, this message translates to:
  /// **'Revoke Delegation'**
  String get revokeDelegation;

  /// No description provided for @delegationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Delegation accepted'**
  String get delegationAccepted;

  /// No description provided for @delegationRejected.
  ///
  /// In en, this message translates to:
  /// **'Delegation rejected'**
  String get delegationRejected;

  /// No description provided for @delegationRevoked.
  ///
  /// In en, this message translates to:
  /// **'Delegation revoked'**
  String get delegationRevoked;

  /// No description provided for @delegationCreated.
  ///
  /// In en, this message translates to:
  /// **'Delegation granted successfully!'**
  String get delegationCreated;

  /// No description provided for @purchaseCredits.
  ///
  /// In en, this message translates to:
  /// **'Purchase Credits'**
  String get purchaseCredits;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @creditPackages.
  ///
  /// In en, this message translates to:
  /// **'Credit Packages'**
  String get creditPackages;

  /// No description provided for @noPackagesFound.
  ///
  /// In en, this message translates to:
  /// **'No packages found'**
  String get noPackagesFound;

  /// No description provided for @payWithSwish.
  ///
  /// In en, this message translates to:
  /// **'Pay with Swish'**
  String get payWithSwish;

  /// No description provided for @payWithPaypal.
  ///
  /// In en, this message translates to:
  /// **'Pay with PayPal'**
  String get payWithPaypal;

  /// No description provided for @payWithKlarna.
  ///
  /// In en, this message translates to:
  /// **'Pay with Klarna'**
  String get payWithKlarna;

  /// No description provided for @redirectingToPayment.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to payment page...'**
  String get redirectingToPayment;

  /// No description provided for @paymentInitiated.
  ///
  /// In en, this message translates to:
  /// **'Payment initiated'**
  String get paymentInitiated;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get markAllRead;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swedish.
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get swedish;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @personnummer.
  ///
  /// In en, this message translates to:
  /// **'Personnummer'**
  String get personnummer;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @editInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get editInfo;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @organizations.
  ///
  /// In en, this message translates to:
  /// **'Organizations'**
  String get organizations;

  /// No description provided for @organizationManagement.
  ///
  /// In en, this message translates to:
  /// **'Organization Management'**
  String get organizationManagement;

  /// No description provided for @operationTypeManagement.
  ///
  /// In en, this message translates to:
  /// **'Operation Types'**
  String get operationTypeManagement;

  /// No description provided for @userOrgMapping.
  ///
  /// In en, this message translates to:
  /// **'User-Organization Mapping'**
  String get userOrgMapping;

  /// No description provided for @creditPackageManagement.
  ///
  /// In en, this message translates to:
  /// **'Credit Packages'**
  String get creditPackageManagement;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get auditLog;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @totalOrganizations.
  ///
  /// In en, this message translates to:
  /// **'Total Organizations'**
  String get totalOrganizations;

  /// No description provided for @activeDelegations.
  ///
  /// In en, this message translates to:
  /// **'Active Delegations'**
  String get activeDelegations;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingCount;

  /// No description provided for @totalCredits.
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get totalCredits;

  /// No description provided for @revenueSEK.
  ///
  /// In en, this message translates to:
  /// **'Revenue (SEK)'**
  String get revenueSEK;

  /// No description provided for @newOrganization.
  ///
  /// In en, this message translates to:
  /// **'New Organization'**
  String get newOrganization;

  /// No description provided for @editOrganization.
  ///
  /// In en, this message translates to:
  /// **'Edit Organization'**
  String get editOrganization;

  /// No description provided for @deleteOrganization.
  ///
  /// In en, this message translates to:
  /// **'Delete Organization'**
  String get deleteOrganization;

  /// No description provided for @deleteOrgConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this organization?'**
  String get deleteOrgConfirm;

  /// No description provided for @orgName.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get orgName;

  /// No description provided for @orgNumber.
  ///
  /// In en, this message translates to:
  /// **'Org Number'**
  String get orgNumber;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @newPackage.
  ///
  /// In en, this message translates to:
  /// **'New Package'**
  String get newPackage;

  /// No description provided for @editPackage.
  ///
  /// In en, this message translates to:
  /// **'Edit Package'**
  String get editPackage;

  /// No description provided for @packageName.
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get packageName;

  /// No description provided for @creditAmount.
  ///
  /// In en, this message translates to:
  /// **'Credit Amount'**
  String get creditAmount;

  /// No description provided for @priceSEK.
  ///
  /// In en, this message translates to:
  /// **'Price (SEK)'**
  String get priceSEK;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {message}'**
  String errorOccurred(String message);

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get sessionExpired;

  /// No description provided for @insufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'Insufficient credits. Please purchase more.'**
  String get insufficientCredits;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @minLength.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {count} characters'**
  String minLength(int count);

  /// No description provided for @invalidPersonnummer.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid personnummer'**
  String get invalidPersonnummer;

  /// No description provided for @amountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountMustBePositive;

  /// No description provided for @selectAtLeastOneOperation.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one operation type'**
  String get selectAtLeastOneOperation;

  /// No description provided for @selectPerson.
  ///
  /// In en, this message translates to:
  /// **'Please select a person'**
  String get selectPerson;

  /// No description provided for @selectOrg.
  ///
  /// In en, this message translates to:
  /// **'Please select an organization'**
  String get selectOrg;

  /// No description provided for @endDateAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get endDateAfterStart;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @dialogSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get dialogSuccess;

  /// No description provided for @dialogWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get dialogWarning;

  /// No description provided for @dialogInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get dialogInfo;

  /// No description provided for @dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirm;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to perform this action?'**
  String get confirmAction;

  /// No description provided for @revokeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to revoke this delegation?'**
  String get revokeConfirm;

  /// No description provided for @rejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this delegation?'**
  String get rejectConfirm;

  /// No description provided for @acceptConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to accept this delegation?'**
  String get acceptConfirm;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get deleteConfirm;

  /// No description provided for @errCannotDelegateToSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot delegate to yourself.'**
  String get errCannotDelegateToSelf;

  /// No description provided for @errInvalidOperationTypes.
  ///
  /// In en, this message translates to:
  /// **'One or more operation types are invalid.'**
  String get errInvalidOperationTypes;

  /// No description provided for @errOnlyGrantorCanRevoke.
  ///
  /// In en, this message translates to:
  /// **'Only the grantor can revoke this delegation.'**
  String get errOnlyGrantorCanRevoke;

  /// No description provided for @errOnlyDelegateCanReject.
  ///
  /// In en, this message translates to:
  /// **'Only the delegate can reject this delegation.'**
  String get errOnlyDelegateCanReject;

  /// No description provided for @errOnlyDelegateCanAccept.
  ///
  /// In en, this message translates to:
  /// **'Only the delegate can accept this delegation.'**
  String get errOnlyDelegateCanAccept;

  /// No description provided for @errDelegationInvalidStatus.
  ///
  /// In en, this message translates to:
  /// **'Delegation cannot perform this action in its current status.'**
  String get errDelegationInvalidStatus;

  /// No description provided for @errUserAlreadyInOrg.
  ///
  /// In en, this message translates to:
  /// **'User is already assigned to this organization.'**
  String get errUserAlreadyInOrg;

  /// No description provided for @errDelegateUserRequired.
  ///
  /// In en, this message translates to:
  /// **'Delegate user is required.'**
  String get errDelegateUserRequired;

  /// No description provided for @errOrganizationRequired.
  ///
  /// In en, this message translates to:
  /// **'Organization is required.'**
  String get errOrganizationRequired;

  /// No description provided for @errOperationTypesRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one operation type is required.'**
  String get errOperationTypesRequired;

  /// No description provided for @errDurationTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Duration type is required.'**
  String get errDurationTypeRequired;

  /// No description provided for @errDurationValueInvalid.
  ///
  /// In en, this message translates to:
  /// **'Duration value must be greater than 0.'**
  String get errDurationValueInvalid;

  /// No description provided for @errStartDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Start date is required for date range.'**
  String get errStartDateRequired;

  /// No description provided for @errEndDateRequired.
  ///
  /// In en, this message translates to:
  /// **'End date is required for date range.'**
  String get errEndDateRequired;

  /// No description provided for @errEndDateBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date.'**
  String get errEndDateBeforeStart;

  /// No description provided for @errOrgNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Organization name is required (max 200 chars).'**
  String get errOrgNameRequired;

  /// No description provided for @errOrgNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Organization number is required.'**
  String get errOrgNumberRequired;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get errInvalidEmail;

  /// No description provided for @errInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number format.'**
  String get errInvalidPhone;

  /// No description provided for @errCreditPackageRequired.
  ///
  /// In en, this message translates to:
  /// **'Credit package is required.'**
  String get errCreditPackageRequired;

  /// No description provided for @errInvalidPaymentProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider must be one of: Swish, PayPal, Klarna.'**
  String get errInvalidPaymentProvider;

  /// No description provided for @errOperationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Operation type name is required (max 200 chars).'**
  String get errOperationNameRequired;

  /// No description provided for @errCreditCostInvalid.
  ///
  /// In en, this message translates to:
  /// **'Credit cost must be 0 or more.'**
  String get errCreditCostInvalid;

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'Record not found.'**
  String get errNotFound;

  /// No description provided for @errInsufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'Insufficient credits. Please purchase more.'**
  String get errInsufficientCredits;

  /// No description provided for @errForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errForbidden;

  /// No description provided for @errUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get errUnauthorized;

  /// No description provided for @errInternalError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errInternalError;

  /// No description provided for @errValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please fix the form errors and try again.'**
  String get errValidationError;

  /// No description provided for @gdprTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data Usage'**
  String get gdprTitle;

  /// No description provided for @gdprSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please read the following information and give your consent before using the app.'**
  String get gdprSubtitle;

  /// No description provided for @gdprDataProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Data'**
  String get gdprDataProcessingTitle;

  /// No description provided for @gdprDataProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'Your BankID authentication data is processed to manage authorization transactions. Your personal number is stored encrypted.'**
  String get gdprDataProcessingBody;

  /// No description provided for @gdprSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get gdprSecurityTitle;

  /// No description provided for @gdprSecurityBody.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored on encrypted Azure servers and protected against unauthorized access. Signed documents are archived for 7 years as required by law.'**
  String get gdprSecurityBody;

  /// No description provided for @gdprRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get gdprRightsTitle;

  /// No description provided for @gdprRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You have the right to request access, correction, and deletion of your data via the profile page.'**
  String get gdprRightsBody;

  /// No description provided for @gdprRequiredConsentLabel.
  ///
  /// In en, this message translates to:
  /// **'I consent to the processing of my personal data for the purposes stated above. (Required)'**
  String get gdprRequiredConsentLabel;

  /// No description provided for @gdprMarketingConsentLabel.
  ///
  /// In en, this message translates to:
  /// **'I consent to receiving communication via WhatsApp, email, and in-app notifications. (Optional)'**
  String get gdprMarketingConsentLabel;

  /// No description provided for @gdprAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'I Accept and Continue'**
  String get gdprAcceptButton;

  /// No description provided for @gdprFootnote.
  ///
  /// In en, this message translates to:
  /// **'This consent is required under GDPR and Swedish PDPL.'**
  String get gdprFootnote;

  /// No description provided for @bankIdSignTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign with BankID'**
  String get bankIdSignTitle;

  /// No description provided for @bankIdSignWaiting.
  ///
  /// In en, this message translates to:
  /// **'Opening BankID app. Please confirm the action in your BankID app.'**
  String get bankIdSignWaiting;

  /// No description provided for @bankIdSignCompleting.
  ///
  /// In en, this message translates to:
  /// **'Completing signature...'**
  String get bankIdSignCompleting;

  /// No description provided for @bankIdSignError.
  ///
  /// In en, this message translates to:
  /// **'Signing failed'**
  String get bankIdSignError;

  /// No description provided for @signAndGrantDelegation.
  ///
  /// In en, this message translates to:
  /// **'Sign with BankID and Grant'**
  String get signAndGrantDelegation;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @notifSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notifSettingsTitle;

  /// No description provided for @notifSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which channels you want to receive notifications from.'**
  String get notifSettingsDesc;

  /// No description provided for @notifChannelInApp.
  ///
  /// In en, this message translates to:
  /// **'In-App'**
  String get notifChannelInApp;

  /// No description provided for @notifChannelInAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications appear inside the app'**
  String get notifChannelInAppDesc;

  /// No description provided for @notifChannelPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notification'**
  String get notifChannelPush;

  /// No description provided for @notifChannelPushDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant notifications sent to your device'**
  String get notifChannelPushDesc;

  /// No description provided for @notifChannelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get notifChannelEmail;

  /// No description provided for @notifChannelEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Sent to the email address in your profile'**
  String get notifChannelEmailDesc;

  /// No description provided for @notifChannelWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get notifChannelWhatsApp;

  /// No description provided for @notifChannelWhatsAppDesc.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp message via Twilio'**
  String get notifChannelWhatsAppDesc;

  /// No description provided for @notifChannelSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get notifChannelSms;

  /// No description provided for @notifChannelSmsDesc.
  ///
  /// In en, this message translates to:
  /// **'SMS message via Twilio'**
  String get notifChannelSmsDesc;

  /// No description provided for @notifChannelInactiveLabel.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get notifChannelInactiveLabel;

  /// No description provided for @notifChannelInactiveDesc.
  ///
  /// In en, this message translates to:
  /// **'This channel is not configured yet.'**
  String get notifChannelInactiveDesc;

  /// No description provided for @notifRequiresEmail.
  ///
  /// In en, this message translates to:
  /// **'An email address must be set in your profile.'**
  String get notifRequiresEmail;

  /// No description provided for @notifRequiresPhone.
  ///
  /// In en, this message translates to:
  /// **'A phone number must be set in your profile.'**
  String get notifRequiresPhone;

  /// No description provided for @notifSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notification settings saved.'**
  String get notifSaveSuccess;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Plans & Pricing'**
  String get products;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @corporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get corporate;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available'**
  String get noProductsAvailable;

  /// No description provided for @corporateApiAccess.
  ///
  /// In en, this message translates to:
  /// **'Corporate API Access'**
  String get corporateApiAccess;

  /// No description provided for @corporateApiDescription.
  ///
  /// In en, this message translates to:
  /// **'Register your company to access our API and enterprise features.'**
  String get corporateApiDescription;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get month;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @operationsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'operations/month'**
  String get operationsPerMonth;

  /// No description provided for @activateFree.
  ///
  /// In en, this message translates to:
  /// **'Activate Free Plan'**
  String get activateFree;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @subscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'Subscription activated successfully!'**
  String get subscriptionActivated;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @confirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get confirmPurchase;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @swishPayment.
  ///
  /// In en, this message translates to:
  /// **'Swish Payment'**
  String get swishPayment;

  /// No description provided for @waitingForPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment confirmation...'**
  String get waitingForPayment;

  /// No description provided for @quotaExhausted.
  ///
  /// In en, this message translates to:
  /// **'Quota Exhausted'**
  String get quotaExhausted;

  /// No description provided for @quotaExhaustedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have used all your operations for this month.'**
  String get quotaExhaustedMessage;

  /// No description provided for @upgradeYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade your plan to continue.'**
  String get upgradeYourPlan;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// No description provided for @corporateApplication.
  ///
  /// In en, this message translates to:
  /// **'Corporate Application'**
  String get corporateApplication;

  /// No description provided for @corporateApplyInfo.
  ///
  /// In en, this message translates to:
  /// **'Fill in your company details below. Our team will review your application and get back to you via email and SMS.'**
  String get corporateApplyInfo;

  /// No description provided for @companyInformation.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyInformation;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Email'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted!'**
  String get applicationSubmitted;

  /// No description provided for @applicationSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your corporate application has been submitted. We will review it and notify you via email and SMS.'**
  String get applicationSubmittedMessage;

  /// No description provided for @applicationError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit application. Please try again.'**
  String get applicationError;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @productManagement.
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get productManagement;

  /// No description provided for @corporateApplications.
  ///
  /// In en, this message translates to:
  /// **'Corporate Applications'**
  String get corporateApplications;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get newProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @monthlyQuota.
  ///
  /// In en, this message translates to:
  /// **'Monthly Quota'**
  String get monthlyQuota;

  /// No description provided for @productType.
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get productType;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate this product?'**
  String get confirmDeleteProduct;

  /// No description provided for @noApplications.
  ///
  /// In en, this message translates to:
  /// **'No applications found'**
  String get noApplications;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @reviewNote.
  ///
  /// In en, this message translates to:
  /// **'Review Note'**
  String get reviewNote;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @approveApplication.
  ///
  /// In en, this message translates to:
  /// **'Approve Application'**
  String get approveApplication;

  /// No description provided for @rejectApplication.
  ///
  /// In en, this message translates to:
  /// **'Reject Application'**
  String get rejectApplication;

  /// No description provided for @approveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will create an organization and notify the applicant.'**
  String get approveConfirmMessage;

  /// No description provided for @rejectConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The applicant will be notified via email and SMS.'**
  String get rejectConfirmMessage;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'sv',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppL10nDe();
    case 'en':
      return AppL10nEn();
    case 'es':
      return AppL10nEs();
    case 'fr':
      return AppL10nFr();
    case 'sv':
      return AppL10nSv();
    case 'tr':
      return AppL10nTr();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
