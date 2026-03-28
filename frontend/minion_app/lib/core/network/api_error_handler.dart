import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

class ApiErrorHandler {
  static String getErrorMessage(BuildContext context, dynamic error) {
    final s = AppL10n.of(context)!;

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return s.networkError;
      }

      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (statusCode == 401) return s.sessionExpired;
      if (statusCode == 402) return s.insufficientCredits;

      if (data is Map<String, dynamic> && data.containsKey('error')) {
        return data['error'] as String;
      }

      return switch (statusCode) {
        400 => s.errorOccurred( 'Bad request'),
        403 => s.errorOccurred( 'Forbidden'),
        404 => s.errorOccurred( 'Not found'),
        500 => s.errorOccurred( 'Server error'),
        _ => s.errorOccurred( 'Unknown error'),
      };
    }

    return s.errorOccurred( error.toString());
  }

  static void showError(BuildContext context, dynamic error) {
    final message = getErrorMessage(context, error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
