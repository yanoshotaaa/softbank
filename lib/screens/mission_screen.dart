import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/common_header.dart';
import '../providers/mission_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({Key? key}) : super(key: key);

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  List<AnimationController> _listAnimationControllers = [];

  final ScrollController _scrollController = ScrollController();
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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _listAnimationControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // 背景グラデーション
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
          // 共通ヘッダー
          Positioned(
            top: statusBarHeight,
            left: 0,
            right: 0,
            child: const CommonHeader(),
          ),
          // メインコンテンツ
          Positioned.fill(
            top: statusBarHeight + 56,
            child: Consumer<MissionProvider>(
              builder: (context, missionProvider, child) {
                if (missionProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final missions = missionProvider.availableMissions;

                // アニメーションコントローラーを初期化（Consumerの外で実行）
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_listAnimationControllers.length != missions.length) {
                    // 既存のコントローラーを破棄
                    for (var controller in _listAnimationControllers) {
                      controller.dispose();
                    }

                    _listAnimationControllers = List.generate(
                      missions.length,
                      (index) => AnimationController(
                        vsync: this,
                        duration: const Duration(milliseconds: 400),
                      ),
                    );

                    for (int i = 0; i < _listAnimationControllers.length; i++) {
                      Future.delayed(Duration(milliseconds: 100 * (i + 1)), () {
                        if (mounted && i < _listAnimationControllers.length) {
                          _listAnimationControllers[i].forward();
                        }
                      });
                    }
                  }
                });

                return CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildMissionHeader(missionProvider),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildAnimatedMissionCard(
                              missions[index], index, missionProvider);
                        },
                        childCount: missions.length,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 40),
                    ),
                  ],
                );
              },
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
                backgroundColor: _primaryColor,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMissionCard(
      Mission mission, int index, MissionProvider missionProvider) {
    // インデックスが範囲外の場合は通常のカードを返す
    if (index >= _listAnimationControllers.length) {
      return _buildMissionCard(mission, missionProvider);
    }

    final controller = _listAnimationControllers[index];
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: slideAnimation,
        child: _buildMissionCard(mission, missionProvider),
      ),
    );
  }

  SliverToBoxAdapter _buildMissionHeader(MissionProvider missionProvider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.flagCheckered,
                    color: _primaryColor, size: 32),
                const SizedBox(width: 16),
                const Text(
                  'ミッション',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textPrimaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '挑戦して報酬を獲得しよう！',
              style: TextStyle(
                fontSize: 15,
                color: _textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.coins,
                    color: _warningColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  '総獲得ポイント: ${missionProvider.totalPoints} P',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textPrimaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '完了: ${missionProvider.completedMissionsCount}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(Mission mission, MissionProvider missionProvider) {
    final progress = missionProvider.getMissionProgress(mission.id);
    final isCompleted = progress?.isCompleted ?? false;
    final isRewardClaimed = progress?.isRewardClaimed ?? false;
    final currentProgress = progress?.progress ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.05)
            : _cardGradientStart,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? _successColor.withValues(alpha: 0.3)
              : _primaryColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(mission, isCompleted),
          const SizedBox(height: 16),
          Text(
            mission.description,
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondaryColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(mission, currentProgress),
          const SizedBox(height: 16),
          _buildCardFooter(
              mission, missionProvider, isCompleted, isRewardClaimed),
        ],
      ),
    );
  }

  Row _buildCardHeader(Mission mission, bool isCompleted) {
    IconData icon;
    switch (mission.category) {
      case 'beginner':
        icon = FontAwesomeIcons.seedling;
        break;
      case 'intermediate':
        icon = FontAwesomeIcons.rocket;
        break;
      case 'advanced':
        icon = FontAwesomeIcons.crown;
        break;
      case 'daily':
        icon = FontAwesomeIcons.calendarDay;
        break;
      default:
        icon = FontAwesomeIcons.question;
    }
    return Row(
      children: [
        FaIcon(icon, color: _primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            mission.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textPrimaryColor,
            ),
          ),
        ),
        if (isCompleted)
          const FaIcon(FontAwesomeIcons.solidCheckCircle,
              color: _successColor, size: 24),
      ],
    );
  }

  Column _buildProgressBar(Mission mission, int currentProgress) {
    final double progress =
        mission.target > 0 ? currentProgress / mission.target : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '進捗',
              style: TextStyle(
                fontSize: 12,
                color: _textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$currentProgress / ${mission.target}',
              style: const TextStyle(
                fontSize: 12,
                color: _textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: _primaryColor.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(_successColor),
          ),
        ),
      ],
    );
  }

  Row _buildCardFooter(Mission mission, MissionProvider missionProvider,
      bool isCompleted, bool isRewardClaimed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const FaIcon(FontAwesomeIcons.coins,
                color: _warningColor, size: 16),
            const SizedBox(width: 8),
            Text(
              '報酬: ${mission.reward} P',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),
          ],
        ),
        if (isCompleted && !isRewardClaimed)
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final success = await missionProvider.claimReward(mission.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${mission.reward}ポイントを獲得しました！'),
                    backgroundColor: _successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('受け取る'),
          )
        else if (isRewardClaimed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _textSecondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '受け取り済み',
              style: TextStyle(
                color: _textSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
