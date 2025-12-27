import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:offline_khatabook/features/ledger/logic/ledger_provider.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final int customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider(customerId));
    final balanceAsync = ref.watch(customerBalanceProvider(customerId));

    return Scaffold(
      appBar: AppBar(title: const Text("Ledger")),
      body: Column(
        children: [
          // Header Summary
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.primary,
            width: double.infinity,
            child: Column(
              children: [
                const Text(
                  "Net Balance",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const Gap(8),
                balanceAsync.when(
                  data: (val) => Text(
                    "₹ ${val.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: val == 0
                          ? Colors.white
                          : (val > 0 ? AppColors.success : AppColors.error),
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text("---"),
                ),
                balanceAsync.when(
                  data: (val) => Text(
                    val == 0
                        ? "All Settled"
                        : (val > 0 ? "You will get" : "You will give"),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty)
                  return const Center(child: Text("No transactions yet"));
                return ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    final isCredit = t.isCredit; // You Gave
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        "₹ ${t.amount}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isCredit ? AppColors.error : AppColors.success,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(t.date) +
                            (t.notes != null ? "\n${t.notes}" : ""),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isCredit ? "YOU GAVE" : "YOU GOT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCredit
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              error: (e, s) => Center(child: Text("Error: $e")),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () => context.push(
                  '/transaction/add?customerId=$customerId&isCredit=true',
                ),
                child: const Text("YOU GAVE"),
              ),
            ),
            const Gap(16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                onPressed: () => context.push(
                  '/transaction/add?customerId=$customerId&isCredit=false',
                ),
                child: const Text("YOU GOT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
