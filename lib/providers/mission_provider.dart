import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Mission {
  final String id;
  final String title;
  final String description;
  final int reward;
  final int target;
  final String category;
  final String type; // 'daily', 'weekly', 'achievement'
  final Map<String, dynamic> conditions; // ミッションの条件
  final DateTime? expiresAt; // 期限（nullの場合は無期限）

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.target,
    required this.category,
    required this.type,
    required this.conditions,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'reward': reward,
        'target': target,
        'category': category,
        'type': type,
        'conditions': conditions,
        'expiresAt': expiresAt?.toIso8601String(),
      };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        reward: json['reward'],
        target: json['target'],
        category: json['category'],
        type: json['type'],
        conditions: json['conditions'],
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'])
            : null,
      );
}

class MissionProgress {
  final String missionId;
  int progress;
  bool isCompleted;
  bool isRewardClaimed;
  DateTime? completedAt;

  MissionProgress({
    required this.missionId,
    this.progress = 0,
    this.isCompleted = false,
    this.isRewardClaimed = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'progress': progress,
        'isCompleted': isCompleted,
        'isRewardClaimed': isRewardClaimed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory MissionProgress.fromJson(Map<String, dynamic> json) =>
      MissionProgress(
        missionId: json['missionId'],
        progress: json['progress'] ?? 0,
        isCompleted: json['isCompleted'] ?? false,
        isRewardClaimed: json['isRewardClaimed'] ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}

class MissionProvider extends ChangeNotifier {
  List<Mission> _availableMissions = [];
  Map<String, MissionProgress> _missionProgress = {};
  int _totalPoints = 0;
  bool _isLoading = false;

  List<Mission> get availableMissions => _availableMissions;
  Map<String, MissionProgress> get missionProgress => _missionProgress;
  int get totalPoints => _totalPoints;
  bool get isLoading => _isLoading;

  MissionProvider() {
    _initializeMissions();
    _loadProgress();
  }

  void _initializeMissions() {
    _availableMissions = [
      // 初心者ミッション
      Mission(
        id: 'first_win',
        title: '初めての勝利',
        description: '最初のハンドで勝利する',
        reward: 100,
        target: 1,
        category: 'beginner',
        type: 'achievement',
        conditions: {'action': 'win_hand'},
      ),
      Mission(
        id: 'play_10_hands',
        title: 'ポーカーに慣れる',
        description: '10ハンドをプレイする',
        reward: 50,
        target: 10,
        category: 'beginner',
        type: 'achievement',
        conditions: {'action': 'play_hand'},
      ),
      Mission(
        id: 'use_gto_5_times',
        title: 'GTOを試す',
        description: 'GTO推奨アクションを5回実行する',
        reward: 200,
        target: 5,
        category: 'beginner',
        type: 'achievement',
        conditions: {'action': 'use_gto'},
      ),

      // 中級者ミッション
      Mission(
        id: 'win_streak_3',
        title: '連続勝利',
        description: '3回連続で勝利する',
        reward: 300,
        target: 3,
        category: 'intermediate',
        type: 'achievement',
        conditions: {'action': 'win_streak'},
      ),
      Mission(
        id: 'use_range_20_times',
        title: 'レンジマスター',
        description: '推奨レンジ内で20回プレイする',
        reward: 400,
        target: 20,
        category: 'intermediate',
        type: 'achievement',
        conditions: {'action': 'use_range'},
      ),
      Mission(
        id: 'earn_5000_chips',
        title: 'チップ収集家',
        description: '合計5,000チップを獲得する',
        reward: 500,
        target: 5000,
        category: 'intermediate',
        type: 'achievement',
        conditions: {'action': 'earn_chips'},
      ),

      // 上級者ミッション
      Mission(
        id: 'use_gto_50_times',
        title: 'GTOマスター',
        description: 'GTO推奨アクションを50回実行する',
        reward: 1000,
        target: 50,
        category: 'advanced',
        type: 'achievement',
        conditions: {'action': 'use_gto'},
      ),
      Mission(
        id: 'earn_20000_chips',
        title: 'ポット王',
        description: '合計20,000チップを獲得する',
        reward: 1500,
        target: 20000,
        category: 'advanced',
        type: 'achievement',
        conditions: {'action': 'earn_chips'},
      ),
      Mission(
        id: 'win_streak_10',
        title: '無敵の連勝',
        description: '10回連続で勝利する',
        reward: 2000,
        target: 10,
        category: 'advanced',
        type: 'achievement',
        conditions: {'action': 'win_streak'},
      ),

      // デイリーミッション
      Mission(
        id: 'daily_play_5',
        title: '今日の練習',
        description: '今日5ハンドをプレイする',
        reward: 100,
        target: 5,
        category: 'daily',
        type: 'daily',
        conditions: {'action': 'play_hand'},
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
      Mission(
        id: 'daily_win_2',
        title: '今日の勝利',
        description: '今日2回勝利する',
        reward: 150,
        target: 2,
        category: 'daily',
        type: 'daily',
        conditions: {'action': 'win_hand'},
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
    ];
  }

  Future<void> _loadProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('mission_progress');
      final points = prefs.getInt('total_points') ?? 0;

      if (progressJson != null) {
        final Map<String, dynamic> progressMap =
            Map<String, dynamic>.from(json.decode(progressJson));
        _missionProgress = progressMap.map(
            (key, value) => MapEntry(key, MissionProgress.fromJson(value)));
      }

      _totalPoints = points;
    } catch (e) {
      // debugPrint('ミッション進捗の読み込みエラー: $e');
      // エラーが発生した場合は初期状態のまま続行
      _missionProgress = {};
      _totalPoints = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(
          _missionProgress.map((key, value) => MapEntry(key, value.toJson())));
      await prefs.setString('mission_progress', progressJson);
      await prefs.setInt('total_points', _totalPoints);
    } catch (e) {
      // debugPrint('ミッション進捗の保存エラー: $e');
      // エラーが発生してもアプリの動作を継続
    }
  }

  MissionProgress _getOrCreateProgress(String missionId) {
    if (!_missionProgress.containsKey(missionId)) {
      _missionProgress[missionId] = MissionProgress(missionId: missionId);
    }
    return _missionProgress[missionId]!;
  }

  // アクションを記録してミッション進捗を更新
  void recordAction(String action,
      {int value = 1, Map<String, dynamic>? data}) {
    for (final mission in _availableMissions) {
      if (mission.conditions['action'] == action) {
        _updateMissionProgress(mission, value, data);
      }
    }
  }

  void _updateMissionProgress(
      Mission mission, int value, Map<String, dynamic>? data) {
    final progress = _getOrCreateProgress(mission.id);

    if (progress.isCompleted) return; // 既に完了済み

    // 特殊なアクションの処理
    switch (mission.conditions['action']) {
      case 'win_streak':
        // 連勝の場合は特別な処理が必要
        break;
      case 'earn_chips':
        // チップ獲得の場合は累積値を使用
        progress.progress += value;
        break;
      default:
        progress.progress += value;
    }

    // 目標達成チェック
    if (progress.progress >= mission.target && !progress.isCompleted) {
      progress.isCompleted = true;
      progress.completedAt = DateTime.now();
    }

    _saveProgress();
    notifyListeners();
  }

  // 連勝記録（特別な処理）
  void recordWinStreak(int streakCount) {
    for (final mission in _availableMissions) {
      if (mission.conditions['action'] == 'win_streak') {
        final progress = _getOrCreateProgress(mission.id);
        if (!progress.isCompleted && streakCount >= mission.target) {
          progress.progress = mission.target;
          progress.isCompleted = true;
          progress.completedAt = DateTime.now();
        }
      }
    }
    _saveProgress();
    notifyListeners();
  }

  // 報酬を受け取る
  Future<bool> claimReward(String missionId) async {
    final progress = _missionProgress[missionId];
    if (progress == null || !progress.isCompleted || progress.isRewardClaimed) {
      return false;
    }

    final mission = _availableMissions.firstWhere((m) => m.id == missionId);
    progress.isRewardClaimed = true;
    _totalPoints += mission.reward;

    await _saveProgress();
    notifyListeners();
    return true;
  }

  // ミッションの進捗を取得
  MissionProgress? getMissionProgress(String missionId) {
    return _missionProgress[missionId];
  }

  // 完了済みミッションの数を取得
  int get completedMissionsCount {
    return _missionProgress.values.where((p) => p.isCompleted).length;
  }

  // 今日のデイリーミッションを取得
  List<Mission> get dailyMissions {
    return _availableMissions.where((m) => m.type == 'daily').toList();
  }

  // 達成ミッションを取得
  List<Mission> get achievementMissions {
    return _availableMissions.where((m) => m.type == 'achievement').toList();
  }

  // ミッションをリセット（デバッグ用）
  Future<void> resetMissions() async {
    _missionProgress.clear();
    _totalPoints = 0;
    await _saveProgress();
    notifyListeners();
  }
}
