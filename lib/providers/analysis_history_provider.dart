import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/analysis_history.dart';

class AnalysisHistoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AnalysisHistory> _histories = [];
  List<AnalysisHistory> _filteredHistories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterResult = '';
  String _filterPosition = '';
  String _filterAction = '';
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  String _sortBy = 'date'; // 'date', 'winRate', 'result'
  bool _sortDescending = true;

  List<AnalysisHistory> get histories => _filteredHistories;
  List<AnalysisHistory> get allHistories => _histories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get filterResult => _filterResult;
  String get filterPosition => _filterPosition;
  String get filterAction => _filterAction;
  DateTime? get filterDateFrom => _filterDateFrom;
  DateTime? get filterDateTo => _filterDateTo;
  String get sortBy => _sortBy;
  bool get sortDescending => _sortDescending;

  // 統計情報を取得
  Map<String, dynamic> get statistics {
    if (_histories.isEmpty) {
      return {
        'total': 0,
        'averageWinRate': 0.0,
        'bestWinRate': 0.0,
        'worstWinRate': 0.0,
        'appropriatePlays': 0,
        'borderlinePlays': 0,
        'improvementNeeded': 0,
        'positions': {},
        'actions': {},
        'recentTrend': 'stable',
      };
    }

    final appropriatePlays =
        _histories.where((h) => h.analysisResult == '適切なプレイ').length;
    final borderlinePlays =
        _histories.where((h) => h.analysisResult == '境界線のプレイ').length;
    final improvementNeeded =
        _histories.where((h) => h.analysisResult == '改善の余地あり').length;

    final positions = <String, int>{};
    final actions = <String, int>{};

    for (final history in _histories) {
      final position = history.handDetails['position'] ?? '';
      final action = history.handDetails['action'] ?? '';

      positions[position] = (positions[position] ?? 0) + 1;
      actions[action] = (actions[action] ?? 0) + 1;
    }

    final winRates = _histories.map((h) => h.winRate).toList();
    final averageWinRate = winRates.reduce((a, b) => a + b) / winRates.length;
    final bestWinRate = winRates.reduce((a, b) => a > b ? a : b);
    final worstWinRate = winRates.reduce((a, b) => a < b ? a : b);

    // 最近の傾向を計算
    final recentHistories = _histories.take(10).toList();
    final recentWinRate = recentHistories.isNotEmpty
        ? recentHistories.map((h) => h.winRate).reduce((a, b) => a + b) /
            recentHistories.length
        : 0.0;

    String recentTrend = 'stable';
    if (recentWinRate > averageWinRate + 0.05) {
      recentTrend = 'improving';
    } else if (recentWinRate < averageWinRate - 0.05) {
      recentTrend = 'declining';
    }

    return {
      'total': _histories.length,
      'averageWinRate': averageWinRate,
      'bestWinRate': bestWinRate,
      'worstWinRate': worstWinRate,
      'appropriatePlays': appropriatePlays,
      'borderlinePlays': borderlinePlays,
      'improvementNeeded': improvementNeeded,
      'positions': positions,
      'actions': actions,
      'recentTrend': recentTrend,
      'recentWinRate': recentWinRate,
    };
  }

  // 検索クエリを設定
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // フィルターを設定
  void setFilters({
    String? result,
    String? position,
    String? action,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    _filterResult = result ?? '';
    _filterPosition = position ?? '';
    _filterAction = action ?? '';
    _filterDateFrom = dateFrom;
    _filterDateTo = dateTo;
    _applyFilters();
  }

  // ソート設定を変更
  void setSort(String sortBy, {bool descending = true}) {
    _sortBy = sortBy;
    _sortDescending = descending;
    _applyFilters();
  }

  // フィルターをリセット
  void resetFilters() {
    _searchQuery = '';
    _filterResult = '';
    _filterPosition = '';
    _filterAction = '';
    _filterDateFrom = null;
    _filterDateTo = null;
    _sortBy = 'date';
    _sortDescending = true;
    _applyFilters();
  }

  // フィルターとソートを適用
  void _applyFilters() {
    var filtered = List<AnalysisHistory>.from(_histories);

    // 検索フィルター
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((history) {
        return history.searchText.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 結果フィルター
    if (_filterResult.isNotEmpty) {
      filtered = filtered.where((history) {
        return history.analysisResult == _filterResult;
      }).toList();
    }

    // ポジションフィルター
    if (_filterPosition.isNotEmpty) {
      filtered = filtered.where((history) {
        return history.handDetails['position'] == _filterPosition;
      }).toList();
    }

    // アクションフィルター
    if (_filterAction.isNotEmpty) {
      filtered = filtered.where((history) {
        return history.handDetails['action'] == _filterAction;
      }).toList();
    }

    // 日付フィルター
    if (_filterDateFrom != null) {
      filtered = filtered.where((history) {
        return history.analyzedAt.isAfter(_filterDateFrom!);
      }).toList();
    }

    if (_filterDateTo != null) {
      filtered = filtered.where((history) {
        return history.analyzedAt
            .isBefore(_filterDateTo!.add(const Duration(days: 1)));
      }).toList();
    }

    // ソート
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'date':
          comparison = a.analyzedAt.compareTo(b.analyzedAt);
          break;
        case 'winRate':
          comparison = a.winRate.compareTo(b.winRate);
          break;
        case 'result':
          comparison = a.analysisResult.compareTo(b.analysisResult);
          break;
        default:
          comparison = a.analyzedAt.compareTo(b.analyzedAt);
      }
      return _sortDescending ? -comparison : comparison;
    });

    _filteredHistories = filtered;
    notifyListeners();
  }

  Future<void> loadHistories() async {
    final user = _auth.currentUser;
    if (user == null) {
      _error = "ユーザーがログインしていません。";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analysis_histories')
          .orderBy('analyzedAt', descending: true)
          .get();

      _histories = snapshot.docs
          .map((doc) => AnalysisHistory.fromFirestore(doc))
          .toList();

      _applyFilters();
    } catch (e) {
      _error = "履歴の読み込みに失敗しました: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHistory(AnalysisHistory history) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analysis_histories')
          .add(history.toFirestore());

      final newHistory = history.copyWith(id: docRef.id);
      _histories.insert(0, newHistory);
      _applyFilters();
    } catch (e) {
      debugPrint("履歴の追加に失敗しました: $e");
    }
  }

  Future<void> deleteHistory(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analysis_histories')
          .doc(id)
          .delete();
      _histories.removeWhere((h) => h.id == id);
      _applyFilters();
    } catch (e) {
      debugPrint("履歴の削除に失敗しました: $e");
    }
  }

  Future<void> updateHistory(AnalysisHistory history) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analysis_histories')
          .doc(history.id)
          .update(history.toFirestore());

      final index = _histories.indexWhere((h) => h.id == history.id);
      if (index != -1) {
        _histories[index] = history;
        _applyFilters();
      }
    } catch (e) {
      debugPrint("履歴の更新に失敗しました: $e");
    }
  }

  // エラー管理
  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
