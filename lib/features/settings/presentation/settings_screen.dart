import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:offline_khatabook/core/services/backup_service.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/features/auth/logic/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          _buildSectionHeader("Security"),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change PIN"),
            onTap: () {
              context.push('/change-pin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text("Biometrics"),
            trailing: Switch(
              value: true,
              onChanged: (val) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Biometrics automatically enabled if available",
                    ),
                  ),
                );
              },
            ),
          ),
          _buildSectionHeader("Data & Backup"),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Backup Now"),
            subtitle: const Text("Export encrypted backup"),
            onTap: () async {
              try {
                final path = await ref
                    .read(backupServiceProvider)
                    .exportBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Backup saved to $path")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Backup Failed: $e")));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Restore Backup"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "To Restore: Reinstall app or Reset Data, then choose 'Restore' on launch.",
                  ),
                ),
              );
            },
          ),
          _buildSectionHeader("Account"),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              "Log Out / Lock App",
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              ref.read(authStateProvider.notifier).lockApp();
              context.go('/lock');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
