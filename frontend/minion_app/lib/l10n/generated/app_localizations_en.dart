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
  String get loginWithBankIdOtherDevice => 'Log in with BankID (Other Device)';

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
  String get creditHistory => 'Credit History';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get noTransactions => 'No transactions yet.';

  @override
  String get txPurchase => 'Credit Purchase';

  @override
  String get txDelegationDeduction => 'Delegation Usage';

  @override
  String get txRefund => 'Refund';

  @override
  String get txManualAdjustment => 'Manual Adjustment';

  @override
  String get balance => 'Balance';

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

  @override
  String get clear => 'Clear';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get dialogSuccess => 'Success';

  @override
  String get dialogWarning => 'Warning';

  @override
  String get dialogInfo => 'Information';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get confirmAction => 'Are you sure you want to perform this action?';

  @override
  String get revokeConfirm =>
      'Are you sure you want to revoke this delegation?';

  @override
  String get rejectConfirm =>
      'Are you sure you want to reject this delegation?';

  @override
  String get acceptConfirm =>
      'Are you sure you want to accept this delegation?';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this?';

  @override
  String get errCannotDelegateToSelf => 'You cannot delegate to yourself.';

  @override
  String get errInvalidOperationTypes =>
      'One or more operation types are invalid.';

  @override
  String get errOnlyGrantorCanRevoke =>
      'Only the grantor can revoke this delegation.';

  @override
  String get errOnlyDelegateCanReject =>
      'Only the delegate can reject this delegation.';

  @override
  String get errOnlyDelegateCanAccept =>
      'Only the delegate can accept this delegation.';

  @override
  String get errDelegationInvalidStatus =>
      'Delegation cannot perform this action in its current status.';

  @override
  String get errUserAlreadyInOrg =>
      'User is already assigned to this organization.';

  @override
  String get errDelegateUserRequired => 'Delegate user is required.';

  @override
  String get errOrganizationRequired => 'Organization is required.';

  @override
  String get errOperationTypesRequired =>
      'At least one operation type is required.';

  @override
  String get errDurationTypeRequired => 'Duration type is required.';

  @override
  String get errDurationValueInvalid =>
      'Duration value must be greater than 0.';

  @override
  String get errStartDateRequired => 'Start date is required for date range.';

  @override
  String get errEndDateRequired => 'End date is required for date range.';

  @override
  String get errEndDateBeforeStart => 'End date must be after start date.';

  @override
  String get errOrgNameRequired =>
      'Organization name is required (max 200 chars).';

  @override
  String get errOrgNumberRequired => 'Organization number is required.';

  @override
  String get errInvalidEmail => 'Invalid email format.';

  @override
  String get errInvalidPhone => 'Invalid phone number format.';

  @override
  String get errCreditPackageRequired => 'Credit package is required.';

  @override
  String get errInvalidPaymentProvider =>
      'Provider must be one of: Swish, PayPal, Klarna.';

  @override
  String get errOperationNameRequired =>
      'Operation type name is required (max 200 chars).';

  @override
  String get errCreditCostInvalid => 'Credit cost must be 0 or more.';

  @override
  String get errNotFound => 'Record not found.';

  @override
  String get errInsufficientCredits =>
      'Insufficient credits. Please purchase more.';

  @override
  String get errForbidden =>
      'You do not have permission to perform this action.';

  @override
  String get errUnauthorized => 'Session expired. Please login again.';

  @override
  String get errInternalError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errValidationError => 'Please fix the form errors and try again.';

  @override
  String get gdprTitle => 'Privacy & Data Usage';

  @override
  String get gdprSubtitle =>
      'Please read the following information and give your consent before using the app.';

  @override
  String get gdprDataProcessingTitle => 'Your Personal Data';

  @override
  String get gdprDataProcessingBody =>
      'Your BankID authentication data is processed to manage authorization transactions. Your personal number is stored encrypted.';

  @override
  String get gdprSecurityTitle => 'Data Security';

  @override
  String get gdprSecurityBody =>
      'Your data is stored on encrypted Azure servers and protected against unauthorized access. Signed documents are archived for 7 years as required by law.';

  @override
  String get gdprRightsTitle => 'Your Rights';

  @override
  String get gdprRightsBody =>
      'You have the right to request access, correction, and deletion of your data via the profile page.';

  @override
  String get gdprRequiredConsentLabel =>
      'I consent to the processing of my personal data for the purposes stated above. (Required)';

  @override
  String get gdprMarketingConsentLabel =>
      'I consent to receiving communication via WhatsApp, email, and in-app notifications. (Optional)';

  @override
  String get gdprAcceptButton => 'I Accept and Continue';

  @override
  String get gdprFootnote =>
      'This consent is required under GDPR and Swedish PDPL.';

  @override
  String get bankIdSignTitle => 'Sign with BankID';

  @override
  String get bankIdSignWaiting =>
      'Opening BankID app. Please confirm the action in your BankID app.';

  @override
  String get bankIdSignCompleting => 'Completing signature...';

  @override
  String get bankIdSignError => 'Signing failed';

  @override
  String get signAndGrantDelegation => 'Sign with BankID and Grant';

  @override
  String get retry => 'Try Again';

  @override
  String get notifSettingsTitle => 'Notification Settings';

  @override
  String get notifSettingsDesc =>
      'Choose which channels you want to receive notifications from.';

  @override
  String get notifChannelInApp => 'In-App';

  @override
  String get notifChannelInAppDesc => 'Notifications appear inside the app';

  @override
  String get notifChannelPush => 'Push Notification';

  @override
  String get notifChannelPushDesc =>
      'Instant notifications sent to your device';

  @override
  String get notifChannelEmail => 'Email';

  @override
  String get notifChannelEmailDesc =>
      'Sent to the email address in your profile';

  @override
  String get notifChannelWhatsApp => 'WhatsApp';

  @override
  String get notifChannelWhatsAppDesc => 'WhatsApp message via Twilio';

  @override
  String get notifChannelSms => 'SMS';

  @override
  String get notifChannelSmsDesc => 'SMS message via Twilio';

  @override
  String get notifChannelInactiveLabel => 'INACTIVE';

  @override
  String get notifChannelInactiveDesc => 'This channel is not configured yet.';

  @override
  String get notifRequiresEmail =>
      'An email address must be set in your profile.';

  @override
  String get notifRequiresPhone =>
      'A phone number must be set in your profile.';

  @override
  String get notifSaveSuccess => 'Notification settings saved.';

  @override
  String get products => 'Plans & Pricing';

  @override
  String get individual => 'Individual';

  @override
  String get corporate => 'Corporate';

  @override
  String get noProductsAvailable => 'No plans available';

  @override
  String get corporateApiAccess => 'Corporate API Access';

  @override
  String get corporateApiDescription =>
      'Register your company to access our API and enterprise features.';

  @override
  String get applyNow => 'Apply Now';

  @override
  String get free => 'Free';

  @override
  String get month => 'mo';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get operationsPerMonth => 'operations/month';

  @override
  String get activateFree => 'Activate Free Plan';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscriptionActivated => 'Subscription activated successfully!';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get confirmPurchase => 'Confirm Purchase';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get swishPayment => 'Swish Payment';

  @override
  String get waitingForPayment => 'Waiting for payment confirmation...';

  @override
  String get quotaExhausted => 'Quota Exhausted';

  @override
  String get quotaExhaustedMessage =>
      'You have used all your operations for this month.';

  @override
  String get upgradeYourPlan => 'Upgrade your plan to continue.';

  @override
  String get later => 'Later';

  @override
  String get viewPlans => 'View Plans';

  @override
  String get corporateApplication => 'Corporate Application';

  @override
  String get corporateApplyInfo =>
      'Fill in your company details below. Our team will review your application and get back to you via email and SMS.';

  @override
  String get companyInformation => 'Company Information';

  @override
  String get companyName => 'Company Name';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get contactName => 'Contact Name';

  @override
  String get contactEmail => 'Contact Email';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get required => 'This field is required';

  @override
  String get submitApplication => 'Submit Application';

  @override
  String get applicationSubmitted => 'Application Submitted!';

  @override
  String get applicationSubmittedMessage =>
      'Your corporate application has been submitted. We will review it and notify you via email and SMS.';

  @override
  String get applicationError =>
      'Failed to submit application. Please try again.';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get productManagement => 'Product Management';

  @override
  String get corporateApplications => 'Corporate Applications';

  @override
  String get newProduct => 'New Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productName => 'Product Name';

  @override
  String get monthlyQuota => 'Monthly Quota';

  @override
  String get productType => 'Product Type';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteProduct =>
      'Are you sure you want to deactivate this product?';

  @override
  String get noApplications => 'No applications found';

  @override
  String get approved => 'Approved';

  @override
  String get reviewNote => 'Review Note';

  @override
  String get optional => 'Optional';

  @override
  String get approveApplication => 'Approve Application';

  @override
  String get rejectApplication => 'Reject Application';

  @override
  String get approveConfirmMessage =>
      'This will create an organization and notify the applicant.';

  @override
  String get rejectConfirmMessage =>
      'The applicant will be notified via email and SMS.';

  @override
  String get approve => 'Approve';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark';

  @override
  String get lightMode => 'Light';

  @override
  String get systemMode => 'System';

  @override
  String get documentTemplates => 'Document Templates';

  @override
  String get createTemplate => 'Create Template';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get previewTemplate => 'Preview';

  @override
  String get previewTemplateHint =>
      'Click Preview to render the template with sample data.';

  @override
  String get templatePlaceholders => 'Available Placeholders';

  @override
  String get templatePlaceholdersDescription =>
      'Click a placeholder to insert it into the HTML editor.';

  @override
  String get version => 'Version';

  @override
  String get settings => 'Settings';

  @override
  String get inactive => 'Inactive';

  @override
  String get noDataFound => 'No data found';

  @override
  String get powerOfAttorney => 'Power of Attorney';

  @override
  String get fullmakt => 'Fullmakt';

  @override
  String get signWithBankId => 'Sign with BankID';

  @override
  String get documentReady => 'Document is ready';

  @override
  String get shareViaWhatsApp => 'Share via WhatsApp';

  @override
  String get shareViaEmail => 'Share via Email';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get scanQrToVerify => 'Scan QR code to verify';

  @override
  String get documentDetails => 'Document Details';

  @override
  String get signatures => 'Signatures';

  @override
  String get grantorSigned => 'Principal signed';

  @override
  String get delegateSigned => 'Agent signed';

  @override
  String get notYetSigned => 'Not yet signed';

  @override
  String get shareDocument => 'Share Document';

  @override
  String get recipientPhone => 'Recipient phone number';

  @override
  String get recipientEmail => 'Recipient email';

  @override
  String get yourName => 'Your name';

  @override
  String get send => 'Send';

  @override
  String get documentShared => 'Document shared successfully';
}
