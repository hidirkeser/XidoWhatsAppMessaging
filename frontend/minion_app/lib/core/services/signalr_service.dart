import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignalRService {
  // Placeholder for SignalR connection
  // In production, use signalr_netcore package
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  bool _connected = false;

  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;
  bool get isConnected => _connected;

  Future<void> connect() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    if (token == null) return;

    // TODO: Replace with actual SignalR connection
    // final connection = HubConnectionBuilder()
    //   .withUrl('${ApiEndpoints.baseUrl.replaceAll('/api', '')}/hubs/notifications',
    //     HttpConnectionOptions(accessTokenFactory: () async => token))
    //   .withAutomaticReconnect()
    //   .build();
    //
    // connection.on('ReceiveNotification', (args) {
    //   _notificationController.add(args![0] as Map<String, dynamic>);
    // });
    //
    // await connection.start();

    _connected = true;
    debugPrint('SignalR: Connected (placeholder)');
  }

  Future<void> disconnect() async {
    _connected = false;
    debugPrint('SignalR: Disconnected');
  }

  void dispose() {
    _notificationController.close();
  }
}
