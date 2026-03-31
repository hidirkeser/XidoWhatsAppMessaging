import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/api_endpoints.dart';
import '../network/api_client.dart';

class NotificationCubit extends Cubit<int> {
  NotificationCubit(this._api) : super(0);

  final ApiClient _api;

  Future<void> fetchUnreadCount() async {
    try {
      final res = await _api.dio.get(ApiEndpoints.notificationsUnreadCount);
      emit(res.data['count'] as int? ?? 0);
    } catch (_) {}
  }

  void increment() => emit(state + 1);

  void reset() => emit(0);
}
