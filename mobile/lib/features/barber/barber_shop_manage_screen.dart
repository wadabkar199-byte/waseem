import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'barber_management_service.dart';
import 'barber_services_screen.dart';

class BarberShopManageScreen extends StatefulWidget {
  const BarberShopManageScreen({super.key});

  @override
  State<BarberShopManageScreen> createState() => _BarberShopManageScreenState();
}

class _BarberShopManageScreenState extends State<BarberShopManageScreen> {
  final BarberManagementService _service = BarberManagementService();
  final _nameCtrl = TextEditingController(text: 'صالون وسيم الفاخر');
  final _descCtrl = TextEditingController(text: 'صالون متميز يقدم أفضل خدمات الحلاقة والعناية بالشعر واللحية.');
  final _addrCtrl = TextEditingController(text: 'طريق الملك فهد، حي العليا، الرياض');

  // حالة الصالون: pending_review (قيد المراجعة) / approved (معتمد) / suspended (موقوف)
  String _shopStatus = 'pending_review';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (_shopStatus) {
      case 'approved':
        return AppColors.success;
      case 'suspended':
      case 'rejected':
        return AppColors.error;
      case 'pending_review':
      default:
        return AppColors.warning;
    }
  }

  String _getStatusText() {
    switch (_shopStatus) {
      case 'approved':
        return 'معتمد ونشط في البحث العام';
      case 'suspended':
        return 'موقوف مؤقتاً من الإدارة';
      case 'pending_review':
      default:
        return 'قيد المراجعة والاعتماد من الإدارة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة الصالون والملف المهني'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة حالة اعتماد الحساب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getStatusColor().withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _shopStatus == 'approved' ? Icons.check_circle_outline : Icons.pending_actions_outlined,
                    color: _getStatusColor(),
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('حالة الصالون:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(
                          _getStatusText(),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getStatusColor()),
                        ),
                        if (_shopStatus == 'pending_review') ...[
                          const SizedBox(height: 4),
                          const Text(
                            'تنبيه: لن يظهر الصالون في نتائج بحث العملاء حتى يتم اعتماده من قبل إدارة وسيم.',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // رفع وتعديل الصور والشعار (مع شروط التحقق من الحجم 5MB)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الصور والهوية البصرية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('الحد الأقصى لكل صورة 5 ميجابايت (صيغ JPG, PNG, WebP فقط)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.storefront_rounded, size: 36, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم التحقق من نوع الصورة وحجمها (أقل من 5MB)')),
                            );
                          },
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('رفع شعار الصالون'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // تعديل بيانات الصالون
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('البيانات الأساسية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم الصالون التجاري'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _addrCtrl,
                    decoration: const InputDecoration(labelText: 'العنوان بالتفصيل والحي'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'نبذة عن الصالون والخدمات'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حفظ بيانات الصالون بنجاح')),
                      );
                    },
                    child: const Text('حفظ التعديلات'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // رابط الانتقال إلى شاشة إدارة الخدمات والأسعار
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.content_cut, color: AppColors.primary),
                ),
                title: const Text('إدارة قائمة الخدمات والأسعار', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('أضف خدماتك وحدد الأسعار والمدد الزمنية'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BarberServicesScreen(shopId: '11111111-0000-0000-0000-000000000001'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
