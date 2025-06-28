import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:math';

class AnalysisHistory {
  final String id;
  final DateTime analyzedAt;
  final String handDescription;
  final double winRate;
  final String analysisResult;
  final Map<String, dynamic> handDetails;
  final String? imagePath; // 分析した画像のパス
  final String? notes; // ユーザーのメモ
  final List<String> tags; // タグ

  AnalysisHistory({
    required this.id,
    required this.analyzedAt,
    required this.handDescription,
    required this.winRate,
    required this.analysisResult,
    required this.handDetails,
    this.imagePath,
    this.notes,
    this.tags = const [],
  });

  // JSONからオブジェクトを作成
  factory AnalysisHistory.fromJson(Map<String, dynamic> json) {
    return AnalysisHistory(
      id: json['id'] as String,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      handDescription: json['handDescription'] as String,
      winRate: json['winRate'] as double,
      analysisResult: json['analysisResult'] as String,
      handDetails: json['handDetails'] as Map<String, dynamic>,
      imagePath: json['imagePath'] as String?,
      notes: json['notes'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // オブジェクトをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analyzedAt': analyzedAt.toIso8601String(),
      'handDescription': handDescription,
      'winRate': winRate,
      'analysisResult': analysisResult,
      'handDetails': handDetails,
      'imagePath': imagePath,
      'notes': notes,
      'tags': tags,
    };
  }

  // 検索用のテキストを取得
  String get searchText {
    return '${handDescription} ${analysisResult} ${handDetails.values.join(' ')} ${notes ?? ''} ${tags.join(' ')}'
        .toLowerCase();
  }

  // for Firestore
  factory AnalysisHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AnalysisHistory(
      id: doc.id,
      analyzedAt: (data['analyzedAt'] as Timestamp).toDate(),
      handDescription: data['handDescription'] ?? '',
      winRate: (data['winRate'] as num?)?.toDouble() ?? 0.0,
      analysisResult: data['analysisResult'] ?? 'unknown',
      handDetails: Map<String, dynamic>.from(data['handDetails'] ?? {}),
      imagePath: data['imagePath'] as String?,
      notes: data['notes'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'analyzedAt': Timestamp.fromDate(analyzedAt),
      'handDescription': handDescription,
      'winRate': winRate,
      'analysisResult': analysisResult,
      'handDetails': handDetails,
      'imagePath': imagePath,
      'notes': notes,
      'tags': tags,
    };
  }

  AnalysisHistory copyWith({
    String? id,
    DateTime? analyzedAt,
    String? handDescription,
    double? winRate,
    String? analysisResult,
    Map<String, dynamic>? handDetails,
    String? imagePath,
    String? notes,
    List<String>? tags,
  }) {
    return AnalysisHistory(
      id: id ?? this.id,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      handDescription: handDescription ?? this.handDescription,
      winRate: winRate ?? this.winRate,
      analysisResult: analysisResult ?? this.analysisResult,
      handDetails: handDetails ?? this.handDetails,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }
}

// 分析履歴を管理するプロバイダー（Firebase Firestore使用）
class AnalysisHistoryProvider extends ChangeNotifier {
  List<AnalysisHistory> _histories = [];
  List<AnalysisHistory> _filteredHistories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterResult = '';
  String _filterPosition = '';
  String _filterAction = '';
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 一時的にFirestoreを無効化（接続エラー回避）
  bool _useLocalOnly = true;

  List<AnalysisHistory> get histories => _filteredHistories;
  List<AnalysisHistory> get allHistories => _histories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get filterResult => _filterResult;
  String get filterPosition => _filterPosition;
  String get filterAction => _filterAction;
  DateTime? get filterDateFrom => _filterDateFrom;
  DateTime? get filterDateTo => _filterDateTo;

  // 現在のユーザーIDを取得
  String? get _currentUserId => _auth.currentUser?.uid;

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

    return {
      'total': _histories.length,
      'averageWinRate': winRates.reduce((a, b) => a + b) / winRates.length,
      'bestWinRate': winRates.reduce((a, b) => a > b ? a : b),
      'worstWinRate': winRates.reduce((a, b) => a < b ? a : b),
      'appropriatePlays': appropriatePlays,
      'borderlinePlays': borderlinePlays,
      'improvementNeeded': improvementNeeded,
      'positions': positions,
      'actions': actions,
    };
  }

  // 新しい分析履歴を追加（Firestore）
  Future<void> addHistory(AnalysisHistory history) async {
    // 一時的にローカル保存のみ使用
    if (_useLocalOnly || _currentUserId == null) {
      await _saveToLocal(history);
      // 新しいリストを作成して代入
      _histories = [history, ..._histories];
      _applyFilters();
      notifyListeners();
      return;
    }

    try {
      // Firestoreに保存
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('histories')
          .doc(history.id)
          .set(history.toFirestore());

      // 新しいリストを作成して代入
      _histories = [history, ..._histories];
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint(
          'Firestore接続エラー - ローカルに保存します: ${e.toString().substring(0, 100)}');
      // エラーの場合はローカルに保存
      await _saveToLocal(history);
      // 新しいリストを作成して代入
      _histories = [history, ..._histories];
      _applyFilters();
      notifyListeners();
    }
  }

  // 分析履歴を更新（Firestore）
  Future<void> updateHistory(AnalysisHistory updatedHistory) async {
    if (_currentUserId == null) {
      debugPrint('ユーザーがログインしていません');
      return;
    }

    try {
      // Firestoreを更新
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('histories')
          .doc(updatedHistory.id)
          .update(updatedHistory.toFirestore());

      // ローカルリストを更新
      final index = _histories.indexWhere((h) => h.id == updatedHistory.id);
      if (index != -1) {
        _histories[index] = updatedHistory;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('履歴の更新エラー: $e');
    }
  }

  // 分析履歴を削除（Firestore）
  Future<void> deleteHistory(String id) async {
    if (_currentUserId == null) {
      debugPrint('ユーザーがログインしていません');
      return;
    }

    try {
      // Firestoreから削除
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('histories')
          .doc(id)
          .delete();

      // 新しいリストを作成して代入
      _histories = _histories.where((history) => history.id != id).toList();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('履歴の削除エラー: $e');
    }
  }

  // 分析履歴を読み込み（Firestore）
  Future<void> loadHistories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 一時的にローカル保存のみ使用
      if (_useLocalOnly || _currentUserId == null) {
        await _loadFromLocal();
        return;
      }

      // Firebase接続テスト
      final isConnected = await _testFirebaseConnection();
      if (!isConnected) {
        debugPrint('Firebase接続不可 - ローカルから読み込みます');
        await _loadFromLocal();
        return;
      }

      // Firestoreから読み込み（タイムアウト設定）
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('histories')
          .orderBy('analyzedAt', descending: true)
          .limit(100) // パフォーマンス向上のため制限
          .get(const GetOptions(source: Source.serverAndCache));

      _histories = querySnapshot.docs
          .map((doc) => AnalysisHistory.fromFirestore(doc))
          .toList();

      _applyFilters();
    } catch (e) {
      debugPrint(
          'Firestore読み込みエラー - ローカルから読み込みます: ${e.toString().substring(0, 100)}');
      // エラーの場合はローカルから読み込み
      await _loadFromLocal();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ローカルに保存（フォールバック用）
  Future<void> _saveToLocal(AnalysisHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historiesJson = prefs.getStringList('analysis_histories') ?? [];
      historiesJson.add(jsonEncode(history.toFirestore()));
      await prefs.setStringList('analysis_histories', historiesJson);
    } catch (e) {
      debugPrint('ローカル保存エラー: $e');
    }
  }

  // ローカルから読み込み（フォールバック用）
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historiesJson = prefs.getStringList('analysis_histories') ?? [];

      _histories = historiesJson
          .map((json) => AnalysisHistory.fromJson(jsonDecode(json)))
          .toList();

      _histories.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
      _applyFilters();
    } catch (e) {
      debugPrint('ローカル読み込みエラー: $e');
      _histories = _getDummyData();
      _applyFilters();
    }
  }

  // 検索クエリを設定
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
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
    notifyListeners();
  }

  // フィルターをリセット
  void resetFilters() {
    _searchQuery = '';
    _filterResult = '';
    _filterPosition = '';
    _filterAction = '';
    _filterDateFrom = null;
    _filterDateTo = null;
    _applyFilters();
    notifyListeners();
  }

  // フィルターを適用
  void _applyFilters() {
    final filtered = _histories.where((history) {
      // 検索クエリフィルター
      if (_searchQuery.isNotEmpty) {
        if (!history.searchText.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // 結果フィルター
      if (_filterResult.isNotEmpty) {
        if (history.analysisResult != _filterResult) {
          return false;
        }
      }

      // ポジションフィルター
      if (_filterPosition.isNotEmpty) {
        if (history.handDetails['position'] != _filterPosition) {
          return false;
        }
      }

      // アクションフィルター
      if (_filterAction.isNotEmpty) {
        if (history.handDetails['action'] != _filterAction) {
          return false;
        }
      }

      // 日付フィルター
      if (_filterDateFrom != null) {
        if (history.analyzedAt.isBefore(_filterDateFrom!)) {
          return false;
        }
      }

      if (_filterDateTo != null) {
        if (history.analyzedAt.isAfter(_filterDateTo!)) {
          return false;
        }
      }

      return true;
    }).toList();

    // 新しいリストを作成して代入（ListViewの子要素順序エラーを防ぐ）
    _filteredHistories = List<AnalysisHistory>.from(filtered);
  }

  // ダミーデータを生成
  List<AnalysisHistory> _getDummyData() {
    final random = Random();
    final positions = ['BTN', 'CO', 'MP', 'UTG', 'BB', 'SB'];
    final actions = ['fold', 'call', 'raise', '3bet', '4bet'];
    final opponents = ['BB', 'BTN', 'CO', 'MP', 'UTG'];
    final stacks = ['50BB', '80BB', '100BB', '150BB', '200BB'];
    final hands = [
      'AKs vs QQ プリフロップ',
      'JJ vs AK プリフロップ',
      'TT vs AQ プリフロップ',
      '99 vs JJ プリフロップ',
      'AKo vs TT プリフロップ',
      'AQs vs KK プリフロップ',
      'AJs vs QQ プリフロップ',
      'KQs vs AA プリフロップ',
    ];

    return List.generate(20, (index) {
      final hand = hands[random.nextInt(hands.length)];
      final winRate = 0.3 + random.nextDouble() * 0.6; // 30% - 90%
      final isAppropriate = winRate > 0.5;

      return AnalysisHistory(
        id: 'dummy_$index',
        analyzedAt: DateTime.now().subtract(Duration(
          days: random.nextInt(30),
          hours: random.nextInt(24),
          minutes: random.nextInt(60),
        )),
        handDescription: hand,
        winRate: winRate,
        analysisResult: isAppropriate ? '適切なプレイ' : '改善の余地あり',
        handDetails: {
          'position': positions[random.nextInt(positions.length)],
          'stack': stacks[random.nextInt(stacks.length)],
          'action': actions[random.nextInt(actions.length)],
          'opponent': opponents[random.nextInt(opponents.length)],
        },
        notes: random.nextBool() ? 'メモ: ${hand}の分析結果' : null,
        tags: random.nextBool() ? ['重要', '復習必要'] : [],
      );
    });
  }

  // 分析結果から履歴を作成
  AnalysisHistory createHistoryFromAnalysis({
    required String handDescription,
    required double winRate,
    required String analysisResult,
    required Map<String, dynamic> handDetails,
    String? imagePath,
    String? notes,
    List<String> tags = const [],
  }) {
    return AnalysisHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      analyzedAt: DateTime.now(),
      handDescription: handDescription,
      winRate: winRate,
      analysisResult: analysisResult,
      handDetails: handDetails,
      imagePath: imagePath,
      notes: notes,
      tags: tags,
    );
  }

  // Firebase接続テスト
  Future<bool> _testFirebaseConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      debugPrint('Firebase接続テスト失敗: ${e.toString().substring(0, 100)}');
      return false;
    }
  }
}
