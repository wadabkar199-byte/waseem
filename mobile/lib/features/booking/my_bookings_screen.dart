import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/state_widgets.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _mockBookings = [
    {
      'id': 'b-1',
      'reference': 'WAS-8921B',
      'shop_name': 'صالون وسيم الفاخر',
      'service_name': 'قص شعر ملكي + غسيل',
      'barber_name': 'كابتن وسيم',
      'date_str': 'اليوم، 04:30 مساءً',
      'price': 50.0,
      'status': 'confirmed', // confirmed, completed, cancelled
    },
    {
      'id': 'b-2',
      'reference': 'WAS-4412A',
      'shop_name': 'صالون الأناقة الملكية',
      'service_name': 'تشذيب وتحديد لحية بالبخار',
      'barber_name': 'أحمد مراد',
      'date_str': 'الأسبوع الماضي، 06:00 مساءً',
      'price': 35.0,
      'status': 'completed',
    },
    {
      'id': 'b-3',
      'reference': 'WAS-1029X',
      'shop_name': 'صالون وسيم الفاخر',
      'service_name': 'باقة وسيم VIP',
      'barber_name': 'أي حلاق متاح',
      'date_str': '12 سبتمبر 2026',
      'price': 85.0,
      'status': 'cancelled',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCancelDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الحجز', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الموعد؟\nوفق سياسة الإلغاء، يمكنك الإلغاء مجاناً حتى ساعتين قبل الموعد.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() => booking['status'] = 'cancelled');
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إلغاء الحجز بنجاح')),
              );
            },
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(Map<String, dynamic> booking) {
    int rating = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('تقييم ${booking['shop_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('كيف كانت تجربتك مع الخدمة والحلاق؟', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setModalState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                decoration: const InputDecoration(hintText: 'اكتب رأيك هنا (اختياري)...'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('شكراً لك! تم حفظ تقييمك الموثق بنجاح')),
                );
              },
              child: const Text('إرسال التقييم'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'القادمة'),
            Tab(text: 'السابقة'),
            Tab(text: 'الملغاة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList('confirmed'),
          _buildBookingsList('completed'),
          _buildBookingsList('cancelled'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String filterStatus) {
    final list = _mockBookings.where((b) => b['status'] == filterStatus).toList();

    if (list.isEmpty) {
      return const EmptyStateWidget(
        title: 'لا توجد حجوزات في هذا القسم',
        subtitle: 'ستظهر مواعيدك هنا فور حجزها',
        icon: Icons.calendar_today_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final b = list[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(b['reference'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                  _buildStatusBadge(b['status']),
                ],
              ),
              const SizedBox(height: 10),
              Text(b['shop_name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${b['service_name']} • الحلاق: ${b['barber_name']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(b['date_str'], style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const Spacer(),
                  Text('${b['price']} ر.س', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              if (b['status'] == 'confirmed') ...[
                const SizedBox(height: 14),
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    onPressed: () => _showCancelDialog(b),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('إلغاء الموعد'),
                  ),
                ),
              ],
              if (b['status'] == 'completed') ...[
                const SizedBox(height: 14),
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.primaryDark,
                      minimumSize: const Size(130, 36),
                    ),
                    onPressed: () => _showReviewDialog(b),
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('تقييم الخدمة'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case 'confirmed':
        bg = AppColors.success.withOpacity(0.12);
        fg = AppColors.success;
        text = 'مؤكد';
        break;
      case 'completed':
        bg = AppColors.primary.withOpacity(0.12);
        fg = AppColors.primary;
        text = 'مكتمل';
        break;
      case 'cancelled':
      default:
        bg = AppColors.error.withOpacity(0.12);
        fg = AppColors.error;
        text = 'ملغى';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
