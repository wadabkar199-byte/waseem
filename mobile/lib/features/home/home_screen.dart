import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صباح الخير،',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  'أحمد السعيد [بيانات تجريبية]',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حقل البحث
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textMuted),
                  hintText: 'ابحث عن حلاق، صالون، أو خدمة...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // لافتة العروض والبانر الرئيسي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'عرض خاص وسيم',
                      style: TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'احصل على خصم 20% على باقة العناية الشاملة',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'حلاقة شعر + تشذيب لحية + عناية بالبشرة',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.primaryDark,
                      minimumSize: const Size(120, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () {},
                    child: const Text('احجز الآن'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // الخدمات الأكثر طلباً
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الخدمات الشائعة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('عرض الكل', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildServiceCategory(Icons.content_cut, 'قص شعر'),
                _buildServiceCategory(Icons.face, 'تشذيب لحية'),
                _buildServiceCategory(Icons.spa, 'تنظيف بشرة'),
                _buildServiceCategory(Icons.color_lens_outlined, 'صبغة'),
              ],
            ),

            const SizedBox(height: 28),
            // الحلاقين المقترحين
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'أفضل الصالونات المقترحة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('المزيد', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildBarberCard(
              name: 'صالون الأناقة الملكية',
              specialty: 'حلاقة كلاسيكية وعصرية • خبرة 7 سنوات',
              rating: '4.9',
              reviews: '142 تقييم',
              distance: '1.2 كم',
            ),
            const SizedBox(height: 12),
            _buildBarberCard(
              name: 'صالون وسيم المتميز',
              specialty: 'عناية كاملة بالرجل • تشذيب وقصات احترافية',
              rating: '4.8',
              reviews: '98 تقييم',
              distance: '2.5 كم',
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildServiceCategory(IconData icon, String title) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  static Widget _buildBarberCard({
    required String name,
    required String specialty,
    required String rating,
    required String reviews,
    required String distance,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(specialty, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text('($reviews)', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const Spacer(),
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    Text(distance, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
