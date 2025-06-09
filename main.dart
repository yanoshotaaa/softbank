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
  final List<ActionData>? actions; // アクション情報を追加

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

      if (result != null && result.files.single.bytes != null) {
        Uint8List fileBytes = result.files.single.bytes!;
        String content = utf8.decode(fileBytes);      
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
        print('=== ハンド変換開始 ===');
        print('handNumber: ${handData['gameInfo']['handNumber']}');
        
        // Find user player with detailed logging
        final playerDetailsList = handData['playerDetails'] as List;
        print('全プレイヤー数: ${playerDetailsList.length}');
        
        for (int i = 0; i < playerDetailsList.length; i++) {
          final player = playerDetailsList[i];
          print('プレイヤー$i: 名前=${player['playerInfo']['name']}, isUser=${player['playerInfo']['isUser']}');
        }
        
        final userPlayerList = playerDetailsList.where(
          (p) => p['playerInfo']['isUser'] == true || p['playerInfo']['name'] == "あなた"
        ).toList();
        
        if (userPlayerList.isEmpty) {
          print('ユーザープレイヤーが見つかりません: ハンド ${handData['gameInfo']['handNumber']}');
          continue;
        }
        
        final userPlayer = userPlayerList.first;
        print('ユーザープレイヤー特定成功: ${userPlayer['playerInfo']['name']}');

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
            // 相手のアクション情報も変換
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
                  street: streetMap[action['stage']] ?? action['stage'].toLowerCase(),
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
              totalBet: (player['actionSummary']['totalAmountBet'] ?? 0).toDouble(),
              folded: player['handInfo']['folded'] ?? false,
              actions: opponentActions,
            ));
          }
        }

        // Determine result with detailed logging
        String result = 'loss';
        print('=== 勝敗判定デバッグ ===');
        print('ユーザープレイヤー名: ${userPlayer['playerInfo']['name']}');
        print('ユーザーisUser: ${userPlayer['playerInfo']['isUser']}');
        print('ユーザーポジション: ${userPlayer['playerInfo']['position']}');
        
        // JSONの構造を詳しく調べる
        print('handData keys: ${handData.keys.toList()}');
        print('winnerInfo exists: ${handData.containsKey('winnerInfo')}');
        print('winnerInfo value: ${handData['winnerInfo']}');
        
        if (handData['winnerInfo'] != null) {
          print('winnerInfo is not null');
          final winnerInfo = handData['winnerInfo'] as Map<String, dynamic>;
          print('winnerInfo keys: ${winnerInfo.keys.toList()}');
          print('winners exists: ${winnerInfo.containsKey('winners')}');
          print('winners value: ${winnerInfo['winners']}');
          
          if (winnerInfo['winners'] != null) {
            final winners = winnerInfo['winners'] as List;
            print('勝者数: ${winners.length}');
            
            for (int i = 0; i < winners.length; i++) {
              final winner = winners[i];
              print('勝者$i - 名前: ${winner['name']}, ポジション: ${winner['position']}, 賞金: ${winner['amountWon']}');
            }
            
            // より確実な勝者判定
            bool isWinner = false;
            
            // 方法1: 名前による判定
            for (final winner in winners) {
              if (winner['name'] == userPlayer['playerInfo']['name'] || 
                  winner['name'] == "あなた") {
                print('名前で勝者判定成功: ${winner['name']}');
                isWinner = true;
                break;
              }
            }
            
            // 方法2: ポジションによる判定（名前判定が失敗した場合）
            if (!isWinner) {
              for (final winner in winners) {
                if (winner['position'] == userPlayer['playerInfo']['position'] && 
                    userPlayer['playerInfo']['isUser'] == true) {
                  print('ポジションで勝者判定成功: ${winner['position']}');
                  isWinner = true;
                  break;
                }
              }
            }
            
            // 方法3: 賞金を獲得しているか確認
            if (!isWinner) {
              for (final winner in winners) {
                if ((winner['name'] == userPlayer['playerInfo']['name'] || 
                     winner['name'] == "あなた" ||
                     winner['position'] == userPlayer['playerInfo']['position']) &&
                    winner['amountWon'] != null && 
                    winner['amountWon'] > 0) {
                  print('賞金で勝者判定成功: ${winner['amountWon']}');
                  isWinner = true;
                  break;
                }
              }
            }
            
            result = isWinner ? 'win' : 'loss';
            print('最終判定: $result');
          } else {
            print('winners が null です');
          }
        } else {
          print('winnerInfo が存在しません');
          
          // winnerInfoがない場合の代替判定
          // チップ情報から利益を確認
          if (userPlayer['chipInfo'] != null && userPlayer['chipInfo']['profit'] != null) {
            final profit = userPlayer['chipInfo']['profit'];
            print('チップ利益: $profit');
            if (profit > 0) {
              result = 'win';
              print('利益による勝者判定: $profit');
            }
          } else {
            print('チップ情報も利用不可');
            
            // 最後の手段: アクションサマリーで判定
            // フォールドしていない＋他の全員がフォールドしていれば勝利の可能性
            final userFolded = userPlayer['handInfo']['folded'] ?? false;
            if (!userFolded) {
              final allPlayers = handData['playerDetails'] as List;
              final activePlayers = allPlayers.where((p) => !(p['handInfo']['folded'] ?? false)).length;
              print('アクティブプレイヤー数: $activePlayers');
              
              if (activePlayers == 1) {
                result = 'win';
                print('フォールド判定による勝利');
              } else if (activePlayers <= 2) {
                // ショーダウンの場合、とりあえず勝利と仮定（データ不足のため）
                result = 'win';
                print('ショーダウン推定勝利');
              }
            }
          }
        }
        print('===================');

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
            cards: [], // プリフロップフォールド
            totalBet: 0,
            folded: true,
            actions: [
              ActionData(street: 'preflop', action: 'fold', amount: 0),
            ],
          ),
        ],
        result: 'win', // 修正: デモデータは勝利に変更
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
    bool isExactMatch = true;
    double? similarityScore;
    
    try {
      matchingBoard = _gtoData.firstWhere(
        (gto) => _normalizeBoard(gto.tree) == boardString,
      );
    } catch (e) {
      // If no exact match, try to find similar board
      final similarBoard = _findSimilarBoard(flop);
      if (similarBoard != null) {
        matchingBoard = similarBoard;
        isExactMatch = false;
        // Calculate similarity score for the found board
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
    
    // Return only if similarity is above 50%
    return bestScore >= 0.5 ? bestMatch : null;
  }

  Map<String, dynamic> _analyzeBoardPattern(List<String> cards) {
    if (cards.length < 3) return {};
    
    final convertedCards = cards.map(_convertCardSuit).toList();
    final ranks = convertedCards.map((card) => card[0]).toList();
    final suits = convertedCards.map((card) => card.substring(1)).toList();
    
    // Rank analysis
    final rankCounts = <String, int>{};
    for (final rank in ranks) {
      rankCounts[rank] = (rankCounts[rank] ?? 0) + 1;
    }
    
    final hasPair = rankCounts.values.any((count) => count >= 2);
    final hasTrips = rankCounts.values.any((count) => count >= 3);
    
    // Suit analysis
    final suitCounts = <String, int>{};
    for (final suit in suits) {
      suitCounts[suit] = (suitCounts[suit] ?? 0) + 1;
    }
    
    final flushDraws = suitCounts.values.where((count) => count >= 2).length;
    final rainbow = suitCounts.keys.length == 3;
    
    // Straight draw analysis
    const rankOrder = 'AKQJT98765432';
    final rankValues = ranks.map((rank) => rankOrder.indexOf(rank)).toList()..sort();
    
    final gaps = [
      rankValues[1] - rankValues[0],
      rankValues[2] - rankValues[1],
    ];
    
    final straightDraw = gaps.every((gap) => gap <= 4) && (rankValues[2] - rankValues[0]) <= 4;
    final connectedBoard = gaps.every((gap) => gap <= 2);
    
    // High card analysis
    final highCardCount = ranks.where((rank) => ['A', 'K', 'Q', 'J'].contains(rank)).length;
    final lowBoard = ranks.every((rank) => !['A', 'K', 'Q', 'J', 'T'].contains(rank));
    
    return {
      'hasPair': hasPair,
      'hasTrips': hasTrips,
      'flushDraws': flushDraws,
      'rainbow': rainbow,
      'straightDraw': straightDraw,
      'connectedBoard': connectedBoard,
      'highCardCount': highCardCount,
      'lowBoard': lowBoard,
      'rankStructure': rankCounts.values.toList()..sort((a, b) => b.compareTo(a)),
      'suitStructure': suitCounts.values.toList()..sort((a, b) => b.compareTo(a)),
    };
  }

  double _calculateBoardSimilarity(Map<String, dynamic> pattern1, Map<String, dynamic> pattern2) {
    if (pattern1.isEmpty || pattern2.isEmpty) return 0;
    
    double score = 0;
    double totalWeight = 0;
    
    // Pair/trips structure comparison (high importance)
    const weight1 = 0.25;
    if (pattern1['hasPair'] == pattern2['hasPair']) score += weight1;
    if (pattern1['hasTrips'] == pattern2['hasTrips']) score += weight1;
    totalWeight += weight1 * 2;
    
    // Flush draw structure comparison (high importance)
    const weight2 = 0.2;
    if (pattern1['flushDraws'] == pattern2['flushDraws']) score += weight2;
    if (pattern1['rainbow'] == pattern2['rainbow']) score += weight2;
    totalWeight += weight2 * 2;
    
    // Straight draw structure comparison (high importance)
    const weight3 = 0.15;
    if (pattern1['straightDraw'] == pattern2['straightDraw']) score += weight3;
    if (pattern1['connectedBoard'] == pattern2['connectedBoard']) score += weight3;
    totalWeight += weight3 * 2;
    
    // High card structure comparison (medium importance)
    const weight4 = 0.1;
    final highCardDiff = (pattern1['highCardCount'] as int) - (pattern2['highCardCount'] as int);
    if (highCardDiff.abs() <= 1) score += weight4;
    if (pattern1['lowBoard'] == pattern2['lowBoard']) score += weight4;
    totalWeight += weight4 * 2;
    
    // Rank structure comparison (medium importance)
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

  double? _getStreetStartPot(HandData hand, String street) {
    print('getStreetStartPot called: $street, streetPots: ${hand.streetPots}');
    
    // Check new JSON format for street start pot information
    if (hand.streetPots != null && hand.streetPots!.containsKey(street)) {
      print('Got street start pot from JSON: $street ${hand.streetPots![street]}');
      return hand.streetPots![street];
    }
    
    // Calculate from chronological actions if available
    final calculatedPot = _calculatePotFromChronologicalActions(hand, street);
    if (calculatedPot != null) {
      print('Calculated pot from chronological actions: $calculatedPot');
      return calculatedPot;
    }
    
    // Estimate from game settings
    double basePot = 4; // Default SB + BB
    if (street == 'preflop') {
      print('Using base preflop pot: $basePot');
      return basePot;
    } else if (street == 'flop') {
      // Add preflop bets
      final preflopBets = _calculateStreetBets(hand, 'preflop');
      final flopStartPot = basePot + preflopBets;
      print('Calculated flop pot: $flopStartPot (base: $basePot + preflop bets: $preflopBets)');
      return flopStartPot;
    }
    
    print('Could not determine pot, returning null');
    return null;
  }

  double? _calculatePotFromChronologicalActions(HandData hand, String targetStreet) {
    // This would require chronological actions data
    // For now, return null and rely on streetPots or calculation
    return null;
  }

  double _calculateStreetBets(HandData hand, String street) {
    double totalBets = 0;
    
    // Calculate from player actions
    for (final action in hand.actions) {
      if (action.street == street && 
          ['bet', 'raise', 'call'].contains(action.action)) {
        totalBets += action.amount;
      }
    }
    
    // Add opponent actions if available
    if (hand.opponents != null) {
      for (final opponent in hand.opponents!) {
        // For simplified calculation, use total bet for preflop
        if (street == 'preflop') {
          totalBets += opponent.totalBet;
        }
      }
    }
    
    return totalBets;
  }

  double _calculateFlopStartPot(HandData hand) {
    // Calculate pot size at start of flop (after preflop is complete)
    double potSize = 0;
    
    // Estimate initial pot based on pot size and player count
    double initialPot = 15; // Default value (SB + BB + antes)
    
    if (hand.potSize < 100) {
      initialPot = (hand.potSize / 3).clamp(15, 50).toDouble();
    } else if (hand.potSize < 500) {
      initialPot = (hand.potSize / 10).clamp(20, 100).toDouble();
    } else {
      initialPot = (hand.potSize / 15).clamp(30, 200).toDouble();
    }
    
    potSize = initialPot;
    
    print('Flop start pot calculation started: initial pot: $potSize');
    
    // Add preflop actions
    for (final action in hand.actions) {
      if (action.street == 'preflop' && 
          ['bet', 'raise', 'call'].contains(action.action)) {
        potSize += action.amount;
        print('Added preflop action: ${action.action} ${action.amount}, cumulative pot: $potSize');
      }
    }
    
    // Add opponent preflop actions if available
    if (hand.opponents != null) {
      for (final opponent in hand.opponents!) {
        // Simplified: add total bet for preflop estimation
        potSize += opponent.totalBet;
        print('Added opponent preflop bet: ${opponent.totalBet}, cumulative pot: $potSize');
      }
    }
    
    print('Flop start pot calculation complete: $potSize');
    return potSize.clamp(initialPot, double.infinity);
  }

  String _translateActionToGTO(ActionData action, HandData hand) {
    print('translateActionToGTO called: ${action.action}, amount: ${action.amount}, handId: ${hand.handId}');
    
    if (action.action == 'check') return 'Check';
    if (action.action == 'bet') {
      if (action.amount <= 0) {
        print('Bet amount is 0 or undefined, returning default 30%');
        return 'Bet 30%'; // Default
      }
      
      // Get street start pot size from new JSON format
      double? streetStartPot = _getStreetStartPot(hand, 'flop');
      print('getStreetStartPot result: $streetStartPot');
      
      // If not available, use traditional calculation method
      if (streetStartPot == null) {
        print('getStreetStartPot failed, using calculateFlopStartPot');
        streetStartPot = _calculateFlopStartPot(hand);
      }
      
      // Calculate ratio relative to street start pot
      final betRatio = (action.amount / streetStartPot) * 100;
      
      // Debug information
      print('Bet analysis (street start pot basis): '
          'action: ${action.action}, '
          'betAmount: ${action.amount}, '
          'streetStartPot: $streetStartPot, '
          'betRatio: ${betRatio.toStringAsFixed(1)}%, '
          'decision: ${betRatio >= 75 ? 'Bet 100%' : betRatio >= 40 ? 'Bet 50%' : 'Bet 30%'}');
      
      if (betRatio >= 75) return 'Bet 100%';      // 75% or more → 100% pot
      if (betRatio >= 40) return 'Bet 50%';       // 40% or more → 50% pot
      return 'Bet 30%';                           // Less than that → 30% pot
    }
    if (action.action == 'call') return 'Check';
    if (action.action == 'fold') return 'Check';
    
    print('Unknown action: ${action.action} -> treating as Check');
    return 'Check';
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
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // ハンドレンジ分析を最初に表示
        if (provider.rangeData.isNotEmpty) _buildHandRangeAnalysisSection(provider),
        const SizedBox(height: 20),
        
        // 詳細ハンド分析を2番目に表示
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: _buildHandsList(provider.hands, provider),
        ),
        const SizedBox(height: 20),
        
        // GTO分析を最後に表示
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
          
          // 相手プレイヤーのハンド表示を追加
          if (hand.opponents != null && hand.opponents!.isNotEmpty) ...[
            const SizedBox(height: 15),
            _buildOpponentsSection(hand),
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
        child: Column(
          children: [
            const Text(
              '🧠 GTO戦略分析',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'BTNポジションでフロップをプレイしたハンドがないため、GTO分析は利用できません。',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GTO分析に必要な条件:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '✅ ボタンポジション（BTN）でのプレイ\n'
                    '✅ フロップ（3枚のコミュニティカード）が配られている\n'
                    '✅ フロップでアクション（ベット、チェック等）を行っている\n'
                    '✅ ビッグブラインド（BB）との対戦',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    int gtoOptimalCount = 0;
    int totalAnalyzed = 0;
    final gtoResults = <Map<String, dynamic>>[];

    for (final hand in applicableHands) {
      final gtoRec = provider.getGTORecommendation(hand);
      if (gtoRec != null) {
        totalAnalyzed++;
        try {
          final flopAction = hand.actions.firstWhere(
            (a) => a.street == 'flop',
          );
          final actualAction = _translateActionToGTO(flopAction, hand);
          final isOptimal = actualAction == gtoRec.bestAction;
          if (isOptimal) {
            gtoOptimalCount++;
          }
          
          gtoResults.add({
            'hand': hand,
            'gtoRec': gtoRec,
            'flopAction': flopAction,
            'actualAction': actualAction,
            'isOptimal': isOptimal,
          });
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
          
          // Summary header
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  '📊 分析対象: $totalAnalyzed ハンド（全${provider.hands.length}ハンド中）',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 ボタンポジションでのフロップ戦略をGTO理論と比較分析します',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Individual hand analysis
          if (gtoResults.isNotEmpty) ...[
            const Text(
              '📋 ハンド別GTO分析',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            ...gtoResults.map((result) => _buildGTOHandAnalysisCard(result)),
          ],
          
          const SizedBox(height: 20),
          
          // Summary statistics
          if (totalAnalyzed > 0) _buildGTOSummaryStats(totalAnalyzed, gtoOptimalCount, gtoCompliance),
          
          const SizedBox(height: 15),
          _buildGTOPerformanceIndicator(gtoCompliance),
        ],
      ),
    );
  }

  Widget _buildGTOHandAnalysisCard(Map<String, dynamic> result) {
    final hand = result['hand'] as HandData;
    final gtoRec = result['gtoRec'] as GTORecommendation;
    final flopAction = result['flopAction'] as ActionData;
    final actualAction = result['actualAction'] as String;
    final isOptimal = result['isOptimal'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: isOptimal ? Colors.green : Colors.red,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ハンド #${hand.handId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Text(
                    'EV: ${gtoRec.ev.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: Colors.purple.shade200,
                      fontSize: 14,
                    ),
                  ),
                  if (!gtoRec.isExactMatch) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        gtoRec.similarityScore != null 
                          ? '類似 ${(gtoRec.similarityScore! * 100).toStringAsFixed(0)}%'
                          : '類似',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Board cards
          Row(
            children: [
              const Text(
                'ボード: ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...gtoRec.board.map((card) => Container(
                margin: const EdgeInsets.only(right: 5),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  card,
                  style: TextStyle(
                    color: _isRedCard(card) ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // GTO recommendation
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 5),
                Text(
                  'エクイティ: ${gtoRec.equity.toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Actual action vs GTO
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOptimal 
                ? Colors.green.withOpacity(0.2) 
                : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                  ],
                ),
                
                // Bet details
                if (flopAction.action == 'bet' && flopAction.amount > 0) ...[
                  const SizedBox(height: 5),
                  Builder(
                    builder: (context) {
                      final flopStartPot = _getStreetStartPot(hand, 'flop') ?? _calculateFlopStartPot(hand);
                      final betRatio = ((flopAction.amount / flopStartPot) * 100);
                      return Text(
                        'ベット: ${flopAction.amount}, フロップ開始ポット: ${flopStartPot.toStringAsFixed(0)} → ${betRatio.toStringAsFixed(1)}% pot',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
                
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      isOptimal ? '✅ GTO最適' : '⚠️ GTO非最適',
                      style: TextStyle(
                        color: isOptimal ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!gtoRec.isExactMatch) ...[
                      const SizedBox(width: 10),
                      Text(
                        '※類似ボード分析',
                        style: TextStyle(
                          color: Colors.orange.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Action frequencies
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

  Widget _buildGTOSummaryStats(int totalAnalyzed, int gtoOptimalCount, double gtoCompliance) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 GTO適合性サマリー',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStatItem('分析対象', '$totalAnalyzed ハンド'),
              _buildSummaryStatItem(
                'GTO最適', 
                '$gtoOptimalCount ハンド',
                subtext: '${gtoCompliance.toStringAsFixed(1)}%',
              ),
              _buildSummaryStatItem(
                '改善余地', 
                '${totalAnalyzed - gtoOptimalCount} ハンド',
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Improvement suggestions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎯 具体的な改善提案:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (gtoCompliance < 60) ...[
                  _buildImprovementPoint('フロップベッティング頻度の調整: GTOでは状況に応じてベット/チェックを使い分けます'),
                  _buildImprovementPoint('ベットサイズの最適化: ポットサイズに対する適切なベット額（30%、50%、100%）を学習しましょう'),
                  _buildImprovementPoint('ボードテクスチャの理解: ドロー系ボードとペア系ボードで戦略を変えましょう'),
                ] else if (gtoCompliance < 80) ...[
                  _buildImprovementPoint('バランス調整: 強いハンドと弱いハンドの混合頻度を最適化しましょう'),
                  _buildImprovementPoint('ポジション活用: BTNの有利性を最大限活かした積極的なプレイを心がけましょう'),
                ] else ...[
                  _buildImprovementPoint('継続性: 現在の高いGTO適合性を維持してください'),
                  _buildImprovementPoint('応用: 他のポジションでも同様の理論的アプローチを適用しましょう'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatItem(String label, String value, {String? subtext}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtext != null) ...[
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImprovementPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Colors.blue),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
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

  double? _getStreetStartPot(HandData hand, String street) {
    return hand.streetPots?[street];
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

  bool _isRedCard(String card) {
    return card.contains('♥') || card.contains('♦') || 
           card.contains('h') || card.contains('d');
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

  Widget _buildOpponentsSection(HandData hand) {
    // プリフロップでフォールドしたプレイヤーを除外
    final activeOpponents = hand.opponents!.where((opponent) {
      // カード情報がない場合は除外（プリフロップフォールド）
      if (opponent.cards.isEmpty) return false;
      
      // アクション情報がある場合は、それを使って判定
      if (opponent.actions != null && opponent.actions!.isNotEmpty) {
        // プリフロップでフォールドしているかチェック
        final preflopActions = opponent.actions!.where((a) => a.street == 'preflop').toList();
        if (preflopActions.isNotEmpty) {
          final lastPreflopAction = preflopActions.last;
          if (lastPreflopAction.action == 'fold') {
            print('${opponent.name}: プリフロップでフォールド');
            return false; // プリフロップフォールドは除外
          }
        }
        
        // フロップ以降のアクションがあるかチェック
        final postFlopActions = opponent.actions!.where((a) => a.street != 'preflop').toList();
        if (postFlopActions.isNotEmpty) {
          print('${opponent.name}: フロップ以降にアクションあり');
          return true; // フロップ以降に参加
        }
      }
      
      // アクション情報がない場合は、従来の方法で判定
      // フォールドしているが、カード情報があり、かつベット額が少ない場合
      if (opponent.folded && opponent.totalBet <= 3) {
        print('${opponent.name}: ベット額が少ないプリフロップフォールド (${opponent.totalBet})');
        return false;
      }
      
      print('${opponent.name}: 表示対象');
      return true;
    }).toList();

    // デバッグ情報
    print('=== 相手プレイヤー表示デバッグ ===');
    print('全相手プレイヤー数: ${hand.opponents?.length ?? 0}');
    for (int i = 0; i < (hand.opponents?.length ?? 0); i++) {
      final opp = hand.opponents![i];
      final hasActions = opp.actions != null && opp.actions!.isNotEmpty;
      final actionSummary = hasActions 
        ? opp.actions!.map((a) => '${a.street}:${a.action}').join(', ')
        : '情報なし';
      print('相手$i: ${opp.name}, folded: ${opp.folded}, cards: ${opp.cards.length}枚, totalBet: ${opp.totalBet}, アクション: $actionSummary');
    }
    print('表示対象プレイヤー数: ${activeOpponents.length}');
    print('========================');

    if (activeOpponents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: const Border(left: BorderSide(color: Colors.grey, width: 4)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👥 相手プレイヤー',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'フロップ以降に参加した相手プレイヤーがいませんでした',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: Colors.blue, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people,
                color: Colors.blue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '👥 フロップ参加プレイヤー (${activeOpponents.length}人)',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // プレイヤーごとの情報を表示
          ...activeOpponents.map((opponent) => _buildOpponentCard(opponent)),
        ],
      ),
    );
  }

  Widget _buildOpponentCard(OpponentData opponent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: opponent.folded 
          ? Colors.red.withOpacity(0.1) 
          : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: opponent.folded 
          ? Border.all(color: Colors.red.withOpacity(0.5), width: 1)
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // プレイヤー名とポジション
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: opponent.folded 
                        ? Colors.red.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      opponent.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _translatePosition(opponent.position),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  if (opponent.folded) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'FOLD',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (opponent.totalBet > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ベット: ${opponent.totalBet.toInt()}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // ハンドカード
          if (opponent.cards.isNotEmpty) ...[
            const Text(
              'ハンド:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 6,
              children: [
                ...opponent.cards.map((card) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: opponent.folded 
                      ? Colors.grey.withOpacity(0.5)
                      : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    card,
                    style: TextStyle(
                      color: opponent.folded 
                        ? Colors.white70
                        : (_isRedCard(card) ? Colors.red : Colors.black),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                )),
                const SizedBox(width: 10),
                
                // ハンドの強さ評価
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _evaluateHandStrength(opponent.cards),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ハンド非公開',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
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