import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/state_widgets.dart';
import 'client_data_service.dart';
import 'client_models.dart';
import 'shop_detail_screen.dart';

class ExploreBarbersScreen extends StatefulWidget {
  const ExploreBarbersScreen({super.key});

  @override
  State<ExploreBarbersScreen> createState() => _ExploreBarbersScreenState();
}

class _ExploreBarbersScreenState extends State<ExploreBarbersScreen> {
  final ClientDataService _dataService = ClientDataService();
  final TextEditingController _searchController = TextEditingController();
  
  double? _selectedRatingFilter;
  late Future<List<BarberShopModel>> _shopsFuture;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  void _fetchShops() {
    setState(() {
      _shopsFuture = _dataService.getApprovedShops(
        searchQuery: _searchController.text,
        minRating: _selectedRatingFilter,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('استكشاف الصالونات والحلاقين'),
      ),
      body: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم، الحي، أو الخدمة...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _fetchShops();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _fetchShops(),
                ),
                const SizedBox(height: 12),
                // أزرار التصفية السريعة
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('الكل'),
                        selected: _selectedRatingFilter == null,
                        onSelected: (_) {
                          _selectedRatingFilter = null;
                          _fetchShops();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text('4.5 فما فوق'),
                          ],
                        ),
                        selected: _selectedRatingFilter == 4.5,
                        onSelected: (_) {
                          _selectedRatingFilter = 4.5;
                          _fetchShops();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('الأعلى تقييماً'),
                        selected: _selectedRatingFilter == 4.8,
                        onSelected: (_) {
                          _selectedRatingFilter = 4.8;
                          _fetchShops();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // قائمة الصالونات مع معالجة كافة الحالات
          Expanded(
            child: FutureBuilder<List<BarberShopModel>>(
              future: _shopsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'جارٍ جلب الصالونات المعتمدة...');
                }

                if (snapshot.hasError) {
                  return ErrorStateWidget(
                    message: 'حدث خطأ أثناء تحميل البيانات',
                    onRetry: _fetchShops,
                  );
                }

                final shops = snapshot.data ?? [];
                if (shops.isEmpty) {
                  return EmptyStateWidget(
                    title: 'لم يتم العثور على صالونات',
                    subtitle: 'جرب البحث بكلمات مختلفة أو إزالة الفلاتر',
                    icon: Icons.search_off_rounded,
                    action: ElevatedButton(
                      onPressed: () {
                        _searchController.clear();
                        _selectedRatingFilter = null;
                        _fetchShops();
                      },
                      child: const Text('إعادة ضبط البحث'),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: shops.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 40),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shop.description ?? shop.addressText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${shop.ratingAverage}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 4),
                                      Text('(${shop.ratingCount})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                      const Spacer(),
                                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                                      Text(shop.districtName ?? 'حي العليا', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
