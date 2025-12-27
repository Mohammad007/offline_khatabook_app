import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/core/widgets/common_widgets.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Reminders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersList(type: 'today'),
          _buildRemindersList(type: 'upcoming'),
          _buildRemindersList(type: 'completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        child: const Icon(Icons.add_alarm_rounded),
      ),
    );
  }

  Widget _buildRemindersList({required String type}) {
    // Sample data - in production, this would come from the database
    final List<_ReminderData> reminders = type == 'completed'
        ? [
            _ReminderData(
              customerName: 'Vikram Singh',
              amount: 3500,
              dueDate: DateTime.now().subtract(const Duration(days: 2)),
              isCompleted: true,
            ),
          ]
        : type == 'today'
        ? [
            _ReminderData(
              customerName: 'Rahul Sharma',
              amount: 5000,
              dueDate: DateTime.now(),
              message: 'Monthly payment due',
            ),
            _ReminderData(
              customerName: 'Priya Patel',
              amount: 2500,
              dueDate: DateTime.now(),
            ),
          ]
        : [
            _ReminderData(
              customerName: 'Amit Kumar',
              amount: 8000,
              dueDate: DateTime.now().add(const Duration(days: 3)),
              message: 'Advance payment',
            ),
            _ReminderData(
              customerName: 'Sneha Gupta',
              amount: 1500,
              dueDate: DateTime.now().add(const Duration(days: 7)),
              isRecurring: true,
            ),
          ];

    if (reminders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.alarm_off_rounded,
        title: 'No Reminders',
        subtitle:
            'You have no ${type == 'completed' ? 'completed' : 'pending'} reminders',
        buttonText: 'Add Reminder',
        onButtonPressed: () => _showAddReminderDialog(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (context, index) => _ReminderCard(
        reminder: reminders[index],
        onMarkComplete: () => _markComplete(reminders[index]),
        onDelete: () => _deleteReminder(reminders[index]),
        onSendReminder: () => _sendReminder(reminders[index]),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddReminderSheet(),
    );
  }

  void _markComplete(_ReminderData reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Marked ${reminder.customerName}\'s reminder as complete',
        ),
      ),
    );
  }

  void _deleteReminder(_ReminderData reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted reminder for ${reminder.customerName}')),
    );
  }

  void _sendReminder(_ReminderData reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder sent to ${reminder.customerName}')),
    );
  }
}

class _ReminderData {
  final String customerName;
  final double amount;
  final DateTime dueDate;
  final String? message;
  final bool isRecurring;
  final bool isCompleted;

  _ReminderData({
    required this.customerName,
    required this.amount,
    required this.dueDate,
    this.message,
    this.isRecurring = false,
    this.isCompleted = false,
  });
}

class _ReminderCard extends StatelessWidget {
  final _ReminderData reminder;
  final VoidCallback onMarkComplete;
  final VoidCallback onDelete;
  final VoidCallback onSendReminder;

  const _ReminderCard({
    required this.reminder,
    required this.onMarkComplete,
    required this.onDelete,
    required this.onSendReminder,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        !reminder.isCompleted && reminder.dueDate.isBefore(DateTime.now());
    final isToday = DateUtils.isSameDay(reminder.dueDate, DateTime.now());

    Color statusColor = AppColors.warning;
    if (reminder.isCompleted) {
      statusColor = AppColors.success;
    } else if (isOverdue) {
      statusColor = AppColors.error;
    } else if (isToday) {
      statusColor = AppColors.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    reminder.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.alarm_rounded,
                    color: statusColor,
                  ),
                ),
                const Gap(16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminder.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (reminder.isRecurring)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    size: 12,
                                    color: AppColors.accent,
                                  ),
                                  Gap(4),
                                  Text(
                                    'Recurring',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        '₹ ${NumberFormat('#,##0').format(reminder.amount)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (reminder.message != null) ...[
                        const Gap(4),
                        Text(
                          reminder.message!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const Gap(8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: statusColor,
                          ),
                          const Gap(4),
                          Text(
                            isToday
                                ? 'Today'
                                : DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(reminder.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isOverdue && !reminder.isCompleted) ...[
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!reminder.isCompleted)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.surfaceVariant),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onSendReminder,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Send'),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.surfaceVariant,
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onMarkComplete,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Complete'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isRecurring = false;

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
                  'Add Reminder',
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

            // Customer Dropdown (placeholder)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_outline, color: AppColors.textSecondary),
                  Gap(12),
                  Text(
                    'Select Customer',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                ],
              ),
            ),
            const Gap(16),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
              ),
            ),
            const Gap(16),

            // Date Picker
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.textSecondary,
                    ),
                    const Gap(12),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),

            // Message
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                prefixIcon: Icon(Icons.note_outlined),
              ),
            ),
            const Gap(16),

            // Recurring Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recurring Reminder'),
              subtitle: const Text('Repeat this reminder monthly'),
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
            ),
            const Gap(24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder created!')),
                  );
                },
                child: const Text('Create Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
