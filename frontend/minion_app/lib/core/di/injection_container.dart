import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../services/signalr_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<SignalRService>(() => SignalRService());
}
