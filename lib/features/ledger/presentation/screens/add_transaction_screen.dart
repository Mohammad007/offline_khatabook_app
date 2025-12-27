import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:offline_khatabook/features/ledger/logic/ledger_provider.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final int customerId;
  final bool isCredit; // true = You Gave, false = You Got

  const AddTransactionScreen({
    super.key,
    required this.customerId,
    required this.isCredit,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    ref
        .read(ledgerProvider.notifier)
        .addTransaction(
          widget.customerId,
          amount,
          widget.isCredit,
          _notesController.text,
        );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = widget.isCredit;
    final color = isCredit ? AppColors.error : AppColors.success;
    final label = isCredit ? "You Gave" : "You Got";

    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              decoration: InputDecoration(
                prefixText: "₹ ",
                labelText: "Amount",
                labelStyle: TextStyle(color: color),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: color, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Gap(16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: "Description / Notes",
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const Gap(16),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: const Text("Save Transaction"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
