import 'package:flutter/material.dart';
import 'main.dart'; // 既存の分析画面をインポート
import 'poker_analysis_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/mission_screen.dart';
import 'screens/account_screen.dart';
import 'screens/home_content.dart';
import 'widgets/common_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ナビゲーションタブの画面リスト
  final List<Widget> _screens = [
    const HomeContent(),
    const PokerAnalysisScreen(),
    const RankingScreen(),
    const MissionScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
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

class _HomeContent extends StatefulWidget {
  const _HomeContent({Key? key}) : super(key: key);

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
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
        // メインUI
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonHeader(),
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool glow;
  const _InfoCard(
      {required this.icon,
      required this.iconColor,
      required this.label,
      required this.value,
      this.glow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: iconColor.withOpacity(0.18),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? buttonText;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final VoidCallback? onPressed;
  final bool glow;
  const _ActionCard(
      {required this.icon,
      required this.iconColor,
      required this.title,
      required this.subtitle,
      this.buttonText,
      this.buttonColor,
      this.buttonTextColor,
      this.onPressed,
      this.glow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: iconColor.withOpacity(0.15),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (buttonText != null && onPressed != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ?? Colors.purple.withOpacity(0.1),
                foregroundColor: buttonTextColor ?? Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: Text(buttonText!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
