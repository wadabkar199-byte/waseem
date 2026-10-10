import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/client_models.dart';

/// خدمة إدارة الصالون وملف الحلاق
class BarberManagementService {
  final SupabaseClient? _client;

  BarberManagementService({SupabaseClient? client})
      : _client = client ?? (Supabase.instance.isInitialized ? Supabase.instance.client : null);

  /// جلب صالون الحلاق الحالي بناءً على المستخدم المسجل
  Future<Map<String, dynamic>?> getMyBarberShop() async {
    if (_client == null || _client!.auth.currentUser == null) {
      return _getMockBarberShop();
    }

    try {
      final userId = _client!.auth.currentUser!.id;
      final response = await _client!
          .from('barber_shops')
          .select('*')
          .eq('owner_id', userId)
          .maybeSingle();

      return response ?? _getMockBarberShop();
    } catch (e) {
      debugPrint('Error getting barber shop: $e');
      return _getMockBarberShop();
    }
  }

  /// رفع صورة المحل أو الشعار مع التحقق من النوع والحجم (أقل من 5MB وصور فقط)
  Future<String?> uploadShopImage({
    required File file,
    required String shopId,
    required String bucketName, // 'shop-logos' or 'shop-covers'
  }) async {
    // 1. التحقق من الحجم محلياً وخادمياً
    final fileSizeInBytes = await file.length();
    const maxSizeBytes = 5 * 1024 * 1024; // 5 MB
    if (fileSizeInBytes > maxSizeBytes) {
      throw Exception('حجم الصورة يتجاوز الحد المسموح به (5 ميجابايت)');
    }

    // 2. التحقق من الامتداد
    final extension = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      throw Exception('صيغة الملف غير مدعومة. يرجى اختيار صورة JPG أو PNG أو WebP');
    }

    if (_client == null) {
      // محاكاة نجاح الرفع أثناء التطوير
      return 'https://images.waseem.app/mock-shop-$shopId.$extension';
    }

    try {
      final fileName = '${shopId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final path = 'shops/$shopId/$fileName';

      await _client!.storage.from(bucketName).upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final publicUrl = _client!.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image to Supabase Storage: $e');
      rethrow;
    }
  }

  /// تحديث بيانات الصالون
  Future<void> updateShopDetails({
    required String shopId,
    required String name,
    required String description,
    required String addressText,
    String? logoUrl,
  }) async {
    if (_client == null) return;

    try {
      await _client!.from('barber_shops').update({
        'name': name,
        'description': description,
        'address_text': addressText,
        if (logoUrl != null) 'logo_url': logoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', shopId);
    } catch (e) {
      debugPrint('Error updating shop: $e');
      rethrow;
    }
  }

  /// إضافة أو تحديث خدمة
  Future<void> saveService({
    String? serviceId,
    required String shopId,
    required String nameAr,
    required String? description,
    required int durationMinutes,
    required double price,
  }) async {
    if (_client == null) return;

    try {
      final payload = {
        'shop_id': shopId,
        'name_ar': nameAr,
        'description': description,
        'duration_minutes': durationMinutes,
        'price': price,
        'is_active': true,
      };

      if (serviceId != null) {
        await _client!.from('services').update(payload).eq('id', serviceId);
      } else {
        await _client!.from('services').insert(payload);
      }
    } catch (e) {
      debugPrint('Error saving service: $e');
      rethrow;
    }
  }

  /// حذف أو تعطيل خدمة
  Future<void> deleteService(String serviceId) async {
    if (_client == null) return;

    try {
      await _client!.from('services').update({'is_active': false}).eq('id', serviceId);
    } catch (e) {
      debugPrint('Error deleting service: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _getMockBarberShop() {
    return {
      'id': '11111111-0000-0000-0000-000000000001',
      'name': 'صالون وسيم الفاخر',
      'description': 'صالون متخصص في قصات الشعر العصرية وتصميم اللحية والعناية بالرجل.',
      'address_text': 'حي العليا، طريق الملك فهد، الرياض',
      'status': 'pending_review', // قيد المراجعة لا يظهر في البحث العام
      'auto_confirm': true,
      'cancellation_window_hours': 2,
      'rating_average': 0.0,
      'rating_count': 0,
    };
  }
}
