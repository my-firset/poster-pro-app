import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PostingLog {
  final String timestamp;
  final String accountName;
  final String groupUrl;
  final String message;
  final String status; // 'success', 'failed', 'pending'

  PostingLog({
    required this.timestamp,
    required this.accountName,
    required this.groupUrl,
    required this.message,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'accountName': accountName,
    'groupUrl': groupUrl,
    'message': message,
    'status': status,
  };

  factory PostingLog.fromJson(Map<String, dynamic> json) => PostingLog(
    timestamp: json['timestamp'],
    accountName: json['accountName'],
    groupUrl: json['groupUrl'],
    message: json['message'],
    status: json['status'],
  );
}

class PostingProvider extends ChangeNotifier {
  List<PostingLog> _logs = [];
  int _successCount = 0;
  int _failedCount = 0;
  int _remainingCount = 0;
  bool _isPosting = false;
  bool _isPaused = false;
  Map<String, int> _accountSuccessCount = {};
  Map<String, int> _accountFailedCount = {};

  List<PostingLog> get logs => _logs;
  int get successCount => _successCount;
  int get failedCount => _failedCount;
  int get remainingCount => _remainingCount;
  bool get isPosting => _isPosting;
  bool get isPaused => _isPaused;
  Map<String, int> get accountSuccessCount => _accountSuccessCount;
  Map<String, int> get accountFailedCount => _accountFailedCount;

  PostingProvider() {
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList('posting_logs') ?? [];
      _logs = logsJson
          .map((json) => PostingLog.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading logs: $e');
    }
  }

  void startPosting(int totalGroups) {
    _isPosting = true;
    _isPaused = false;
    _successCount = 0;
    _failedCount = 0;
    _remainingCount = totalGroups;
    _logs.clear();
    _accountSuccessCount.clear();
    _accountFailedCount.clear();
    notifyListeners();
  }

  void pausePosting() {
    _isPaused = true;
    notifyListeners();
  }

  void resumePosting() {
    _isPaused = false;
    notifyListeners();
  }

  void stopPosting() {
    _isPosting = false;
    _isPaused = false;
    notifyListeners();
  }

  void addLog(PostingLog log) {
    _logs.add(log);
    
    if (log.status == 'success') {
      _successCount++;
      _accountSuccessCount[log.accountName] = 
          (_accountSuccessCount[log.accountName] ?? 0) + 1;
    } else if (log.status == 'failed') {
      _failedCount++;
      _accountFailedCount[log.accountName] = 
          (_accountFailedCount[log.accountName] ?? 0) + 1;
    }
    
    _remainingCount = (_remainingCount - 1).clamp(0, double.infinity).toInt();
    _saveLogs();
    notifyListeners();
  }

  Future<void> clearLogs() async {
    _logs.clear();
    _successCount = 0;
    _failedCount = 0;
    _remainingCount = 0;
    _accountSuccessCount.clear();
    _accountFailedCount.clear();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('posting_logs');
    } catch (e) {
      debugPrint('Error clearing logs: $e');
    }
    
    notifyListeners();
  }

  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = _logs
          .map((log) => jsonEncode(log.toJson()))
          .toList();
      await prefs.setStringList('posting_logs', logsJson);
    } catch (e) {
      debugPrint('Error saving logs: $e');
    }
  }
}
