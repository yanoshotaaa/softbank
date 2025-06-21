import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with TickerProviderStateMixin {
  // カラーパレットの定義
  static const _primaryColor = Color(0xFF2C3E50);
  static const _secondaryColor = Color(0xFF34495E);
  static const _backgroundColor = Color(0xFFFAFAFA);
  static const _textPrimaryColor = Color(0xFF2C3E50);
  static const _textSecondaryColor = Color(0xFF7F8C8D);

  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      rankingData.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    _slideAnimations = _animationControllers.map((controller) {
      return Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = 56;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          Container(
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
          Positioned(
            top: statusBarHeight,
            left: 0,
            right: 0,
            child: const CommonHeader(),
          ),
          Positioned.fill(
            top: statusBarHeight + headerHeight,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildRankingHeader(),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = rankingData[index];
                      return FadeTransition(
                        opacity: _fadeAnimations[index],
                        child: SlideTransition(
                          position: _slideAnimations[index],
                          child: _buildRankItem(item, context),
                        ),
                      );
                    },
                    childCount: rankingData.length,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildRankingHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.trophy,
                    color: Color(0xFFF39C12), size: 32),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    '週間ランキング',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                      letterSpacing: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                const SizedBox(width: 16),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.update,
                          size: 16, color: _textSecondaryColor),
                      const SizedBox(width: 6),
                      Text(
                        '更新: 2時間前',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'トッププレイヤーたちの熱い戦いをチェックしよう！',
              style: TextStyle(
                fontSize: 15,
                color: _textSecondaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(Map<String, dynamic> item, BuildContext context) {
    final int rank = item['rank'];
    final bool isTopThree = rank <= 3;

    final Color cardColor;
    final Color borderColor;

    if (rank == 1) {
      cardColor = const Color(0xFFFFF9C4);
      borderColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      cardColor = const Color(0xFFF5F5F5);
      borderColor = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      cardColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFCD7F32);
    } else {
      cardColor = Colors.white;
      borderColor = Colors.grey.withValues(alpha: 0.2);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isTopThree ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          _buildRankIndicator(rank),
          const SizedBox(width: 16),
          _buildPlayerInfo(item),
          const Spacer(),
          _buildScoreAndTrend(item),
        ],
      ),
    );
  }

  Widget _buildRankIndicator(int rank) {
    if (rank <= 3) {
      IconData icon;
      Color color;
      if (rank == 1) {
        icon = FontAwesomeIcons.medal;
        color = const Color(0xFFFFD700);
      } else if (rank == 2) {
        icon = FontAwesomeIcons.medal;
        color = const Color(0xFFC0C0C0);
      } else {
        icon = FontAwesomeIcons.medal;
        color = const Color(0xFFCD7F32);
      }
      return FaIcon(icon, color: color, size: 36);
    } else {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _primaryColor.withValues(alpha: 0.1),
        ),
        child: Text(
          '$rank',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimaryColor,
          ),
        ),
      );
    }
  }

  Widget _buildPlayerInfo(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['name'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Score: ${item['score']}',
          style: const TextStyle(
            fontSize: 14,
            color: _textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreAndTrend(Map<String, dynamic> item) {
    final String trend = item['trend'];
    final bool isUp = trend.startsWith('+');
    final bool isDown = trend.startsWith('-');
    final Color trendColor =
        isUp ? Colors.green : (isDown ? Colors.red : _textSecondaryColor);
    final IconData trendIcon = isUp
        ? Icons.arrow_upward
        : (isDown ? Icons.arrow_downward : Icons.remove);

    return Row(
      children: [
        Text(
          '${item['score']}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            Icon(trendIcon, color: trendColor, size: 16),
            const SizedBox(width: 4),
            Text(
              trend.substring(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: trendColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
