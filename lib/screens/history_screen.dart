import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/common_header.dart';
import '../home_screen.dart';
import '../models/analysis_history.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
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
  final TextEditingController _searchController = TextEditingController();
  bool _showScrollToTop = false;
  bool _showFilters = false;
  bool _showStatistics = false;

  // フィルター用のドロップダウン値
  String _selectedResult = '';
  String _selectedPosition = '';
  String _selectedAction = '';

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
    _searchController.addListener(_onSearchChanged);

    // 履歴データを読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
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

  void _onSearchChanged() {
    context
        .read<AnalysisHistoryProvider>()
        .setSearchQuery(_searchController.text);
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
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ハンド、結果、ポジションで検索...',
          prefixIcon: const Icon(Icons.search, color: _textSecondaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: _textSecondaryColor),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'フィルター',
                style: TextStyle(
                  fontFamily: 'Noto Sans JP',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimaryColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<AnalysisHistoryProvider>().resetFilters();
                  setState(() {
                    _selectedResult = '';
                    _selectedPosition = '';
                    _selectedAction = '';
                  });
                },
                child: const Text('リセット'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 結果とポジションのフィルター
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedResult.isEmpty ? null : _selectedResult,
                  decoration: const InputDecoration(
                    labelText: '結果',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('すべて')),
                    DropdownMenuItem(value: '適切なプレイ', child: Text('適切なプレイ')),
                    DropdownMenuItem(value: '境界線のプレイ', child: Text('境界線のプレイ')),
                    DropdownMenuItem(value: '改善の余地あり', child: Text('改善の余地あり')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedResult = value ?? '';
                    });
                    context.read<AnalysisHistoryProvider>().setFilters(
                          result: value?.isEmpty == true ? null : value,
                        );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPosition.isEmpty ? null : _selectedPosition,
                  decoration: const InputDecoration(
                    labelText: 'ポジション',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('すべて')),
                    DropdownMenuItem(value: 'BTN', child: Text('BTN')),
                    DropdownMenuItem(value: 'CO', child: Text('CO')),
                    DropdownMenuItem(value: 'MP', child: Text('MP')),
                    DropdownMenuItem(value: 'UTG', child: Text('UTG')),
                    DropdownMenuItem(value: 'BB', child: Text('BB')),
                    DropdownMenuItem(value: 'SB', child: Text('SB')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPosition = value ?? '';
                    });
                    context.read<AnalysisHistoryProvider>().setFilters(
                          position: value?.isEmpty == true ? null : value,
                        );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // アクションフィルター（全幅）
          DropdownButtonFormField<String>(
            value: _selectedAction.isEmpty ? null : _selectedAction,
            decoration: const InputDecoration(
              labelText: 'アクション',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: '', child: Text('すべて')),
              DropdownMenuItem(value: 'fold', child: Text('fold')),
              DropdownMenuItem(value: 'call', child: Text('call')),
              DropdownMenuItem(value: 'raise', child: Text('raise')),
              DropdownMenuItem(value: '3bet', child: Text('3bet')),
              DropdownMenuItem(value: '4bet', child: Text('4bet')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedAction = value ?? '';
              });
              context.read<AnalysisHistoryProvider>().setFilters(
                    action: value?.isEmpty == true ? null : value,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    if (!_showStatistics) return const SizedBox.shrink();

    return Consumer<AnalysisHistoryProvider>(
      builder: (context, provider, child) {
        final stats = provider.statistics;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '統計情報',
                style: TextStyle(
                  fontFamily: 'Noto Sans JP',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '総分析数',
                      '${stats['total']}',
                      Icons.analytics,
                      _primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      '平均勝率',
                      '${(stats['averageWinRate'] * 100).toStringAsFixed(1)}%',
                      Icons.trending_up,
                      _successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '適切なプレイ',
                      '${stats['appropriatePlays']}',
                      Icons.check_circle,
                      _successColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      '境界線のプレイ',
                      '${stats['borderlinePlays']}',
                      Icons.help_outline,
                      _warningColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '改善必要',
                      '${stats['improvementNeeded']}',
                      Icons.warning,
                      _errorColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      '最高勝率',
                      '${(stats['bestWinRate'] * 100).toStringAsFixed(1)}%',
                      Icons.star,
                      _successColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Noto Sans JP',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Noto Sans JP',
              fontSize: 10,
              color: _textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(AnalysisHistory history) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final winRateColor = history.winRate >= 0.5 ? _successColor : _warningColor;

    // 分析結果に基づく色の決定
    Color resultColor;
    switch (history.analysisResult) {
      case '適切なプレイ':
        resultColor = _successColor;
        break;
      case '境界線のプレイ':
        resultColor = _warningColor;
        break;
      case '改善の余地あり':
        resultColor = _errorColor;
        break;
      default:
        resultColor = _textSecondaryColor;
    }

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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          HistoryDetailScreen(history: history),
                    ),
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
                      // タグとメモの表示
                      if (history.tags.isNotEmpty || history.notes != null) ...[
                        const SizedBox(height: 12),
                        if (history.tags.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: history.tags
                                .map((tag) => Chip(
                                      label: Text(
                                        tag,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor:
                                          _primaryColor.withOpacity(0.1),
                                      labelStyle:
                                          const TextStyle(color: _primaryColor),
                                    ))
                                .toList(),
                          ),
                        if (history.notes != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            history.notes!,
                            style: TextStyle(
                              fontFamily: 'Noto Sans JP',
                              fontSize: 12,
                              color: _textSecondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
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
          // 検索・フィルター・統計ボタン
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                          if (_showFilters) _showStatistics = false;
                        });
                      },
                      icon: Icon(_showFilters
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined),
                      label: const Text('フィルター'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _showFilters ? _primaryColor : Colors.white,
                        foregroundColor:
                            _showFilters ? Colors.white : _primaryColor,
                        elevation: _showFilters ? 4 : 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showStatistics = !_showStatistics;
                          if (_showStatistics) _showFilters = false;
                        });
                      },
                      icon: Icon(_showStatistics
                          ? Icons.bar_chart
                          : Icons.bar_chart_outlined),
                      label: const Text('統計'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _showStatistics ? _primaryColor : Colors.white,
                        foregroundColor:
                            _showStatistics ? Colors.white : _primaryColor,
                        elevation: _showStatistics ? 4 : 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 履歴リスト
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top +
                  120, // ステータスバー + ヘッダー + ボタン
              bottom: 80,
            ),
            child: Consumer<AnalysisHistoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.allHistories.isEmpty) {
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // ダミーデータを追加してテスト
                            final historyProvider =
                                context.read<AnalysisHistoryProvider>();
                            final testHistory =
                                historyProvider.createHistoryFromAnalysis(
                              handDescription: 'テストハンド AKs vs QQ',
                              winRate: 0.65,
                              analysisResult: '適切なプレイ',
                              handDetails: {
                                'position': 'BTN',
                                'stack': '100BB',
                                'action': '3bet',
                                'opponent': 'BB',
                              },
                              notes: 'テスト用の履歴です',
                              tags: ['テスト'],
                            );
                            historyProvider.addHistory(testHistory);
                          },
                          child: const Text('テスト履歴を追加'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.histories.isEmpty &&
                    provider.allHistories.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 64,
                          color: _textSecondaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'フィルター条件に一致する履歴がありません',
                          style: TextStyle(
                            fontFamily: 'Noto Sans JP',
                            fontSize: 16,
                            color: _textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '検索条件やフィルターを変更してください',
                          style: TextStyle(
                            fontFamily: 'Noto Sans JP',
                            fontSize: 14,
                            color: _textSecondaryColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<AnalysisHistoryProvider>()
                                .resetFilters();
                            setState(() {
                              _selectedResult = '';
                              _selectedPosition = '';
                              _selectedAction = '';
                              _searchController.clear();
                            });
                          },
                          child: const Text('フィルターをリセット'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  key: const PageStorageKey('history_list'),
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildSearchBar(),
                    _buildFilterSection(),
                    _buildStatisticsSection(),
                    ...provider.histories
                        .map((history) => _buildHistoryCard(history))
                        .toList(),
                  ],
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
