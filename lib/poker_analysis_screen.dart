import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // Providerやモデルのため
import 'widgets/common_header.dart';
import 'providers/mission_provider.dart';
import 'providers/poker_analysis_provider.dart';
import 'models/analysis_history.dart';

class PokerAnalysisScreen extends StatefulWidget {
  const PokerAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<PokerAnalysisScreen> createState() => _PokerAnalysisScreenState();
}

class _PokerAnalysisScreenState extends State<PokerAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late ScrollController _scrollController;
  bool _showScrollToTop = false;

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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollController();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  void _initializeScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 200;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load CSV data when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokerAnalysisProvider>().loadCsvAssets();
    });
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = 56;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // 落ち着いたグラデーション背景
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundColor,
                  Colors.white,
                  _backgroundColor.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // 豪華な装飾的背景要素
          // 左上の装飾円
          Positioned(
            top: -150,
            left: -150,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animationController.value * 0.05,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _primaryColor.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 右上の装飾円
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_animationController.value * 0.08,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _secondaryColor.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 中央下の装飾円
          Positioned(
            bottom: -200,
            left: MediaQuery.of(context).size.width * 0.3,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animationController.value * 0.06,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _primaryColor.withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 装飾的な線
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            right: 0,
            child: Container(
              width: 2,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 左上の装飾的な線
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 0,
            child: Container(
              width: 2,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _secondaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ステータスバー部分を白で塗りつぶす
          Container(
            width: double.infinity,
            height: statusBarHeight,
            color: Colors.white,
          ),
          // 共通ヘッダーをステータスバー直下に固定
          Positioned(
            top: statusBarHeight,
            left: 0,
            right: 0,
            child: const CommonHeader(),
          ),
          // 本体（ヘッダー分下げる）
          Positioned.fill(
            top: statusBarHeight + headerHeight,
            child: SafeArea(
              top: false,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ゴージャスなタイトルカード
                              _buildTitleCard(),
                              const SizedBox(height: 28),
                              // ゴージャスなアップロードカード
                              _buildUploadCard(context),
                              const SizedBox(height: 24),
                              // ゴージャスなJSONフォーマット説明カード
                              _buildJsonFormatCard(),
                              const SizedBox(height: 28),
                              // 分析結果やローディング
                              Consumer<PokerAnalysisProvider>(
                                builder: (context, provider, child) {
                                  if (provider.isLoading) {
                                    return _buildLoadingSection();
                                  } else if (provider.hands.isNotEmpty) {
                                    // ハンド分析が完了した時にミッション進捗を更新
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _updateMissionProgress(provider);
                                      _updateWinStreak(provider);
                                      _saveAnalysisToHistory(provider);
                                    });
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
                },
              ),
            ),
          ),
          // スクロールトップボタン
          if (_showScrollToTop)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: _primaryColor.withValues(alpha: 0.9),
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardGradientStart, _cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
            color: _primaryColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Stack(
        children: [
          // 装飾的な背景パターン
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primaryColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _secondaryColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // メインコンテンツ
          Column(
            children: [
              // アイコンとタイトル
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'SBテキサスホールデム\nハンド分析AI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: _textPrimaryColor,
                            letterSpacing: 1.2,
                            height: 1.3,
                            fontFamily: 'Noto Sans JP',
                            shadows: [
                              Shadow(
                                color: Colors.white,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: _primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _primaryColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'AI分析エンジン',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _primaryColor,
                              fontFamily: 'Noto Sans JP',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'プレイデータを分析して、戦略的なフィードバックを提供します',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _textSecondaryColor,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  fontFamily: 'Noto Sans JP',
                  shadows: [
                    Shadow(
                      color: Colors.white,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardGradientStart, _cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
            color: _primaryColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Stack(
        children: [
          // 装飾的な背景パターン
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _secondaryColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // メインコンテンツ
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ヘッダー部分
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _primaryColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animationController.value * 0.1,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _primaryColor.withValues(alpha: 0.1),
                                  _secondaryColor.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: Icon(Icons.folder_open,
                                color: _primaryColor, size: 24),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ハンドデータをアップロード',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimaryColor,
                          fontFamily: 'Noto Sans JP',
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ボタン部分
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _primaryColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: _buildActionButton(
                        '📁 データ読み込み',
                        const Color(0xFFF3F4F6),
                        () {
                          HapticFeedback.mediumImpact();
                          context.read<PokerAnalysisProvider>().loadJsonFile();
                        },
                        textColor: _textPrimaryColor,
                        icon: null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: _buildActionButton(
                        '🎮 自動データ読み込み',
                        const Color(0xFFE6F4EA),
                        () {
                          HapticFeedback.mediumImpact();
                          context.read<PokerAnalysisProvider>().loadDemoData();
                        },
                        textColor: _textPrimaryColor,
                        icon: null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJsonFormatCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardGradientStart, _cardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: _primaryColor.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: _textPrimaryColor,
          fontFamily: 'Fira Code',
          fontSize: 13,
          height: 1.5,
          letterSpacing: 0.5,
        ),
        child: _buildJsonFormatInfo(),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color backgroundColor,
    VoidCallback onPressed, {
    Color? textColor,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _primaryColor.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor ?? _primaryColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? _primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Noto Sans JP',
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJsonFormatInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
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
              color: Colors.white.withValues(alpha: 0.8),
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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardGradientStart, _cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2.2),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            '分析中...',
            style: TextStyle(
              color: _textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Noto Sans JP',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(PokerAnalysisProvider provider) {
    return Column(
      children: [
        // 分析結果ヘッダー
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_cardGradientStart, _cardGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: _primaryColor, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    '分析結果',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (provider.stats != null) _buildStatsGrid(provider.stats!),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ハンドレンジ分析を最初に表示
        if (provider.rangeData.isNotEmpty)
          _buildHandRangeAnalysisSection(provider),
        const SizedBox(height: 20),

        // 詳細ハンド分析を2番目に表示
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_cardGradientStart, _cardGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
                color: _primaryColor.withValues(alpha: 0.15), width: 1.5),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border:
            Border.all(color: _primaryColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondaryColor,
              fontWeight: FontWeight.w500,
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
        Row(
          children: [
            Icon(Icons.psychology, color: _primaryColor, size: 24),
            const SizedBox(width: 10),
            const Text(
              '詳細ハンド分析',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),
          ],
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border:
            Border.all(color: _primaryColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ハンド #${hand.handId}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hand.result == 'win'
                      ? _successColor.withValues(alpha: 0.1)
                      : _errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hand.result == 'win'
                        ? _successColor.withValues(alpha: 0.3)
                        : _errorColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  hand.result == 'win' ? '勝利' : '敗北',
                  style: TextStyle(
                    color: hand.result == 'win' ? _successColor : _errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ポジション: ${_translatePosition(hand.position)}',
            style: TextStyle(color: _textSecondaryColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            'ホールカード:',
            style: TextStyle(
              color: _textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildCardsRow(hand.yourCards),
          const SizedBox(height: 12),
          Text(
            'コミュニティカード:',
            style: TextStyle(
              color: _textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildCardsRow(hand.communityCards),
          const SizedBox(height: 16),
          Text(
            'アクション:',
            style: TextStyle(
              color: _textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildActionsRow(hand.actions),
          const SizedBox(height: 16),
          _buildFeedbackSection(hand),
          if (gtoRecommendation != null) ...[
            const SizedBox(height: 16),
            _buildGTORecommendationCard(hand, gtoRecommendation),
          ],

          // 相手プレイヤーのハンド表示を追加
          if (hand.opponents != null && hand.opponents!.isNotEmpty) ...[
            const SizedBox(height: 16),
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
    bool isRed = card.contains('♥') ||
        card.contains('♦') ||
        card.contains('h') ||
        card.contains('d');

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '${action.street}: ${action.action}${action.amount > 0 ? ' ${action.amount.toInt()}' : ''}',
        style: TextStyle(
          color: _primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(HandData hand) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _successColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: _successColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI フィードバック',
                style: TextStyle(
                  color: _successColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _generateFeedback(hand),
            style: TextStyle(
              color: _textPrimaryColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGTOAnalysisSection(PokerAnalysisProvider provider) {
    final applicableHands = provider.hands
        .where((hand) =>
            hand.position.toLowerCase() == 'button' &&
            hand.communityCards.length >= 3 &&
            hand.actions.any((a) => a.street == 'flop'))
        .toList();

    if (applicableHands.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_cardGradientStart, _cardGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.8), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology, color: _primaryColor, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'GTO戦略分析（BTN vs BB フロップ）',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'BTNポジションでフロップをプレイしたハンドがないため、GTO分析は利用できません。',
              style: TextStyle(color: _textSecondaryColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GTO分析に必要な条件:',
                    style: TextStyle(
                      color: _textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '✅ ボタンポジション（BTN）でのプレイ\n'
                    '✅ フロップ（3枚のコミュニティカード）が配られている\n'
                    '✅ フロップでアクション（ベット、チェック等）を行っている\n'
                    '✅ ビッグブラインド（BB）との対戦',
                    style: TextStyle(color: _textSecondaryColor, fontSize: 13),
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

    final gtoCompliance =
        totalAnalyzed > 0 ? (gtoOptimalCount / totalAnalyzed) * 100 : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardGradientStart, _cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
            color: _primaryColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.psychology, color: _primaryColor, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'GTO戦略分析（BTN vs BB フロップ）',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '分析対象: $totalAnalyzed ハンド（全${provider.hands.length}ハンド中）',
                  style: TextStyle(
                      color: _textPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'ボタンポジションでのフロップ戦略をGTO理論と比較分析します',
                  style: TextStyle(color: _textSecondaryColor, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Individual hand analysis
          if (gtoResults.isNotEmpty) ...[
            Text(
              'ハンド別GTO分析',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),
            const SizedBox(height: 15),
            ...gtoResults.map((result) => _buildGTOHandAnalysisCard(result)),
          ],

          const SizedBox(height: 20),

          // Summary statistics
          if (totalAnalyzed > 0)
            _buildGTOSummaryStats(
                totalAnalyzed, gtoOptimalCount, gtoCompliance),

          const SizedBox(height: 15),
          _buildGTOPerformanceIndicator(gtoCompliance),
        ],
      ),
    );
  }

  Widget _buildGTOHandAnalysisCard(Map<String, dynamic> result) {
    final hand = result['hand'] as HandData;
    final gtoRec = result['gtoRec'] as GTORecommendation;
    final actualAction = result['actualAction'] as String;
    final isOptimal = result['isOptimal'] as bool;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // タイムライン
          _buildTimeline(isOptimal),
          const SizedBox(width: 12),
          // 分析コンテンツ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandHeader(hand, gtoRec),
                const SizedBox(height: 12),
                _buildGTOActionCard(gtoRec),
                const SizedBox(height: 12),
                _buildActualActionCard(actualAction, isOptimal),
                const SizedBox(height: 12),
                _buildActionFrequencies(gtoRec),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(bool isOptimal) {
    return Container(
      width: 12,
      decoration: BoxDecoration(
        color:
            (isOptimal ? _successColor : _errorColor).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Container(
          width: 4,
          decoration: BoxDecoration(
            color: isOptimal ? _successColor : _errorColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHandHeader(HandData hand, GTORecommendation gtoRec) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cards
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Hand: ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ...hand.yourCards.map((c) => _buildPlayingCard(c)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text("Board: ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ...gtoRec.board.map((c) => _buildPlayingCard(c)),
              ],
            ),
          ],
        ),
        // EV and Similarity
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'EV: ${gtoRec.ev.toStringAsFixed(1)}',
              style: TextStyle(
                color: _textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (!gtoRec.isExactMatch) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _warningColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gtoRec.similarityScore != null
                      ? '類似 ${(gtoRec.similarityScore! * 100).toStringAsFixed(0)}%'
                      : '類似',
                  style: TextStyle(
                    color: _warningColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildGTOActionCard(GTORecommendation gtoRec) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: _primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'GTO推奨アクション',
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: 'アクション: ',
              style: TextStyle(color: _textSecondaryColor, fontSize: 13),
              children: [
                TextSpan(
                  text:
                      '${gtoRec.bestAction} (${gtoRec.bestFrequency.toStringAsFixed(1)}%)',
                  style: TextStyle(
                      color: _primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'エクイティ: ${gtoRec.equity.toStringAsFixed(1)}%',
            style: TextStyle(color: _textSecondaryColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActualActionCard(String actualAction, bool isOptimal) {
    final color = isOptimal ? _successColor : _errorColor;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isOptimal ? Icons.check_circle : Icons.warning,
                  color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                '実際のアクション',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: 'アクション: ',
              style: TextStyle(color: _textSecondaryColor, fontSize: 13),
              children: [
                TextSpan(
                  text: actualAction,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isOptimal ? 'GTO最適' : 'GTO非最適',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFrequencies(GTORecommendation gtoRec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'アクション頻度:',
          style: TextStyle(
            color: _textSecondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: gtoRec.allActions.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${entry.key}: ${entry.value.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGTOSummaryStats(
      int totalAnalyzed, int gtoOptimalCount, double gtoCompliance) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
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
              color: Colors.blue.withValues(alpha: 0.2),
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
                  _buildImprovementPoint(
                      'フロップベッティング頻度の調整: GTOでは状況に応じてベット/チェックを使い分けます'),
                  _buildImprovementPoint(
                      'ベットサイズの最適化: ポットサイズに対する適切なベット額（30%、50%、100%）を学習しましょう'),
                  _buildImprovementPoint(
                      'ボードテクスチャの理解: ドロー系ボードとペア系ボードで戦略を変えましょう'),
                ] else if (gtoCompliance < 80) ...[
                  _buildImprovementPoint('バランス調整: 強いハンドと弱いハンドの混合頻度を最適化しましょう'),
                  _buildImprovementPoint(
                      'ポジション活用: BTNの有利性を最大限活かした積極的なプレイを心がけましょう'),
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
            color: Colors.white.withValues(alpha: 0.8),
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
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
              color: isOptimal
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 5,
              alignment: WrapAlignment.start,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      double streetStartPot =
          hand.streetPots?['flop'] ?? _calculateFlopStartPot(hand);
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
      indicatorColor = Colors.purple;
      performanceText = '🏆 優秀: GTO理論に非常に近いプレイができています！';
    } else if (compliance >= 60) {
      indicatorColor = Colors.purple.shade300;
      performanceText = '📈 良好: 概ねGTOに沿ったプレイです。さらなる向上の余地があります。';
    } else {
      indicatorColor = Colors.purple.shade200;
      performanceText = '⚠️ 要改善: GTO理論との乖離が大きいです。戦略の見直しをお勧めします。';
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: indicatorColor, width: 4)),
      ),
      child: Text(
        performanceText,
        style: TextStyle(color: indicatorColor),
      ),
    );
  }

  bool _isRedCard(String card) {
    return card.contains('♥') ||
        card.contains('♦') ||
        card.contains('h') ||
        card.contains('d');
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
        : 'ポジションを考慈したプレイを心がけましょう。';

    String resultFeedback =
        hand.result == 'win' ? '良いプレイで勝利を収めました！' : '次回はより戦略的なアプローチを検討してみてください。';

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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardGradientStart, _cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
            color: _primaryColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_on, color: _primaryColor, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '📊 プリフロップハンドレンジ分析',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPositionRangeAnalysis(provider),
        ],
      ),
    );
  }

  Widget _buildPositionRangeAnalysis(PokerAnalysisProvider provider) {
    const positions = ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'];

    return Column(
      children: positions.map((position) {
        final positionHands = provider.hands
            .where((h) => _translatePositionToShort(h.position) == position)
            .toList();

        if (positionHands.isEmpty) return const SizedBox.shrink();

        return _buildPositionCard(position, positionHands, provider);
      }).toList(),
    );
  }

  Widget _buildPositionCard(
      String position, List<HandData> hands, PokerAnalysisProvider provider) {
    // デバッグ情報を削除（または条件付きで出力）
    // print('=== レンジ分析デバッグ ===');
    // print('ポジション: $position');
    // print('総ハンド数: ${hands.length}');
    // print('レンジデータ数: ${provider.rangeData.length}');

    final playedHands = hands
        .map((h) {
          final normalized = provider.normalizeHand(h.yourCards);
          // print('ハンド: ${h.yourCards} -> 正規化: $normalized');
          return normalized;
        })
        .where((h) => h.isNotEmpty)
        .toList();

    // print('正規化後のプレイハンド数: ${playedHands.length}');
    // print('プレイハンド: $playedHands');

    // ポジション名をレンジデータ用に変換
    final rangePosition = _convertPositionForRange(position);
    // print('レンジ用ポジション名: $rangePosition');

    final optimalRange = provider.getOptimalRange(rangePosition);
    // print('最適レンジ: $optimalRange');
    // print('レンジ内ハンド数: ${optimalRange.values.expand((x) => x).length}');

    final allRecommendedHands = [
      ...optimalRange['raise']!,
      ...optimalRange['raiseOrCall']!,
      ...optimalRange['raiseOrFold']!,
      ...optimalRange['call']!,
    ];

    final inRange =
        playedHands.where((hand) => allRecommendedHands.contains(hand)).length;
    final tooLoose =
        playedHands.where((hand) => !allRecommendedHands.contains(hand)).length;
    final rangeCompliance = playedHands.isNotEmpty
        ? ((inRange / playedHands.length) * 100).toStringAsFixed(1)
        : '0';

    // print('レンジ内: $inRange, レンジ外: $tooLoose, 適合率: $rangeCompliance%');
    // print('========================');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$position (${_translatePosition(position.toLowerCase())})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: _buildRangeStat('プレイハンド数', '${playedHands.length}')),
                Expanded(child: _buildRangeStat('レンジ適合率', '$rangeCompliance%')),
                Expanded(child: _buildRangeStat('レンジ外プレイ', '$tooLoose')),
              ],
            ),
          ),

          const SizedBox(height: 12),

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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: _textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRangeGrid(Map<String, List<String>> optimalRange,
      List<String> playedHands, PokerAnalysisProvider provider) {
    final allHands = provider.generateAllHands();
    final playedSet = playedHands.toSet();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
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

  Widget _buildRangeCell(
      String hand, Map<String, List<String>> optimalRange, bool isPlayed) {
    Color backgroundColor = Colors.grey.withOpacity(0.3); // default: fold
    Color textColor = _textPrimaryColor;

    if (optimalRange['raise']!.contains(hand)) {
      backgroundColor = const Color(0xFFE74C3C); // レッド
      textColor = Colors.white;
    } else if (optimalRange['raiseOrCall']!.contains(hand)) {
      backgroundColor = const Color(0xFFF39C12); // オレンジ
      textColor = Colors.white;
    } else if (optimalRange['raiseOrFold']!.contains(hand)) {
      backgroundColor = const Color(0xFF3498DB); // ブルー
      textColor = Colors.white;
    } else if (optimalRange['call']!.contains(hand)) {
      backgroundColor = const Color(0xFF27AE60); // グリーン
      textColor = Colors.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: isPlayed
            ? Border.all(color: const Color(0xFFF1C40F), width: 2)
            : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: isPlayed
            ? [
                BoxShadow(
                  color: const Color(0xFFF1C40F).withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          hand,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildRangeLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildLegendItem(const Color(0xFFE74C3C), 'レイズ'),
          _buildLegendItem(const Color(0xFFF39C12), 'レイズかコール'),
          _buildLegendItem(const Color(0xFF3498DB), 'レイズかフォールド'),
          _buildLegendItem(const Color(0xFF27AE60), 'コール'),
          _buildLegendItem(Colors.grey.withOpacity(0.3), 'フォールド'),
          _buildLegendItem(Colors.transparent, '実際にプレイ',
              border: const Color(0xFFF1C40F)),
        ],
      ),
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
            boxShadow: border != null
                ? [
                    BoxShadow(
                      color: border.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: _textPrimaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOpponentsSection(HandData hand) {
    // プリフロップでフォールドしたプレイヤーを除外
    final activeOpponents = hand.opponents!.where((opponent) {
      // カード情報がない場合は除外（プリフロップフォールド）
      if (opponent.cards.isEmpty) return false;

      // アクション情報がある場合は、それを使って判定
      if (opponent.actions != null && opponent.actions!.isNotEmpty) {
        // プリフロップでフォールドしているかチェック
        final preflopActions =
            opponent.actions!.where((a) => a.street == 'preflop').toList();
        if (preflopActions.isNotEmpty) {
          final lastPreflopAction = preflopActions.last;
          if (lastPreflopAction.action == 'fold') {
            // print('${opponent.name}: プリフロップでフォールド');
            return false; // プリフロップフォールドは除外
          }
        }

        // フロップ以降のアクションがあるかチェック
        final postFlopActions =
            opponent.actions!.where((a) => a.street != 'preflop').toList();
        if (postFlopActions.isNotEmpty) {
          // print('${opponent.name}: フロップ以降にアクションあり');
          return true; // フロップ以降に参加
        }
      }

      // アクション情報がない場合は、従来の方法で判定
      // フォールドしているが、カード情報があり、かつベット額が少ない場合
      if (opponent.folded && opponent.totalBet <= 3) {
        // print('${opponent.name}: ベット額が少ないプリフロップフォールド (${opponent.totalBet})');
        return false;
      }

      // print('${opponent.name}: 表示対象');
      return true;
    }).toList();

    // デバッグ情報を削除
    // print('=== 相手プレイヤー表示デバッグ ===');
    // print('全相手プレイヤー数: ${hand.opponents?.length ?? 0}');
    // for (int i = 0; i < (hand.opponents?.length ?? 0); i++) {
    //   final opponent = hand.opponents![i];
    //   print('相手$i: ${opponent.name}, folded: ${opponent.folded}, cards: ${opponent.cards.length}枚, totalBet: ${opponent.totalBet}, アクション: ${opponent.actions?.map((a) => '${a.street}:${a.action}').join(', ')}');
    // }
    // print('表示対象プレイヤー数: ${activeOpponents.length}');
    // print('========================');

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(
                Icons.people,
                color: Colors.blue,
                size: 18,
              ),
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
            ? Colors.purple.shade200.withOpacity(0.1)
            : Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: opponent.folded
            ? Border.all(
                color: Colors.purple.shade200.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // プレイヤー名とポジション
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: opponent.folded
                      ? Colors.purple.shade200.withOpacity(0.3)
                      : Colors.purple.withOpacity(0.3),
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
              Text(
                _translatePosition(opponent.position),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              if (opponent.folded)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade200.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FOLD',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (opponent.totalBet > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  // ハンド分析時にミッション進捗を更新
  void _updateMissionProgress(PokerAnalysisProvider provider) {
    final missionProvider = context.read<MissionProvider>();

    // ハンドプレイの記録
    missionProvider.recordAction('play_hand');

    // 勝利の記録
    for (final hand in provider.hands) {
      if (hand.result.toLowerCase().contains('win') ||
          hand.result.toLowerCase().contains('勝利')) {
        missionProvider.recordAction('win_hand');
      }
    }

    // GTO使用の記録（GTOデータが読み込まれている場合）
    if (provider.gtoData.isNotEmpty) {
      missionProvider.recordAction('use_gto');
    }

    // レンジ使用の記録（レンジデータが読み込まれている場合）
    if (provider.rangeData.isNotEmpty) {
      missionProvider.recordAction('use_range');
    }

    // チップ獲得の記録
    int totalChipsEarned = 0;
    for (final hand in provider.hands) {
      if (hand.result.toLowerCase().contains('win') ||
          hand.result.toLowerCase().contains('勝利')) {
        totalChipsEarned += hand.potSize.toInt();
      }
    }
    if (totalChipsEarned > 0) {
      missionProvider.recordAction('earn_chips', value: totalChipsEarned);
    }

    // 分析結果を履歴に保存
    _saveAnalysisToHistory(provider);
  }

  // 分析結果を履歴に保存
  void _saveAnalysisToHistory(PokerAnalysisProvider provider) {
    if (provider.hands.isEmpty) return;

    final historyProvider = context.read<AnalysisHistoryProvider>();

    // 各ハンドを履歴に保存
    for (final hand in provider.hands) {
      // 勝率を計算（簡易版）
      final winRate = hand.result.toLowerCase().contains('win') ||
              hand.result.toLowerCase().contains('勝利')
          ? 0.7
          : 0.3;

      // 分析結果を判定
      final analysisResult = _determineAnalysisResult(hand, winRate, provider);

      // ハンドの説明を作成
      final handDescription = _createHandDescription(hand);

      // 詳細データを作成
      final handDetails = {
        'position': _translatePosition(hand.position),
        'stack': _estimateStackSize(hand),
        'action': _getMainAction(hand),
        'opponent': hand.opponents?.isNotEmpty == true
            ? hand.opponents!.first.name
            : 'Unknown',
        'potSize': hand.potSize,
        'result': hand.result,
      };

      // 詳細メモを作成
      final notes = _createDetailedNotes(hand, winRate, provider);

      // タグを決定
      final tags = _determineTags(hand, provider);

      // 履歴を作成して保存
      final history = historyProvider.createHistoryFromAnalysis(
        handDescription: handDescription,
        winRate: winRate,
        analysisResult: analysisResult,
        handDetails: handDetails,
        notes: notes,
        tags: tags,
      );

      historyProvider.addHistory(history);
    }
  }

  // 詳細な勝率計算
  double _calculateDetailedWinRate(
      HandData hand, PokerAnalysisProvider provider) {
    double baseWinRate = 0.5; // ベース勝率

    // 結果に基づく調整
    if (hand.result.toLowerCase().contains('win') ||
        hand.result.toLowerCase().contains('勝利')) {
      baseWinRate = 0.7; // 勝利した場合は高い勝率
    } else if (hand.result.toLowerCase().contains('lose') ||
        hand.result.toLowerCase().contains('敗北')) {
      baseWinRate = 0.3; // 敗北した場合は低い勝率
    } else if (hand.result.toLowerCase().contains('tie') ||
        hand.result.toLowerCase().contains('引き分け')) {
      baseWinRate = 0.5; // 引き分けは中程度
    }

    // ポットサイズに基づく調整
    if (hand.potSize > 100) {
      baseWinRate += 0.05; // 大きなポットは少し勝率を上げる
    } else if (hand.potSize < 20) {
      baseWinRate -= 0.05; // 小さなポットは少し勝率を下げる
    }

    // アクションに基づく調整
    final action = _getMainAction(hand);
    switch (action) {
      case 'fold':
        baseWinRate -= 0.1; // フォールドは勝率を下げる
        break;
      case 'raise':
      case '3bet':
      case '4bet':
        baseWinRate += 0.05; // アグレッシブなアクションは勝率を上げる
        break;
      case 'call':
        baseWinRate += 0.02; // コールは少し勝率を上げる
        break;
    }

    // 0.0-1.0の範囲に制限
    return baseWinRate.clamp(0.0, 1.0);
  }

  // 分析結果の判定
  String _determineAnalysisResult(
      HandData hand, double winRate, PokerAnalysisProvider provider) {
    // 勝率に基づく基本判定
    if (winRate >= 0.6) {
      return '適切なプレイ';
    } else if (winRate <= 0.4) {
      return '改善の余地あり';
    } else {
      return '境界線のプレイ';
    }
  }

  // スタックサイズの推定
  String _estimateStackSize(HandData hand) {
    // ポットサイズからスタックサイズを推定
    if (hand.potSize > 200) {
      return '200BB+';
    } else if (hand.potSize > 100) {
      return '150BB';
    } else if (hand.potSize > 50) {
      return '100BB';
    } else if (hand.potSize > 20) {
      return '80BB';
    } else {
      return '50BB';
    }
  }

  // ハンドの説明作成
  String _createHandDescription(HandData hand) {
    final yourHand = hand.yourCards.join('');
    final opponentHand = _getOpponentHand(hand);

    if (hand.communityCards.isNotEmpty) {
      // コミュニティカードがある場合はストリートを特定
      String street = 'プリフロップ';
      if (hand.communityCards.length == 3) {
        street = 'フロップ';
      } else if (hand.communityCards.length == 4) {
        street = 'ターン';
      } else if (hand.communityCards.length == 5) {
        street = 'リバー';
      }
      return '$yourHand vs $opponentHand $street';
    } else {
      return '$yourHand vs $opponentHand プリフロップ';
    }
  }

  // 詳細なメモ作成
  String _createDetailedNotes(
      HandData hand, double winRate, PokerAnalysisProvider provider) {
    List<String> notes = [];

    // 基本情報
    notes.add('ポットサイズ: ${hand.potSize.toInt()}BB');
    notes.add('結果: ${hand.result}');
    notes.add('勝率: ${(winRate * 100).toStringAsFixed(1)}%');

    // アクション情報
    final action = _getMainAction(hand);
    if (action != 'unknown') {
      notes.add('メインアクション: $action');
    }

    // 相手情報
    if (hand.opponents?.isNotEmpty == true) {
      final opponent = hand.opponents!.first;
      notes.add(
          '相手: ${opponent.name} (${_translatePositionToShort(opponent.position)})');
      if (opponent.totalBet > 0) {
        notes.add('相手ベット: ${opponent.totalBet.toInt()}BB');
      }
    }

    // GTO分析情報
    if (provider.gtoData.isNotEmpty) {
      notes.add('GTO分析: 利用可能');
    }

    // レンジ分析情報
    if (provider.rangeData.isNotEmpty) {
      notes.add('レンジ分析: 利用可能');
    }

    return notes.join(', ');
  }

  // タグの決定
  List<String> _determineTags(HandData hand, PokerAnalysisProvider provider) {
    List<String> tags = ['自動分析'];

    // 結果に基づくタグ
    if (hand.result.toLowerCase().contains('win') ||
        hand.result.toLowerCase().contains('勝利')) {
      tags.add('勝利');
    } else if (hand.result.toLowerCase().contains('lose') ||
        hand.result.toLowerCase().contains('敗北')) {
      tags.add('敗北');
    }

    // アクションに基づくタグ
    final action = _getMainAction(hand);
    if (action == '3bet' || action == '4bet') {
      tags.add('アグレッシブ');
    } else if (action == 'fold') {
      tags.add('フォールド');
    }

    // ポットサイズに基づくタグ
    if (hand.potSize > 100) {
      tags.add('大ポット');
    } else if (hand.potSize < 20) {
      tags.add('小ポット');
    }

    // 分析ツールに基づくタグ
    if (provider.gtoData.isNotEmpty) {
      tags.add('GTO分析');
    }
    if (provider.rangeData.isNotEmpty) {
      tags.add('レンジ分析');
    }

    return tags;
  }

  // メインアクションを取得
  String _getMainAction(HandData hand) {
    if (hand.actions == null || hand.actions!.isEmpty) return 'unknown';

    // プリフロップの最後のアクションを取得
    final preflopActions =
        hand.actions!.where((a) => a.street == 'preflop').toList();
    if (preflopActions.isNotEmpty) {
      final lastAction = preflopActions.last.action.toLowerCase();
      if (lastAction.contains('raise')) return 'raise';
      if (lastAction.contains('call')) return 'call';
      if (lastAction.contains('fold')) return 'fold';
      if (lastAction.contains('3bet')) return '3bet';
      if (lastAction.contains('4bet')) return '4bet';
    }

    return 'unknown';
  }

  // 相手のハンドを取得
  String _getOpponentHand(HandData hand) {
    if (hand.opponents?.isNotEmpty == true) {
      final opponent = hand.opponents!.first;
      if (opponent.cards.isNotEmpty) {
        return opponent.cards.join('');
      }
    }
    return 'Unknown';
  }

  // 連勝記録の更新
  void _updateWinStreak(PokerAnalysisProvider provider) {
    final missionProvider = context.read<MissionProvider>();
    int currentStreak = 0;

    // 最新のハンドから連勝を計算
    for (int i = provider.hands.length - 1; i >= 0; i--) {
      final hand = provider.hands[i];
      if (hand.result.toLowerCase().contains('win') ||
          hand.result.toLowerCase().contains('勝利')) {
        currentStreak++;
      } else {
        break;
      }
    }

    if (currentStreak > 0) {
      missionProvider.recordWinStreak(currentStreak);
    }
  }

  String _convertPositionForRange(String position) {
    const map = {
      'UTG': 'UTG',
      'HJ': 'HJ',
      'CO': 'CO',
      'BTN': 'BTN',
      'SB': 'SB',
      'BB': 'BB',
      'button': 'BTN',
      'small_blind': 'SB',
      'big_blind': 'BB',
      'under_the_gun': 'UTG',
      'middle_position': 'CO',
      'late_position': 'HJ',
      'hijack': 'HJ',
      'cutoff': 'CO',
    };
    return map[position] ?? position;
  }
}
