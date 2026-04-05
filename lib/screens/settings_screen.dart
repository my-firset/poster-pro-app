import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/account_provider.dart';
import '../providers/posting_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _randomWordsController;
  bool _addGroupName = false;
  bool _addRandomEmoji = false;
  bool _skipFailedGroups = false;
  String _postingSpeed = 'normal';

  @override
  void initState() {
    super.initState();
    _randomWordsController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _randomWordsController.text = prefs.getString('random_words') ?? '';
        _addGroupName = prefs.getBool('add_group_name') ?? false;
        _addRandomEmoji = prefs.getBool('add_random_emoji') ?? false;
        _skipFailedGroups = prefs.getBool('skip_failed_groups') ?? false;
        _postingSpeed = prefs.getString('posting_speed') ?? 'normal';
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('random_words', _randomWordsController.text);
      await prefs.setBool('add_group_name', _addGroupName);
      await prefs.setBool('add_random_emoji', _addRandomEmoji);
      await prefs.setBool('skip_failed_groups', _skipFailedGroups);
      await prefs.setString('posting_speed', _postingSpeed);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
        );
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> _clearAllAccounts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف جميع الحسابات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final accountProvider = context.read<AccountProvider>();
      for (final account in List.from(accountProvider.accounts)) {
        await accountProvider.deleteAccount(account.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف جميع الحسابات')),
        );
      }
    }
  }

  Future<void> _clearPostingHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف سجل النشر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<PostingProvider>().clearLogs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف السجل')),
        );
      }
    }
  }

  @override
  void dispose() {
    _randomWordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Random Words
            const Text(
              'كلمات عشوائية للـ [RAND]',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _randomWordsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'أدخل الكلمات مفصولة بفواصل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Toggles
            SwitchListTile(
              title: const Text('إضافة اسم الجروب تلقائياً'),
              subtitle: const Text('يضيف [GNAME] في نهاية المنشور'),
              value: _addGroupName,
              onChanged: (value) {
                setState(() {
                  _addGroupName = value;
                });
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('إضافة إيموجي عشوائي'),
              subtitle: const Text('يضيف إيموجي في نهاية المنشور'),
              value: _addRandomEmoji,
              onChanged: (value) {
                setState(() {
                  _addRandomEmoji = value;
                });
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('تخطي الجروبات الفاشلة'),
              subtitle: const Text('لا تحاول النشر في الجروبات التي فشل فيها النشر'),
              value: _skipFailedGroups,
              onChanged: (value) {
                setState(() {
                  _skipFailedGroups = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Posting Speed
            const Text(
              'سرعة النشر',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _postingSpeed,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'slow',
                  child: Text('بطيء (30-60 ثانية)'),
                ),
                DropdownMenuItem(
                  value: 'normal',
                  child: Text('عادي (15-30 ثانية)'),
                ),
                DropdownMenuItem(
                  value: 'fast',
                  child: Text('سريع (5-15 ثانية)'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _postingSpeed = value ?? 'normal';
                });
              },
            ),
            const SizedBox(height: 24),

            // Save Settings Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('حفظ الإعدادات'),
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'منطقة الخطر',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),

            // Clear Accounts Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _clearAllAccounts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('مسح جميع الحسابات'),
              ),
            ),
            const SizedBox(height: 12),

            // Clear History Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _clearPostingHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('مسح سجل النشر'),
              ),
            ),
            const SizedBox(height: 24),

            // App Version
            Center(
              child: Text(
                'Poster Pro v1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
