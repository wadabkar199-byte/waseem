import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'analytics_service.dart';

class BarberAnalyticsScreen extends StatefulWidget {
  final String shopId;

  const BarberAnalyticsScreen({super.key, required this.shopId});

  @override
  State<BarberAnalyticsScreen> createState() => _BarberAnalyticsScreenState();
}

class _BarberAnalyticsScreenState extends State<BarberAnalyticsScreen> {
  final AnalyticsService _service = AnalyticsService();
  late Future<BarberFinancialReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _service.getShopFinancialReport(widget.shopId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإحصاءات والتقارير المالية'),
      ),
      body: FutureBuilder<BarberFinancialReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final report = snapshot.data ??
              BarberFinancialReport(
                recordedRevenue: 0,
                collectedCashRevenue: 0,
                collectedOnlineRevenue: 0,
                totalAppointments: 0,
                completedAppointments: 0,
                cancelledAppointments: 0,
                noShowAppointments: 0,
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة الإيرادات الكلية
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
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
                      const Text(
                        'إجمالي الإيرادات المسجلة للحجوزات',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${report.recordedRevenue.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('المحصل فعلياً', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              Text(
                                '${report.actualTotalCollected.toStringAsFixed(0)} ر.س',
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('المتبقي للتحصيل', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              Text(
                                '${report.pendingCollection.toStringAsFixed(0)} ر.س',
                                style: const TextStyle(color: AppColors.secondaryLight, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // تفصيل طرق التحصيل الفعلي
                const Text('تفصيل المبالغ المحصلة فعلياً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'نقد استلمه الحلاق',
                        value: '${report.collectedCashRevenue.toStringAsFixed(0)} ر.س',
                        icon: Icons.payments_outlined,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'دفع إلكتروني',
                        value: '${report.collectedOnlineRevenue.toStringAsFixed(0)} ر.س',
                        icon: Icons.credit_card_rounded,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // إحصاءات تشغيل المواعيد
                const Text('حركة المواعيد والعمليات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildRowItem('إجمالي الحجوزات المستلمة', '${report.totalAppointments}', AppColors.textPrimary),
                      const Divider(),
                      _buildRowItem('مواعيد اكتملت بنجاح', '${report.completedAppointments}', AppColors.success),
                      const Divider(),
                      _buildRowItem('حجوزات ملغاة', '${report.cancelledAppointments}', AppColors.error),
                      const Divider(),
                      _buildRowItem('حالات عدم الحضور (No-Show)', '${report.noShowAppointments}', AppColors.warning),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  static Widget _buildRowItem(String title, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          Text(count, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
