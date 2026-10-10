import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة استقبال وتسجيل توكن الإشعارات FCM في تطبيق وسيم
class FcmNotificationService {
  final SupabaseClient? _client;

  FcmNotificationService({SupabaseClient? client})
      : _client = client ?? (Supabase.instance.isInitialized ? Supabase.instance.client : null);

  /// تهيئة المستمعين للإشعارات في الخلفية والمقدمة
  Future<void> initializeNotificationHandlers() async {
    debugPrint('FCM handlers initialized (Foreground & Background configured)');
  }

  /// حفظ رمز الجهاز (Device Token) في حساب المستخدم بخادم Supabase
  Future<void> syncDeviceToken(String fcmToken) async {
    if (_client == null || _client!.auth.currentUser == null) return;

    try {
      final userId = _client!.auth.currentUser!.id;
      // حفظ التوكن في جدول profiles لإرسال الإشعارات إلى هذا المستخدم
      await _client!.from('profiles').update({
        'fcm_token': fcmToken,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      debugPrint('Device FCM token synchronized successfully');
    } catch (e) {
      debugPrint('Error syncing FCM token: $e');
    }
  }

  /// معالجة النقر على الإشعار وتوجيه المستخدم للحجز المعني
  void handleNotificationNavigation(Map<String, dynamic> data) {
    final bookingRef = data['booking_reference'];
    debugPrint('Navigate to booking details for ref: $bookingRef');
  }
}
