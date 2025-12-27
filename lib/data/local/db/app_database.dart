import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ============================================================================
// CUSTOMERS TABLE
// ============================================================================
@DataClassName('Customer')
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get mobile => text()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get avatarColor => text().withDefault(const Constant('#3D5A80'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

// ============================================================================
// TRANSACTIONS TABLE
// ============================================================================
@DataClassName('TransactionItem')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  RealColumn get amount => real()();
  BoolColumn get isCredit => boolean()(); // true = You gave, false = You got
  TextColumn get notes => text().nullable()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get attachmentPath => text().nullable()(); // For receipt images
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

// ============================================================================
// CATEGORIES TABLE (NEW MODULE)
// ============================================================================
@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  TextColumn get color => text().withDefault(const Constant('#3D5A80'))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// REMINDERS TABLE (NEW MODULE)
// ============================================================================
@DataClassName('Reminder')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  RealColumn get amount => real()();
  TextColumn get message => text().nullable()();
  DateTimeColumn get reminderDate => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringType => text().nullable()(); // daily, weekly, monthly
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// QUICK NOTES TABLE (NEW MODULE)
// ============================================================================
@DataClassName('QuickNote')
class QuickNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  TextColumn get color => text().withDefault(const Constant('#FEF3C7'))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

// ============================================================================
// BUSINESS PROFILE TABLE (NEW MODULE)
// ============================================================================
@DataClassName('BusinessProfile')
class BusinessProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get businessName => text()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get mobile => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get gstNumber => text().nullable()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get upiId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// ACTIVITY LOG TABLE (NEW MODULE - For audit trail)
// ============================================================================
@DataClassName('ActivityLog')
class ActivityLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()(); // created, updated, deleted
  TextColumn get entityType => text()(); // customer, transaction, etc.
  IntColumn get entityId => integer()();
  TextColumn get details => text().nullable()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// DATABASE CLASS
// ============================================================================
@DriftDatabase(
  tables: [
    Customers,
    Transactions,
    Categories,
    Reminders,
    QuickNotes,
    BusinessProfiles,
    ActivityLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  final String _password;

  AppDatabase(this._password) : super(_openConnection(_password));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insert default categories
        await _insertDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(categories);
          await m.createTable(reminders);
          await m.createTable(quickNotes);
          await m.createTable(businessProfiles);
          await m.createTable(activityLogs);
          await _insertDefaultCategories();
        }
      },
    );
  }

  Future<void> _insertDefaultCategories() async {
    final defaults = [
      CategoriesCompanion.insert(
        name: 'Sales',
        icon: const Value('sell'),
        color: const Value('#10B981'),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Purchase',
        icon: const Value('shopping_cart'),
        color: const Value('#3B82F6'),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Loan',
        icon: const Value('account_balance'),
        color: const Value('#F59E0B'),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Rent',
        icon: const Value('home'),
        color: const Value('#8B5CF6'),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Service',
        icon: const Value('build'),
        color: const Value('#EC4899'),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Other',
        icon: const Value('more_horiz'),
        color: const Value('#6B7280'),
        isSystem: const Value(true),
      ),
    ];

    for (final cat in defaults) {
      await into(categories).insert(cat, mode: InsertMode.insertOrIgnore);
    }
  }

  // ============================================================================
  // CUSTOMER QUERIES
  // ============================================================================
  Stream<List<Customer>> watchAllCustomers() {
    return (select(
      customers,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Stream<List<Customer>> watchFavoriteCustomers() {
    return (select(customers)..where((t) => t.isFavorite.equals(true))).watch();
  }

  Future<Customer?> getCustomerById(int id) {
    return (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Customer>> searchCustomers(String query) {
    return (select(
      customers,
    )..where((t) => t.name.like('%$query%') | t.mobile.like('%$query%'))).get();
  }

  // ============================================================================
  // TRANSACTION QUERIES
  // ============================================================================
  Stream<List<TransactionItem>> watchTransactionsForCustomer(int customerId) {
    return (select(transactions)
          ..where(
            (t) => t.customerId.equals(customerId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<TransactionItem>> watchRecentTransactions({int limit = 10}) {
    return (select(transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .watch();
  }

  Future<double> getCustomerBalance(int customerId) async {
    final txns =
        await (select(transactions)..where(
              (t) =>
                  t.customerId.equals(customerId) & t.isDeleted.equals(false),
            ))
            .get();

    double balance = 0;
    for (final t in txns) {
      balance += t.isCredit ? -t.amount : t.amount;
    }
    return balance;
  }

  // ============================================================================
  // CATEGORY QUERIES
  // ============================================================================
  Stream<List<Category>> watchAllCategories() {
    return select(categories).watch();
  }

  // ============================================================================
  // REMINDER QUERIES
  // ============================================================================
  Stream<List<Reminder>> watchActiveReminders() {
    return (select(reminders)
          ..where((t) => t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.reminderDate)]))
        .watch();
  }

  Stream<List<Reminder>> watchTodayReminders() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(reminders)..where(
          (t) =>
              t.reminderDate.isBiggerOrEqualValue(startOfDay) &
              t.reminderDate.isSmallerThanValue(endOfDay) &
              t.isCompleted.equals(false),
        ))
        .watch();
  }

  // ============================================================================
  // QUICK NOTES QUERIES
  // ============================================================================
  Stream<List<QuickNote>> watchAllNotes() {
    return (select(quickNotes)..orderBy([
          (t) => OrderingTerm.desc(t.isPinned),
          (t) => OrderingTerm.desc(t.createdAt),
        ]))
        .watch();
  }

  // ============================================================================
  // BUSINESS PROFILE QUERIES
  // ============================================================================
  Future<BusinessProfile?> getBusinessProfile() {
    return (select(businessProfiles)..limit(1)).getSingleOrNull();
  }

  // ============================================================================
  // ANALYTICS QUERIES
  // ============================================================================
  Future<Map<String, double>> getMonthlyStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final txns =
        await (select(transactions)..where(
              (t) =>
                  t.date.isBiggerOrEqualValue(startOfMonth) &
                  t.isDeleted.equals(false),
            ))
            .get();

    double totalGiven = 0;
    double totalReceived = 0;

    for (final t in txns) {
      if (t.isCredit) {
        totalGiven += t.amount;
      } else {
        totalReceived += t.amount;
      }
    }

    return {
      'given': totalGiven,
      'received': totalReceived,
      'net': totalReceived - totalGiven,
    };
  }

  Future<int> getTotalCustomersCount() async {
    final result = await select(customers).get();
    return result.length;
  }

  Future<int> getActiveRemindersCount() async {
    final result = await (select(
      reminders,
    )..where((t) => t.isCompleted.equals(false))).get();
    return result.length;
  }
}

LazyDatabase _openConnection(String password) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'secure_ledger.sqlite'));

    return NativeDatabase(
      file,
      setup: (database) {
        database.execute("PRAGMA key = '$password';");
      },
    );
  });
}
