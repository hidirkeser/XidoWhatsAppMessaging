import 'package:flutter_test/flutter_test.dart';
import 'package:minion_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minion_app/core/network/api_client.dart';

void main() {
  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final bloc = AuthBloc(apiClient: ApiClient());
      expect(bloc.state, isA<AuthInitial>());
      bloc.close();
    });

    test('AuthInitBankId event has correct props', () {
      final event = AuthInitBankId();
      expect(event.props, isEmpty);
    });

    test('AuthCollect event contains orderRef', () {
      final event = AuthCollect('test-order-ref');
      expect(event.orderRef, 'test-order-ref');
      expect(event.props, ['test-order-ref']);
    });

    test('AuthAuthenticated state has correct values', () {
      const state = AuthAuthenticated(
        userId: 'test-id',
        firstName: 'Test',
        lastName: 'User',
        personalNumber: '199001011234',
        isAdmin: true,
      );
      expect(state.userId, 'test-id');
      expect(state.firstName, 'Test');
      expect(state.lastName, 'User');
      expect(state.isAdmin, true);
    });

    test('AuthError state contains message', () {
      const state = AuthError('test error');
      expect(state.message, 'test error');
      expect(state.props, ['test error']);
    });

    test('AuthWaitingForBankId state has correct values', () {
      const state = AuthWaitingForBankId(
        orderRef: 'ref-1',
        autoStartToken: 'token-1',
        qrData: 'qr-data-1',
      );
      expect(state.orderRef, 'ref-1');
      expect(state.autoStartToken, 'token-1');
      expect(state.qrData, 'qr-data-1');
    });

    test('different AuthError states with same message are equal', () {
      const state1 = AuthError('error');
      const state2 = AuthError('error');
      expect(state1, equals(state2));
    });

    test('different AuthError states with different messages are not equal', () {
      const state1 = AuthError('error1');
      const state2 = AuthError('error2');
      expect(state1, isNot(equals(state2)));
    });
  });
}
