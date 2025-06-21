import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class UserProfile {
  final String id;
  final String username;
  final String email;
  final String avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': preferences,
    };
  }

  UserProfile copyWith({
    String? username,
    String? email,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      preferences: preferences ?? this.preferences,
    );
  }
}

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 一時的にFirestoreを無効化（接続エラー回避）
  bool _useLocalOnly = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _auth.currentUser != null;

  // 現在のユーザーIDを取得
  String? get _currentUserId => _auth.currentUser?.uid;

  // プロフィールを読み込み
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUserId == null) {
        // ログインしていない場合はローカルから読み込み
        await _loadFromLocal();
        return;
      }

      // Firestoreから読み込み
      final doc =
          await _firestore.collection('users').doc(_currentUserId).get();

      if (doc.exists) {
        final data = doc.data()!;
        _profile = UserProfile.fromJson(data);
      } else {
        // プロフィールが存在しない場合はデフォルトプロフィールを作成
        await _createDefaultProfile();
      }
    } catch (e) {
      debugPrint('プロフィール読み込みエラー - ローカルから読み込みます: $e');
      await _loadFromLocal();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // プロフィールを更新
  Future<void> updateProfile({
    String? username,
    String? email,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) async {
    if (_profile == null) return;

    final updatedProfile = _profile!.copyWith(
      username: username,
      email: email,
      avatar: avatar,
      preferences: preferences,
    );

    try {
      if (_currentUserId != null) {
        // Firestoreに保存
        await _firestore
            .collection('users')
            .doc(_currentUserId)
            .update(updatedProfile.toJson());
      }

      // ローカルにも保存
      await _saveToLocal(updatedProfile);

      _profile = updatedProfile;
      notifyListeners();
    } catch (e) {
      debugPrint('プロフィール更新エラー: $e');
      // エラーの場合はローカルに保存
      await _saveToLocal(updatedProfile);
      _profile = updatedProfile;
      notifyListeners();
    }
  }

  // デフォルトプロフィールを作成
  Future<void> _createDefaultProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final defaultProfile = UserProfile(
      id: user.uid,
      username: user.displayName ?? 'SHOOTER',
      email: user.email ?? '',
      avatar: '🎮',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      preferences: {
        'theme': 'light',
        'notifications': true,
        'sound': true,
        'haptic': true,
      },
    );

    try {
      // Firestoreに保存
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(defaultProfile.toJson());

      _profile = defaultProfile;
    } catch (e) {
      debugPrint('デフォルトプロフィール作成エラー: $e');
      // エラーの場合はローカルに保存
      await _saveToLocal(defaultProfile);
      _profile = defaultProfile;
    }
  }

  // ローカルに保存
  Future<void> _saveToLocal(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('ローカル保存エラー: $e');
    }
  }

  // ローカルから読み込み
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString('user_profile');
      if (profileString != null) {
        _profile = UserProfile.fromJson(jsonDecode(profileString));
      } else if (_currentUserId != null) {
        await _createDefaultProfile();
      }
    } catch (e) {
      debugPrint('ローカル読み込みエラー: $e');
      if (_currentUserId != null) {
        await _createDefaultProfile();
      }
    }
  }

  // 設定項目を取得
  T getPreference<T>(String key, T defaultValue) {
    return _profile?.preferences[key] as T? ?? defaultValue;
  }

  // 設定項目を更新
  Future<void> setPreference<T>(String key, T value) async {
    if (_profile == null) return;

    final newPreferences = Map<String, dynamic>.from(_profile!.preferences);
    newPreferences[key] = value;

    await updateProfile(preferences: newPreferences);
  }

  // ユーザーサインアウト時にプロフィールをクリア
  Future<void> clearProfile() async {
    _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    notifyListeners();
  }
}
