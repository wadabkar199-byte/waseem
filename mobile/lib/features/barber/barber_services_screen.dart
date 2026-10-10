import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'barber_management_service.dart';

class BarberServicesScreen extends StatefulWidget {
  final String shopId;

  const BarberServicesScreen({super.key, required this.shopId});

  @override
  State<BarberServicesScreen> createState() => _BarberServicesScreenState();
}

class _BarberServicesScreenState extends State<BarberServicesScreen> {
  final BarberManagementService _service = BarberManagementService();

  // قائمة تجريبية تفاعلية للخدمات
  final List<Map<String, dynamic>> _services = [
    {
      'id': '1',
      'name_ar': 'قص شعر كلاسيكي',
      'price': 40.0,
      'duration_minutes': 30,
      'description': 'قص وتنسيق الشعر مع غسيل خفيف',
    },
    {
      'id': '2',
      'name_ar': 'تشذيب وتحديد لحية',
      'price': 30.0,
      'duration_minutes': 20,
      'description': 'تحديد دقيق بالموس وزيوت اللحية',
    },
    {
      'id': '3',
      'name_ar': 'باقة وسيم VIP',
      'price': 85.0,
      'duration_minutes': 50,
      'description': 'قص شعر + لحية + سنفرة وجه بالبخار',
    },
  ];

  void _showAddEditServiceDialog([Map<String, dynamic>? service]) {
    final nameCtrl = TextEditingController(text: service?['name_ar'] ?? '');
    final priceCtrl = TextEditingController(text: service != null ? '${service['price']}' : '');
    final durationCtrl = TextEditingController(text: service != null ? '${service['duration_minutes']}' : '30');
    final descCtrl = TextEditingController(text: service?['description'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(service == null ? 'إضافة خدمة جديدة' : 'تعديل الخدمة', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم الخدمة (مثل: قص شعر)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعر (ر.س)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المدة بالدقائق (مثلاً: 30)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'وصف الخدمة (اختياري)'),
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
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;

              final price = double.tryParse(priceCtrl.text) ?? 0.0;
              final duration = int.tryParse(durationCtrl.text) ?? 30;

              setState(() {
                if (service == null) {
                  _services.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name_ar': nameCtrl.text.trim(),
                    'price': price,
                    'duration_minutes': duration,
                    'description': descCtrl.text.trim(),
                  });
                } else {
                  service['name_ar'] = nameCtrl.text.trim();
                  service['price'] = price;
                  service['duration_minutes'] = duration;
                  service['description'] = descCtrl.text.trim();
                }
              });

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ بيانات الخدمة بنجاح')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الخدمات والأسعار'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddEditServiceDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة خدمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final s = _services[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name_ar'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${s['duration_minutes']} دقيقة • ${s['price']} ر.س', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      if (s['description'] != null && s['description'].toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(s['description'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () => _showAddEditServiceDialog(s),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    setState(() => _services.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف الخدمة')),
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
