import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/network/api_client.dart';

class CreditCubit extends Cubit<int> {
  CreditCubit() : super(0);

  Future<void> loadBalance() async {
    try {
      final response = await sl<ApiClient>().dio.get(ApiEndpoints.creditsBalance);
      emit(response.data['balance'] as int? ?? 0);
    } catch (_) {}
  }
}
