import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minion_app/features/credits/cubit/credit_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('CreditCubit', () {
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
    });

    // ── Initial state ─────────────────────────────────────────────────────────

    test('initial state is 0', () {
      final cubit = CreditCubit(dio: mockDio);
      expect(cubit.state, 0);
      cubit.close();
    });

    // ── loadBalance ───────────────────────────────────────────────────────────

    blocTest<CreditCubit, int>(
      'loadBalance emits balance from API response',
      build: () {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/credits/balance'),
              statusCode: 200,
              data: {'balance': 42},
            ));
        return CreditCubit(dio: mockDio);
      },
      act: (cubit) => cubit.loadBalance(),
      expect: () => [42],
    );

    blocTest<CreditCubit, int>(
      'loadBalance emits 0 when balance field is missing',
      build: () {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/credits/balance'),
              statusCode: 200,
              data: <String, dynamic>{},
            ));
        return CreditCubit(dio: mockDio);
      },
      act: (cubit) => cubit.loadBalance(),
      expect: () => [0],
    );

    blocTest<CreditCubit, int>(
      'loadBalance emits correct balance when value is 0',
      build: () {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/credits/balance'),
              statusCode: 200,
              data: {'balance': 0},
            ));
        return CreditCubit(dio: mockDio);
      },
      act: (cubit) => cubit.loadBalance(),
      expect: () => [0],
    );

    blocTest<CreditCubit, int>(
      'loadBalance emits nothing when API throws DioException',
      build: () {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/credits/balance'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return CreditCubit(dio: mockDio);
      },
      act: (cubit) => cubit.loadBalance(),
      expect: () => <int>[], // no state change — error is swallowed
    );

    blocTest<CreditCubit, int>(
      'loadBalance emits nothing when generic exception thrown',
      build: () {
        when(() => mockDio.get(any())).thenThrow(Exception('unexpected'));
        return CreditCubit(dio: mockDio);
      },
      act: (cubit) => cubit.loadBalance(),
      expect: () => <int>[],
    );

    blocTest<CreditCubit, int>(
      'multiple loadBalance calls update state each time',
      build: () {
        var callCount = 0;
        when(() => mockDio.get(any())).thenAnswer((_) async {
          callCount++;
          return Response(
            requestOptions: RequestOptions(path: '/credits/balance'),
            statusCode: 200,
            data: {'balance': callCount * 10},
          );
        });
        return CreditCubit(dio: mockDio);
      },
      act: (cubit) async {
        await cubit.loadBalance();
        await cubit.loadBalance();
        await cubit.loadBalance();
      },
      expect: () => [10, 20, 30],
    );
  });
}
