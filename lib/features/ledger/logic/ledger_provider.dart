import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_khatabook/data/local/db/app_database.dart';
import 'package:offline_khatabook/features/auth/logic/auth_provider.dart';
import 'package:drift/drift.dart';

// Stream of Customers
final customersStreamProvider = StreamProvider.autoDispose((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return const Stream<List<Customer>>.empty();

  return (db.select(
    db.customers,
  )..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
});

// Stream of Transactions for a Customer
final transactionsStreamProvider = StreamProvider.family
    .autoDispose<List<TransactionItem>, int>((ref, customerId) {
      final db = ref.watch(databaseProvider);
      if (db == null) return const Stream.empty();

      return (db.select(db.transactions)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          // ..limit(100) // maybe pagination later
          .watch();
    });

// Balance Calculation
final customerBalanceProvider = StreamProvider.family.autoDispose<double, int>((
  ref,
  customerId,
) {
  final db = ref.watch(databaseProvider);
  if (db == null) return Stream.value(0.0);

  return (db.select(
    db.transactions,
  )..where((t) => t.customerId.equals(customerId))).watch().map((transactions) {
    double balance = 0;
    for (var t in transactions) {
      if (t.isCredit) {
        balance += t.amount; // You Gave
      } else {
        balance -= t.amount; // You Got
      }
    }
    return balance;
  });
});

final ledgerProvider = NotifierProvider<LedgerNotifier, void>(
  LedgerNotifier.new,
);

class LedgerNotifier extends Notifier<void> {
  @override
  void build() {
    return;
  }

  Future<void> addCustomer(String name, String mobile) async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    await db
        .into(db.customers)
        .insert(CustomersCompanion(name: Value(name), mobile: Value(mobile)));
  }

  Future<void> addTransaction(
    int customerId,
    double amount,
    bool isCredit,
    String notes,
  ) async {
    final db = ref.read(databaseProvider);
    if (db == null) return;

    if (amount <= 0) throw Exception("Amount must be positive");

    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion(
            customerId: Value(customerId),
            amount: Value(amount),
            isCredit: Value(isCredit),
            notes: Value(notes),
          ),
        );
  }
}
