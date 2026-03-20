// ============================================================
//  screens/settings/settings_screen.dart — Dark Vault edition
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../category/category_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(title: Text('⚙️ Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile banner ─────────────────────────────────
          Container(
            decoration: t.accentCard(),
            padding:    const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  color:        t.accentGlow,
                  shape:        BoxShape.circle,
                  border:       Border.all(
                      color: kAccent.withOpacity(0.5), width: 2),
                ),
                child: Center(
                  child: Text('💰', style: TextStyle(fontSize: 26))),
              ),
              SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('EzzeExpense',
                  style: TextStyle(
                    color: t.textPrimary, fontSize: 17,
                    fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('v1.0.0  ·  ${settings.currency} Mode',
                  style: TextStyle(color: t.textSecond, fontSize: 12)),
              ]),
            ]),
          ),
          SizedBox(height: 20),

          // ── Appearance ─────────────────────────────────────
          _sectionLabel(context, '🎨  Appearance'),
          SizedBox(height: 8),
          Container(
            decoration: t.glowCard(),
            child: _SettingsTile(
              emoji:    '🌙',
              title:    'Dark Mode',
              subtitle: settings.isDark ? '🌙 Dark theme active' : '☀️ Light theme active',
              trailing: Switch(
                value:       settings.isDark,
                onChanged:   (_) => settings.toggleTheme(),
                activeColor: kAccent,
              ),
            ),
          ),
          SizedBox(height: 16),

          // ── Currency ───────────────────────────────────────
          _sectionLabel(context, '💱  Currency'),
          SizedBox(height: 8),
          Container(
            decoration: t.glowCard(),
            child: Column(children: [
              ...kCurrencies.map((c) {
                final selected = settings.currency == c;
                final isLast   = c == kCurrencies.last;
                return Column(children: [
                  GestureDetector(
                    onTap: () => settings.setCurrency(c),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: selected
                                ? t.accentGlow : t.bgCardAlt,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: selected
                                  ? kAccent.withOpacity(0.5) : t.border),
                          ),
                          child: Center(
                            child: Text(kCurrencySymbols[c] ?? c,
                              style: TextStyle(
                                color:      selected ? kAccent : t.textSecond,
                                fontWeight: FontWeight.w700,
                                fontSize:   16))),
                          ),
                        SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c,
                              style: TextStyle(
                                color:      selected ? t.textPrimary : t.textSecond,
                                fontWeight: selected
                                    ? FontWeight.w600 : FontWeight.w400,
                                fontSize: 14)),
                            Text(c == 'BDT'
                                ? 'Bangladeshi Taka' : 'US Dollar',
                              style: TextStyle(
                                  color: t.textHint, fontSize: 12)),
                          ],
                        )),
                        if (selected)
                          Icon(Icons.check_circle_rounded,
                              color: kAccent, size: 20),
                      ]),
                    ),
                  ),
                  if (!isLast)
                    Divider(height: 1, color: t.divider,
                        indent: 16, endIndent: 16),
                ]);
              }),
            ]),
          ),
          SizedBox(height: 16),

          // ── Data Management ────────────────────────────────
          _sectionLabel(context, '🗄️  Data Management'),
          SizedBox(height: 8),
          Container(
            decoration: t.glowCard(),
            child: Column(children: [
              _SettingsTile(
                emoji:    '🏷️',
                title:    'Manage Categories',
                subtitle: 'Add, edit or remove categories',
                trailing: Icon(Icons.chevron_right_rounded,
                    color: t.textHint, size: 20),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const CategoryManagementScreen())),
              ),
              Divider(height: 1, color: t.divider,
                  indent: 60, endIndent: 16),
              _SettingsTile(
                emoji:    '📤',
                title:    'Export Data',
                subtitle: 'Save as JSON backup file',
                trailing: Icon(Icons.chevron_right_rounded,
                    color: t.textHint, size: 20),
                onTap: () => _exportData(context),
              ),
              Divider(height: 1, color: t.divider,
                  indent: 60, endIndent: 16),
              _SettingsTile(
                emoji:    '📥',
                title:    'Import Data',
                subtitle: 'Restore from JSON backup',
                trailing: Icon(Icons.chevron_right_rounded,
                    color: t.textHint, size: 20),
                onTap: () => _importData(context),
              ),
              Divider(height: 1, color: t.divider,
                  indent: 60, endIndent: 16),
              _SettingsTile(
                emoji:    '🗑️',
                title:    'Clear All Data',
                subtitle: 'Permanently delete all expenses',
                titleColor: kDanger,
                trailing: Icon(Icons.chevron_right_rounded,
                    color: t.textHint, size: 20),
                onTap: () => _clearData(context),
              ),
            ]),
          ),
          SizedBox(height: 16),

          // ── About ──────────────────────────────────────────
          _sectionLabel(context, 'ℹ️  About'),
          SizedBox(height: 8),
          Container(
            decoration: t.glowCard(),
            child: Column(children: [
              const _SettingsTile(
                emoji:    '📱',
                title:    'App Version',
                subtitle: 'EzzeExpense v1.0.0',
                trailing: Text('1.0.0',
                  style: TextStyle(
                    color: kAccent, fontWeight: FontWeight.w600,
                    fontSize: 13)),
              ),
              Divider(height: 1, color: t.divider,
                  indent: 60, endIndent: 16),
              const _SettingsTile(
                emoji:    '🛠️',
                title:    'Built with Flutter',
                subtitle: 'Dark Vault Theme · 2024',
                trailing: Text('❤️',
                    style: TextStyle(fontSize: 18)),
              ),
            ]),
          ),
          const SizedBox(height: 32),

          // Footer
          Center(child: Column(children: [
            Text('💰 EzzeExpense',
              style: TextStyle(
                color: kAccent, fontWeight: FontWeight.w700,
                fontSize: 14)),
            SizedBox(height: 4),
            Text('Track smart. Spend wise. 🚀',
              style: TextStyle(color: t.textHint, fontSize: 12)),
          ])),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final t = EzzeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(text,
        style: TextStyle(
          color: t.textSecond, fontSize: 12,
          fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final t = EzzeTheme.of(context);
    try {
      final ep      = context.read<ExpenseProvider>();
      final jsonStr = ep.exportJson();
      final dir     = await getApplicationDocumentsDirectory();
      final file    = File('${dir.path}/ezze_backup_'
          '${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonStr);
      await Share.shareXFiles([XFile(file.path)],
          subject: 'EzzeExpense Backup');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final t = EzzeTheme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _darkDialog(
        title: '📥 Import Data',
        content: 'This will replace ALL current data. Continue?',
        confirmLabel: 'Continue',
        confirmColor: kAccent,
      ),
    );
    if (confirm != true || !context.mounted) return;
    try {
      final ctrl   = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (_) {
          final t = EzzeTheme.of(context);
          return AlertDialog(
          backgroundColor: t.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: t.border)),
          title: Text('📋 Paste JSON Backup',
            style: TextStyle(color: t.textPrimary, fontSize: 17)),
          content: TextField(
            controller: ctrl, maxLines: 6,
            style: TextStyle(color: t.textPrimary, fontSize: 13),
            decoration: const InputDecoration(
                hintText: 'Paste your JSON backup here...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: t.textSecond))),
            FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              style: FilledButton.styleFrom(
                backgroundColor: t.accentGlow,
                foregroundColor: kAccent,
                side: const BorderSide(color: kAccent)),
              child: const Text('Import')),
          ],
        );},
      );
      if (result != null && result.isNotEmpty && context.mounted) {
        context.read<ExpenseProvider>().importJson(result);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Data imported successfully!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  Future<void> _clearData(BuildContext context) async {
    final t = EzzeTheme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _darkDialog(
        title: '🗑️ Clear All Data',
        content: 'This will permanently delete ALL expenses.\nThis cannot be undone!',
        confirmLabel: 'Delete All',
        confirmColor: kDanger,
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<ExpenseProvider>().clearAll();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ All data cleared.')));
    }
  }

  Widget _darkDialog({
    required String title,
    required String content,
    required String confirmLabel,
    required Color  confirmColor,
  }) => Builder(builder: (context) {
    final t = EzzeTheme.of(context);
    return AlertDialog(
      backgroundColor: t.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: t.border)),
      title: Text(title,
        style: TextStyle(color: t.textPrimary, fontSize: 17)),
      content: Text(content,
        style: TextStyle(color: t.textSecond)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel',
              style: TextStyle(color: t.textSecond))),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: confirmColor.withOpacity(0.12),
            foregroundColor: confirmColor,
            side: BorderSide(color: confirmColor)),
          child: Text(confirmLabel)),
      ],
    );
  });
}

// ── Settings Tile ─────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final String  emoji;
  final String  title;
  final String  subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor:  t.accentGlow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color:        t.bgCardAlt,
                borderRadius: BorderRadius.circular(9),
                border:       Border.all(color: t.border),
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 17))),
            ),
            SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: TextStyle(
                    color:      titleColor ?? t.textPrimary,
                    fontSize:   14,
                    fontWeight: FontWeight.w600)),
                Text(subtitle,
                  style: TextStyle(
                      color: t.textHint, fontSize: 12)),
              ],
            )),
            if (trailing != null) trailing!,
          ]),
        ),
      ),
    );
  }
}
