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
  String get loginWithBankIdOtherDevice =>
      'Iniciar sesión con BankID (otro dispositivo)';

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
  String get creditHistory => 'Historial de créditos';

  @override
  String get currentBalance => 'Saldo actual';

  @override
  String get noTransactions => 'Aún no hay transacciones.';

  @override
  String get txPurchase => 'Compra de créditos';

  @override
  String get txDelegationDeduction => 'Uso de delegación';

  @override
  String get txRefund => 'Reembolso';

  @override
  String get txManualAdjustment => 'Ajuste manual';

  @override
  String get balance => 'Saldo';

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

  @override
  String get clear => 'Limpiar';

  @override
  String get ok => 'Aceptar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get dialogSuccess => 'Éxito';

  @override
  String get dialogWarning => 'Advertencia';

  @override
  String get dialogInfo => 'Información';

  @override
  String get dialogConfirm => 'Confirmar';

  @override
  String get areYouSure => '¿Está seguro?';

  @override
  String get confirmAction => '¿Está seguro de que desea realizar esta acción?';

  @override
  String get revokeConfirm =>
      '¿Está seguro de que desea revocar esta delegación?';

  @override
  String get rejectConfirm =>
      '¿Está seguro de que desea rechazar esta delegación?';

  @override
  String get acceptConfirm =>
      '¿Está seguro de que desea aceptar esta delegación?';

  @override
  String get deleteConfirm => '¿Está seguro de que desea eliminar esto?';

  @override
  String get errCannotDelegateToSelf => 'No puede delegarse a sí mismo.';

  @override
  String get errInvalidOperationTypes =>
      'Uno o más tipos de operación no son válidos.';

  @override
  String get errOnlyGrantorCanRevoke =>
      'Solo el otorgante puede revocar esta delegación.';

  @override
  String get errOnlyDelegateCanReject =>
      'Solo el delegado puede rechazar esta delegación.';

  @override
  String get errOnlyDelegateCanAccept =>
      'Solo el delegado puede aceptar esta delegación.';

  @override
  String get errDelegationInvalidStatus =>
      'La delegación no puede realizar esta acción en su estado actual.';

  @override
  String get errUserAlreadyInOrg =>
      'El usuario ya está asignado a esta organización.';

  @override
  String get errDelegateUserRequired => 'Se requiere usuario delegado.';

  @override
  String get errOrganizationRequired => 'Se requiere organización.';

  @override
  String get errOperationTypesRequired =>
      'Se requiere al menos un tipo de operación.';

  @override
  String get errDurationTypeRequired => 'Se requiere tipo de duración.';

  @override
  String get errDurationValueInvalid =>
      'El valor de duración debe ser mayor que 0.';

  @override
  String get errStartDateRequired =>
      'Se requiere fecha de inicio para el rango de fechas.';

  @override
  String get errEndDateRequired =>
      'Se requiere fecha de fin para el rango de fechas.';

  @override
  String get errEndDateBeforeStart =>
      'La fecha de fin debe ser posterior a la fecha de inicio.';

  @override
  String get errOrgNameRequired =>
      'Se requiere nombre de organización (máx. 200 caracteres).';

  @override
  String get errOrgNumberRequired => 'Se requiere número de organización.';

  @override
  String get errInvalidEmail => 'Formato de correo electrónico no válido.';

  @override
  String get errInvalidPhone => 'Formato de número de teléfono no válido.';

  @override
  String get errCreditPackageRequired => 'Se requiere paquete de crédito.';

  @override
  String get errInvalidPaymentProvider =>
      'El proveedor debe ser Swish, PayPal o Klarna.';

  @override
  String get errOperationNameRequired =>
      'Se requiere nombre del tipo de operación (máx. 200 caracteres).';

  @override
  String get errCreditCostInvalid => 'El costo de crédito debe ser 0 o más.';

  @override
  String get errNotFound => 'Registro no encontrado.';

  @override
  String get errInsufficientCredits =>
      'Créditos insuficientes. Por favor compre más.';

  @override
  String get errForbidden => 'No tiene permiso para realizar esta acción.';

  @override
  String get errUnauthorized =>
      'La sesión ha expirado. Por favor inicie sesión de nuevo.';

  @override
  String get errInternalError =>
      'Ocurrió un error inesperado. Por favor inténtelo de nuevo.';

  @override
  String get errValidationError =>
      'Por favor corrija los errores del formulario e inténtelo de nuevo.';

  @override
  String get gdprTitle => 'Privacidad y uso de datos';

  @override
  String get gdprSubtitle =>
      'Lea la siguiente información y dé su consentimiento antes de usar la app.';

  @override
  String get gdprDataProcessingTitle => 'Sus datos personales';

  @override
  String get gdprDataProcessingBody =>
      'Sus datos de autenticación BankID se procesan para gestionar transacciones de autorización. Su número personal se almacena cifrado.';

  @override
  String get gdprSecurityTitle => 'Seguridad de datos';

  @override
  String get gdprSecurityBody =>
      'Sus datos se almacenan en servidores Azure cifrados. Los documentos firmados se archivan 7 años según la ley.';

  @override
  String get gdprRightsTitle => 'Sus derechos';

  @override
  String get gdprRightsBody =>
      'Tiene derecho a solicitar acceso, corrección y eliminación de sus datos desde la página de perfil.';

  @override
  String get gdprRequiredConsentLabel =>
      'Doy mi consentimiento para el tratamiento de mis datos personales para los fines indicados. (Obligatorio)';

  @override
  String get gdprMarketingConsentLabel =>
      'Doy mi consentimiento para recibir comunicaciones por WhatsApp, email y notificaciones. (Opcional)';

  @override
  String get gdprAcceptButton => 'Acepto y continúo';

  @override
  String get gdprFootnote =>
      'Este consentimiento es requerido por el RGPD y la PDPL sueca.';

  @override
  String get bankIdSignTitle => 'Firmar con BankID';

  @override
  String get bankIdSignWaiting =>
      'Abriendo la app BankID. Por favor confirme la acción en su app BankID.';

  @override
  String get bankIdSignCompleting => 'Completando firma...';

  @override
  String get bankIdSignError => 'Error al firmar';

  @override
  String get signAndGrantDelegation => 'Firmar con BankID y conceder';

  @override
  String get retry => 'Reintentar';

  @override
  String get notifSettingsTitle => 'Configuración de notificaciones';

  @override
  String get notifSettingsDesc =>
      'Elija los canales por los que desea recibir notificaciones.';

  @override
  String get notifChannelInApp => 'En la app';

  @override
  String get notifChannelInAppDesc =>
      'Las notificaciones aparecen dentro de la app';

  @override
  String get notifChannelPush => 'Notificación push';

  @override
  String get notifChannelPushDesc =>
      'Notificaciones instantáneas enviadas a su dispositivo';

  @override
  String get notifChannelEmail => 'Correo electrónico';

  @override
  String get notifChannelEmailDesc =>
      'Enviado al correo electrónico de su perfil';

  @override
  String get notifChannelWhatsApp => 'WhatsApp';

  @override
  String get notifChannelWhatsAppDesc => 'Mensaje de WhatsApp vía Twilio';

  @override
  String get notifChannelSms => 'SMS';

  @override
  String get notifChannelSmsDesc => 'Mensaje SMS vía Twilio';

  @override
  String get notifChannelInactiveLabel => 'INACTIVO';

  @override
  String get notifChannelInactiveDesc => 'Este canal aún no está configurado.';

  @override
  String get notifRequiresEmail =>
      'Se debe establecer una dirección de correo electrónico en su perfil.';

  @override
  String get notifRequiresPhone =>
      'Se debe establecer un número de teléfono en su perfil.';

  @override
  String get notifSaveSuccess => 'Configuración de notificaciones guardada.';

  @override
  String get products => 'Planes y precios';

  @override
  String get individual => 'Individual';

  @override
  String get corporate => 'Corporativo';

  @override
  String get noProductsAvailable => 'No hay planes disponibles';

  @override
  String get corporateApiAccess => 'Acceso API corporativo';

  @override
  String get corporateApiDescription =>
      'Registre su empresa para acceder a nuestra API y funciones empresariales.';

  @override
  String get applyNow => 'Solicitar ahora';

  @override
  String get free => 'Gratis';

  @override
  String get month => 'mes';

  @override
  String get unlimited => 'Ilimitado';

  @override
  String get operationsPerMonth => 'operaciones/mes';

  @override
  String get activateFree => 'Activar plan gratuito';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get subscriptionActivated => '¡Suscripción activada con éxito!';

  @override
  String get selectPaymentMethod => 'Seleccionar método de pago';

  @override
  String get confirmPurchase => 'Confirmar compra';

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String get swishPayment => 'Pago con Swish';

  @override
  String get waitingForPayment => 'Esperando confirmación de pago...';

  @override
  String get quotaExhausted => 'Cuota agotada';

  @override
  String get quotaExhaustedMessage =>
      'Ha utilizado todas sus operaciones de este mes.';

  @override
  String get upgradeYourPlan => 'Mejore su plan para continuar.';

  @override
  String get later => 'Más tarde';

  @override
  String get viewPlans => 'Ver planes';

  @override
  String get corporateApplication => 'Solicitud corporativa';

  @override
  String get corporateApplyInfo =>
      'Complete los datos de su empresa a continuación. Nuestro equipo revisará su solicitud y se comunicará con usted por correo electrónico y SMS.';

  @override
  String get companyInformation => 'Información de la empresa';

  @override
  String get companyName => 'Nombre de la empresa';

  @override
  String get contactInformation => 'Información de contacto';

  @override
  String get contactName => 'Nombre de contacto';

  @override
  String get contactEmail => 'Correo de contacto';

  @override
  String get contactPhone => 'Teléfono de contacto';

  @override
  String get required => 'Este campo es obligatorio';

  @override
  String get submitApplication => 'Enviar solicitud';

  @override
  String get applicationSubmitted => '¡Solicitud enviada!';

  @override
  String get applicationSubmittedMessage =>
      'Su solicitud corporativa ha sido enviada. La revisaremos y le notificaremos por correo electrónico y SMS.';

  @override
  String get applicationError =>
      'Error al enviar la solicitud. Por favor, inténtelo de nuevo.';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get productManagement => 'Gestión de productos';

  @override
  String get corporateApplications => 'Solicitudes corporativas';

  @override
  String get newProduct => 'Nuevo producto';

  @override
  String get editProduct => 'Editar producto';

  @override
  String get productName => 'Nombre del producto';

  @override
  String get monthlyQuota => 'Cuota mensual';

  @override
  String get productType => 'Tipo de producto';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get confirmDeleteProduct =>
      '¿Está seguro de que desea desactivar este producto?';

  @override
  String get noApplications => 'No se encontraron solicitudes';

  @override
  String get approved => 'Aprobado';

  @override
  String get reviewNote => 'Nota de revisión';

  @override
  String get optional => 'Opcional';

  @override
  String get approveApplication => 'Aprobar solicitud';

  @override
  String get rejectApplication => 'Rechazar solicitud';

  @override
  String get approveConfirmMessage =>
      'Esto creará una organización y notificará al solicitante.';

  @override
  String get rejectConfirmMessage =>
      'El solicitante será notificado por correo electrónico y SMS.';

  @override
  String get approve => 'Aprobar';

  @override
  String get appearance => 'Apariencia';

  @override
  String get darkMode => 'Oscuro';

  @override
  String get lightMode => 'Claro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get documentTemplates => 'Plantillas de documentos';

  @override
  String get createTemplate => 'Crear plantilla';

  @override
  String get editTemplate => 'Editar plantilla';

  @override
  String get previewTemplate => 'Vista previa';

  @override
  String get previewTemplateHint =>
      'Haz clic en Vista previa para renderizar la plantilla con datos de ejemplo.';

  @override
  String get templatePlaceholders => 'Marcadores de posición disponibles';

  @override
  String get templatePlaceholdersDescription =>
      'Haz clic en un marcador para insertarlo.';

  @override
  String get version => 'Versión';

  @override
  String get settings => 'Configuración';

  @override
  String get inactive => 'Inactivo';

  @override
  String get noDataFound => 'No se encontraron datos';

  @override
  String get powerOfAttorney => 'Poder notarial';

  @override
  String get fullmakt => 'Fullmakt';

  @override
  String get signWithBankId => 'Firmar con BankID';

  @override
  String get documentReady => 'El documento está listo';

  @override
  String get shareViaWhatsApp => 'Compartir por WhatsApp';

  @override
  String get shareViaEmail => 'Compartir por correo';

  @override
  String get downloadPdf => 'Descargar PDF';

  @override
  String get scanQrToVerify => 'Escanear QR para verificar';

  @override
  String get documentDetails => 'Detalles del documento';

  @override
  String get signatures => 'Firmas';

  @override
  String get grantorSigned => 'El poderdante ha firmado';

  @override
  String get delegateSigned => 'El apoderado ha firmado';

  @override
  String get notYetSigned => 'Aún no firmado';

  @override
  String get shareDocument => 'Compartir documento';

  @override
  String get recipientPhone => 'Teléfono del destinatario';

  @override
  String get recipientEmail => 'Correo del destinatario';

  @override
  String get yourName => 'Su nombre';

  @override
  String get send => 'Enviar';

  @override
  String get documentShared => 'Documento compartido con éxito';
}
