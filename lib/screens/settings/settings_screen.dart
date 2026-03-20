// ============================================================
//  screens/settings/settings_screen.dart
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../category/category_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Appearance ─────────────────────────────────────
          _sectionHeader(context, 'Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title:     const Text('Dark Mode'),
            subtitle:  Text(settings.isDark
                ? 'Dark theme active'
                : 'Light theme active'),
            value:     settings.isDark,
            onChanged: (_) => settings.toggleTheme(),
          ),

          // ── Currency ───────────────────────────────────────
          _sectionHeader(context, 'Currency'),
          ...kCurrencies.map((c) => RadioListTile<String>(
            secondary: Text(
              kCurrencySymbols[c] ?? c,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            title:    Text(c),
            subtitle: Text(c == 'BDT' ? 'Bangladeshi Taka' : 'US Dollar'),
            value:      c,
            groupValue: settings.currency,
            onChanged:  (v) => settings.setCurrency(v!),
          )),

          // ── Data Management ────────────────────────────────
          _sectionHeader(context, 'Data Management'),
          ListTile(
            leading:  const Icon(Icons.category_outlined),
            title:    const Text('Manage Categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CategoryManagementScreen()),
            ),
          ),
          ListTile(
            leading:  const Icon(Icons.upload_file),
            title:    const Text('Export Data'),
            subtitle: const Text('Save as JSON backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap:    () => _exportData(context),
          ),
          ListTile(
            leading:  const Icon(Icons.download),
            title:    const Text('Import Data'),
            subtitle: const Text('Restore from JSON backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap:    () => _importData(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title:   const Text('Clear All Data',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Permanently delete all expenses'),
            onTap:   () => _clearData(context),
          ),

          // ── About ──────────────────────────────────────────
          _sectionHeader(context, 'About'),
          const ListTile(
            leading:  Icon(Icons.info_outline),
            title:    Text('App Version'),
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            leading: Icon(Icons.favorite_outline, color: Colors.red),
            title:   Text('Made with Flutter'),
            subtitle: Text('EzzeExpense © 2024'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize:    11,
          fontWeight:  FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final ep      = context.read<ExpenseProvider>();
      final jsonStr = ep.exportJson();
      final dir     = await getApplicationDocumentsDirectory();
      final file    = File(
          '${dir.path}/ezze_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonStr);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'EzzeExpense Backup',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Import Data'),
        content: const Text(
            'This will replace ALL current data. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    try {
      final ctrl   = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title:   const Text('Paste JSON Backup'),
          content: TextField(
            controller: ctrl,
            maxLines:   6,
            decoration: const InputDecoration(
                hintText: 'Paste your JSON backup here...'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(context, ctrl.text),
                child: const Text('Import')),
          ],
        ),
      );
      if (result != null && result.isNotEmpty && context.mounted) {
        context.read<ExpenseProvider>().importJson(result);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data imported successfully!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  Future<void> _clearData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Clear All Data'),
        content: const Text(
            '⚠️ This will permanently delete ALL expenses. This cannot be undone!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style:     FilledButton.styleFrom(backgroundColor: Colors.red),
            child:     const Text('Delete All'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<ExpenseProvider>().clearAll();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared.')));
    }
  }
}
