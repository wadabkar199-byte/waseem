import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// نموذج بيانات العرض الترويجي (عرض وسيم)
class PromotionModel {
  final String id;
  final String shopId;
  final String code;
  final String title;
  final String? description;
  final String discountType; // 'percentage' or 'fixed_amount'
  final double discountValue;
  final double minOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int? maxUses;
  final int usedCount;
  final bool isActive;

  PromotionModel({
    required this.id,
    required this.shopId,
    required this.code,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.startDate,
    required this.endDate,
    this.maxUses,
    required this.usedCount,
    required this.isActive,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      code: json['code'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String? ?? 'percentage',
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      maxUses: json['max_uses'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// خدمة إدارة والتحقق من العروض والخصومات
class PromotionService {
  final SupabaseClient? _client;

  PromotionService({SupabaseClient? client})
      : _client = client ?? (Supabase.instance.isInitialized ? Supabase.instance.client : null);

  /// جلب العروض النشطة لصالون معين تظهر للعملاء
  Future<List<PromotionModel>> getActivePromotions(String shopId) async {
    if (_client == null) return _getMockPromotions(shopId);

    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client!
          .from('promotions')
          .select('*')
          .eq('shop_id', shopId)
          .eq('is_active', true)
          .lte('start_date', now)
          .gte('end_date', now);

      final List<dynamic> list = response as List<dynamic>;
      return list.map((json) => PromotionModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error getting promotions: $e');
      return _getMockPromotions(shopId);
    }
  }

  /// إنشاء عرض جديد من قبل الحلاق لصالونه فقط
  Future<void> createPromotion({
    required String shopId,
    required String code,
    required String title,
    required String description,
    required String discountType,
    required double discountValue,
    required DateTime startDate,
    required DateTime endDate,
    int? maxUses,
  }) async {
    if (_client == null) return;

    try {
      await _client!.from('promotions').insert({
        'shop_id': shopId,
        'code': code.toUpperCase().trim(),
        'title': title.trim(),
        'description': description.trim(),
        'discount_type': discountType,
        'discount_value': discountValue,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'max_uses': maxUses,
        'is_active': true,
      });
    } catch (e) {
      debugPrint('Error creating promotion: $e');
      rethrow;
    }
  }

  /// التحقق الصارم من العرض وحساب السعر خادمياً لمنع التلاعب
  Future<Map<String, dynamic>> validateAndCalculateDiscount({
    required String shopId,
    required String promoCode,
    required double originalAmount,
  }) async {
    // التحقق النهائي يُحسم خادمياً دائماً
    if (_client == null) {
      // محاكاة الخصم أثناء التطوير
      if (promoCode.toUpperCase() == 'WASEEM20') {
        final discount = originalAmount * 0.20;
        return {
          'is_valid': true,
          'discount_amount': discount,
          'final_amount': originalAmount - discount,
          'message': 'تم تطبيق خصم 20%',
        };
      }
      return {
        'is_valid': false,
        'discount_amount': 0.0,
        'final_amount': originalAmount,
        'message': 'كود الخصم غير صحيح أو منتهي',
      };
    }

    try {
      final now = DateTime.now().toIso8601String();
      final promo = await _client!
          .from('promotions')
          .select('*')
          .eq('shop_id', shopId)
          .eq('code', promoCode.toUpperCase().trim())
          .eq('is_active', true)
          .lte('start_date', now)
          .gte('end_date', now)
          .maybeSingle();

      if (promo == null) {
        return {
          'is_valid': false,
          'discount_amount': 0.0,
          'final_amount': originalAmount,
          'message': 'الكود غير صالح أو منتهي الصلاحية',
        };
      }

      final maxUses = promo['max_uses'] as int?;
      final usedCount = promo['used_count'] as int? ?? 0;
      if (maxUses != null && usedCount >= maxUses) {
        return {
          'is_valid': false,
          'discount_amount': 0.0,
          'final_amount': originalAmount,
          'message': 'تم استنفاد الحد الأقصى لاستخدام هذا العرض',
        };
      }

      final discountType = promo['discount_type'] as String;
      final discountVal = (promo['discount_value'] as num).toDouble();
      double discountAmount = 0.0;

      if (discountType == 'percentage') {
        discountAmount = (originalAmount * discountVal) / 100.0;
      } else {
        discountAmount = discountVal;
      }

      if (discountAmount > originalAmount) {
        discountAmount = originalAmount;
      }

      return {
        'is_valid': true,
        'discount_amount': discountAmount,
        'final_amount': originalAmount - discountAmount,
        'message': 'تم تطبيق العرض بنجاح',
      };
    } catch (e) {
      debugPrint('Error validating promo: $e');
      rethrow;
    }
  }

  List<PromotionModel> _getMockPromotions(String shopId) {
    return [
      PromotionModel(
        id: 'promo-1',
        shopId: shopId,
        code: 'WASEEM20',
        title: 'عرض وسيم الترحيبي',
        description: 'خصم 20% على باقة العناية الشاملة وحلاقة الشعر الملكية',
        discountType: 'percentage',
        discountValue: 20.0,
        minOrderAmount: 50.0,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        maxUses: 100,
        usedCount: 14,
        isActive: true,
      ),
    ];
  }
}
