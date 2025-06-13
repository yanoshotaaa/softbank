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
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // 豪華なグラデーション背景
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFB993D6).withOpacity(0.95),
                  const Color(0xFF8CA6DB).withOpacity(0.95),
                  const Color(0xFFF3E6FF).withOpacity(0.95),
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
                          Colors.purple.withOpacity(0.1),
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
        return Colors.purple;
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: rankColor.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 6),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isTopThree
                  ? rankColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.7),
              width: isTopThree ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      rankColor.withOpacity(0.8),
                      rankColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isTopThree
                      ? Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 24,
                        )
                      : Text(
                          rank.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTrendColor(trend).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTrendIcon(trend),
                                color: _getTrendColor(trend),
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                trend,
                                style: TextStyle(
                                  color: _getTrendColor(trend),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: rankColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$score pt',
                  style: TextStyle(
                    color: rankColor.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTrendColor(String trend) {
    if (trend.startsWith('+')) return Colors.green;
    if (trend == '0') return Colors.grey;
    return Colors.red;
  }

  IconData _getTrendIcon(String trend) {
    if (trend.startsWith('+')) return Icons.arrow_upward;
    if (trend == '0') return Icons.remove;
    return Icons.arrow_downward;
  }
}
