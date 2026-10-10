import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/client_models.dart';
import 'booking_flow_service.dart';

class BookingFlowScreen extends StatefulWidget {
  final BarberShopModel shop;
  final ServiceModel initialService;

  const BookingFlowScreen({
    super.key,
    required this.shop,
    required this.initialService,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final BookingFlowService _bookingService = BookingFlowService();
  int _currentStep = 0; // 0: الحلاق والوقت, 1: طريقة الدفع والملاحظات, 2: التأكيد

  String? _selectedBarberId;
  String _selectedBarberName = 'أي حلاق متاح';
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String _paymentMethod = 'cash'; // 'cash' or 'card'
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    '10:00 ص', '10:45 ص', '11:30 ص',
    '01:15 م', '02:00 م', '04:30 م',
    '05:15 م', '06:00 م', '07:30 م', '08:15 م'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _handleConfirmBooking() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار وقت الموعد أولاً')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _bookingService.submitAppointmentAtomic(
        clientId: 'current-user-id',
        shopId: widget.shop.id,
        barberId: _selectedBarberId ?? '33333333-0000-0000-0000-000000000001',
        serviceIds: [widget.initialService.id],
        startTime: _selectedDate,
        paymentMethod: _paymentMethod,
        promotionCode: _promoController.text.trim().isNotEmpty ? _promoController.text.trim() : null,
        clientNotes: _notesController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        _showSuccessDialog(result['booking_reference'] as String? ?? 'WAS-8921');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر إتمام الحجز: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showSuccessDialog(String reference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 54),
            ),
            const SizedBox(height: 18),
            const Text('تم تأكيد الحجز بنجاح!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('رقم الحجز: $reference', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
            const SizedBox(height: 12),
            Text(
              'موعدك في ${widget.shop.name}\nاليوم في تمام $_selectedTimeSlot',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('العودة للرئيسية'),
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
        title: const Text('حجز موعد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // تفاصيل الخدمة والصالون المختار
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.content_cut, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.initialService.nameAr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(widget.shop.name, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('${widget.initialService.durationMinutes} دقيقة • ${widget.initialService.price} ر.س', style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // اختيار الحلاق
            const Text('اختر الحلاق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('أي حلاق متاح'),
                    selected: _selectedBarberId == null,
                    onSelected: (val) {
                      if (val) setState(() { _selectedBarberId = null; _selectedBarberName = 'أي حلاق متاح'; });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('كابتن وسيم'),
                    selected: _selectedBarberId == 'barber-1',
                    onSelected: (val) {
                      if (val) setState(() { _selectedBarberId = 'barber-1'; _selectedBarberName = 'كابتن وسيم'; });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('أحمد مراد'),
                    selected: _selectedBarberId == 'barber-2',
                    onSelected: (val) {
                      if (val) setState(() { _selectedBarberId = 'barber-2'; _selectedBarberName = 'أحمد مراد'; });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // اختيار الوقت المتاح
            const Text('الأوقات المتاحة اليوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  selectedColor: AppColors.secondary,
                  onSelected: (selected) {
                    setState(() => _selectedTimeSlot = selected ? slot : null);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // طريقة الدفع
            const Text('طريقة الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('نقداً بالمحل', style: TextStyle(fontSize: 14)),
                    value: 'cash',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('بطاقة / Apple Pay', style: TextStyle(fontSize: 14)),
                    value: 'card',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // كود الخصم والملاحظات
            TextField(
              controller: _promoController,
              decoration: const InputDecoration(
                labelText: 'كود الخصم (عروض وسيم)',
                prefixIcon: Icon(Icons.local_offer_outlined, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات إضافية للحلاق (اختياري)',
                prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 28),

            // زر تأكيد الحجز
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleConfirmBooking,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('تأكيد الحجز (${widget.initialService.price} ر.س)'),
            ),
          ],
        ),
      ),
    );
  }
}
