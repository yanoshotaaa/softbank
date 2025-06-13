import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_header.dart';
import 'plan_diagnosis_screen.dart';
import 'store_reservation_screen.dart';

class HomeContent extends StatefulWidget {
  final Function(int)? onTabSelected;

  const HomeContent({Key? key, this.onTabSelected}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  // カラーパレットの定義
  static const _primaryColor = Color(0xFF6B46C1); // メインカラー
  static const _secondaryColor = Color(0xFF9F7AEA); // アクセントカラー
  static const _backgroundColor = Color(0xFFF7FAFC); // 背景色
  static const _textPrimaryColor = Color(0xFF2D3748); // 主要テキスト色
  static const _textSecondaryColor = Color(0xFF718096); // 補助テキスト色
  static const _successColor = Color(0xFF48BB78); // 成功色
  static const _warningColor = Color(0xFFED8936); // 警告色
  static const _errorColor = Color(0xFFE53E3E); // エラー色
  static const _cardGradientStart = Color(0xFFF3E8FF); // カードグラデーション開始色
  static const _cardGradientEnd = Color(0xFFE9D8FD); // カードグラデーション終了色

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 200 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Stack(
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
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 0.1,
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
        // 固定ヘッダー
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: statusBarHeight),
            child: const CommonHeader(),
          ),
        ),
        // メインコンテンツ
        Positioned(
          top: statusBarHeight + 56,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ユーザー情報カード
                Container(
                  margin: const EdgeInsets.all(16),
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
                        color: _primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _primaryColor.withOpacity(0.8),
                                  _secondaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SHOOTER',
                                  style: TextStyle(
                                    color: _textPrimaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Noto Sans JP',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '次のレベルまで 300ポイント',
                                      style: TextStyle(
                                        color: _textSecondaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Noto Sans JP',
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _primaryColor.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Lv.7',
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Noto Sans JP',
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
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.65,
                          backgroundColor: _primaryColor.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              _primaryColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 統計情報
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.analytics,
                            value: '128',
                            label: '分析回数',
                            color: _primaryColor,
                          ),
                          _buildStatItem(
                            icon: Icons.emoji_events,
                            value: '85%',
                            label: '勝率',
                            color: _successColor,
                          ),
                          _buildStatItem(
                            icon: Icons.trending_up,
                            value: '2,500',
                            label: 'ポイント',
                            color: _warningColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // クイックアクションセクション
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'クイックアクション',
                        style: TextStyle(
                          color: _textPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Noto Sans JP',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildQuickActionCard(
                            icon: Icons.analytics,
                            title: '分析開始',
                            subtitle: '最新のハンドを分析',
                            color: _primaryColor,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              widget.onTabSelected?.call(1);
                            },
                          ),
                          _buildQuickActionCard(
                            icon: Icons.history,
                            title: '履歴',
                            subtitle: '過去の分析結果',
                            color: _primaryColor,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              widget.onTabSelected?.call(1);
                            },
                          ),
                          _buildQuickActionCard(
                            icon: Icons.emoji_events,
                            title: 'ランキング',
                            subtitle: '週間ランキング',
                            color: _primaryColor,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              widget.onTabSelected?.call(2);
                            },
                          ),
                          _buildQuickActionCard(
                            icon: Icons.flag,
                            title: 'ミッション',
                            subtitle: '達成状況を確認',
                            color: _primaryColor,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              widget.onTabSelected?.call(3);
                            },
                          ),
                          _buildQuickActionCard(
                            icon: Icons.phone_android,
                            title: '携帯プラン診断',
                            subtitle: 'あなたに最適なプランを診断',
                            color: _primaryColor,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlanDiagnosisScreen(),
                                ),
                              );
                            },
                          ),
                          _buildQuickActionCard(
                            icon: Icons.calendar_today,
                            title: '店舗予約',
                            subtitle: '店舗を予約する',
                            color: _primaryColor,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StoreReservationScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 携帯プラン診断セクション
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '携帯プラン診断',
                        style: TextStyle(
                          color: _textPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Noto Sans JP',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: 0.95, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _primaryColor.withOpacity(0.8),
                                _primaryColor.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const PlanDiagnosisScreen(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;
                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);
                                      return SlideTransition(
                                          position: offsetAnimation,
                                          child: child);
                                    },
                                    maintainState: true,
                                    fullscreenDialog: false,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // 装飾的な背景要素
                                  Positioned(
                                    right: -20,
                                    top: -20,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: -10,
                                    bottom: -10,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                  // メインコンテンツ
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.phone_android,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'あなたに最適なプランを診断',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Noto Sans JP',
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '現在の利用状況から最適なプランを提案',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 14,
                                                  fontFamily: 'Noto Sans JP',
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.bolt,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '診断は約3分',
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.9),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            'Noto Sans JP',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 24,
                                          ),
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
                    ],
                  ),
                ),
                // 最近の分析セクション
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '最近の分析',
                            style: TextStyle(
                              color: _textPrimaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Noto Sans JP',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              // 履歴画面へ遷移
                            },
                            child: Text(
                              'すべて見る',
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Noto Sans JP',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRecentAnalysisCard(
                        title: 'AKs vs QQ',
                        date: '2024/03/15',
                        result: '勝利',
                        isWin: true,
                      ),
                      const SizedBox(height: 12),
                      _buildRecentAnalysisCard(
                        title: 'JJ vs AKo',
                        date: '2024/03/14',
                        result: '敗北',
                        isWin: false,
                      ),
                    ],
                  ),
                ),
              ],
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
              backgroundColor: Colors.purple.withOpacity(0.9),
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: _textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Noto Sans JP',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _textSecondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Noto Sans JP',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: (MediaQuery.of(context).size.width - 48) / 2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: _primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: _textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Noto Sans JP',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: _textSecondaryColor.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Noto Sans JP',
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAnalysisCard({
    required String title,
    required String date,
    required String result,
    required bool isWin,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardGradientStart, _cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWin
                  ? _successColor.withOpacity(0.1)
                  : _errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isWin
                    ? _successColor.withOpacity(0.2)
                    : _errorColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              isWin ? Icons.emoji_events : Icons.trending_down,
              color: isWin ? _successColor : _errorColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Noto Sans JP',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: _textSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Noto Sans JP',
                  ),
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
              color: isWin
                  ? _successColor.withOpacity(0.1)
                  : _errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isWin
                    ? _successColor.withOpacity(0.2)
                    : _errorColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              result,
              style: TextStyle(
                color: isWin ? _successColor : _errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Noto Sans JP',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
