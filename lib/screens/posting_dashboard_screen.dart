import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/posting_provider.dart';
import '../providers/campaign_provider.dart';

class PostingDashboardScreen extends StatefulWidget {
  const PostingDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PostingDashboardScreen> createState() => _PostingDashboardScreenState();
}

class _PostingDashboardScreenState extends State<PostingDashboardScreen> {
  Future<void> _exportReport(PostingProvider provider) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) return;

      final timestamp = DateTime.now().toString().replaceAll(' ', '_');
      final file = File('${directory.path}/posting_report_$timestamp.txt');

      final buffer = StringBuffer();
      buffer.writeln('تقرير النشر');
      buffer.writeln('=' * 50);
      buffer.writeln('التاريخ: ${DateTime.now()}');
      buffer.writeln('');
      buffer.writeln('الملخص:');
      buffer.writeln('نجح: ${provider.successCount}');
      buffer.writeln('فشل: ${provider.failedCount}');
      buffer.writeln('المتبقي: ${provider.remainingCount}');
      buffer.writeln('');
      buffer.writeln('التفاصيل:');
      buffer.writeln('-' * 50);

      for (final log in provider.logs) {
        buffer.writeln('${log.timestamp} | ${log.accountName} | ${log.groupUrl}');
        buffer.writeln('الحالة: ${log.status}');
        buffer.writeln('الرسالة: ${log.message}');
        buffer.writeln('');
      }

      await file.writeAsString(buffer.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حفظ التقرير: ${file.path}')),
        );
      }
    } catch (e) {
      debugPrint('Error exporting report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ التقرير: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة النشر المباشر'),
        centerTitle: true,
      ),
      body: Consumer2<PostingProvider, CampaignProvider>(
        builder: (context, postingProvider, campaignProvider, _) {
          final total = postingProvider.successCount +
              postingProvider.failedCount +
              postingProvider.remainingCount;
          final progress = total > 0
              ? (postingProvider.successCount + postingProvider.failedCount) /
                  total
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF1877F2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% مكتمل',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Counter Cards
                Row(
                  children: [
                    Expanded(
                      child: _CounterCard(
                        title: 'نجح',
                        count: postingProvider.successCount,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CounterCard(
                        title: 'فشل',
                        count: postingProvider.failedCount,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CounterCard(
                        title: 'المتبقي',
                        count: postingProvider.remainingCount,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Live Log
                const Text(
                  'سجل النشر المباشر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a1a),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: postingProvider.logs.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد سجلات بعد',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: postingProvider.logs.length,
                          itemBuilder: (context, index) {
                            final log = postingProvider.logs[index];
                            final color = log.status == 'success'
                                ? Colors.green
                                : log.status == 'failed'
                                    ? Colors.red
                                    : Colors.orange;

                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '[${log.timestamp}] ${log.accountName}: ${log.message}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),

                // Control Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: postingProvider.isPosting
                            ? () => postingProvider.pausePosting()
                            : null,
                        icon: const Icon(Icons.pause),
                        label: const Text('إيقاف مؤقت'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: postingProvider.isPosting
                            ? () => postingProvider.stopPosting()
                            : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('إيقاف الكل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _exportReport(postingProvider),
                    icon: const Icon(Icons.download),
                    label: const Text('حفظ التقرير'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _CounterCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
