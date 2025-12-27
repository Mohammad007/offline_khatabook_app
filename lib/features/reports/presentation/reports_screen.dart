import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/core/widgets/common_widgets.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),
            const Gap(24),

            // Summary Cards
            _buildSummarySection(),
            const Gap(24),

            // Charts Section
            _buildChartsSection(),
            const Gap(24),

            // Top Customers
            _buildTopCustomersSection(),
            const Gap(24),

            // Recent Activity
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedPeriod = period);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Received',
                value: '₹ 25,000',
                icon: Icons.arrow_downward_rounded,
                color: AppColors.success,
                change: '+12.5%',
                isPositive: true,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Given',
                value: '₹ 18,500',
                icon: Icons.arrow_upward_rounded,
                color: AppColors.error,
                change: '-5.2%',
                isPositive: false,
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Net Balance',
                value: '₹ 6,500',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.info,
                change: '+8.3%',
                isPositive: true,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _SummaryCard(
                title: 'Transactions',
                value: '48',
                icon: Icons.receipt_long_rounded,
                color: AppColors.accent,
                change: '+15',
                isPositive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cash Flow Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Last 7 days',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Gap(20),
          // Placeholder for Chart
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _SimpleChartPainter(),
              size: const Size(double.infinity, 180),
            ),
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(color: AppColors.success, label: 'Received'),
              const Gap(24),
              _ChartLegend(color: AppColors.error, label: 'Given'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Customers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(12),
        ...List.generate(
          3,
          (index) => _TopCustomerTile(
            rank: index + 1,
            name: ['Rahul Sharma', 'Priya Patel', 'Amit Kumar'][index],
            amount: [12500, 8900, 7200][index].toDouble(),
            transactions: [15, 12, 8][index],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(12),
        ...List.generate(
          5,
          (index) => _ActivityTile(
            action: index.isEven ? 'Received' : 'Given',
            customerName: ['Rahul', 'Priya', 'Amit', 'Sneha', 'Vikram'][index],
            amount: [2500, 1800, 3200, 950, 4100][index].toDouble(),
            time: '${index + 1}h ago',
          ),
        ),
      ],
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;
  final bool isPositive;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.error)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const Gap(6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _TopCustomerTile extends StatelessWidget {
  final int rank;
  final String name;
  final double amount;
  final int transactions;

  const _TopCustomerTile({
    required this.rank,
    required this.name,
    required this.amount,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank == 1 ? AppColors.warning : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$transactions transactions',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹ ${NumberFormat('#,##0').format(amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String action;
  final String customerName;
  final double amount;
  final String time;

  const _ActivityTile({
    required this.action,
    required this.customerName,
    required this.amount,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isReceived = action == 'Received';
    final color = isReceived ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isReceived ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$action from $customerName',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isReceived ? '+' : '-'}₹ ${amount.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final receivedPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final givenPaint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final receivedPath = Path();
    final givenPath = Path();

    // Sample data points
    final receivedPoints = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.9];
    final givenPoints = [0.2, 0.3, 0.5, 0.4, 0.3, 0.5, 0.4];

    for (int i = 0; i < receivedPoints.length; i++) {
      final x = (size.width / (receivedPoints.length - 1)) * i;
      final y = size.height - (size.height * receivedPoints[i]);

      if (i == 0) {
        receivedPath.moveTo(x, y);
      } else {
        receivedPath.lineTo(x, y);
      }
    }

    for (int i = 0; i < givenPoints.length; i++) {
      final x = (size.width / (givenPoints.length - 1)) * i;
      final y = size.height - (size.height * givenPoints[i]);

      if (i == 0) {
        givenPath.moveTo(x, y);
      } else {
        givenPath.lineTo(x, y);
      }
    }

    canvas.drawPath(receivedPath, receivedPaint);
    canvas.drawPath(givenPath, givenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
