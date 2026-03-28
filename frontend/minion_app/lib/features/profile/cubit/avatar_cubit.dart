import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarCubit extends Cubit<String?> {
  static const _key = 'user_avatar_path';

  AvatarCubit() : super(null);

  Future<void> loadAvatar() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_key);
    if (path != null && File(path).existsSync()) {
      emit(path);
    }
  }

  Future<void> setAvatar(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
    emit(path);
  }

  Future<void> clearAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    emit(null);
  }
}
