import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // بطاقة المستخدم
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: const Text('أ', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أحمد السعيد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('ahmed.saeed@example.com', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        SizedBox(height: 2),
                        Text('+966 50 123 4567', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // قائمة الإعدادات والصفحات
            _buildSection(
              title: 'حسابي والحجوزات',
              items: [
                _buildTile(Icons.calendar_today_outlined, 'سجل الحجوزات', () {}),
                _buildTile(Icons.favorite_outline, 'الصالونات المفضلة', () {}),
                _buildTile(Icons.notifications_none, 'إعدادات الإشعارات', () {}),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: 'المساعدة والمعلومات',
              items: [
                _buildTile(Icons.help_outline, 'مركز المساعدة والدعم', () {
                  _showInfoDialog(context, 'مركز المساعدة', 'يمكنك التواصل مع فريق دعم وسيم عبر البريد الإلكتروني support@waseem.app');
                }),
                _buildTile(Icons.privacy_tip_outlined, 'سياسة الخصوصية', () {
                  _showInfoDialog(context, 'سياسة الخصوصية', 'تحرص منصة وسيم على حماية بيانات المستخدمين وخصوصيتهم وفق أعلى المعايير الأمنية.');
                }),
                _buildTile(Icons.description_outlined, 'الشروط والأحكام', () {
                  _showInfoDialog(context, 'الشروط والأحكام', 'تخضع جميع الحجوزات والخدمات المقدمة لشروط وسياسات الاستخدام المعتمدة في منصة وسيم.');
                }),
              ],
            ),

            const SizedBox(height: 24),

            // زر تسجيل الخروج
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSection({required String title, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, right: 16, bottom: 6),
            child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          ),
          ...items,
        ],
      ),
    );
  }

  static Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  static void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
