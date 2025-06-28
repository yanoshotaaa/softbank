import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/analysis_history.dart';

class AnalysisHistoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AnalysisHistory> _histories = [];
  List<AnalysisHistory> get histories => _histories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

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
          .orderBy('analysisDate', descending: true)
          .get();

      _histories = snapshot.docs
          .map((doc) => AnalysisHistory.fromFirestore(doc))
          .toList();
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
      notifyListeners();
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
      notifyListeners();
    } catch (e) {
      debugPrint("履歴の削除に失敗しました: $e");
    }
  }
}
