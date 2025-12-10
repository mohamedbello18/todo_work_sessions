import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final dndProvider = StateNotifierProvider<DndNotifier, bool>((ref) {
  return DndNotifier();
});

class DndNotifier extends StateNotifier<bool> {
  DndNotifier() : super(false) {
    if (Platform.isAndroid || Platform.isIOS) {
      _checkDndStatus();
    }
  }

  Future<void> _checkDndStatus() async {
    final status = await Permission.accessNotificationPolicy.status;
    state = status.isGranted;
  }

  Future<void> requestDndPermission() async {
    final status = await Permission.accessNotificationPolicy.request();
    state = status.isGranted;
    if (await Permission.accessNotificationPolicy.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> toggleDnd() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await Permission.accessNotificationPolicy.isGranted) {
        // This is where you would toggle DND if the platform allows.
        // For now, we will just reflect the permission status.
        state = !state;
      } else {
        await requestDndPermission();
      }
    }
  }
}
