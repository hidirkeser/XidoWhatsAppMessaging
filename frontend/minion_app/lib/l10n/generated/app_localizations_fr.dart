// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppL10nFr extends AppL10n {
  AppL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Minion';

  @override
  String get bankIdAuthSystem => 'Système d\'autorisation BankID';

  @override
  String get loginWithBankId => 'Se connecter avec BankID';

  @override
  String get loginWithBankIdOtherDevice =>
      'Se connecter avec BankID (autre appareil)';

  @override
  String get thisDevice => 'Cet appareil';

  @override
  String get otherDevice => 'Autre appareil';

  @override
  String get scanQrCode => 'Scannez le code QR avec\nvotre app BankID';

  @override
  String get openingBankIdApp => 'Ouverture de l\'app BankID...';

  @override
  String get openBankIdApp => 'Ouvrir l\'app BankID';

  @override
  String get waitingForApproval => 'En attente de votre approbation BankID...';

  @override
  String get cancel => 'Annuler';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get delegations => 'Délégations';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profil';

  @override
  String get creditBalance => 'Solde de crédits';

  @override
  String get buyCredits => 'Acheter des crédits';

  @override
  String remainingCredits(int count) {
    return 'Crédits restants : $count';
  }

  @override
  String thisOperationCosts(int count) {
    return 'Cette opération : $count crédits';
  }

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get grantDelegation => 'Accorder une délégation';

  @override
  String get myDelegations => 'Mes délégations';

  @override
  String get recentDelegations => 'Délégations récentes';

  @override
  String get noDelegationsYet => 'Aucune délégation pour l\'instant';

  @override
  String grantedDelegations(int count) {
    return 'Accordées ($count)';
  }

  @override
  String receivedDelegations(int count) {
    return 'Reçues ($count)';
  }

  @override
  String get noGrantedDelegations => 'Vous n\'avez accordé aucune délégation';

  @override
  String get noReceivedDelegations => 'Aucune délégation accordée pour vous';

  @override
  String get all => 'Tous';

  @override
  String get active => 'Actif';

  @override
  String get pending => 'En attente';

  @override
  String get rejected => 'Rejeté';

  @override
  String get revoked => 'Révoqué';

  @override
  String get expired => 'Expiré';

  @override
  String get personSelection => 'Sélection de personne';

  @override
  String get searchByPersonnummer =>
      'Rechercher par personnummer, nom ou e-mail';

  @override
  String get organization => 'Organisation';

  @override
  String get selectOrganization => 'Sélectionner une organisation';

  @override
  String get operationTypes => 'Types d\'opération';

  @override
  String get duration => 'Durée';

  @override
  String get selectDateRange => 'Sélectionner une plage de dates';

  @override
  String get start => 'Début';

  @override
  String get end => 'Fin';

  @override
  String get minutes => 'Minutes';

  @override
  String get hours => 'Heures';

  @override
  String get days => 'Jours';

  @override
  String get value => 'Valeur';

  @override
  String get noteOptional => 'Note (facultatif)';

  @override
  String grantDelegationBtn(int cost) {
    return 'Accorder la délégation ($cost crédits)';
  }

  @override
  String get sending => 'Envoi en cours...';

  @override
  String get delegationDetail => 'Détail de la délégation';

  @override
  String get status => 'Statut';

  @override
  String get credits => 'Crédits';

  @override
  String get creditHistory => 'Historique des crédits';

  @override
  String get currentBalance => 'Solde actuel';

  @override
  String get noTransactions => 'Pas encore de transactions.';

  @override
  String get txPurchase => 'Achat de crédits';

  @override
  String get txDelegationDeduction => 'Utilisation de délégation';

  @override
  String get txRefund => 'Remboursement';

  @override
  String get txManualAdjustment => 'Ajustement manuel';

  @override
  String get balance => 'Solde';

  @override
  String get grantor => 'Délégant';

  @override
  String get delegatePerson => 'Délégué';

  @override
  String get validityPeriod => 'Période de validité';

  @override
  String get note => 'Note';

  @override
  String get accept => 'Accepter';

  @override
  String get reject => 'Rejeter';

  @override
  String get revokeDelegation => 'Révoquer la délégation';

  @override
  String get delegationAccepted => 'Délégation acceptée';

  @override
  String get delegationRejected => 'Délégation rejetée';

  @override
  String get delegationRevoked => 'Délégation révoquée';

  @override
  String get delegationCreated => 'Délégation accordée avec succès !';

  @override
  String get purchaseCredits => 'Acheter des crédits';

  @override
  String get paymentMethod => 'Méthode de paiement';

  @override
  String get creditPackages => 'Forfaits de crédits';

  @override
  String get noPackagesFound => 'Aucun forfait trouvé';

  @override
  String get payWithSwish => 'Payer avec Swish';

  @override
  String get payWithPaypal => 'Payer avec PayPal';

  @override
  String get payWithKlarna => 'Payer avec Klarna';

  @override
  String get redirectingToPayment => 'Redirection vers la page de paiement...';

  @override
  String get paymentInitiated => 'Paiement initié';

  @override
  String get noTransactionsYet => 'Aucune transaction pour l\'instant';

  @override
  String get noNotifications => 'Aucune notification pour l\'instant';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int count) {
    return 'Il y a $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'Il y a $count h';
  }

  @override
  String daysAgo(int count) {
    return 'Il y a $count jours';
  }

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get swedish => 'Suédois';

  @override
  String get turkish => 'Turc';

  @override
  String get german => 'Allemand';

  @override
  String get spanish => 'Espagnol';

  @override
  String get french => 'Français';

  @override
  String get appLanguage => 'Langue de l\'app';

  @override
  String get fullName => 'Nom complet';

  @override
  String get personnummer => 'Personnummer';

  @override
  String get email => 'E-mail';

  @override
  String get phone => 'Téléphone';

  @override
  String get notSpecified => 'Non spécifié';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String get profileUpdateFailed => 'Échec de la mise à jour du profil';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get editInfo => 'Modifier les informations';

  @override
  String get theme => 'Thème';

  @override
  String get adminPanel => 'Panneau d\'administration';

  @override
  String get users => 'Utilisateurs';

  @override
  String get organizations => 'Organisations';

  @override
  String get organizationManagement => 'Gestion des organisations';

  @override
  String get operationTypeManagement => 'Types d\'opération';

  @override
  String get userOrgMapping => 'Utilisateur-Organisation';

  @override
  String get creditPackageManagement => 'Forfaits de crédits';

  @override
  String get auditLog => 'Journal d\'audit';

  @override
  String get management => 'Gestion';

  @override
  String get totalUsers => 'Total des utilisateurs';

  @override
  String get totalOrganizations => 'Total des organisations';

  @override
  String get activeDelegations => 'Délégations actives';

  @override
  String get pendingCount => 'En attente';

  @override
  String get totalCredits => 'Total des crédits';

  @override
  String get revenueSEK => 'Revenus (SEK)';

  @override
  String get newOrganization => 'Nouvelle organisation';

  @override
  String get editOrganization => 'Modifier l\'organisation';

  @override
  String get deleteOrganization => 'Supprimer l\'organisation';

  @override
  String get deleteOrgConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette organisation ?';

  @override
  String get orgName => 'Nom de l\'organisation';

  @override
  String get orgNumber => 'N° d\'org.';

  @override
  String get city => 'Ville';

  @override
  String get create => 'Créer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get newPackage => 'Nouveau forfait';

  @override
  String get editPackage => 'Modifier le forfait';

  @override
  String get packageName => 'Nom du forfait';

  @override
  String get creditAmount => 'Montant de crédits';

  @override
  String get priceSEK => 'Prix (SEK)';

  @override
  String get description => 'Description';

  @override
  String get error => 'Erreur';

  @override
  String errorOccurred(String message) {
    return 'Une erreur s\'est produite : $message';
  }

  @override
  String get networkError => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get sessionExpired => 'Session expirée. Veuillez vous reconnecter.';

  @override
  String get insufficientCredits =>
      'Crédits insuffisants. Veuillez en acheter plus.';

  @override
  String get loading => 'Chargement...';

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get invalidEmail => 'Veuillez saisir une adresse e-mail valide';

  @override
  String get invalidPhone => 'Veuillez saisir un numéro de téléphone valide';

  @override
  String minLength(int count) {
    return 'Doit comporter au moins $count caractères';
  }

  @override
  String get invalidPersonnummer => 'Veuillez saisir un personnummer valide';

  @override
  String get amountMustBePositive => 'Le montant doit être supérieur à 0';

  @override
  String get selectAtLeastOneOperation =>
      'Veuillez sélectionner au moins un type d\'opération';

  @override
  String get selectPerson => 'Veuillez sélectionner une personne';

  @override
  String get selectOrg => 'Veuillez sélectionner une organisation';

  @override
  String get endDateAfterStart =>
      'La date de fin doit être postérieure à la date de début';

  @override
  String get clear => 'Effacer';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get dialogSuccess => 'Succès';

  @override
  String get dialogWarning => 'Avertissement';

  @override
  String get dialogInfo => 'Information';

  @override
  String get dialogConfirm => 'Confirmer';

  @override
  String get areYouSure => 'Êtes-vous sûr?';

  @override
  String get confirmAction =>
      'Êtes-vous sûr de vouloir effectuer cette action?';

  @override
  String get revokeConfirm =>
      'Êtes-vous sûr de vouloir révoquer cette délégation?';

  @override
  String get rejectConfirm =>
      'Êtes-vous sûr de vouloir rejeter cette délégation?';

  @override
  String get acceptConfirm =>
      'Êtes-vous sûr de vouloir accepter cette délégation?';

  @override
  String get deleteConfirm => 'Êtes-vous sûr de vouloir supprimer ceci?';

  @override
  String get errCannotDelegateToSelf =>
      'Vous ne pouvez pas déléguer à vous-même.';

  @override
  String get errInvalidOperationTypes =>
      'Un ou plusieurs types d\'opération sont invalides.';

  @override
  String get errOnlyGrantorCanRevoke =>
      'Seul l\'accordant peut révoquer cette délégation.';

  @override
  String get errOnlyDelegateCanReject =>
      'Seul le délégué peut rejeter cette délégation.';

  @override
  String get errOnlyDelegateCanAccept =>
      'Seul le délégué peut accepter cette délégation.';

  @override
  String get errDelegationInvalidStatus =>
      'La délégation ne peut pas effectuer cette action dans son statut actuel.';

  @override
  String get errUserAlreadyInOrg =>
      'L\'utilisateur est déjà assigné à cette organisation.';

  @override
  String get errDelegateUserRequired => 'L\'utilisateur délégué est requis.';

  @override
  String get errOrganizationRequired => 'L\'organisation est requise.';

  @override
  String get errOperationTypesRequired =>
      'Au moins un type d\'opération est requis.';

  @override
  String get errDurationTypeRequired => 'Le type de durée est requis.';

  @override
  String get errDurationValueInvalid =>
      'La valeur de durée doit être supérieure à 0.';

  @override
  String get errStartDateRequired =>
      'La date de début est requise pour la plage de dates.';

  @override
  String get errEndDateRequired =>
      'La date de fin est requise pour la plage de dates.';

  @override
  String get errEndDateBeforeStart =>
      'La date de fin doit être postérieure à la date de début.';

  @override
  String get errOrgNameRequired =>
      'Le nom de l\'organisation est requis (max. 200 caractères).';

  @override
  String get errOrgNumberRequired => 'Le numéro d\'organisation est requis.';

  @override
  String get errInvalidEmail => 'Format d\'e-mail invalide.';

  @override
  String get errInvalidPhone => 'Format de numéro de téléphone invalide.';

  @override
  String get errCreditPackageRequired => 'Le forfait de crédit est requis.';

  @override
  String get errInvalidPaymentProvider =>
      'Le fournisseur doit être Swish, PayPal ou Klarna.';

  @override
  String get errOperationNameRequired =>
      'Le nom du type d\'opération est requis (max. 200 caractères).';

  @override
  String get errCreditCostInvalid => 'Le coût en crédits doit être 0 ou plus.';

  @override
  String get errNotFound => 'Enregistrement introuvable.';

  @override
  String get errInsufficientCredits =>
      'Crédits insuffisants. Veuillez en acheter davantage.';

  @override
  String get errForbidden =>
      'Vous n\'avez pas la permission d\'effectuer cette action.';

  @override
  String get errUnauthorized =>
      'La session a expiré. Veuillez vous reconnecter.';

  @override
  String get errInternalError =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get errValidationError =>
      'Veuillez corriger les erreurs du formulaire et réessayer.';

  @override
  String get gdprTitle => 'Confidentialité et utilisation des données';

  @override
  String get gdprSubtitle =>
      'Veuillez lire les informations suivantes et donner votre consentement avant d\'utiliser l\'application.';

  @override
  String get gdprDataProcessingTitle => 'Vos données personnelles';

  @override
  String get gdprDataProcessingBody =>
      'Vos données d\'authentification BankID sont traitées pour gérer les transactions d\'autorisation. Votre numéro personnel est stocké chiffré.';

  @override
  String get gdprSecurityTitle => 'Sécurité des données';

  @override
  String get gdprSecurityBody =>
      'Vos données sont stockées sur des serveurs Azure chiffrés. Les documents signés sont archivés 7 ans conformément à la loi.';

  @override
  String get gdprRightsTitle => 'Vos droits';

  @override
  String get gdprRightsBody =>
      'Vous avez le droit de demander l\'accès, la rectification et la suppression de vos données depuis la page de profil.';

  @override
  String get gdprRequiredConsentLabel =>
      'Je consens au traitement de mes données personnelles aux fins indiquées. (Obligatoire)';

  @override
  String get gdprMarketingConsentLabel =>
      'Je consens à recevoir des communications via WhatsApp, e-mail et notifications. (Optionnel)';

  @override
  String get gdprAcceptButton => 'J\'accepte et continue';

  @override
  String get gdprFootnote =>
      'Ce consentement est requis par le RGPD et la PDPL suédoise.';

  @override
  String get bankIdSignTitle => 'Signer avec BankID';

  @override
  String get bankIdSignWaiting =>
      'Ouverture de l\'app BankID. Veuillez confirmer l\'action dans votre app BankID.';

  @override
  String get bankIdSignCompleting => 'Finalisation de la signature...';

  @override
  String get bankIdSignError => 'Échec de la signature';

  @override
  String get signAndGrantDelegation => 'Signer avec BankID et accorder';

  @override
  String get retry => 'Réessayer';

  @override
  String get notifSettingsTitle => 'Paramètres de notifications';

  @override
  String get notifSettingsDesc =>
      'Choisissez les canaux par lesquels vous souhaitez recevoir des notifications.';

  @override
  String get notifChannelInApp => 'Dans l\'app';

  @override
  String get notifChannelInAppDesc =>
      'Les notifications s\'affichent dans l\'application';

  @override
  String get notifChannelPush => 'Notification push';

  @override
  String get notifChannelPushDesc =>
      'Notifications instantanées envoyées sur votre appareil';

  @override
  String get notifChannelEmail => 'E-mail';

  @override
  String get notifChannelEmailDesc =>
      'Envoyé à l\'adresse e-mail de votre profil';

  @override
  String get notifChannelWhatsApp => 'WhatsApp';

  @override
  String get notifChannelWhatsAppDesc => 'Message WhatsApp via Twilio';

  @override
  String get notifChannelSms => 'SMS';

  @override
  String get notifChannelSmsDesc => 'Message SMS via Twilio';

  @override
  String get notifChannelInactiveLabel => 'INACTIF';

  @override
  String get notifChannelInactiveDesc =>
      'Ce canal n\'est pas encore configuré.';

  @override
  String get notifRequiresEmail =>
      'Une adresse e-mail doit être définie dans votre profil.';

  @override
  String get notifRequiresPhone =>
      'Un numéro de téléphone doit être défini dans votre profil.';

  @override
  String get notifSaveSuccess => 'Paramètres de notifications enregistrés.';

  @override
  String get products => 'Forfaits et tarifs';

  @override
  String get individual => 'Individuel';

  @override
  String get corporate => 'Entreprise';

  @override
  String get noProductsAvailable => 'Aucun forfait disponible';

  @override
  String get corporateApiAccess => 'Accès API entreprise';

  @override
  String get corporateApiDescription =>
      'Enregistrez votre entreprise pour accéder à notre API et aux fonctionnalités entreprise.';

  @override
  String get applyNow => 'Postuler maintenant';

  @override
  String get free => 'Gratuit';

  @override
  String get month => 'mois';

  @override
  String get unlimited => 'Illimité';

  @override
  String get operationsPerMonth => 'opérations/mois';

  @override
  String get activateFree => 'Activer le forfait gratuit';

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get subscriptionActivated => 'Abonnement activé avec succès !';

  @override
  String get selectPaymentMethod => 'Sélectionner le mode de paiement';

  @override
  String get confirmPurchase => 'Confirmer l\'achat';

  @override
  String get productNotFound => 'Produit introuvable';

  @override
  String get swishPayment => 'Paiement Swish';

  @override
  String get waitingForPayment =>
      'En attente de la confirmation du paiement...';

  @override
  String get quotaExhausted => 'Quota épuisé';

  @override
  String get quotaExhaustedMessage =>
      'Vous avez utilisé toutes vos opérations pour ce mois.';

  @override
  String get upgradeYourPlan => 'Mettez à niveau votre forfait pour continuer.';

  @override
  String get later => 'Plus tard';

  @override
  String get viewPlans => 'Voir les forfaits';

  @override
  String get corporateApplication => 'Demande entreprise';

  @override
  String get corporateApplyInfo =>
      'Remplissez les informations de votre entreprise ci-dessous. Notre équipe examinera votre demande et vous contactera par e-mail et SMS.';

  @override
  String get companyInformation => 'Informations sur l\'entreprise';

  @override
  String get companyName => 'Nom de l\'entreprise';

  @override
  String get contactInformation => 'Informations de contact';

  @override
  String get contactName => 'Nom du contact';

  @override
  String get contactEmail => 'E-mail de contact';

  @override
  String get contactPhone => 'Téléphone de contact';

  @override
  String get required => 'Ce champ est obligatoire';

  @override
  String get submitApplication => 'Soumettre la demande';

  @override
  String get applicationSubmitted => 'Demande soumise !';

  @override
  String get applicationSubmittedMessage =>
      'Votre demande entreprise a été soumise. Nous l\'examinerons et vous notifierons par e-mail et SMS.';

  @override
  String get applicationError =>
      'Échec de l\'envoi de la demande. Veuillez réessayer.';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get productManagement => 'Gestion des produits';

  @override
  String get corporateApplications => 'Demandes entreprise';

  @override
  String get newProduct => 'Nouveau produit';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get productName => 'Nom du produit';

  @override
  String get monthlyQuota => 'Quota mensuel';

  @override
  String get productType => 'Type de produit';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String get confirmDeleteProduct =>
      'Êtes-vous sûr de vouloir désactiver ce produit ?';

  @override
  String get noApplications => 'Aucune demande trouvée';

  @override
  String get approved => 'Approuvé';

  @override
  String get reviewNote => 'Note de révision';

  @override
  String get optional => 'Facultatif';

  @override
  String get approveApplication => 'Approuver la demande';

  @override
  String get rejectApplication => 'Rejeter la demande';

  @override
  String get approveConfirmMessage =>
      'Cela créera une organisation et notifiera le demandeur.';

  @override
  String get rejectConfirmMessage =>
      'Le demandeur sera notifié par e-mail et SMS.';

  @override
  String get approve => 'Approuver';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkMode => 'Sombre';

  @override
  String get lightMode => 'Clair';

  @override
  String get systemMode => 'Système';
}
