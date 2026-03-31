import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthInitBankId extends AuthEvent {}

class AuthCollect extends AuthEvent {
  final String orderRef;
  const AuthCollect(this.orderRef);
  @override
  List<Object?> get props => [orderRef];
}

class AuthCancel extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthLogout extends AuthEvent {}

class AuthConsentAccepted extends AuthEvent {}

class AuthUpdateProfile extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  const AuthUpdateProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });
  @override
  List<Object?> get props => [firstName, lastName, email, phone];
}

/// API çağrısı yapılmadan sadece auth state'ini günceller.
/// Profile sayfası API'yi direkt çağırdıktan sonra bunu dispatch eder.
class AuthProfileSynced extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  const AuthProfileSynced({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });
  @override
  List<Object?> get props => [firstName, lastName, email, phone];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthWaitingForBankId extends AuthState {
  final String orderRef;
  final String autoStartToken;
  final String qrData;

  const AuthWaitingForBankId({
    required this.orderRef,
    required this.autoStartToken,
    required this.qrData,
  });

  @override
  List<Object?> get props => [orderRef, autoStartToken, qrData];
}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String firstName;
  final String lastName;
  final String personalNumber;
  final bool isAdmin;
  final String email;
  final String phone;
  final DateTime? gdprConsentAcceptedAt;

  const AuthAuthenticated({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.personalNumber,
    required this.isAdmin,
    this.email = '',
    this.phone = '',
    this.gdprConsentAcceptedAt,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, personalNumber, isAdmin, email, phone, gdprConsentAcceptedAt];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient _apiClient;
  Timer? _pollingTimer;
  String? _currentOrderRef;

  AuthBloc({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(AuthInitial()) {
    on<AuthInitBankId>(_onInitBankId);
    on<AuthCollect>(_onCollect);
    on<AuthCancel>(_onCancel);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLogout>(_onLogout);
    on<AuthUpdateProfile>(_onUpdateProfile);
    on<AuthConsentAccepted>(_onConsentAccepted);
    on<AuthProfileSynced>(_onProfileSynced);
  }

  Future<void> _onInitBankId(AuthInitBankId event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.authInit);
      final data = response.data;

      _currentOrderRef = data['orderRef'];

      emit(AuthWaitingForBankId(
        orderRef: data['orderRef'],
        autoStartToken: data['autoStartToken'],
        qrData: data['qrData'],
      ));

      _startPolling(data['orderRef']);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _startPolling(String orderRef) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      add(AuthCollect(orderRef));
    });
  }

  Future<void> _onCollect(AuthCollect event, Emitter<AuthState> emit) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.authCollect,
        data: {'orderRef': event.orderRef},
      );
      final data = response.data;

      if (data['status'] == 'complete') {
        _pollingTimer?.cancel();
        await _apiClient.saveTokens(data['accessToken'], data['refreshToken']);

        final user = data['user'];
        emit(AuthAuthenticated(
          userId: user['id'],
          firstName: user['firstName'] ?? '',
          lastName: user['lastName'] ?? '',
          personalNumber: user['personalNumber'] ?? '',
          isAdmin: user['isAdmin'] ?? false,
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          gdprConsentAcceptedAt: null,
        ));
      } else if (data['status'] == 'failed') {
        _pollingTimer?.cancel();
        emit(AuthError(data['hintCode'] ?? 'Authentication failed'));
      }
      // 'pending' status: keep polling, don't emit new state
    } catch (e) {
      _pollingTimer?.cancel();
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCancel(AuthCancel event, Emitter<AuthState> emit) async {
    _pollingTimer?.cancel();
    if (_currentOrderRef != null) {
      try {
        await _apiClient.dio.post(
          ApiEndpoints.authCancel,
          data: {'orderRef': _currentOrderRef},
        );
      } catch (_) {}
    }
    emit(AuthInitial());
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final hasToken = await _apiClient.hasToken();
    if (hasToken) {
      try {
        final response = await _apiClient.dio.get(ApiEndpoints.usersMe);
        final user = response.data;
        final gdprRaw = user['gdprConsentAcceptedAt'] as String?;
        emit(AuthAuthenticated(
          userId: user['id'] ?? '',
          firstName: user['firstName'] ?? '',
          lastName: user['lastName'] ?? '',
          personalNumber: user['personalNumber'] ?? '',
          isAdmin: user['isAdmin'] ?? false,
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          gdprConsentAcceptedAt: gdprRaw != null ? DateTime.tryParse(gdprRaw) : null,
        ));
      } catch (_) {
        await _apiClient.clearTokens();
      }
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    _pollingTimer?.cancel();
    await _apiClient.clearTokens();
    emit(AuthInitial());
  }

  Future<void> _onUpdateProfile(AuthUpdateProfile event, Emitter<AuthState> emit) async {
    if (state is! AuthAuthenticated) return;
    final current = state as AuthAuthenticated;
    try {
      final response = await _apiClient.dio.put(
        '/api/users/me',
        data: {
          'firstName': event.firstName,
          'lastName': event.lastName,
          'email': event.email,
          'phone': event.phone,
        },
      );
      final user = response.data;
      emit(AuthAuthenticated(
        userId: user['id'] ?? current.userId,
        firstName: user['firstName'] ?? event.firstName,
        lastName: user['lastName'] ?? event.lastName,
        personalNumber: current.personalNumber,
        isAdmin: current.isAdmin,
        email: user['email'] ?? event.email,
        phone: user['phone'] ?? event.phone,
        gdprConsentAcceptedAt: current.gdprConsentAcceptedAt,
      ));
    } catch (e) {
      // Don't change state on error, re-emit current state
      emit(AuthAuthenticated(
        userId: current.userId,
        firstName: current.firstName,
        lastName: current.lastName,
        personalNumber: current.personalNumber,
        isAdmin: current.isAdmin,
        email: current.email,
        phone: current.phone,
        gdprConsentAcceptedAt: current.gdprConsentAcceptedAt,
      ));
    }
  }

  Future<void> _onProfileSynced(AuthProfileSynced event, Emitter<AuthState> emit) async {
    if (state is! AuthAuthenticated) return;
    final current = state as AuthAuthenticated;
    emit(AuthAuthenticated(
      userId: current.userId,
      firstName: event.firstName,
      lastName: event.lastName,
      personalNumber: current.personalNumber,
      isAdmin: current.isAdmin,
      email: event.email,
      phone: event.phone,
      gdprConsentAcceptedAt: current.gdprConsentAcceptedAt,
    ));
  }

  Future<void> _onConsentAccepted(AuthConsentAccepted event, Emitter<AuthState> emit) async {
    if (state is! AuthAuthenticated) return;
    final current = state as AuthAuthenticated;
    emit(AuthAuthenticated(
      userId: current.userId,
      firstName: current.firstName,
      lastName: current.lastName,
      personalNumber: current.personalNumber,
      isAdmin: current.isAdmin,
      email: current.email,
      phone: current.phone,
      gdprConsentAcceptedAt: DateTime.now(),
    ));
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
