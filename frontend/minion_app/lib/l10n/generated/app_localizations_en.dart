// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Minion';

  @override
  String get bankIdAuthSystem => 'BankID Authorization System';

  @override
  String get loginWithBankId => 'Login with BankID';

  @override
  String get thisDevice => 'This device';

  @override
  String get otherDevice => 'Other device';

  @override
  String get scanQrCode => 'Scan QR code with your\nBankID app';

  @override
  String get openingBankIdApp => 'Opening BankID app...';

  @override
  String get openBankIdApp => 'Open BankID App';

  @override
  String get waitingForApproval => 'Waiting for your BankID approval...';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Logout';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get delegations => 'Delegations';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get creditBalance => 'Credit Balance';

  @override
  String get buyCredits => 'Buy Credits';

  @override
  String remainingCredits(int count) {
    return 'Remaining credits: $count';
  }

  @override
  String thisOperationCosts(int count) {
    return 'This operation: $count credits';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get grantDelegation => 'Grant Delegation';

  @override
  String get myDelegations => 'My Delegations';

  @override
  String get recentDelegations => 'Recent Delegations';

  @override
  String get noDelegationsYet => 'No delegations yet';

  @override
  String grantedDelegations(int count) {
    return 'Granted ($count)';
  }

  @override
  String receivedDelegations(int count) {
    return 'Received ($count)';
  }

  @override
  String get noGrantedDelegations => 'You haven\'t granted any delegations';

  @override
  String get noReceivedDelegations => 'No delegations granted to you';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get pending => 'Pending';

  @override
  String get rejected => 'Rejected';

  @override
  String get revoked => 'Revoked';

  @override
  String get expired => 'Expired';

  @override
  String get personSelection => 'Person Selection';

  @override
  String get searchByPersonnummer => 'Search by personnummer, name or email';

  @override
  String get organization => 'Organization';

  @override
  String get selectOrganization => 'Select organization';

  @override
  String get operationTypes => 'Operation Types';

  @override
  String get duration => 'Duration';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get minutes => 'Minutes';

  @override
  String get hours => 'Hours';

  @override
  String get days => 'Days';

  @override
  String get value => 'Value';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String grantDelegationBtn(int cost) {
    return 'Grant Delegation ($cost credits)';
  }

  @override
  String get sending => 'Sending...';

  @override
  String get delegationDetail => 'Delegation Detail';

  @override
  String get status => 'Status';

  @override
  String get credits => 'Credits';

  @override
  String get grantor => 'Grantor';

  @override
  String get delegatePerson => 'Delegate';

  @override
  String get validityPeriod => 'Validity Period';

  @override
  String get note => 'Note';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get revokeDelegation => 'Revoke Delegation';

  @override
  String get delegationAccepted => 'Delegation accepted';

  @override
  String get delegationRejected => 'Delegation rejected';

  @override
  String get delegationRevoked => 'Delegation revoked';

  @override
  String get delegationCreated => 'Delegation granted successfully!';

  @override
  String get purchaseCredits => 'Purchase Credits';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get creditPackages => 'Credit Packages';

  @override
  String get noPackagesFound => 'No packages found';

  @override
  String get payWithSwish => 'Pay with Swish';

  @override
  String get payWithPaypal => 'Pay with PayPal';

  @override
  String get payWithKlarna => 'Pay with Klarna';

  @override
  String get redirectingToPayment => 'Redirecting to payment page...';

  @override
  String get paymentInitiated => 'Payment initiated';

  @override
  String get creditHistory => 'Credit History';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get swedish => 'Swedish';

  @override
  String get turkish => 'Turkish';

  @override
  String get german => 'German';

  @override
  String get spanish => 'Spanish';

  @override
  String get french => 'French';

  @override
  String get appLanguage => 'App Language';

  @override
  String get fullName => 'Full Name';

  @override
  String get personnummer => 'Personnummer';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get editInfo => 'Edit Information';

  @override
  String get theme => 'Theme';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get users => 'Users';

  @override
  String get organizations => 'Organizations';

  @override
  String get organizationManagement => 'Organization Management';

  @override
  String get operationTypeManagement => 'Operation Types';

  @override
  String get userOrgMapping => 'User-Organization Mapping';

  @override
  String get creditPackageManagement => 'Credit Packages';

  @override
  String get auditLog => 'Audit Log';

  @override
  String get management => 'Management';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get totalOrganizations => 'Total Organizations';

  @override
  String get activeDelegations => 'Active Delegations';

  @override
  String get pendingCount => 'Pending';

  @override
  String get totalCredits => 'Total Credits';

  @override
  String get revenueSEK => 'Revenue (SEK)';

  @override
  String get newOrganization => 'New Organization';

  @override
  String get editOrganization => 'Edit Organization';

  @override
  String get deleteOrganization => 'Delete Organization';

  @override
  String get deleteOrgConfirm =>
      'Are you sure you want to delete this organization?';

  @override
  String get orgName => 'Organization Name';

  @override
  String get orgNumber => 'Org Number';

  @override
  String get city => 'City';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get newPackage => 'New Package';

  @override
  String get editPackage => 'Edit Package';

  @override
  String get packageName => 'Package Name';

  @override
  String get creditAmount => 'Credit Amount';

  @override
  String get priceSEK => 'Price (SEK)';

  @override
  String get description => 'Description';

  @override
  String get error => 'Error';

  @override
  String errorOccurred(String message) {
    return 'An error occurred: $message';
  }

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get sessionExpired => 'Session expired. Please login again.';

  @override
  String get insufficientCredits =>
      'Insufficient credits. Please purchase more.';

  @override
  String get loading => 'Loading...';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String minLength(int count) {
    return 'Must be at least $count characters';
  }

  @override
  String get invalidPersonnummer => 'Please enter a valid personnummer';

  @override
  String get amountMustBePositive => 'Amount must be greater than 0';

  @override
  String get selectAtLeastOneOperation =>
      'Please select at least one operation type';

  @override
  String get selectPerson => 'Please select a person';

  @override
  String get selectOrg => 'Please select an organization';

  @override
  String get endDateAfterStart => 'End date must be after start date';
}
