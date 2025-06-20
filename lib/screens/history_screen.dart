import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/common_header.dart';
import '../home_screen.dart';
import '../models/analysis_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  // カラーパレットの定義
  static const _primaryColor = Color(0xFF2C3E50); // メインカラー（ダークグレー）
  static const _secondaryColor = Color(0xFF34495E); // アクセントカラー（ライトグレー）
  static const _backgroundColor = Color(0xFFFAFAFA); // 背景色（オフホワイト）
  static const _textPrimaryColor = Color(0xFF2C3E50); // 主要テキスト色
  static const _textSecondaryColor = Color(0xFF7F8C8D); // 補助テキスト色
  static const _successColor = Color(0xFF27AE60); // 成功色（グリーン）
  static const _warningColor = Color(0xFFF39C12); // 警告色（オレンジ）
  static const _errorColor = Color(0xFFE74C3C); // エラー色（レッド）
  static const _cardGradientStart = Color(0xFFFFFFFF); // カードグラデーション開始色（白）
  static const _cardGradientEnd = Color(0xFFF8F9FA); // カードグラデーション終了色（ライトグレー）

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
        // 履歴データを読み込む
        context.read<AnalysisHistoryProvider>().loadHistories();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  void _handleNavigation(int index) {
    if (index == 0) {
      Navigator.of(context).pop(); // ホームタブが選択された場合は前の画面に戻る
    } else {
      // 他のタブが選択された場合はHomeScreenに遷移
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false, // すべての画面をクリア
      );
      // HomeScreenの状態を更新するために少し遅延を入れる
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          final homeScreen =
              context.findRootAncestorStateOfType<HomeScreenState>();
          if (homeScreen != null) {
            homeScreen.setState(() {
              homeScreen.selectedIndex = index;
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildHistoryCard(AnalysisHistory history) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final winRateColor = history.winRate >= 0.5 ? _successColor : _warningColor;
    final resultColor =
        history.analysisResult == '適切なプレイ' ? _successColor : _warningColor;

    return Dismissible(
      // スワイプで削除可能に
      key: Key(history.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: _errorColor,
        ),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        context.read<AnalysisHistoryProvider>().deleteHistory(history.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('分析履歴を削除しました'),
            action: SnackBarAction(
              label: '元に戻す',
              onPressed: () {
                context.read<AnalysisHistoryProvider>().addHistory(history);
              },
            ),
          ),
        );
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shadowColor: _primaryColor.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.white.withOpacity(0.8),
                width: 1,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                // タップで詳細表示
                onTap: () {
                  // TODO: 詳細画面への遷移を実装
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('詳細表示は今後実装予定です')),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              history.handDescription,
                              style: const TextStyle(
                                fontFamily: 'Noto Sans JP',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textPrimaryColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: resultColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: resultColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              history.analysisResult,
                              style: TextStyle(
                                fontFamily: 'Noto Sans JP',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: resultColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: _textSecondaryColor.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(history.analyzedAt),
                            style: TextStyle(
                              fontFamily: 'Noto Sans JP',
                              fontSize: 12,
                              color: _textSecondaryColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailItem(
                                    'ポジション', history.handDetails['position']),
                                _buildDetailItem(
                                    'スタック', history.handDetails['stack']),
                                _buildDetailItem(
                                    'アクション', history.handDetails['action']),
                                _buildDetailItem(
                                    '相手', history.handDetails['opponent']),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: winRateColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: winRateColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          '勝率',
                                          style: TextStyle(
                                            fontFamily: 'Noto Sans JP',
                                            fontSize: 12,
                                            color: _textSecondaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(history.winRate * 100).toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontFamily: 'Noto Sans JP',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: winRateColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Noto Sans JP',
            fontSize: 10,
            color: _textSecondaryColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Noto Sans JP',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // 背景グラデーション
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _primaryColor.withOpacity(0.05),
                  _backgroundColor,
                ],
              ),
            ),
          ),
          // 共通ヘッダー
          Positioned(
            top: MediaQuery.of(context).padding.top, // ステータスバーの高さを考慮
            left: 0,
            right: 0,
            child: const CommonHeader(
              title: '分析履歴',
              showBackButton: true,
            ),
          ),
          // 履歴リスト
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 56, // ステータスバー + ヘッダーの高さ
              bottom: 80,
            ),
            child: Consumer<AnalysisHistoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.histories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: _textSecondaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '分析履歴がありません',
                          style: TextStyle(
                            fontFamily: 'Noto Sans JP',
                            fontSize: 16,
                            color: _textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ハンドを分析すると、ここに履歴が表示されます',
                          style: TextStyle(
                            fontFamily: 'Noto Sans JP',
                            fontSize: 14,
                            color: _textSecondaryColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.histories.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(provider.histories[index]);
                  },
                );
              },
            ),
          ),
          // スクロールトップボタン
          if (_showScrollToTop)
            Positioned(
              right: 16,
              bottom: 80,
              child: FloatingActionButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: Colors.white,
                elevation: 4,
                child: Icon(
                  Icons.arrow_upward,
                  color: _primaryColor,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 履歴画面はボトムバーにないので、ホームを選択状態に
        onTap: _handleNavigation,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6B46C1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'ランキング',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'ミッション',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'アカウント',
          ),
        ],
      ),
    );
  }
}
