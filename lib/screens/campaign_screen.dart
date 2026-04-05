import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/campaign_provider.dart';
import '../providers/account_provider.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({Key? key}) : super(key: key);

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final _nameController = TextEditingController();
  final _textController = TextEditingController();
  final _groupUrlsController = TextEditingController();
  final _minDelayController = TextEditingController(text: '15');
  final _maxDelayController = TextEditingController(text: '45');
  
  List<String> _selectedImages = [];
  Set<String> _selectedAccountIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _textController.dispose();
    _groupUrlsController.dispose();
    _minDelayController.dispose();
    _maxDelayController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      
      if (result != null) {
        setState(() {
          _selectedImages = result.paths.whereType<String>().toList();
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _startCampaign() {
    if (_nameController.text.isEmpty ||
        _textController.text.isEmpty ||
        _groupUrlsController.text.isEmpty ||
        _selectedAccountIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    final groupUrls = _groupUrlsController.text
        .split('\n')
        .where((url) => url.trim().isNotEmpty)
        .toList();

    final campaign = Campaign(
      name: _nameController.text,
      text: _textController.text,
      groupUrls: groupUrls,
      selectedAccountIds: _selectedAccountIds.toList(),
      imagePaths: _selectedImages.isNotEmpty ? _selectedImages : null,
      minDelay: int.tryParse(_minDelayController.text) ?? 15,
      maxDelay: int.tryParse(_maxDelayController.text) ?? 45,
    );

    context.read<CampaignProvider>().saveCampaign(campaign);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الحملة بنجاح')),
    );

    // Clear form
    _nameController.clear();
    _textController.clear();
    _groupUrlsController.clear();
    _minDelayController.text = '15';
    _maxDelayController.text = '45';
    _selectedImages.clear();
    _selectedAccountIds.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حملة جديدة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم الحملة',
                hintText: 'مثال: حملة الربيع',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Post Text
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'نص المنشور',
                hintText: 'اكتب نص المنشور هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Group URLs
            TextField(
              controller: _groupUrlsController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'روابط المجموعات',
                hintText: 'ضع رابط كل مجموعة في سطر منفصل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Images
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image),
                    label: const Text('اختر صور'),
                  ),
                ),
                const SizedBox(width: 8),
                if (_selectedImages.isNotEmpty)
                  Text(
                    '${_selectedImages.length} صور',
                    style: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Delay Settings
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minDelayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الحد الأدنى للتأخير (ثانية)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxDelayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الحد الأقصى للتأخير (ثانية)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Account Selection
            const Text(
              'اختر الحسابات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<AccountProvider>(
              builder: (context, accountProvider, _) {
                if (accountProvider.accounts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('لا توجد حسابات متاحة'),
                  );
                }

                return Column(
                  children: accountProvider.accounts.map((account) {
                    return CheckboxListTile(
                      title: Text(account.name),
                      subtitle: Text(
                        account.type == 'personal' ? 'حساب شخصي' : 'صفحة',
                      ),
                      value: _selectedAccountIds.contains(account.id),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedAccountIds.add(account.id);
                          } else {
                            _selectedAccountIds.remove(account.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Start Campaign Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startCampaign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'ابدأ الحملة',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
