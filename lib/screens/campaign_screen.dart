import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/campaign_provider.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({Key? key}) : super(key: key);

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _commentController = TextEditingController();
  final _linkController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _includeComment = false;
  bool _includeLink = false;

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
            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان الحملة',
                hintText: 'أدخل عنوان الحملة',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1F3A),
              ),
            ),
            const SizedBox(height: 16),

            // Content Field
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'محتوى المنشور',
                hintText: 'أدخل محتوى المنشور',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1F3A),
              ),
            ),
            const SizedBox(height: 16),

            // Comment Option
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF1877F2).withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('إضافة تعليق'),
                    value: _includeComment,
                    onChanged: (value) {
                      setState(() => _includeComment = value ?? false);
                    },
                    activeColor: const Color(0xFF1877F2),
                  ),
                  if (_includeComment)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'نص التعليق',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A0E27),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Link Option
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('مشاركة رابط'),
                    value: _includeLink,
                    onChanged: (value) {
                      setState(() => _includeLink = value ?? false);
                    },
                    activeColor: const Color(0xFF7C3AED),
                  ),
                  if (_includeLink)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _linkController,
                        decoration: InputDecoration(
                          labelText: 'الرابط',
                          hintText: 'https://example.com',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A0E27),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Schedule Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1877F2).withOpacity(0.1),
                    const Color(0xFF7C3AED).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1877F2).withOpacity(0.3),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'جدولة النشر',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedDate == null
                                ? 'اختر التاريخ'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() => _selectedTime = time);
                            }
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _selectedTime == null
                                ? 'اختر الوقت'
                                : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Create Campaign Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createCampaign,
                icon: const Icon(Icons.send),
                label: const Text('إنشاء الحملة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF1877F2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createCampaign() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    final campaign = {
      'title': _titleController.text,
      'content': _contentController.text,
      'comment': _includeComment ? _commentController.text : null,
      'link': _includeLink ? _linkController.text : null,
      'scheduledDate': _selectedDate,
      'scheduledTime': _selectedTime,
    };

    context.read<CampaignProvider>().addCampaign(campaign);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء الحملة بنجاح')),
    );

    // Clear form
    _titleController.clear();
    _contentController.clear();
    _commentController.clear();
    _linkController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _includeComment = false;
      _includeLink = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _commentController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
