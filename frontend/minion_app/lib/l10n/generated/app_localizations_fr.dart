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
  String get creditHistory => 'Historique des crédits';

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
}
