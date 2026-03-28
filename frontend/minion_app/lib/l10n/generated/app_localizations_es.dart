// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Minion';

  @override
  String get bankIdAuthSystem => 'Sistema de autorización BankID';

  @override
  String get loginWithBankId => 'Iniciar sesión con BankID';

  @override
  String get thisDevice => 'Este dispositivo';

  @override
  String get otherDevice => 'Otro dispositivo';

  @override
  String get scanQrCode => 'Escanea el código QR con\ntu app BankID';

  @override
  String get openingBankIdApp => 'Abriendo la app BankID...';

  @override
  String get openBankIdApp => 'Abrir app BankID';

  @override
  String get waitingForApproval => 'Esperando tu aprobación de BankID...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get dashboard => 'Panel';

  @override
  String get delegations => 'Delegaciones';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get profile => 'Perfil';

  @override
  String get creditBalance => 'Saldo de créditos';

  @override
  String get buyCredits => 'Comprar créditos';

  @override
  String remainingCredits(int count) {
    return 'Créditos restantes: $count';
  }

  @override
  String thisOperationCosts(int count) {
    return 'Esta operación: $count créditos';
  }

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get grantDelegation => 'Conceder delegación';

  @override
  String get myDelegations => 'Mis delegaciones';

  @override
  String get recentDelegations => 'Delegaciones recientes';

  @override
  String get noDelegationsYet => 'Sin delegaciones aún';

  @override
  String grantedDelegations(int count) {
    return 'Concedidas ($count)';
  }

  @override
  String receivedDelegations(int count) {
    return 'Recibidas ($count)';
  }

  @override
  String get noGrantedDelegations => 'No has concedido ninguna delegación';

  @override
  String get noReceivedDelegations => 'No hay delegaciones concedidas a ti';

  @override
  String get all => 'Todos';

  @override
  String get active => 'Activo';

  @override
  String get pending => 'Pendiente';

  @override
  String get rejected => 'Rechazado';

  @override
  String get revoked => 'Revocado';

  @override
  String get expired => 'Vencido';

  @override
  String get personSelection => 'Selección de persona';

  @override
  String get searchByPersonnummer => 'Buscar por personnummer, nombre o email';

  @override
  String get organization => 'Organización';

  @override
  String get selectOrganization => 'Seleccionar organización';

  @override
  String get operationTypes => 'Tipos de operación';

  @override
  String get duration => 'Duración';

  @override
  String get selectDateRange => 'Seleccionar rango de fechas';

  @override
  String get start => 'Inicio';

  @override
  String get end => 'Fin';

  @override
  String get minutes => 'Minutos';

  @override
  String get hours => 'Horas';

  @override
  String get days => 'Días';

  @override
  String get value => 'Valor';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String grantDelegationBtn(int cost) {
    return 'Conceder delegación ($cost créditos)';
  }

  @override
  String get sending => 'Enviando...';

  @override
  String get delegationDetail => 'Detalle de delegación';

  @override
  String get status => 'Estado';

  @override
  String get credits => 'Créditos';

  @override
  String get grantor => 'Delegante';

  @override
  String get delegatePerson => 'Delegado';

  @override
  String get validityPeriod => 'Período de validez';

  @override
  String get note => 'Nota';

  @override
  String get accept => 'Aceptar';

  @override
  String get reject => 'Rechazar';

  @override
  String get revokeDelegation => 'Revocar delegación';

  @override
  String get delegationAccepted => 'Delegación aceptada';

  @override
  String get delegationRejected => 'Delegación rechazada';

  @override
  String get delegationRevoked => 'Delegación revocada';

  @override
  String get delegationCreated => '¡Delegación concedida con éxito!';

  @override
  String get purchaseCredits => 'Comprar créditos';

  @override
  String get paymentMethod => 'Método de pago';

  @override
  String get creditPackages => 'Paquetes de créditos';

  @override
  String get noPackagesFound => 'No se encontraron paquetes';

  @override
  String get payWithSwish => 'Pagar con Swish';

  @override
  String get payWithPaypal => 'Pagar con PayPal';

  @override
  String get payWithKlarna => 'Pagar con Klarna';

  @override
  String get redirectingToPayment => 'Redirigiendo a la página de pago...';

  @override
  String get paymentInitiated => 'Pago iniciado';

  @override
  String get creditHistory => 'Historial de créditos';

  @override
  String get noTransactionsYet => 'Sin transacciones aún';

  @override
  String get noNotifications => 'Sin notificaciones aún';

  @override
  String get markAllRead => 'Marcar todo como leído';

  @override
  String get justNow => 'Ahora mismo';

  @override
  String minutesAgo(int count) {
    return 'Hace $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'Hace $count horas';
  }

  @override
  String daysAgo(int count) {
    return 'Hace $count días';
  }

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get swedish => 'Sueco';

  @override
  String get turkish => 'Turco';

  @override
  String get german => 'Alemán';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Francés';

  @override
  String get appLanguage => 'Idioma de la app';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get personnummer => 'Personnummer';

  @override
  String get email => 'Correo electrónico';

  @override
  String get phone => 'Teléfono';

  @override
  String get notSpecified => 'No especificado';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get profileUpdated => 'Perfil actualizado correctamente';

  @override
  String get profileUpdateFailed => 'No se pudo actualizar el perfil';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get editInfo => 'Editar información';

  @override
  String get theme => 'Tema';

  @override
  String get adminPanel => 'Panel de administración';

  @override
  String get users => 'Usuarios';

  @override
  String get organizations => 'Organizaciones';

  @override
  String get organizationManagement => 'Gestión de organizaciones';

  @override
  String get operationTypeManagement => 'Tipos de operación';

  @override
  String get userOrgMapping => 'Usuario-Organización';

  @override
  String get creditPackageManagement => 'Paquetes de créditos';

  @override
  String get auditLog => 'Registro de auditoría';

  @override
  String get management => 'Gestión';

  @override
  String get totalUsers => 'Total de usuarios';

  @override
  String get totalOrganizations => 'Total de organizaciones';

  @override
  String get activeDelegations => 'Delegaciones activas';

  @override
  String get pendingCount => 'Pendiente';

  @override
  String get totalCredits => 'Total de créditos';

  @override
  String get revenueSEK => 'Ingresos (SEK)';

  @override
  String get newOrganization => 'Nueva organización';

  @override
  String get editOrganization => 'Editar organización';

  @override
  String get deleteOrganization => 'Eliminar organización';

  @override
  String get deleteOrgConfirm =>
      '¿Estás seguro de que deseas eliminar esta organización?';

  @override
  String get orgName => 'Nombre de la organización';

  @override
  String get orgNumber => 'Número de org.';

  @override
  String get city => 'Ciudad';

  @override
  String get create => 'Crear';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get newPackage => 'Nuevo paquete';

  @override
  String get editPackage => 'Editar paquete';

  @override
  String get packageName => 'Nombre del paquete';

  @override
  String get creditAmount => 'Cantidad de créditos';

  @override
  String get priceSEK => 'Precio (SEK)';

  @override
  String get description => 'Descripción';

  @override
  String get error => 'Error';

  @override
  String errorOccurred(String message) {
    return 'Ha ocurrido un error: $message';
  }

  @override
  String get networkError => 'Error de red. Comprueba tu conexión.';

  @override
  String get sessionExpired =>
      'Sesión expirada. Por favor, inicia sesión de nuevo.';

  @override
  String get insufficientCredits =>
      'Créditos insuficientes. Por favor, compra más.';

  @override
  String get loading => 'Cargando...';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get invalidEmail => 'Por favor introduce un correo electrónico válido';

  @override
  String get invalidPhone => 'Por favor introduce un número de teléfono válido';

  @override
  String minLength(int count) {
    return 'Debe tener al menos $count caracteres';
  }

  @override
  String get invalidPersonnummer =>
      'Por favor introduce un personnummer válido';

  @override
  String get amountMustBePositive => 'El importe debe ser mayor que 0';

  @override
  String get selectAtLeastOneOperation =>
      'Por favor selecciona al menos un tipo de operación';

  @override
  String get selectPerson => 'Por favor selecciona una persona';

  @override
  String get selectOrg => 'Por favor selecciona una organización';

  @override
  String get endDateAfterStart =>
      'La fecha de fin debe ser posterior a la fecha de inicio';
}
