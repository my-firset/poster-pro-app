import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class FacebookAccount {
  final String id;
  final String name;
  final String type; // 'personal' or 'page'
  final String? pageName;
  final bool isLoggedIn;
  final String? cookies;

  FacebookAccount({
    String? id,
    required this.name,
    required this.type,
    this.pageName,
    this.isLoggedIn = false,
    this.cookies,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'pageName': pageName,
    'isLoggedIn': isLoggedIn,
  };

  factory FacebookAccount.fromJson(Map<String, dynamic> json) => FacebookAccount(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    pageName: json['pageName'],
    isLoggedIn: json['isLoggedIn'] ?? false,
  );
}

class AccountProvider extends ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();
  List<FacebookAccount> _accounts = [];

  List<FacebookAccount> get accounts => _accounts;

  AccountProvider() {
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = prefs.getStringList('accounts') ?? [];
      _accounts = accountsJson
          .map((json) => FacebookAccount.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    }
  }

  Future<void> addAccount(FacebookAccount account) async {
    _accounts.add(account);
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(FacebookAccount account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      await _saveAccounts();
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String accountId) async {
    _accounts.removeWhere((a) => a.id == accountId);
    await _secureStorage.delete(key: 'cookies_$accountId');
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> saveCookies(String accountId, String cookies) async {
    await _secureStorage.write(
      key: 'cookies_$accountId',
      value: cookies,
    );
  }

  Future<String?> getCookies(String accountId) async {
    return await _secureStorage.read(key: 'cookies_$accountId');
  }

  Future<void> _saveAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = _accounts
          .map((account) => jsonEncode(account.toJson()))
          .toList();
      await prefs.setStringList('accounts', accountsJson);
    } catch (e) {
      debugPrint('Error saving accounts: $e');
    }
  }
}
