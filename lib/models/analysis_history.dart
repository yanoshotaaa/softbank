import 'package:flutter/material.dart';

class AnalysisHistory {
  final String id;
  final DateTime analyzedAt;
  final String handDescription;
  final double winRate;
  final String analysisResult;
  final Map<String, dynamic> handDetails;
  final String? imagePath; // 分析した画像のパス

  AnalysisHistory({
    required this.id,
    required this.analyzedAt,
    required this.handDescription,
    required this.winRate,
    required this.analysisResult,
    required this.handDetails,
    this.imagePath,
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
    };
  }
}

// 分析履歴を管理するプロバイダー
class AnalysisHistoryProvider extends ChangeNotifier {
  List<AnalysisHistory> _histories = [];
  bool _isLoading = false;

  List<AnalysisHistory> get histories => _histories;
  bool get isLoading => _isLoading;

  // 新しい分析履歴を追加
  Future<void> addHistory(AnalysisHistory history) async {
    _histories.insert(0, history); // 新しい履歴を先頭に追加
    notifyListeners();
    // TODO: 永続化処理を実装
  }

  // 分析履歴を削除
  Future<void> deleteHistory(String id) async {
    _histories.removeWhere((history) => history.id == id);
    notifyListeners();
    // TODO: 永続化処理を実装
  }

  // 分析履歴を読み込み
  Future<void> loadHistories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: 永続化されたデータを読み込む処理を実装
      // 現在はダミーデータを使用
      _histories = [
        AnalysisHistory(
          id: '1',
          analyzedAt: DateTime.now().subtract(const Duration(hours: 2)),
          handDescription: 'AKs vs QQ プリフロップ',
          winRate: 0.65,
          analysisResult: '適切なプレイ',
          handDetails: {
            'position': 'BTN',
            'stack': '100BB',
            'action': '3bet',
            'opponent': 'BB',
          },
        ),
        AnalysisHistory(
          id: '2',
          analyzedAt: DateTime.now().subtract(const Duration(days: 1)),
          handDescription: 'JJ vs AK プリフロップ',
          winRate: 0.45,
          analysisResult: '改善の余地あり',
          handDetails: {
            'position': 'CO',
            'stack': '80BB',
            'action': 'call',
            'opponent': 'BTN',
          },
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
