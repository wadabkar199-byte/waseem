import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'client_models.dart';

/// خدمة جلب البيانات الحقيقية للعميل مع دعم التخزين المؤقت للاتصال الضعيف
class ClientDataService {
  final SupabaseClient? _client;

  // ذاكرة تخزين مؤقت خفيفة (Cache) لتحسين تجربة الاتصال الضعيف
  static List<BarberShopModel>? _cachedShops;
  static DateTime? _cacheTimestamp;

  ClientDataService({SupabaseClient? client})
      : _client = client ?? (Supabase.instance.isInitialized ? Supabase.instance.client : null);

  /// جلب قائمة الصالونات المعتمدة مع البحث والتصفية
  Future<List<BarberShopModel>> getApprovedShops({
    String? searchQuery,
    String? regionId,
    double? minRating,
  }) async {
    // 1. التحقق من التخزين المؤقت في حال عدم وجود فلترة
    final isSimpleQuery = searchQuery == null && regionId == null && minRating == null;
    if (isSimpleQuery && _cachedShops != null && _cacheTimestamp != null) {
      if (DateTime.now().difference(_cacheTimestamp!) < const Duration(minutes: 5)) {
        return _cachedShops!;
      }
    }

    if (_client == null) {
      // إرجاع بيانات أولية محلية مؤقتة إن لم يكن الاتصال مهيئاً
      return _getFallbackShops();
    }

    try {
      var query = _client!
          .from('barber_shops')
          .select('*, regions(district_name)')
          .eq('status', 'approved');

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.ilike('name', '%${searchQuery.trim()}%');
      }

      if (regionId != null) {
        query = query.eq('region_id', regionId);
      }

      if (minRating != null) {
        query = query.gte('rating_average', minRating);
      }

      final response = await query.order('rating_average', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      final shops = data.map((json) => BarberShopModel.fromJson(json as Map<String, dynamic>)).toList();

      if (isSimpleQuery) {
        _cachedShops = shops;
        _cacheTimestamp = DateTime.now();
      }

      return shops;
    } catch (e) {
      debugPrint('Error fetching shops from Supabase: $e');
      // في حال انقطاع الاتصال نلجأ إلى الكاش إن وجد
      if (_cachedShops != null) return _cachedShops!;
      return _getFallbackShops();
    }
  }

  /// جلب خدمات الصالون
  Future<List<ServiceModel>> getShopServices(String shopId) async {
    if (_client == null) return _getFallbackServices(shopId);

    try {
      final response = await _client!
          .from('services')
          .select('*')
          .eq('shop_id', shopId)
          .eq('is_active', true)
          .order('price', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => ServiceModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return _getFallbackServices(shopId);
    }
  }

  /// جلب حلاقي الصالون
  Future<List<BarberModel>> getShopBarbers(String shopId) async {
    if (_client == null) return _getFallbackBarbers(shopId);

    try {
      final response = await _client!
          .from('barbers')
          .select('*')
          .eq('shop_id', shopId)
          .eq('is_active', true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => BarberModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching barbers: $e');
      return _getFallbackBarbers(shopId);
    }
  }

  // --- بيانات احتياطية ذكية عند انقطاع الإنترنت أو أثناء التطوير ---
  List<BarberShopModel> _getFallbackShops() {
    return [
      BarberShopModel(
        id: '11111111-0000-0000-0000-000000000001',
        name: 'صالون وسيم المتميز',
        description: 'صالون رجالي فاخر يقدم أرقى خدمات الحلاقة والعناية الشخصية بأيدي خبراء متخصصين.',
        addressText: 'طريق الملك فهد، حي العليا، الرياض',
        ratingAverage: 4.9,
        ratingCount: 168,
        districtName: 'العليا',
        distanceKm: 1.4,
      ),
      BarberShopModel(
        id: '11111111-0000-0000-0000-000000000002',
        name: 'صالون الأناقة الملكية',
        description: 'قصات كلاسيكية وعصرية، تشذيب لحية بالبخار وتنظيف بشرة عميق.',
        addressText: 'طريق أنس بن مالك، حي الملقا، الرياض',
        ratingAverage: 4.8,
        ratingCount: 112,
        districtName: 'الملقا',
        distanceKm: 3.1,
      ),
    ];
  }

  List<ServiceModel> _getFallbackServices(String shopId) {
    return [
      ServiceModel(
        id: '22222222-0000-0000-0000-000000000001',
        shopId: shopId,
        nameAr: 'قص شعر ملكي وسيم',
        description: 'قص وتصفيف الشعر مع غسيل وسيشوار احترافي',
        durationMinutes: 30,
        price: 50.0,
      ),
      ServiceModel(
        id: '22222222-0000-0000-0000-000000000002',
        shopId: shopId,
        nameAr: 'تشذيب ورسم لحية',
        description: 'تحديد دقيق بالموس مع زيوت العناية الطبيعية والمنشفة الساخنة',
        durationMinutes: 20,
        price: 35.0,
      ),
      ServiceModel(
        id: '22222222-0000-0000-0000-000000000003',
        shopId: shopId,
        nameAr: 'باقة وسيم المتكاملة',
        description: 'شعر + لحية + تنظيف بشرة بالبخار وماسك طيني',
        durationMinutes: 60,
        price: 95.0,
      ),
    ];
  }

  List<BarberModel> _getFallbackBarbers(String shopId) {
    return [
      BarberModel(
        id: '33333333-0000-0000-0000-000000000001',
        shopId: shopId,
        name: 'كابتن وسيم',
        title: 'خبير الحلاقة وتصميم الإطلالات',
      ),
      BarberModel(
        id: '33333333-0000-0000-0000-000000000002',
        shopId: shopId,
        name: 'أحمد مراد',
        title: 'أخصائي قصات عصرية ولحية',
      ),
    ];
  }
}
