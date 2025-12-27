import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/core/widgets/common_widgets.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final List<_CategoryData> _categories = [
    _CategoryData(
      name: 'Sales',
      icon: Icons.sell_rounded,
      color: Color(0xFF10B981),
      count: 25,
      isSystem: true,
    ),
    _CategoryData(
      name: 'Purchase',
      icon: Icons.shopping_cart_rounded,
      color: Color(0xFF3B82F6),
      count: 18,
      isSystem: true,
    ),
    _CategoryData(
      name: 'Loan',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFF59E0B),
      count: 8,
      isSystem: true,
    ),
    _CategoryData(
      name: 'Rent',
      icon: Icons.home_rounded,
      color: Color(0xFF8B5CF6),
      count: 4,
      isSystem: true,
    ),
    _CategoryData(
      name: 'Service',
      icon: Icons.build_rounded,
      color: Color(0xFFEC4899),
      count: 12,
      isSystem: true,
    ),
    _CategoryData(
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF6B7280),
      count: 5,
      isSystem: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_rounded),
            onPressed: () => _showCategoryStats(context),
            tooltip: 'Category Statistics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.elevatedShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Categories',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const Gap(4),
                      Text(
                        '${_categories.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          // Categories Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _categories.length + 1, // +1 for Add button
              itemBuilder: (context, index) {
                if (index == _categories.length) {
                  return _AddCategoryCard(
                    onTap: () => _showAddCategoryDialog(context),
                  );
                }
                return _CategoryCard(
                  category: _categories[index],
                  onTap: () => _showCategoryDetails(_categories[index]),
                  onEdit: () => _editCategory(_categories[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddCategorySheet(),
    );
  }

  void _showCategoryStats(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Category Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(24),
            ..._categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: cat.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const Gap(12),
                    Expanded(child: Text(cat.name)),
                    Text(
                      '${cat.count}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetails(_CategoryData category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.name}: ${category.count} transactions'),
      ),
    );
  }

  void _editCategory(_CategoryData category) {
    if (category.isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System categories cannot be edited')),
      );
      return;
    }
    // TODO: Implement edit
  }
}

class _CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final int count;
  final bool isSystem;

  _CategoryData({
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    this.isSystem = false,
  });
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData category;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                    if (category.isSystem)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'System',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Gap(4),
                Text(
                  '${category.count} transactions',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddCategoryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCategoryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 40, color: AppColors.accent),
              Gap(8),
              Text(
                'Add Category',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet();

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  Color _selectedColor = AppColors.primary;
  IconData _selectedIcon = Icons.category_rounded;

  final List<Color> _colorOptions = [
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    AppColors.error,
    AppColors.warning,
    AppColors.info,
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];

  final List<IconData> _iconOptions = [
    Icons.category_rounded,
    Icons.shopping_cart_rounded,
    Icons.sell_rounded,
    Icons.account_balance_rounded,
    Icons.home_rounded,
    Icons.build_rounded,
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.flight_rounded,
    Icons.medical_services_rounded,
    Icons.school_rounded,
    Icons.sports_esports_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Gap(24),

            // Name Input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Transportation',
              ),
            ),
            const Gap(24),

            // Color Picker
            const Text(
              'Select Color',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorOptions
                  .map(
                    (color) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedColor == color
                              ? Border.all(
                                  color: AppColors.textPrimary,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: _selectedColor == color
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Gap(24),

            // Icon Picker
            const Text(
              'Select Icon',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _iconOptions
                  .map(
                    (icon) => GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? _selectedColor.withOpacity(0.2)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedIcon == icon
                              ? Border.all(color: _selectedColor, width: 2)
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: _selectedIcon == icon
                              ? _selectedColor
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Gap(24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category created!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                ),
                child: const Text('Create Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
