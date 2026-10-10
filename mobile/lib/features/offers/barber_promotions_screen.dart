import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'promotion_service.dart';

class BarberPromotionsScreen extends StatefulWidget {
  final String shopId;

  const BarberPromotionsScreen({super.key, required this.shopId});

  @override
  State<BarberPromotionsScreen> createState() => _BarberPromotionsScreenState();
}

class _BarberPromotionsScreenState extends State<BarberPromotionsScreen> {
  final PromotionService _service = PromotionService();

  final List<Map<String, dynamic>> _promos = [
    {
      'id': '1',
      'code': 'WASEEM20',
      'title': 'عرض وسيم الترحيبي',
      'discount_type': 'نسبة 20%',
      'uses': '14 من 100 مستخدم',
      'status': 'نشط',
    },
    {
      'id': '2',
      'code': 'FRIDAY15',
      'title': 'خصم الجمعة المباركة',
      'discount_type': 'خصم 15 ر.س',
      'uses': '50 من 50 مستخدم',
      'status': 'مكتمل الاستخدام',
    },
  ];

  void _showAddPromotionDialog() {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    final usesCtrl = TextEditingController(text: '50');
    String discountType = 'percentage';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إنشاء عرض جديد', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'كود الخصم (مثال: SUMMER10)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'عنوان العرض'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('نسبة مئوية %'),
                        selected: discountType == 'percentage',
                        onSelected: (val) {
                          if (val) setDialogState(() => discountType = 'percentage');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('مبلغ ثابت (ر.س)'),
                        selected: discountType == 'fixed_amount',
                        onSelected: (val) {
                          if (val) setDialogState(() => discountType = 'fixed_amount');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: discountType == 'percentage' ? 'قيمة الخصم (%)' : 'قيمة الخصم (ر.س)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الحد الأقصى لعدد الاستخدامات'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (codeCtrl.text.trim().isEmpty || valCtrl.text.trim().isEmpty) return;
                setState(() {
                  _promos.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'code': codeCtrl.text.trim().toUpperCase(),
                    'title': titleCtrl.text.trim(),
                    'discount_type': discountType == 'percentage' ? '${valCtrl.text}%' : '${valCtrl.text} ر.س',
                    'uses': '0 من ${usesCtrl.text} مستخدم',
                    'status': 'نشط',
                  });
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إنشاء العرض بنجاح')),
                );
              },
              child: const Text('حفظ ونشر'),
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
        title: const Text('إدارة عروض وسيم'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddPromotionDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إنشاء عرض جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _promos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = _promos[index];
          final isActive = p['status'] == 'نشط';
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_offer_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(p['code'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.success.withOpacity(0.12) : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p['status'],
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? AppColors.success : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(p['title'], style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('${p['discount_type']} • ${p['uses']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    setState(() => _promos.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف العرض')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
