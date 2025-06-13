import 'package:flutter/foundation.dart';

class PokerAnalysisProvider with ChangeNotifier {
  bool _isAnalyzing = false;
  String? _currentImagePath;
  String? _analysisResult;
  double? _winRate;
  String? _handDescription;
  Map<String, dynamic>? _handDetails;

  bool get isAnalyzing => _isAnalyzing;
  String? get currentImagePath => _currentImagePath;
  String? get analysisResult => _analysisResult;
  double? get winRate => _winRate;
  String? get handDescription => _handDescription;
  Map<String, dynamic>? get handDetails => _handDetails;

  void startAnalysis() {
    _isAnalyzing = true;
    notifyListeners();
  }

  void endAnalysis() {
    _isAnalyzing = false;
    notifyListeners();
  }

  void setImagePath(String path) {
    _currentImagePath = path;
    notifyListeners();
  }

  void setAnalysisResult({
    required String result,
    required double winRate,
    required String handDescription,
    required Map<String, dynamic> handDetails,
  }) {
    _analysisResult = result;
    _winRate = winRate;
    _handDescription = handDescription;
    _handDetails = handDetails;
    notifyListeners();
  }

  void resetAnalysis() {
    _currentImagePath = null;
    _analysisResult = null;
    _winRate = null;
    _handDescription = null;
    _handDetails = null;
    _isAnalyzing = false;
    notifyListeners();
  }
}
