import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

/// Maps backend error codes to localized strings.
class ErrorCodeTranslator {
  static String? translate(BuildContext context, String? errorCode) {
    if (errorCode == null) return null;
    final s = AppL10n.of(context);
    if (s == null) return null;

    return switch (errorCode) {
      'CANNOT_DELEGATE_TO_SELF'   => s.errCannotDelegateToSelf,
      'INVALID_OPERATION_TYPES'   => s.errInvalidOperationTypes,
      'ONLY_GRANTOR_CAN_REVOKE'   => s.errOnlyGrantorCanRevoke,
      'ONLY_DELEGATE_CAN_REJECT'  => s.errOnlyDelegateCanReject,
      'ONLY_DELEGATE_CAN_ACCEPT'  => s.errOnlyDelegateCanAccept,
      'DELEGATION_INVALID_STATUS' => s.errDelegationInvalidStatus,
      'USER_ALREADY_IN_ORG'       => s.errUserAlreadyInOrg,
      'DELEGATE_USER_REQUIRED'    => s.errDelegateUserRequired,
      'ORGANIZATION_REQUIRED'     => s.errOrganizationRequired,
      'OPERATION_TYPES_REQUIRED'  => s.errOperationTypesRequired,
      'DURATION_TYPE_REQUIRED'    => s.errDurationTypeRequired,
      'DURATION_VALUE_INVALID'    => s.errDurationValueInvalid,
      'START_DATE_REQUIRED'       => s.errStartDateRequired,
      'END_DATE_REQUIRED'         => s.errEndDateRequired,
      'END_DATE_BEFORE_START'     => s.errEndDateBeforeStart,
      'ORG_NAME_REQUIRED'         => s.errOrgNameRequired,
      'ORG_NUMBER_REQUIRED'       => s.errOrgNumberRequired,
      'INVALID_EMAIL'             => s.errInvalidEmail,
      'INVALID_PHONE'             => s.errInvalidPhone,
      'CREDIT_PACKAGE_REQUIRED'   => s.errCreditPackageRequired,
      'INVALID_PAYMENT_PROVIDER'  => s.errInvalidPaymentProvider,
      'OPERATION_NAME_REQUIRED'   => s.errOperationNameRequired,
      'CREDIT_COST_INVALID'       => s.errCreditCostInvalid,
      'NOT_FOUND'                 => s.errNotFound,
      'INSUFFICIENT_CREDITS'      => s.errInsufficientCredits,
      'FORBIDDEN'                 => s.errForbidden,
      'UNAUTHORIZED'              => s.errUnauthorized,
      'INTERNAL_ERROR'            => s.errInternalError,
      'VALIDATION_ERROR'          => s.errValidationError,
      _                           => null,
    };
  }
}
