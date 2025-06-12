import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    _controller.dispose();
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
            ),
          ),
        ),
        // 固定ヘッダー（白背景＋余白）
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
        // スクロール可能な本体部分（ヘッダー分下げる）
        Positioned.fill(
          top: statusBarHeight + 64, // 64はCommonHeaderの高さを想定
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ユーザー情報セクション
                Container(
                  margin: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                                      color: Colors.purple
                                          .withOpacity(0.3 * _animation.value),
                                      blurRadius: 24 * _animation.value,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Color(0xFFE1BEE7),
                                  child: Icon(Icons.person,
                                      size: 40, color: Colors.purple),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
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
                                        fontSize: 20,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color:
                                                Colors.purple.withOpacity(0.3)),
                                      ),
                                      child: const Text(
                                        'VIP',
                                        style: TextStyle(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // 進捗バー
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 0.7,
                                    backgroundColor:
                                        Colors.purple.withOpacity(0.1),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.purple),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '次のレベルまで 300ポイント',
                                  style: TextStyle(
                                    color: Colors.purple.withOpacity(0.8),
                                    fontSize: 12,
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
                // クイックアクションセクション
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'クイックアクション',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
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
                            color: Colors.purple,
                            onTap: () {
                              // 分析画面へ遷移
                            },
                          ),
                          _buildQuickActionCard(
                            icon: Icons.history,
                            title: '履歴',
                            subtitle: '過去の分析結果',
                            color: Colors.blue,
                            onTap: () {
                              // 履歴画面へ遷移
                            },
                          ),
                          _buildQuickActionCard(
                            icon: Icons.emoji_events,
                            title: 'ランキング',
                            subtitle: '週間ランキング',
                            color: Colors.amber,
                            onTap: () {
                              // ランキング画面へ遷移
                            },
                          ),
                          _buildQuickActionCard(
                            icon: Icons.flag,
                            title: 'ミッション',
                            subtitle: '達成状況を確認',
                            color: Colors.green,
                            onTap: () {
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // すべての分析結果へ遷移
                            },
                            child: Text(
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
                      ),
                      const SizedBox(height: 12),
                      _buildRecentAnalysisCard(
                        hand: 'Q♥ Q♦',
                        result: '敗北',
                        date: '2024/03/19',
                        compliance: 0.65,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
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
  }) {
    final isWin = result == '勝利';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isWin ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hand,
              style: TextStyle(
                color: isWin ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isWin ? Colors.green : Colors.red)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result,
                        style: TextStyle(
                          color: isWin ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: compliance,
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.purple),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GTO準拠度 ${(compliance * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.purple.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
