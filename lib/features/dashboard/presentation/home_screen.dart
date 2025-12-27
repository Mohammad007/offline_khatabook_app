import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/core/widgets/common_widgets.dart';
import 'package:offline_khatabook/features/ledger/logic/ledger_provider.dart';
import 'package:offline_khatabook/data/local/db/app_database.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with Gradient
            SliverToBoxAdapter(child: _buildHeader(context)),

            // Stats Row
            SliverToBoxAdapter(child: _buildQuickStats()),

            // Quick Actions
            SliverToBoxAdapter(child: _buildQuickActions(context)),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search customers...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
            ),

            // Section Header
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Customers',
                actionText: 'Add',
                actionIcon: Icons.add,
              ),
            ),

            // Customer List
            customersAsync.when(
              data: (customers) {
                final filtered = _searchQuery.isEmpty
                    ? customers
                    : customers
                          .where(
                            (c) =>
                                c.name.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                c.mobile.contains(_searchQuery),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.people_outline,
                      title: _searchQuery.isEmpty
                          ? 'No Customers Yet'
                          : 'No Results',
                      subtitle: _searchQuery.isEmpty
                          ? 'Add your first customer to start tracking transactions'
                          : 'Try a different search term',
                      buttonText: _searchQuery.isEmpty ? 'Add Customer' : null,
                      onButtonPressed: _searchQuery.isEmpty
                          ? () => context.push('/add-customer')
                          : null,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CustomerCard(customer: filtered[index]),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-customer'),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Customer'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const Gap(4),
                    const Text(
                      'Secure Ledger',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () => context.push('/reminders'),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatsCard(
              title: 'You Will Get',
              value: '₹ 0.00',
              icon: Icons.arrow_downward_rounded,
              color: AppColors.success,
              subtitle: 'Total receivables',
            ),
          ),
          const Gap(12),
          Expanded(
            child: StatsCard(
              title: 'You Will Give',
              value: '₹ 0.00',
              icon: Icons.arrow_upward_rounded,
              color: AppColors.error,
              subtitle: 'Total payables',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(
            icon: Icons.receipt_long_rounded,
            label: 'Reports',
            color: AppColors.info,
            onTap: () => context.push('/reports'),
          ),
          QuickActionButton(
            icon: Icons.alarm_rounded,
            label: 'Reminders',
            color: AppColors.warning,
            onTap: () => context.push('/reminders'),
          ),
          QuickActionButton(
            icon: Icons.category_rounded,
            label: 'Categories',
            color: AppColors.accent,
            onTap: () => context.push('/categories'),
          ),
          QuickActionButton(
            icon: Icons.note_alt_rounded,
            label: 'Notes',
            color: AppColors.success,
            onTap: () => context.push('/notes'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _CustomerCard extends ConsumerWidget {
  final Customer customer;
  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(customerBalanceProvider(customer.id));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/customer/${customer.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Gap(16),

                // Name and Mobile
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (customer.isFavorite)
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.warning,
                              size: 18,
                            ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        customer.mobile,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Balance
                balanceAsync.when(
                  data: (balance) {
                    final isPositive = balance > 0;
                    final isNegative = balance < 0;
                    final color = balance == 0
                        ? AppColors.textMuted
                        : (isPositive ? AppColors.success : AppColors.error);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹ ${balance.abs().toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            balance == 0
                                ? 'Settled'
                                : (isPositive ? 'You\'ll get' : 'You\'ll give'),
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text('--'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
