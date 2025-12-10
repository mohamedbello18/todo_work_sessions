// lib/features/settings/application/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Adaptateur pour que Hive puisse stocker l'enum ThemeMode
class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 4; // On utilise le prochain ID disponible

  @override
  ThemeMode read(BinaryReader reader) {
    return ThemeMode.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeByte(obj.index);
  }
}

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Box _settingsBox;

  ThemeNotifier(this._settingsBox) : super(_settingsBox.get('themeMode', defaultValue: ThemeMode.system) as ThemeMode);

  void setTheme(ThemeMode themeMode) {
    state = themeMode;
    _settingsBox.put('themeMode', themeMode);
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final settingsBox = Hive.box('settings');
  return ThemeNotifier(settingsBox);
});
