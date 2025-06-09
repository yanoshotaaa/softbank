// pubspec.yaml dependencies needed:
/*
name: poker_analyzer
description: Texas Hold'em Hand Analysis Flutter App

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  file_picker: ^6.1.1
  csv: ^5.0.2
  json_annotation: ^4.8.1
  provider: ^6.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';

// Main App
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PokerAnalysisProvider(),
      child: MaterialApp(
        title: 'テキサスホールデム ハンド分析AI',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: const Color(0xFF0f4c3a),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        home: const PokerAnalysisScreen(),
      ),
    );
  }
}

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
          .toList() ?? [],
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

  OpponentData({
    required this.name,
    required this.position,
    required this.cards,
    required this.totalBet,
    required this.folded,
  });

  factory OpponentData.fromJson(Map<String, dynamic> json) {
    return OpponentData(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      cards: List<String>.from(json['cards'] ?? []),
      totalBet: (json['total_bet'] ?? 0).toDouble(),
      folded: json['folded'] ?? false,
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

  GTORecommendation({
    required this.board,
    required this.boardString,
    required this.equity,
    required this.ev,
    required this.bestAction,
    required this.bestFrequency,
    required this.allActions,
    required this.isExactMatch,
  });
}

// Provider for state management
class PokerAnalysisProvider extends ChangeNotifier {
  List<HandData> _hands = [];
  GameStats? _stats;
  bool _isLoading = false;
  List<GTOData> _gtoData = [];
  List<HandRangeData> _rangeData = [];

  List<HandData> get hands => _hands;
  GameStats? get stats => _stats;
  bool get isLoading => _isLoading;
  List<GTOData> get gtoData => _gtoData;
  List<HandRangeData> get rangeData => _rangeData;

  Future<void> loadCsvAssets() async {
    try {
      // Load BTNBB.csv
      final btnbbContent = await rootBundle.loadString('assets/BTNBB.csv');
      final btnbbRows = const CsvToListConverter().convert(btnbbContent);
      _gtoData = btnbbRows.skip(1).map((row) => GTOData.fromCsv(row)).toList();

      // Load hands.csv
      final handsContent = await rootBundle.loadString('assets/hands.csv');
      final handsRows = const CsvToListConverter().convert(handsContent);
      _rangeData = handsRows.skip(1)
          .where((row) => row.length >= 6 && row[0].toString().isNotEmpty && row[4].toString().isNotEmpty)
          .map((row) => HandRangeData.fromCsv(row))
          .toList();

      print('Loaded ${_gtoData.length} GTO entries and ${_rangeData.length} range entries');
    } catch (e) {
      print('Error loading CSV assets: $e');
    }
  }

  Future<void> loadJsonFile() async {
    try {
      _isLoading = true;
      notifyListeners();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> jsonData = json.decode(content);
        
        // Check for different JSON formats
        if (jsonData['hands'] != null && jsonData['hands'] is List) {
          // Check if it's the detailed history format
          final hands = jsonData['hands'] as List;
          if (hands.isNotEmpty && hands[0]['gameInfo'] != null) {
            // Detailed history format
            _hands = _convertDetailedHistoryFormat(jsonData);
          } else if (hands.isNotEmpty && hands[0]['hand_id'] != null) {
            // Standard analysis format
            _hands = hands.map((handJson) => HandData.fromJson(handJson)).toList();
          } else {
            throw Exception('未知のJSONフォーマットです。');
          }
          _calculateStats();
        } else {
          throw Exception('有効なハンドデータが見つかりません。');
        }
      }
    } catch (e) {
      print('Error loading file: $e');
      // Show error to user
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<HandData> _convertDetailedHistoryFormat(Map<String, dynamic> data) {
    final convertedHands = <HandData>[];
    
    if (data['hands'] == null) return convertedHands;
    
    for (final handData in data['hands']) {
      try {
        // Find user player
        final userPlayer = (handData['playerDetails'] as List).firstWhere(
          (p) => p['playerInfo']['isUser'] == true || p['playerInfo']['name'] == "あなた",
          orElse: () => null,
        );
        
        if (userPlayer == null) {
          print('ユーザープレイヤーが見つかりません: ハンド ${handData['gameInfo']['handNumber']}');
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
              street: streetMap[action['stage']] ?? action['stage'].toLowerCase(),
              action: action['action'],
              amount: (action['amount'] ?? 0).toDouble(),
            ));
          }
        }

        // Convert opponents
        final opponents = <OpponentData>[];
        for (final player in handData['playerDetails']) {
          if (player['playerInfo']['isUser'] != true && player['playerInfo']['name'] != "あなた") {
            opponents.add(OpponentData(
              name: player['playerInfo']['name'],
              position: _convertPosition(player['playerInfo']['position']),
              cards: player['handInfo']['holeCards'] != null 
                  ? List<String>.from(player['handInfo']['holeCards'])
                  : [],
              totalBet: (player['actionSummary']['totalAmountBet'] ?? 0).toDouble(),
              folded: player['handInfo']['folded'] ?? false,
            ));
          }
        }

        // Determine result
        String result = 'loss';
        if (handData['winnerInfo'] != null && handData['winnerInfo']['winners'] != null) {
          final winners = handData['winnerInfo']['winners'] as List;
          final isWinner = winners.any((w) => 
            w['name'] == userPlayer['playerInfo']['name'] || 
            (userPlayer['playerInfo']['isUser'] == true)
          );
          result = isWinner ? 'win' : 'loss';
        }

        // Calculate pot size and street pots
        final gameSettings = handData['gameInfo']['gameSettings'];
        final smallBlind = (gameSettings['smallBlind'] ?? 1).toDouble();
        final bigBlind = (gameSettings['bigBlind'] ?? 3).toDouble();
        final ante = (gameSettings['ante'] ?? 0).toDouble();
        final playerCount = gameSettings['playerCount'] ?? 6;
        
        // Calculate street start pots from chronological actions
        final streetPots = _calculateStreetPots(handData, smallBlind, bigBlind, ante, playerCount);
        
        // Calculate total pot
        double totalPot = smallBlind + bigBlind + (ante * playerCount);
        if (handData['playerDetails'] != null) {
          for (final player in handData['playerDetails']) {
            totalPot += (player['actionSummary']['totalAmountBet'] ?? 0).toDouble();
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
        print('ハンド変換エラー: $e');
        continue;
      }
    }

    return convertedHands;
  }

  Map<String, double> _calculateStreetPots(Map<String, dynamic> handData, 
      double smallBlind, double bigBlind, double ante, int playerCount) {
    
    final streetPots = <String, double>{};
    
    // Initial pot (blinds + antes)
    double currentPot = smallBlind + bigBlind + (ante * playerCount);
    streetPots['preflop'] = currentPot;

    if (handData['chronologicalActions'] == null) {
      // Fallback calculation
      streetPots['flop'] = currentPot + 15; // Estimate
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
      
      // If we've moved to a new street, record the pot size
      if (normalizedStreet != currentStreet) {
        streetPots[normalizedStreet] = currentPot;
        currentStreet = normalizedStreet;
      }
      
      // Add bet amount to current pot
      if (['bet', 'raise', 'call'].contains(action['action']) && action['amount'] != null) {
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
          ),
          OpponentData(
            name: 'CPU1',
            position: 'small_blind', 
            cards: ['9♣', 'T♣'],
            totalBet: 0,
            folded: true,
          ),
        ],
        result: 'win',
        potSize: 18,
        streetPots: {
          'preflop': 4,
          'flop': 18,
          'turn': 18,
          'river': 18
        },
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
    int preflopRaises = _hands.where((h) => 
        h.actions.any((a) => a.street == 'preflop' && a.action == 'raise')
    ).length;
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
    
    // Find exact match first
    GTOData? matchingBoard;
    try {
      matchingBoard = _gtoData.firstWhere(
        (gto) => _normalizeBoard(gto.tree) == boardString,
      );
    } catch (e) {
      return null;
    }

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
      isExactMatch: true,
    );
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

  String _convertCardSuit(String card) {
    if (card.length < 2) return card;
    const suitMap = {
      '♠': 's', '♣': 'c', '♥': 'h', '♦': 'd',
      's': 's', 'c': 'c', 'h': 'h', 'd': 'd'
    };
    final rank = card[0].toUpperCase();
    final lastChar = card.substring(card.length - 1);
    final suit = suitMap[lastChar] ?? lastChar;
    return rank + suit;
  }

  List<String> _generateAllHands() {
    const ranks = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];
    final hands = <String>[];
    
    for (int i = 0; i < ranks.length; i++) {
      for (int j = 0; j < ranks.length; j++) {
        if (i == j) {
          hands.add(ranks[i] + ranks[j]); // pocket pairs
        } else if (i < j) {
          hands.add(ranks[i] + ranks[j] + 's'); // suited
        } else {
          hands.add(ranks[j] + ranks[i] + 'o'); // offsuit
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
        final hands = row.hands.split(',').map((h) => h.trim().replaceAll('"', '')).where((h) => h.isNotEmpty).toList();
        
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

    const rankOrder = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];
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
        final hands = row.hands.split(',')
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
    const ranks = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];
    final hands = <String>[];
    
    for (int i = 0; i < ranks.length; i++) {
      for (int j = 0; j < ranks.length; j++) {
        if (i == j) {
          hands.add(ranks[i] + ranks[j]); // pocket pairs
        } else if (i < j) {
          hands.add(ranks[i] + ranks[j] + 's'); // suited
        } else {
          hands.add(ranks[j] + ranks[i] + 'o'); // offsuit
        }
      }
    }
    
    return hands;
  }
}

// Main Screen
class PokerAnalysisScreen extends StatelessWidget {
  const PokerAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load CSV data when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokerAnalysisProvider>().loadCsvAssets();
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f4c3a), Color(0xFF1e6b5a)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildUploadSection(context),
                const SizedBox(height: 30),
                Consumer<PokerAnalysisProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return _buildLoadingSection();
                    } else if (provider.hands.isNotEmpty) {
                      return _buildAnalysisSection(provider);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            '🃏 テキサスホールデム\nハンド分析AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'プレイデータを分析して、戦略的なフィードバックを提供します',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '📁 ハンドデータをアップロード',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'JSONファイルを選択してください',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  '📎 ファイルを選択',
                  Colors.amber,
                  () => context.read<PokerAnalysisProvider>().loadJsonFile(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  '🎮 デモデータで試す',
                  Colors.green,
                  () => context.read<PokerAnalysisProvider>().loadDemoData(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildJsonFormatInfo(),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildJsonFormatInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '期待されるJSONフォーマット:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '''【サポートされるJSONフォーマット】

1. 分析用フォーマット:
{
  "hands": [
    {
      "hand_id": 1,
      "your_cards": ["Ah", "Kd"],
      "community_cards": ["Qh", "Jc", "10s"],
      "position": "button",
      "actions": [
        {"street": "preflop", "action": "raise", "amount": 100}
      ],
      "result": "win",
      "pot_size": 800
    }
  ]
}

2. 詳細履歴フォーマット（ゲームアプリ出力）:
{
  "metadata": {...},
  "hands": [
    {
      "gameInfo": {...},
      "playerDetails": [...],
      "gameStats": {...}
    }
  ]
}''',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Courier',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Colors.amber),
          SizedBox(height: 20),
          Text(
            '分析中...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(PokerAnalysisProvider provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 分析結果',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (provider.stats != null) _buildStatsGrid(provider.stats!),
              const SizedBox(height: 30),
              _buildHandsList(provider.hands, provider),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (provider.rangeData.isNotEmpty) _buildHandRangeAnalysisSection(provider),
        const SizedBox(height: 20),
        if (provider.gtoData.isNotEmpty) _buildGTOAnalysisSection(provider),
      ],
    );
  }

  Widget _buildStatsGrid(GameStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard('総ハンド数', stats.totalHands.toString()),
            _buildStatCard('勝率', '${stats.winRate.toStringAsFixed(1)}%'),
            _buildStatCard('平均ポット', stats.avgPot.toStringAsFixed(0)),
            _buildStatCard('攻撃性', '${stats.aggression.toStringAsFixed(1)}%'),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHandsList(List<HandData> hands, PokerAnalysisProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 詳細ハンド分析',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hands.length,
          itemBuilder: (context, index) {
            return _buildHandCard(hands[index], provider);
          },
        ),
      ],
    );
  }

  Widget _buildHandCard(HandData hand, PokerAnalysisProvider provider) {
    final gtoRecommendation = provider.getGTORecommendation(hand);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Colors.amber, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ハンド #${hand.handId}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Text(
                hand.result == 'win' ? '勝利' : '敗北',
                style: TextStyle(
                  color: hand.result == 'win' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'ポジション: ${_translatePosition(hand.position)}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'ホールカード:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          _buildCardsRow(hand.yourCards),
          const SizedBox(height: 10),
          const Text(
            'コミュニティカード:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          _buildCardsRow(hand.communityCards),
          const SizedBox(height: 15),
          const Text(
            'アクション:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          _buildActionsRow(hand.actions),
          const SizedBox(height: 15),
          _buildFeedbackSection(hand),
          if (gtoRecommendation != null) ...[
            const SizedBox(height: 15),
            _buildGTORecommendationCard(hand, gtoRecommendation),
          ],
        ],
      ),
    );
  }

  Widget _buildCardsRow(List<String> cards) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cards.map((card) => _buildPlayingCard(card)).toList(),
    );
  }

  Widget _buildPlayingCard(String card) {
    bool isRed = card.contains('♥') || card.contains('♦') || 
                 card.contains('h') || card.contains('d');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        card,
        style: TextStyle(
          color: isRed ? Colors.red : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildActionsRow(List<ActionData> actions) {
    return Wrap(
      spacing: 8,
      runSpacing: 5,
      children: actions.map((action) => _buildActionChip(action)).toList(),
    );
  }

  Widget _buildActionChip(ActionData action) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${action.street}: ${action.action}${action.amount > 0 ? ' ${action.amount.toInt()}' : ''}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(HandData hand) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
        border: const Border(
          left: BorderSide(color: Colors.green, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🤖 AI フィードバック',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _generateFeedback(hand),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGTOAnalysisSection(PokerAnalysisProvider provider) {
    final applicableHands = provider.hands.where((hand) => 
      hand.position.toLowerCase() == 'button' && 
      hand.communityCards.length >= 3 &&
      hand.actions.any((a) => a.street == 'flop')
    ).toList();

    if (applicableHands.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          children: [
            Text(
              '🧠 GTO戦略分析',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'BTNポジションでフロップをプレイしたハンドがないため、GTO分析は利用できません。',
              style: TextStyle(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    int gtoOptimalCount = 0;
    int totalAnalyzed = 0;

    for (final hand in applicableHands) {
      final gtoRec = provider.getGTORecommendation(hand);
      if (gtoRec != null) {
        totalAnalyzed++;
        try {
          final flopAction = hand.actions.firstWhere(
            (a) => a.street == 'flop',
          );
          final actualAction = _translateActionToGTO(flopAction, hand);
          if (actualAction == gtoRec.bestAction) {
            gtoOptimalCount++;
          }
        } catch (e) {
          // No flop action found
        }
      }
    }

    final gtoCompliance = totalAnalyzed > 0 ? (gtoOptimalCount / totalAnalyzed) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧠 GTO戦略分析（BTN vs BB フロップ）',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '分析対象ハンド:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '$totalAnalyzed',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GTO最適プレイ:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '$gtoOptimalCount (${gtoCompliance.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: gtoCompliance >= 70 ? Colors.green : 
                               gtoCompliance >= 50 ? Colors.orange : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildGTOPerformanceIndicator(gtoCompliance),
        ],
      ),
    );
  }

  Widget _buildGTOPerformanceIndicator(double compliance) {
    Color indicatorColor;
    String performanceText;
    
    if (compliance >= 80) {
      indicatorColor = Colors.green;
      performanceText = '🏆 優秀: GTO理論に非常に近いプレイができています！';
    } else if (compliance >= 60) {
      indicatorColor = Colors.orange;
      performanceText = '📈 良好: 概ねGTOに沿ったプレイです。さらなる向上の余地があります。';
    } else {
      indicatorColor = Colors.red;
      performanceText = '⚠️ 要改善: GTO理論との乖離が大きいです。戦略の見直しをお勧めします。';
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: indicatorColor, width: 4)),
      ),
      child: Text(
        performanceText,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildGTORecommendationCard(HandData hand, GTORecommendation gtoRec) {
    ActionData? flopAction;
    try {
      flopAction = hand.actions.firstWhere((a) => a.street == 'flop');
    } catch (e) {
      flopAction = ActionData(street: 'flop', action: 'check', amount: 0);
    }
    
    final actualAction = _translateActionToGTO(flopAction, hand);
    final isOptimal = actualAction == gtoRec.bestAction;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: Colors.purple, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧠 GTO分析',
            style: TextStyle(
              color: Colors.purple.shade200,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'エクイティ: ${gtoRec.equity.toStringAsFixed(1)}% | EV: ${gtoRec.ev.toStringAsFixed(1)}',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'GTO推奨: ',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '${gtoRec.bestAction} (${gtoRec.bestFrequency.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOptimal ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                const Text(
                  '実際のアクション: ',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  actualAction,
                  style: TextStyle(
                    color: isOptimal ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isOptimal ? '✅ GTO最適' : '⚠️ GTO非最適',
                  style: TextStyle(
                    color: isOptimal ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'アクション頻度:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 8,
            runSpacing: 5,
            children: gtoRec.allActions.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _translateActionToGTO(ActionData action, HandData hand) {
    if (action.action == 'check') return 'Check';
    if (action.action == 'bet') {
      if (action.amount == 0) return 'Bet 30%';
      
      // Calculate pot ratio based on street start pot
      double streetStartPot = hand.streetPots?['flop'] ?? _calculateFlopStartPot(hand);
      double betRatio = (action.amount / streetStartPot) * 100;
      
      if (betRatio >= 75) return 'Bet 100%';
      if (betRatio >= 40) return 'Bet 50%';
      return 'Bet 30%';
    }
    if (action.action == 'call') return 'Check';
    if (action.action == 'fold') return 'Check';
    
    return 'Check';
  }

  double _calculateFlopStartPot(HandData hand) {
    // Simple calculation - in reality this would be more complex
    double initialPot = 15; // SB + BB estimate
    
    // Add preflop bets
    for (final action in hand.actions) {
      if (action.street == 'preflop' && 
          ['bet', 'raise', 'call'].contains(action.action)) {
        initialPot += action.amount;
      }
    }
    
    return initialPot;
  }

  String _translatePosition(String position) {
    const positions = {
      'button': 'ボタン',
      'small_blind': 'スモールブラインド',
      'big_blind': 'ビッグブラインド',
      'under_the_gun': 'アンダーザガン',
      'middle_position': 'ミドルポジション',
      'late_position': 'レイトポジション',
      'hijack': 'ハイジャック',
      'cutoff': 'カットオフ',
    };
    return positions[position.toLowerCase()] ?? position;
  }

  String _generateFeedback(HandData hand) {
    // Simple feedback generation
    String handStrength = _evaluateHandStrength(hand.yourCards);
    String positionAdvice = hand.position == 'button' 
        ? 'レイトポジションの利点を活かせています。'
        : 'ポジションを考慮したプレイを心がけましょう。';
    
    String resultFeedback = hand.result == 'win' 
        ? '良いプレイで勝利を収めました！' 
        : '次回はより戦略的なアプローチを検討してみてください。';
    
    return '$handStrength $positionAdvice $resultFeedback';
  }

  String _evaluateHandStrength(List<String> cards) {
    if (cards.length != 2) return '不明なハンド';
    
    // Extract ranks (simplified)
    String rank1 = cards[0][0];
    String rank2 = cards[1][0];
    
    if (rank1 == rank2) {
      if (['A', 'K', 'Q', 'J'].contains(rank1)) {
        return 'プレミアムペア（非常に強い）';
      } else {
        return 'ポケットペア（強い）';
      }
    } else if (['A', 'K', 'Q', 'J'].contains(rank1) || 
               ['A', 'K', 'Q', 'J'].contains(rank2)) {
      return 'ハイカード（中程度）';
    } else {
      return '弱いハンド';
    }
  }

  // Hand Range Analysis Section
  Widget _buildHandRangeAnalysisSection(PokerAnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 プリフロップハンドレンジ分析',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          _buildPositionRangeAnalysis(provider),
        ],
      ),
    );
  }

  Widget _buildPositionRangeAnalysis(PokerAnalysisProvider provider) {
    const positions = ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'];
    
    return Column(
      children: positions.map((position) {
        final positionHands = provider.hands.where((h) => 
          _translatePositionToShort(h.position) == position
        ).toList();
        
        if (positionHands.isEmpty) return const SizedBox.shrink();
        
        return _buildPositionCard(position, positionHands, provider);
      }).toList(),
    );
  }

  Widget _buildPositionCard(String position, List<HandData> hands, PokerAnalysisProvider provider) {
    final playedHands = hands.map((h) => provider.normalizeHand(h.yourCards)).where((h) => h.isNotEmpty).toList();
    final optimalRange = provider.getOptimalRange(position);
    
    final allRecommendedHands = [
      ...optimalRange['raise']!,
      ...optimalRange['raiseOrCall']!,
      ...optimalRange['raiseOrFold']!,
      ...optimalRange['call']!,
    ];

    final inRange = playedHands.where((hand) => allRecommendedHands.contains(hand)).length;
    final tooLoose = playedHands.where((hand) => !allRecommendedHands.contains(hand)).length;
    final rangeCompliance = playedHands.isNotEmpty ? ((inRange / playedHands.length) * 100).toStringAsFixed(1) : '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: Colors.blue, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$position (${_translatePosition(position.toLowerCase())})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRangeStat('プレイハンド数', '${playedHands.length}'),
              _buildRangeStat('レンジ適合率', '$rangeCompliance%'),
              _buildRangeStat('レンジ外プレイ', '$tooLoose'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Range Grid
          _buildRangeGrid(optimalRange, playedHands, provider),
          
          const SizedBox(height: 15),
          
          // Legend
          _buildRangeLegend(),
        ],
      ),
    );
  }

  Widget _buildRangeStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeGrid(Map<String, List<String>> optimalRange, List<String> playedHands, PokerAnalysisProvider provider) {
    final allHands = provider.generateAllHands();
    final playedSet = playedHands.toSet();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 13,
          childAspectRatio: 1,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: allHands.length,
        itemBuilder: (context, index) {
          final hand = allHands[index];
          return _buildRangeCell(hand, optimalRange, playedSet.contains(hand));
        },
      ),
    );
  }

  Widget _buildRangeCell(String hand, Map<String, List<String>> optimalRange, bool isPlayed) {
    Color backgroundColor = Colors.white.withOpacity(0.1); // default: fold
    
    if (optimalRange['raise']!.contains(hand)) {
      backgroundColor = Colors.red;
    } else if (optimalRange['raiseOrCall']!.contains(hand)) {
      backgroundColor = Colors.yellow;
    } else if (optimalRange['raiseOrFold']!.contains(hand)) {
      backgroundColor = Colors.blue;
    } else if (optimalRange['call']!.contains(hand)) {
      backgroundColor = Colors.green;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(3),
        border: isPlayed ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Center(
        child: Text(
          hand,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: backgroundColor == Colors.yellow ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRangeLegend() {
    return Wrap(
      spacing: 10,
      runSpacing: 5,
      children: [
        _buildLegendItem(Colors.red, 'レイズ'),
        _buildLegendItem(Colors.yellow, 'レイズかコール'),
        _buildLegendItem(Colors.blue, 'レイズかフォールド'),
        _buildLegendItem(Colors.green, 'コール'),
        _buildLegendItem(Colors.white.withOpacity(0.1), 'フォールド'),
        _buildLegendItem(Colors.transparent, '実際にプレイ', border: Colors.amber),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, {Color? border}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: border != null ? Border.all(color: border, width: 2) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  List<String> _generateAllHands() {
    const ranks = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];
    final hands = <String>[];
    
    for (int i = 0; i < ranks.length; i++) {
      for (int j = 0; j < ranks.length; j++) {
        if (i == j) {
          hands.add(ranks[i] + ranks[j]); // pocket pairs
        } else if (i < j) {
          hands.add(ranks[i] + ranks[j] + 's'); // suited
        } else {
          hands.add(ranks[j] + ranks[i] + 'o'); // offsuit
        }
      }
    }
    
    return hands;
  }

  String _translatePositionToShort(String position) {
    const map = {
      'under_the_gun': 'UTG',
      'hijack': 'HJ',
      'cutoff': 'CO',
      'button': 'BTN',
      'small_blind': 'SB',
      'big_blind': 'BB',
      'utg': 'UTG',
      'hj': 'HJ',
      'co': 'CO',
      'btn': 'BTN',
      'sb': 'SB',
      'bb': 'BB'
    };
    return map[position.toLowerCase()] ?? position.toUpperCase();
  }
}