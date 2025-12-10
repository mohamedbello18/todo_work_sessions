// lib/core/application/service_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Provider pour le NotificationService.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Le provider pour le service DND a été supprimé.
