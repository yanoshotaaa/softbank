import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_header.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

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
                const Color(0xFFA18CD1).withOpacity(0.95),
                const Color(0xFFFBC2EB).withOpacity(0.95),
              ],
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
        // スクロール可能な本体部分
        Positioned.fill(
          top: statusBarHeight + 64,
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ユーザー情報セクション
                    Container(
                      margin: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // アバター
                              AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(
                                              0.3 * _animation.value),
                                          blurRadius: 24 * _animation.value,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const CircleAvatar(
                                      radius: 36,
                                      backgroundColor: Color(0xFFE1BEE7),
                                      child: Icon(Icons.person,
                                          size: 44, color: Colors.purple),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 20),
                              // ユーザー情報
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'SHOOTER',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: Colors.purple,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.purple.withOpacity(0.8),
                                                Colors.purple.withOpacity(0.6),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.purple
                                                    .withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'VIP',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // 進捗バー
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: 0.7,
                                        backgroundColor:
                                            Colors.purple.withOpacity(0.1),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.purple),
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '次のレベルまで 300ポイント',
                                          style: TextStyle(
                                            color:
                                                Colors.purple.withOpacity(0.8),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Lv.7',
                                          style: TextStyle(
                                            color:
                                                Colors.purple.withOpacity(0.8),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
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
                          // 統計情報
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.analytics,
                                value: '128',
                                label: '分析回数',
                              ),
                              _buildStatItem(
                                icon: Icons.emoji_events,
                                value: '85%',
                                label: '勝率',
                              ),
                              _buildStatItem(
                                icon: Icons.trending_up,
                                value: '2,500',
                                label: 'ポイント',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // クイックアクションセクション
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'クイックアクション',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  // すべてのアクションを表示
                                },
                                icon: const Icon(
                                  Icons.grid_view,
                                  size: 18,
                                  color: Colors.purple,
                                ),
                                label: Text(
                                  'すべて',
                                  style: TextStyle(
                                    color: Colors.purple.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
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
                                color: Colors.purple,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  // 分析画面へ遷移
                                },
                              ),
                              _buildQuickActionCard(
                                icon: Icons.history,
                                title: '履歴',
                                subtitle: '過去の分析結果',
                                color: Colors.blue,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  // 履歴画面へ遷移
                                },
                              ),
                              _buildQuickActionCard(
                                icon: Icons.emoji_events,
                                title: 'ランキング',
                                subtitle: '週間ランキング',
                                color: Colors.amber,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  // ランキング画面へ遷移
                                },
                              ),
                              _buildQuickActionCard(
                                icon: Icons.flag,
                                title: 'ミッション',
                                subtitle: '達成状況を確認',
                                color: Colors.green,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  // ミッション画面へ遷移
                                },
                              ),
                            ],
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  // すべての分析結果へ遷移
                                },
                                icon: const Icon(
                                  Icons.history,
                                  size: 18,
                                  color: Colors.purple,
                                ),
                                label: Text(
                                  'すべて見る',
                                  style: TextStyle(
                                    color: Colors.purple.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildRecentAnalysisCard(
                            hand: 'A♠ K♠',
                            result: '勝利',
                            date: '2024/03/20',
                            compliance: 0.85,
                            potSize: '12,500',
                            position: 'BTN',
                          ),
                          const SizedBox(height: 12),
                          _buildRecentAnalysisCard(
                            hand: 'Q♥ Q♦',
                            result: '敗北',
                            date: '2024/03/19',
                            compliance: 0.65,
                            potSize: '8,200',
                            position: 'CO',
                          ),
                        ],
                      ),
                    ),
                  ],
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
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.purple, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.purple.withOpacity(0.7),
              fontSize: 12,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnalysisCard({
    required String hand,
    required String result,
    required String date,
    required double compliance,
    required String potSize,
    required String position,
  }) {
    final isWin = result == '勝利';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isWin ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hand,
                  style: TextStyle(
                    color: isWin ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isWin ? Colors.green : Colors.red)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            result,
                            style: TextStyle(
                              color: isWin ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            position,
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${potSize}円',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: compliance,
              backgroundColor: Colors.purple.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GTO準拠度 ${(compliance * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.purple.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // 詳細を表示
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '詳細を見る',
                  style: TextStyle(
                    color: Colors.purple.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
