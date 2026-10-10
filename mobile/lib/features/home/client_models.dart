/// نموذج بيانات صالون الحلاقة
class BarberShopModel {
  final String id;
  final String name;
  final String? description;
  final String addressText;
  final String? logoUrl;
  final String? coverImageUrl;
  final double ratingAverage;
  final int ratingCount;
  final String? districtName;
  final double? distanceKm;

  BarberShopModel({
    required this.id,
    required this.name,
    this.description,
    required this.addressText,
    this.logoUrl,
    this.coverImageUrl,
    required this.ratingAverage,
    required this.ratingCount,
    this.districtName,
    this.distanceKm,
  });

  factory BarberShopModel.fromJson(Map<String, dynamic> json) {
    return BarberShopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      addressText: json['address_text'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] as int? ?? 0,
      districtName: json['regions'] != null ? json['regions']['district_name'] as String? : null,
    );
  }
}

/// نموذج بيانات الخدمة
class ServiceModel {
  final String id;
  final String shopId;
  final String nameAr;
  final String? description;
  final int durationMinutes;
  final double price;

  ServiceModel({
    required this.id,
    required this.shopId,
    required this.nameAr,
    this.description,
    required this.durationMinutes,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      nameAr: json['name_ar'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}

/// نموذج بيانات الحلاق العامل
class BarberModel {
  final String id;
  final String shopId;
  final String name;
  final String? title;
  final String? photoUrl;

  BarberModel({
    required this.id,
    required this.shopId,
    required this.name,
    this.title,
    this.photoUrl,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      title: json['title'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}
