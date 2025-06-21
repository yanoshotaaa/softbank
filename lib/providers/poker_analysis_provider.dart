import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';

// Data Models
class HandData {
  final int handId;
  final List<String> yourCards;
  final List<String> communityCards;
  final String position;
  final List<ActionData> actions;
  final String result;
  final double potSize;
  final List<OpponentData>? opponents;
  final Map<String, double>? streetPots;

  HandData({
    required this.handId,
    required this.yourCards,
    required this.communityCards,
    required this.position,
    required this.actions,
    required this.result,
    required this.potSize,
    this.opponents,
    this.streetPots,
  });

  factory HandData.fromJson(Map<String, dynamic> json) {
    return HandData(
      handId: json['hand_id'] ?? 0,
      yourCards: List<String>.from(json['your_cards'] ?? []),
      communityCards: List<String>.from(json['community_cards'] ?? []),
      position: json['position'] ?? '',
      actions: (json['actions'] as List?)
              ?.map((a) => ActionData.fromJson(a))
              .toList() ??
          [],
      result: json['result'] ?? '',
      potSize: (json['pot_size'] ?? 0).toDouble(),
      opponents: (json['opponents'] as List?)
          ?.map((o) => OpponentData.fromJson(o))
          .toList(),
      streetPots: json['streetPots'] != null
          ? Map<String, double>.from(json['streetPots'])
          : null,
    );
  }
}

class ActionData {
  final String street;
  final String action;
  final double amount;

  ActionData({
    required this.street,
    required this.action,
    required this.amount,
  });

  factory ActionData.fromJson(Map<String, dynamic> json) {
    return ActionData(
      street: json['street'] ?? '',
      action: json['action'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class OpponentData {
  final String name;
  final String position;
  final List<String> cards;
  final double totalBet;
  final bool folded;
  final List<ActionData>? actions;

  OpponentData({
    required this.name,
    required this.position,
    required this.cards,
    required this.totalBet,
    required this.folded,
    this.actions,
  });

  factory OpponentData.fromJson(Map<String, dynamic> json) {
    return OpponentData(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      cards: List<String>.from(json['cards'] ?? []),
      totalBet: (json['total_bet'] ?? 0).toDouble(),
      folded: json['folded'] ?? false,
      actions: (json['actions'] as List?)
          ?.map((a) => ActionData.fromJson(a))
          .toList(),
    );
  }
}

class GameStats {
  final int totalHands;
  final double winRate;
  final double avgPot;
  final double aggression;

  GameStats({
    required this.totalHands,
    required this.winRate,
    required this.avgPot,
    required this.aggression,
  });
}

// GTO Data Models
class GTOData {
  final String tree;
  final double equity;
  final double ev;
  final double bet100;
  final double bet50;
  final double bet30;
  final double check;

  GTOData({
    required this.tree,
    required this.equity,
    required this.ev,
    required this.bet100,
    required this.bet50,
    required this.bet30,
    required this.check,
  });

  factory GTOData.fromCsv(List<dynamic> row) {
    return GTOData(
      tree: row[0].toString(),
      equity: double.tryParse(row[1].toString()) ?? 0.0,
      ev: double.tryParse(row[2].toString()) ?? 0.0,
      bet100: double.tryParse(row[3].toString()) ?? 0.0,
      bet50: double.tryParse(row[4].toString()) ?? 0.0,
      bet30: double.tryParse(row[5].toString()) ?? 0.0,
      check: double.tryParse(row[6].toString()) ?? 0.0,
    );
  }
}

// Hand Range Data Models
class HandRangeData {
  final String position;
  final String hands;
  final String color;

  HandRangeData({
    required this.position,
    required this.hands,
    required this.color,
  });

  factory HandRangeData.fromCsv(List<dynamic> row) {
    return HandRangeData(
      position: row[0].toString(),
      hands: row[4].toString(),
      color: row[5].toString(),
    );
  }
}

class GTORecommendation {
  final List<String> board;
  final String boardString;
  final double equity;
  final double ev;
  final String bestAction;
  final double bestFrequency;
  final Map<String, double> allActions;
  final bool isExactMatch;
  final double? similarityScore;

  GTORecommendation({
    required this.board,
    required this.boardString,
    required this.equity,
    required this.ev,
    required this.bestAction,
    required this.bestFrequency,
    required this.allActions,
    required this.isExactMatch,
    this.similarityScore,
  });
}

class PokerAnalysisProvider with ChangeNotifier {
  List<HandData> _hands = [];
  GameStats? _stats;
  bool _isLoading = false;
  List<GTOData> _gtoData = [];
  List<HandRangeData> _rangeData = [];

  // 既存のプロパティ
  bool _isAnalyzing = false;
  String? _currentImagePath;
  String? _analysisResult;
  double? _winRate;
  String? _handDescription;
  Map<String, dynamic>? _handDetails;

  // Getters
  List<HandData> get hands => _hands;
  GameStats? get stats => _stats;
  bool get isLoading => _isLoading;
  List<GTOData> get gtoData => _gtoData;
  List<HandRangeData> get rangeData => _rangeData;
  bool get isAnalyzing => _isAnalyzing;
  String? get currentImagePath => _currentImagePath;
  String? get analysisResult => _analysisResult;
  double? get winRate => _winRate;
  String? get handDescription => _handDescription;
  Map<String, dynamic>? get handDetails => _handDetails;

  // 既存のメソッド
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

  // 新しいメソッド
  Future<void> loadJsonFile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (result == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes);

      final jsonData = json.decode(content);

      if (jsonData != null) {
        if (jsonData['hands'] != null && jsonData['hands'] is List) {
          final hands = jsonData['hands'] as List;
          if (hands.isNotEmpty) {
            if (hands[0]['gameInfo'] != null) {
              _hands = _convertDetailedHistoryFormat(jsonData);
            } else if (hands[0]['hand_id'] != null) {
              _hands =
                  hands.map((handJson) => HandData.fromJson(handJson)).toList();
            } else {
              throw Exception('未知のJSONフォーマットです。');
            }
            _calculateStats();
          }
        } else {
          throw Exception('有効なハンドデータが見つかりません。');
        }
      } else {
        throw Exception('ファイルの内容を読み込めませんでした。');
      }
    } catch (e, stackTrace) {
      debugPrint('エラー発生: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<HandData> _convertDetailedHistoryFormat(Map<String, dynamic> jsonData) {
    final hands = jsonData['hands'] as List;
    final convertedHands = <HandData>[];

    for (final handData in hands) {
      try {
        final playerDetailsList = handData['playerDetails'] as List;

        // Find user player
        Map<String, dynamic>? userPlayer;
        for (final player in playerDetailsList) {
          if (player['playerInfo']['isUser'] == true ||
              player['playerInfo']['name'] == "あなた") {
            userPlayer = player;
            break;
          }
        }

        if (userPlayer == null) {
          continue;
        }

        // Convert actions
        final actions = <ActionData>[];
        if (userPlayer['detailedActions'] != null) {
          for (final action in userPlayer['detailedActions']) {
            final streetMap = {
              'プリフロップ': 'preflop',
              'フロップ': 'flop',
              'ターン': 'turn',
              'リバー': 'river'
            };

            actions.add(ActionData(
              street:
                  streetMap[action['stage']] ?? action['stage'].toLowerCase(),
              action: action['action'],
              amount: (action['amount'] ?? 0).toDouble(),
            ));
          }
        }

        // Convert opponents
        final opponents = <OpponentData>[];
        for (final player in handData['playerDetails']) {
          if (player['playerInfo']['isUser'] != true &&
              player['playerInfo']['name'] != "あなた") {
            final opponentActions = <ActionData>[];
            if (player['detailedActions'] != null) {
              for (final action in player['detailedActions']) {
                final streetMap = {
                  'プリフロップ': 'preflop',
                  'フロップ': 'flop',
                  'ターン': 'turn',
                  'リバー': 'river'
                };

                opponentActions.add(ActionData(
                  street: streetMap[action['stage']] ??
                      action['stage'].toLowerCase(),
                  action: action['action'],
                  amount: (action['amount'] ?? 0).toDouble(),
                ));
              }
            }

            opponents.add(OpponentData(
              name: player['playerInfo']['name'],
              position: _convertPosition(player['playerInfo']['position']),
              cards: player['handInfo']['holeCards'] != null
                  ? List<String>.from(player['handInfo']['holeCards'])
                  : [],
              totalBet:
                  (player['actionSummary']['totalAmountBet'] ?? 0).toDouble(),
              folded: player['handInfo']['folded'] ?? false,
              actions: opponentActions,
            ));
          }
        }

        // Determine result
        String result = 'loss';
        if (handData['winnerInfo'] != null) {
          final winnerInfo = handData['winnerInfo'] as Map<String, dynamic>;
          if (winnerInfo['winners'] != null) {
            final winners = winnerInfo['winners'] as List;
            bool isWinner = false;

            for (final winner in winners) {
              if (winner['name'] == userPlayer['playerInfo']['name'] ||
                  winner['name'] == "あなた") {
                isWinner = true;
                break;
              }
            }

            if (!isWinner) {
              for (final winner in winners) {
                if (winner['position'] ==
                    userPlayer['playerInfo']['position']) {
                  isWinner = true;
                  break;
                }
              }
            }

            if (!isWinner) {
              for (final winner in winners) {
                if (winner['amountWon'] != null && winner['amountWon'] > 0) {
                  isWinner = true;
                  break;
                }
              }
            }

            result = isWinner ? 'win' : 'loss';
          }
        }

        // Calculate pot size and street pots
        final gameSettings = handData['gameInfo']['gameSettings'];
        final smallBlind = (gameSettings['smallBlind'] ?? 1).toDouble();
        final bigBlind = (gameSettings['bigBlind'] ?? 3).toDouble();
        final ante = (gameSettings['ante'] ?? 0).toDouble();
        final playerCount = gameSettings['playerCount'] ?? 6;

        final streetPots = _calculateStreetPots(
            handData, smallBlind, bigBlind, ante, playerCount);

        double totalPot = smallBlind + bigBlind + (ante * playerCount);
        if (handData['playerDetails'] != null) {
          for (final player in handData['playerDetails']) {
            totalPot +=
                (player['actionSummary']['totalAmountBet'] ?? 0).toDouble();
          }
        }

        final convertedHand = HandData(
          handId: handData['gameInfo']['handNumber'],
          yourCards: userPlayer['handInfo']['holeCards'] != null
              ? List<String>.from(userPlayer['handInfo']['holeCards'])
              : [],
          communityCards: handData['gameStats']['boardCards'] != null
              ? List<String>.from(handData['gameStats']['boardCards'])
              : [],
          position: _convertPosition(userPlayer['playerInfo']['position']),
          actions: actions,
          opponents: opponents,
          result: result,
          potSize: totalPot,
          streetPots: streetPots,
        );

        convertedHands.add(convertedHand);
      } catch (e) {
        continue;
      }
    }

    return convertedHands;
  }

  Map<String, double> _calculateStreetPots(Map<String, dynamic> handData,
      double smallBlind, double bigBlind, double ante, int playerCount) {
    final streetPots = <String, double>{};

    double currentPot = smallBlind + bigBlind + (ante * playerCount);
    streetPots['preflop'] = currentPot;

    if (handData['chronologicalActions'] == null) {
      streetPots['flop'] = currentPot + 15;
      streetPots['turn'] = streetPots['flop']! + 10;
      streetPots['river'] = streetPots['turn']! + 10;
      return streetPots;
    }

    final actions = handData['chronologicalActions'] as List;
    String currentStreet = 'preflop';

    for (final action in actions) {
      final stage = action['stage'];
      final streetMap = {
        'プリフロップ': 'preflop',
        'フロップ': 'flop',
        'ターン': 'turn',
        'リバー': 'river'
      };
      final normalizedStreet = streetMap[stage] ?? stage.toLowerCase();

      if (normalizedStreet != currentStreet) {
        streetPots[normalizedStreet] = currentPot;
        currentStreet = normalizedStreet;
      }

      if (['bet', 'raise', 'call'].contains(action['action']) &&
          action['amount'] != null) {
        currentPot += (action['amount'] ?? 0).toDouble();
      }
    }

    return streetPots;
  }

  String _convertPosition(String position) {
    const positionMap = {
      'UTG': 'under_the_gun',
      'HJ': 'hijack',
      'CO': 'cutoff',
      'BTN': 'button',
      'SB': 'small_blind',
      'BB': 'big_blind'
    };
    return positionMap[position] ?? position.toLowerCase();
  }

  void loadDemoData() {
    _hands = [
      HandData(
        handId: 1,
        yourCards: ['Q♥', '9♥'],
        communityCards: ['8♦', '2♥', 'T♦', '2♣', '4♥'],
        position: 'button',
        actions: [
          ActionData(street: 'preflop', action: 'raise', amount: 9),
          ActionData(street: 'flop', action: 'check', amount: 0),
          ActionData(street: 'turn', action: 'check', amount: 0),
          ActionData(street: 'river', action: 'check', amount: 0),
        ],
        opponents: [
          OpponentData(
            name: 'CPU2',
            position: 'big_blind',
            cards: ['5♣', 'A♠'],
            totalBet: 6,
            folded: false,
            actions: [
              ActionData(street: 'preflop', action: 'call', amount: 6),
              ActionData(street: 'flop', action: 'check', amount: 0),
              ActionData(street: 'turn', action: 'check', amount: 0),
              ActionData(street: 'river', action: 'check', amount: 0),
            ],
          ),
          OpponentData(
            name: 'CPU1',
            position: 'small_blind',
            cards: ['9♣', 'T♣'],
            totalBet: 0,
            folded: true,
            actions: [
              ActionData(street: 'preflop', action: 'fold', amount: 0),
            ],
          ),
          OpponentData(
            name: 'CPU3',
            position: 'under_the_gun',
            cards: [],
            totalBet: 0,
            folded: true,
            actions: [
              ActionData(street: 'preflop', action: 'fold', amount: 0),
            ],
          ),
        ],
        result: 'win',
        potSize: 18,
        streetPots: {'preflop': 4, 'flop': 18, 'turn': 18, 'river': 18},
      ),
      HandData(
        handId: 2,
        yourCards: ['A♥', 'K♦'],
        communityCards: ['A♠', 'K♦', 'J♣'],
        position: 'button',
        actions: [
          ActionData(street: 'preflop', action: 'raise', amount: 100),
          ActionData(street: 'flop', action: 'bet', amount: 150),
        ],
        opponents: [
          OpponentData(
            name: 'CPU1',
            position: 'big_blind',
            cards: ['K♣', 'J♠'],
            totalBet: 200,
            folded: true,
            actions: [
              ActionData(street: 'preflop', action: 'call', amount: 100),
              ActionData(street: 'flop', action: 'fold', amount: 0),
            ],
          ),
        ],
        result: 'win',
        potSize: 800,
      ),
    ];
    _calculateStats();
    notifyListeners();
  }

  void _calculateStats() {
    if (_hands.isEmpty) return;

    int totalHands = _hands.length;
    int wins = _hands.where((h) => h.result == 'win').length;
    double winRate = (wins / totalHands) * 100;
    double totalPots = _hands.fold(0, (sum, h) => sum + h.potSize);
    double avgPot = totalPots / totalHands;
    int preflopRaises = _hands
        .where((h) =>
            h.actions.any((a) => a.street == 'preflop' && a.action == 'raise'))
        .length;
    double aggression = (preflopRaises / totalHands) * 100;

    _stats = GameStats(
      totalHands: totalHands,
      winRate: winRate,
      avgPot: avgPot,
      aggression: aggression,
    );
  }

  GTORecommendation? getGTORecommendation(HandData hand) {
    if (_gtoData.isEmpty || hand.communityCards.length < 3) return null;

    final flop = hand.communityCards.take(3).toList();
    final boardString = _createBoardString(flop);

    GTOData? matchingBoard;
    bool isExactMatch = true;
    double? similarityScore;

    try {
      matchingBoard = _gtoData.firstWhere(
        (gto) => _normalizeBoard(gto.tree) == boardString,
      );
    } catch (e) {
      final similarBoard = _findSimilarBoard(flop);
      if (similarBoard != null) {
        matchingBoard = similarBoard;
        isExactMatch = false;
        final targetPattern = _analyzeBoardPattern(flop);
        final dbBoard = _parseDBBoard(similarBoard.tree);
        if (dbBoard != null) {
          final dbPattern = _analyzeBoardPattern(dbBoard);
          similarityScore = _calculateBoardSimilarity(targetPattern, dbPattern);
        }
      }
    }

    if (matchingBoard == null) return null;

    final actions = {
      'Check': matchingBoard.check,
      'Bet 30%': matchingBoard.bet30,
      'Bet 50%': matchingBoard.bet50,
      'Bet 100%': matchingBoard.bet100,
    };

    String bestAction = 'Check';
    double bestFrequency = matchingBoard.check;

    actions.forEach((action, frequency) {
      if (frequency > bestFrequency) {
        bestAction = action;
        bestFrequency = frequency;
      }
    });

    return GTORecommendation(
      board: flop,
      boardString: boardString,
      equity: matchingBoard.equity,
      ev: matchingBoard.ev,
      bestAction: bestAction,
      bestFrequency: bestFrequency,
      allActions: actions,
      isExactMatch: isExactMatch,
      similarityScore: similarityScore,
    );
  }

  GTOData? _findSimilarBoard(List<String> targetFlop) {
    if (_gtoData.isEmpty) return null;

    final targetPattern = _analyzeBoardPattern(targetFlop);
    GTOData? bestMatch;
    double bestScore = -1;

    for (final row in _gtoData) {
      final dbBoard = _parseDBBoard(row.tree);
      if (dbBoard == null || dbBoard.length < 3) continue;

      final dbPattern = _analyzeBoardPattern(dbBoard);
      final similarity = _calculateBoardSimilarity(targetPattern, dbPattern);

      if (similarity > bestScore) {
        bestScore = similarity;
        bestMatch = row;
      }
    }

    return bestScore >= 0.5 ? bestMatch : null;
  }

  Map<String, dynamic> _analyzeBoardPattern(List<String> cards) {
    if (cards.length < 3) return {};

    final convertedCards = cards.map(_convertCardSuit).toList();
    final ranks = convertedCards.map((card) => card[0]).toList();
    final suits = convertedCards.map((card) => card.substring(1)).toList();

    final rankCounts = <String, int>{};
    for (final rank in ranks) {
      rankCounts[rank] = (rankCounts[rank] ?? 0) + 1;
    }

    final hasPair = rankCounts.values.any((count) => count >= 2);
    final hasTrips = rankCounts.values.any((count) => count >= 3);

    final suitCounts = <String, int>{};
    for (final suit in suits) {
      suitCounts[suit] = (suitCounts[suit] ?? 0) + 1;
    }

    final flushDraws = suitCounts.values.where((count) => count >= 2).length;
    final rainbow = suitCounts.keys.length == 3;

    const rankOrder = 'AKQJT98765432';
    final rankValues = ranks.map((rank) => rankOrder.indexOf(rank)).toList()
      ..sort();

    final gaps = [
      rankValues[1] - rankValues[0],
      rankValues[2] - rankValues[1],
    ];

    final straightDraw =
        gaps.every((gap) => gap <= 4) && (rankValues[2] - rankValues[0]) <= 4;
    final connectedBoard = gaps.every((gap) => gap <= 2);

    final highCardCount =
        ranks.where((rank) => ['A', 'K', 'Q', 'J'].contains(rank)).length;
    final lowBoard =
        ranks.every((rank) => !['A', 'K', 'Q', 'J', 'T'].contains(rank));

    return {
      'hasPair': hasPair,
      'hasTrips': hasTrips,
      'flushDraws': flushDraws,
      'rainbow': rainbow,
      'straightDraw': straightDraw,
      'connectedBoard': connectedBoard,
      'highCardCount': highCardCount,
      'lowBoard': lowBoard,
      'rankStructure': rankCounts.values.toList()
        ..sort((a, b) => b.compareTo(a)),
      'suitStructure': suitCounts.values.toList()
        ..sort((a, b) => b.compareTo(a)),
    };
  }

  double _calculateBoardSimilarity(
      Map<String, dynamic> pattern1, Map<String, dynamic> pattern2) {
    if (pattern1.isEmpty || pattern2.isEmpty) return 0;

    double score = 0;
    double totalWeight = 0;

    const weight1 = 0.25;
    if (pattern1['hasPair'] == pattern2['hasPair']) score += weight1;
    if (pattern1['hasTrips'] == pattern2['hasTrips']) score += weight1;
    totalWeight += weight1 * 2;

    const weight2 = 0.2;
    if (pattern1['flushDraws'] == pattern2['flushDraws']) score += weight2;
    if (pattern1['rainbow'] == pattern2['rainbow']) score += weight2;
    totalWeight += weight2 * 2;

    const weight3 = 0.15;
    if (pattern1['straightDraw'] == pattern2['straightDraw']) score += weight3;
    if (pattern1['connectedBoard'] == pattern2['connectedBoard'])
      score += weight3;
    totalWeight += weight3 * 2;

    const weight4 = 0.1;
    final highCardDiff =
        (pattern1['highCardCount'] as int) - (pattern2['highCardCount'] as int);
    if (highCardDiff.abs() <= 1) score += weight4;
    if (pattern1['lowBoard'] == pattern2['lowBoard']) score += weight4;
    totalWeight += weight4 * 2;

    const weight5 = 0.1;
    final rank1 = pattern1['rankStructure'] as List<int>;
    final rank2 = pattern2['rankStructure'] as List<int>;
    if (rank1.toString() == rank2.toString()) score += weight5;
    totalWeight += weight5;

    return totalWeight > 0 ? score / totalWeight : 0;
  }

  List<String>? _parseDBBoard(String treeString) {
    if (treeString.length < 6) return null;

    final cards = <String>[];
    for (int i = 0; i < 6; i += 2) {
      if (i + 1 < treeString.length) {
        final rank = treeString[i];
        final suit = treeString[i + 1];
        cards.add(rank + suit);
      }
    }
    return cards;
  }

  String _createBoardString(List<String> cards) {
    if (cards.length < 3) return '';

    final normalizedCards = cards.map((card) {
      final convertedCard = _convertCardSuit(card);
      return convertedCard[0] + convertedCard.substring(1).toLowerCase();
    }).toList();

    normalizedCards.sort((a, b) {
      const rankOrder = 'AKQJT98765432';
      return rankOrder.indexOf(a[0]) - rankOrder.indexOf(b[0]);
    });

    return normalizedCards.join('');
  }

  String _normalizeBoard(String treeString) {
    if (treeString.length < 6) return '';

    final cards = <String>[];
    for (int i = 0; i < 6; i += 2) {
      if (i + 1 < treeString.length) {
        cards.add(treeString[i] + treeString[i + 1].toLowerCase());
      }
    }

    cards.sort((a, b) {
      const rankOrder = 'AKQJT98765432';
      return rankOrder.indexOf(a[0]) - rankOrder.indexOf(b[0]);
    });

    return cards.join('');
  }

  double? getStreetStartPot(HandData hand, String street) {
    if (hand.streetPots != null && hand.streetPots!.containsKey(street)) {
      return hand.streetPots![street];
    }

    if (hand.actions != null) {
      double calculatedPot = 0;
      for (final action in hand.actions!) {
        if (action.street == street) {
          calculatedPot += action.amount;
        }
      }
      if (calculatedPot > 0) {
        return calculatedPot;
      }
    }

    final basePot = hand.potSize * 0.3;
    return basePot;
  }

  String _analyzeBetAction(ActionData action, HandData hand, String street) {
    final streetStartPot = getStreetStartPot(hand, street);
    if (streetStartPot == null) {
      return 'check';
    }

    if (action.amount == 0 || action.amount.isNaN) {
      return 'check';
    }

    final betPercentage = (action.amount / streetStartPot) * 100;

    if (betPercentage < 25) {
      return 'min-raise';
    } else if (betPercentage < 50) {
      return 'small-bet';
    } else if (betPercentage < 100) {
      return 'medium-bet';
    } else {
      return 'large-bet';
    }
  }

  String _analyzeAction(ActionData action, HandData hand) {
    switch (action.action.toLowerCase()) {
      case 'fold':
        return 'fold';
      case 'check':
        return 'check';
      case 'call':
        return 'call';
      case 'raise':
      case 'bet':
        return _analyzeBetAction(action, hand, action.street);
      default:
        return 'check';
    }
  }

  String _convertCardSuit(String card) {
    if (card.length < 2) return card;
    const suitMap = {
      '♠': 's',
      '♣': 'c',
      '♥': 'h',
      '♦': 'd',
      's': 's',
      'c': 'c',
      'h': 'h',
      'd': 'd'
    };
    final rank = card[0].toUpperCase();
    final lastChar = card.substring(card.length - 1);
    final suit = suitMap[lastChar] ?? lastChar;
    return rank + suit;
  }

  List<String> _generateAllHands() {
    const ranks = [
      'A',
      'K',
      'Q',
      'J',
      'T',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2'
    ];
    final hands = <String>[];

    for (int i = 0; i < ranks.length; i++) {
      for (int j = 0; j < ranks.length; j++) {
        if (i == j) {
          hands.add(ranks[i] + ranks[j]);
        } else if (i < j) {
          hands.add(ranks[i] + ranks[j] + 's');
        } else {
          hands.add(ranks[j] + ranks[i] + 'o');
        }
      }
    }

    return hands;
  }

  Map<String, List<String>> getOptimalRange(String position) {
    final result = {
      'raise': <String>[],
      'raiseOrCall': <String>[],
      'raiseOrFold': <String>[],
      'call': <String>[],
    };

    final rows = _rangeData.where((row) => row.position == position).toList();

    for (final row in rows) {
      if (row.hands.isNotEmpty) {
        final hands = row.hands
            .split(',')
            .map((h) => h.trim().replaceAll('"', ''))
            .where((h) => h.isNotEmpty)
            .toList();

        switch (row.color) {
          case 'red':
            result['raise']!.addAll(hands);
            break;
          case 'yellow':
            result['raiseOrCall']!.addAll(hands);
            break;
          case 'blue':
            result['raiseOrFold']!.addAll(hands);
            break;
          case 'green':
            result['call']!.addAll(hands);
            break;
        }
      }
    }

    return result;
  }

  void clearData() {
    _hands = [];
    _stats = null;
    notifyListeners();
  }

  String normalizeHand(List<String> cards) {
    if (cards.length != 2) return '';

    final convertedCards = cards.map(_convertCardSuit).toList();
    String r1 = convertedCards[0][0].toUpperCase();
    String s1 = convertedCards[0].substring(1);
    String r2 = convertedCards[1][0].toUpperCase();
    String s2 = convertedCards[1].substring(1);

    const rankOrder = [
      'A',
      'K',
      'Q',
      'J',
      'T',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2'
    ];
    final r1Index = rankOrder.indexOf(r1);
    final r2Index = rankOrder.indexOf(r2);

    if (r1Index > r2Index) {
      final temp = r1;
      r1 = r2;
      r2 = temp;
      final tempS = s1;
      s1 = s2;
      s2 = tempS;
    }

    if (r1 == r2) return r1 + r2;
    if (s1 == s2) return r1 + r2 + 's';
    return r1 + r2 + 'o';
  }

  Map<String, List<String>> getlRange(String position) {
    final result = {
      'raise': <String>[],
      'raiseOrCall': <String>[],
      'raiseOrFold': <String>[],
      'call': <String>[],
    };

    final rows = _rangeData.where((row) => row.position == position).toList();

    for (final row in rows) {
      if (row.hands.isNotEmpty) {
        final hands = row.hands
            .split(',')
            .map((h) => h.trim().replaceAll('"', ''))
            .where((h) => h.isNotEmpty)
            .toList();

        switch (row.color) {
          case 'red':
            result['raise']!.addAll(hands);
            break;
          case 'yellow':
            result['raiseOrCall']!.addAll(hands);
            break;
          case 'blue':
            result['raiseOrFold']!.addAll(hands);
            break;
          case 'green':
            result['call']!.addAll(hands);
            break;
        }
      }
    }

    return result;
  }

  List<String> generateAllHands() {
    const ranks = [
      'A',
      'K',
      'Q',
      'J',
      'T',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2'
    ];
    final hands = <String>[];

    for (int i = 0; i < ranks.length; i++) {
      for (int j = 0; j < ranks.length; j++) {
        if (i == j) {
          hands.add(ranks[i] + ranks[j]);
        } else if (i < j) {
          hands.add(ranks[i] + ranks[j] + 's');
        } else {
          hands.add(ranks[j] + ranks[i] + 'o');
        }
      }
    }

    return hands;
  }

  Future<void> loadCsvAssets() async {
    try {
      // Load BTNBB.csv
      final btnbbContent = await rootBundle.loadString('assets/BTNBB.csv');
      final btnbbRows = const CsvToListConverter().convert(btnbbContent);
      _gtoData = btnbbRows.skip(1).map((row) => GTOData.fromCsv(row)).toList();

      // Load hands.csv
      final handsContent = await rootBundle.loadString('assets/hands.csv');
      final handsRows = const CsvToListConverter().convert(handsContent);
      _rangeData = handsRows
          .skip(1)
          .where((row) =>
              row.length >= 6 &&
              row[0].toString().isNotEmpty &&
              row[4].toString().isNotEmpty)
          .map((row) => HandRangeData.fromCsv(row))
          .toList();
    } catch (e) {
      debugPrint('Error loading CSV assets: $e');
    }
  }
}
