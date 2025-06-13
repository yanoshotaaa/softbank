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
import 'home_screen.dart';
import 'models/analysis_history.dart';
import 'providers/poker_analysis_provider.dart';

// Main App
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PokerAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisHistoryProvider()),
      ],
      child: MaterialApp(
        title: 'SoftBank',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          fontFamily: 'Noto Sans JP',
          scaffoldBackgroundColor: const Color(0xFFF7FAFC),
        ),
        home: const HomeScreen(),
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
      _rangeData = handsRows
          .skip(1)
          .where((row) =>
              row.length >= 6 &&
              row[0].toString().isNotEmpty &&
              row[4].toString().isNotEmpty)
          .map((row) => HandRangeData.fromCsv(row))
          .toList();

      print(
          'Loaded ${_gtoData.length} GTO entries and ${_rangeData.length} range entries');
    } catch (e) {
      print('Error loading CSV assets: $e');
    }
  }

  Future<void> loadJsonFile() async {
    try {
      print('=== ファイル読み込み開始 ===');
      _isLoading = true;
      notifyListeners();

      print('FilePickerを呼び出し...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // ファイルの内容を直接読み込む
      );

      print('FilePicker結果: ${result != null ? '成功' : 'キャンセル'}');
      if (result != null) {
        print('選択されたファイル: ${result.files.single.name}');
        print('ファイルサイズ: ${result.files.single.size} bytes');
        print('ファイルパス: ${result.files.single.path}');

        if (result.files.single.bytes != null) {
          print('ファイルの内容を読み込み中...');
          Uint8List fileBytes = result.files.single.bytes!;
          String content = utf8.decode(fileBytes);
          print('ファイルの内容をデコード完了');

          print('JSONパース開始...');
          Map<String, dynamic> jsonData = json.decode(content);
          print('JSONパース完了');

          // Check for different JSON formats
          if (jsonData['hands'] != null && jsonData['hands'] is List) {
            print('hands配列を検出: ${jsonData['hands'].length}件');
            final hands = jsonData['hands'] as List;
            if (hands.isNotEmpty) {
              print('最初のハンドデータ: ${hands[0].keys.toList()}');
              if (hands[0]['gameInfo'] != null) {
                print('詳細履歴フォーマットを検出');
                _hands = _convertDetailedHistoryFormat(jsonData);
              } else if (hands[0]['hand_id'] != null) {
                print('標準分析フォーマットを検出');
                _hands = hands
                    .map((handJson) => HandData.fromJson(handJson))
                    .toList();
              } else {
                throw Exception('未知のJSONフォーマットです。');
              }
              _calculateStats();
            }
          } else {
            throw Exception('有効なハンドデータが見つかりません。');
          }
        } else {
          print('ファイルの内容がnullです');
          throw Exception('ファイルの内容を読み込めませんでした。');
        }
      }
    } catch (e, stackTrace) {
      print('=== エラー発生 ===');
      print('エラーメッセージ: $e');
      print('スタックトレース: $stackTrace');
      // Show error to user
    } finally {
      _isLoading = false;
      notifyListeners();
      print('=== ファイル読み込み終了 ===');
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
          print(
              'プレイヤー$i: 名前=${player['playerInfo']['name']}, isUser=${player['playerInfo']['isUser']}');
        }

        final userPlayerList = playerDetailsList
            .where((p) =>
                p['playerInfo']['isUser'] == true ||
                p['playerInfo']['name'] == "あなた")
            .toList();

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
              print(
                  '勝者$i - 名前: ${winner['name']}, ポジション: ${winner['position']}, 賞金: ${winner['amountWon']}');
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
                if (winner['position'] ==
                        userPlayer['playerInfo']['position'] &&
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
                        winner['position'] ==
                            userPlayer['playerInfo']['position']) &&
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
          if (userPlayer['chipInfo'] != null &&
              userPlayer['chipInfo']['profit'] != null) {
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
              final activePlayers = allPlayers
                  .where((p) => !(p['handInfo']['folded'] ?? false))
                  .length;
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
        final streetPots = _calculateStreetPots(
            handData, smallBlind, bigBlind, ante, playerCount);

        // Calculate total pot
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
    final rankValues = ranks.map((rank) => rankOrder.indexOf(rank)).toList()
      ..sort();

    final gaps = [
      rankValues[1] - rankValues[0],
      rankValues[2] - rankValues[1],
    ];

    final straightDraw =
        gaps.every((gap) => gap <= 4) && (rankValues[2] - rankValues[0]) <= 4;
    final connectedBoard = gaps.every((gap) => gap <= 2);

    // High card analysis
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
    if (pattern1['connectedBoard'] == pattern2['connectedBoard'])
      score += weight3;
    totalWeight += weight3 * 2;

    // High card structure comparison (medium importance)
    const weight4 = 0.1;
    final highCardDiff =
        (pattern1['highCardCount'] as int) - (pattern2['highCardCount'] as int);
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
      print(
          'Got street start pot from JSON: $street ${hand.streetPots![street]}');
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
      print(
          'Calculated flop pot: $flopStartPot (base: $basePot + preflop bets: $preflopBets)');
      return flopStartPot;
    }

    print('Could not determine pot, returning null');
    return null;
  }

  double? _calculatePotFromChronologicalActions(
      HandData hand, String targetStreet) {
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
        print(
            'Added preflop action: ${action.action} ${action.amount}, cumulative pot: $potSize');
      }
    }

    // Add opponent preflop actions if available
    if (hand.opponents != null) {
      for (final opponent in hand.opponents!) {
        // Simplified: add total bet for preflop estimation
        potSize += opponent.totalBet;
        print(
            'Added opponent preflop bet: ${opponent.totalBet}, cumulative pot: $potSize');
      }
    }

    print('Flop start pot calculation complete: $potSize');
    return potSize.clamp(initialPot, double.infinity);
  }

  String _translateActionToGTO(ActionData action, HandData hand) {
    print(
        'translateActionToGTO called: ${action.action}, amount: ${action.amount}, handId: ${hand.handId}');

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

      if (betRatio >= 75) return 'Bet 100%'; // 75% or more → 100% pot
      if (betRatio >= 40) return 'Bet 50%'; // 40% or more → 50% pot
      return 'Bet 30%'; // Less than that → 30% pot
    }
    if (action.action == 'call') return 'Check';
    if (action.action == 'fold') return 'Check';

    print('Unknown action: ${action.action} -> treating as Check');
    return 'Check';
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
