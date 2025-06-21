import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/analysis_history.dart';

class AnalysisHistoryProvider with ChangeNotifier {
  List<AnalysisHistory> _histories = [];
  final String _storageKey = 'analysis_histories';

  List<AnalysisHistory> get histories => _histories;

  AnalysisHistoryProvider() {
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historiesString = prefs.getString(_storageKey);
    if (historiesString != null) {
      final List<dynamic> historiesJson = json.decode(historiesString);
      _histories =
          historiesJson.map((json) => AnalysisHistory.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final String historiesString =
        json.encode(_histories.map((h) => h.toJson()).toList());
    await prefs.setString(_storageKey, historiesString);
  }

  void addHistory(AnalysisHistory history) {
    _histories.insert(0, history);
    _saveHistories();
    notifyListeners();
  }

  void deleteHistory(String id) {
    _histories.removeWhere((h) => h.id == id);
    _saveHistories();
    notifyListeners();
  }
}
