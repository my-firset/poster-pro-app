import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class Campaign {
  final String id;
  final String name;
  final String text;
  final List<String> groupUrls;
  final List<String> selectedAccountIds;
  final List<String>? imagePaths;
  final int minDelay;
  final int maxDelay;
  final DateTime createdAt;

  Campaign({
    String? id,
    required this.name,
    required this.text,
    required this.groupUrls,
    required this.selectedAccountIds,
    this.imagePaths,
    this.minDelay = 15,
    this.maxDelay = 45,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'text': text,
    'groupUrls': groupUrls,
    'selectedAccountIds': selectedAccountIds,
    'imagePaths': imagePaths,
    'minDelay': minDelay,
    'maxDelay': maxDelay,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json['id'],
    name: json['name'],
    text: json['text'],
    groupUrls: List<String>.from(json['groupUrls'] ?? []),
    selectedAccountIds: List<String>.from(json['selectedAccountIds'] ?? []),
    imagePaths: json['imagePaths'] != null ? List<String>.from(json['imagePaths']) : null,
    minDelay: json['minDelay'] ?? 15,
    maxDelay: json['maxDelay'] ?? 45,
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class CampaignProvider extends ChangeNotifier {
  List<Campaign> _campaigns = [];
  Campaign? _currentCampaign;

  List<Campaign> get campaigns => _campaigns;
  Campaign? get currentCampaign => _currentCampaign;

  CampaignProvider() {
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final campaignsJson = prefs.getStringList('campaigns') ?? [];
      _campaigns = campaignsJson
          .map((json) => Campaign.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading campaigns: $e');
    }
  }

  Future<void> saveCampaign(Campaign campaign) async {
    final index = _campaigns.indexWhere((c) => c.id == campaign.id);
    if (index != -1) {
      _campaigns[index] = campaign;
    } else {
      _campaigns.add(campaign);
    }
    _currentCampaign = campaign;
    await _saveCampaigns();
    notifyListeners();
  }

  Future<void> deleteCampaign(String campaignId) async {
    _campaigns.removeWhere((c) => c.id == campaignId);
    if (_currentCampaign?.id == campaignId) {
      _currentCampaign = null;
    }
    await _saveCampaigns();
    notifyListeners();
  }

  void setCurrentCampaign(Campaign campaign) {
    _currentCampaign = campaign;
    notifyListeners();
  }

  Future<void> _saveCampaigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final campaignsJson = _campaigns
          .map((campaign) => jsonEncode(campaign.toJson()))
          .toList();
      await prefs.setStringList('campaigns', campaignsJson);
    } catch (e) {
      debugPrint('Error saving campaigns: $e');
    }
  }
}
