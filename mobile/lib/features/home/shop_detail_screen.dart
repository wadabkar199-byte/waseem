import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/state_widgets.dart';
import 'client_data_service.dart';
import 'client_models.dart';
import '../booking/booking_flow_screen.dart';

class ShopDetailScreen extends StatefulWidget {
  final BarberShopModel shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ClientDataService _dataService = ClientDataService();
  bool _isFavorite = false;

  late Future<List<ServiceModel>> _servicesFuture;
  late Future<List<BarberModel>> _barbersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _servicesFuture = _dataService.getShopServices(widget.shop.id);
    _barbersFuture = _dataService.getShopBarbers(widget.shop.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFavorite ? 'تمت الإضافة إلى المفضلة' : 'تمت الإزالة من المفضلة'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.primaryDark,
                      child: const Center(
                        child: Icon(Icons.storefront_rounded, size: 80, color: AppColors.secondary),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.shop.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.shop.ratingAverage} (${widget.shop.ratingCount} تقييم)',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.location_on, color: AppColors.secondary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                widget.shop.districtName ?? 'حي العليا',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'الخدمات والأسعار'),
                    Tab(text: 'الحلاقين'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // تبويب الخدمات
            FutureBuilder<List<ServiceModel>>(
              future: _servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'جارٍ جلب قائمة الخدمات...');
                }
                if (snapshot.hasError) {
                  return ErrorStateWidget(
                    message: 'تعذر تحميل الخدمات',
                    onRetry: () => setState(() => _loadData()),
                  );
                }
                final services = snapshot.data ?? [];
                if (services.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'لا توجد خدمات متاحة',
                    subtitle: 'لم يقم هذا الصالون بإضافة خدمات بعد',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = services[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nameAr,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                if (item.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(item.description!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text('${item.durationMinutes} دقيقة', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.price.toStringAsFixed(0)} ر.س',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(80, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BookingFlowScreen(
                                        shop: widget.shop,
                                        initialService: item,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('اختيار', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // تبويب الحلاقين
            FutureBuilder<List<BarberModel>>(
              future: _barbersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'جارٍ جلب الحلاقين...');
                }
                if (snapshot.hasError) {
                  return ErrorStateWidget(
                    message: 'تعذر تحميل الحلاقين',
                    onRetry: () => setState(() => _loadData()),
                  );
                }
                final barbers = snapshot.data ?? [];
                if (barbers.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'لا يوجد حلاقين مسجلين',
                    subtitle: 'سيتم إضافة الحلاقين قريباً',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: barbers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final barber = barbers[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.surfaceSubtle,
                            child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(barber.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                if (barber.title != null) ...[
                                  const SizedBox(height: 4),
                                  Text(barber.title!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
