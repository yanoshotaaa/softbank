import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_header.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
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

  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  List<AnimationController>? _rankAnimations;
  List<Animation<double>>? _rankFadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // パルスアニメーションの初期化
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController!,
        curve: Curves.easeInOut,
      ),
    );

    // ランキングアニメーションの初期化
    _rankAnimations = List.generate(
      10,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + (index * 100)),
      ),
    );

    _rankFadeAnimations = _rankAnimations!.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );
    }).toList();

    // アニメーションを順次開始
    for (var controller in _rankAnimations!) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _rankAnimations?.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pulseAnimation == null || _rankFadeAnimations == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = 56;
    final List<Map<String, dynamic>> rankingData = [
      {'rank': 1, 'name': 'SHOOTER', 'score': 3200, 'trend': '+2'},
      {'rank': 2, 'name': 'POKERKING', 'score': 2800, 'trend': '-1'},
      {'rank': 3, 'name': 'AI_BOT', 'score': 2500, 'trend': '+3'},
      {'rank': 4, 'name': 'YUKI', 'score': 2100, 'trend': '0'},
      {'rank': 5, 'name': 'TAKASHI', 'score': 1800, 'trend': '-2'},
      {'rank': 6, 'name': 'POKERMASTER', 'score': 1700, 'trend': '+1'},
      {'rank': 7, 'name': 'CARDWIZARD', 'score': 1650, 'trend': '-1'},
      {'rank': 8, 'name': 'ALLIN', 'score': 1600, 'trend': '+2'},
      {'rank': 9, 'name': 'BLUFFKING', 'score': 1550, 'trend': '0'},
      {'rank': 10, 'name': 'FOLDMASTER', 'score': 1500, 'trend': '-1'},
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // 背景グラデーション
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primaryColor.withOpacity(0.95),
                  _secondaryColor.withOpacity(0.95),
                  _backgroundColor.withOpacity(0.95),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // 装飾的な背景要素
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _pulseAnimation!,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _pulseAnimation!.value * 0.1,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _primaryColor.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // ステータスバー部分を白で塗りつぶす
          Container(
            width: double.infinity,
            height: statusBarHeight,
            color: Colors.white,
          ),
          // 共通ヘッダー
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイトル＋トロフィー
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation!,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseAnimation!.value * 0.1),
                              child: const Icon(
                                Icons.emoji_events,
                                color: Color(0xFFFFD700),
                                size: 32,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '週間ランキング',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D28D9),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.update,
                                size: 16,
                                color: Colors.purple.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '更新まで 2:30',
                                style: TextStyle(
                                  color: Colors.purple.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ランキングリスト
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: rankingData.length,
                      separatorBuilder: (context, i) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = rankingData[i];
                        return AnimatedBuilder(
                          animation: _rankFadeAnimations![i],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  0, 50 * (1 - _rankFadeAnimations![i].value)),
                              child: Opacity(
                                opacity: _rankFadeAnimations![i].value,
                                child: _RankCard(
                                  rank: item['rank'],
                                  name: item['name'],
                                  score: item['score'],
                                  trend: item['trend'],
                                  isTopThree: i < 3,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final String trend;
  final bool isTopThree;

  const _RankCard({
    required this.rank,
    required this.name,
    required this.score,
    required this.trend,
    required this.isTopThree,
  });

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // 金
      case 2:
        return const Color(0xFFC0C0C0); // 銀
      case 3:
        return const Color(0xFFCD7F32); // 銅
      default:
        return _RankingScreenState._primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // ユーザープロフィールへ遷移
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _RankingScreenState._cardGradientStart,
                _RankingScreenState._cardGradientEnd
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _RankingScreenState._primaryColor.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: rankColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Noto Sans JP',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: _RankingScreenState._textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Noto Sans JP',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$score pt',
                      style: TextStyle(
                        color: _RankingScreenState._textSecondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Noto Sans JP',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: trend.startsWith('+')
                      ? _RankingScreenState._successColor.withOpacity(0.1)
                      : trend.startsWith('-')
                          ? _RankingScreenState._errorColor.withOpacity(0.1)
                          : _RankingScreenState._textSecondaryColor
                              .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: trend.startsWith('+')
                        ? _RankingScreenState._successColor.withOpacity(0.2)
                        : trend.startsWith('-')
                            ? _RankingScreenState._errorColor.withOpacity(0.2)
                            : _RankingScreenState._textSecondaryColor
                                .withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trend.startsWith('+')
                          ? Icons.arrow_upward
                          : trend.startsWith('-')
                              ? Icons.arrow_downward
                              : Icons.remove,
                      color: trend.startsWith('+')
                          ? _RankingScreenState._successColor
                          : trend.startsWith('-')
                              ? _RankingScreenState._errorColor
                              : _RankingScreenState._textSecondaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: trend.startsWith('+')
                            ? _RankingScreenState._successColor
                            : trend.startsWith('-')
                                ? _RankingScreenState._errorColor
                                : _RankingScreenState._textSecondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Noto Sans JP',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
