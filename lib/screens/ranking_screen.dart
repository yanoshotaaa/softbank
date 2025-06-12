import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = 56;
    final List<Map<String, dynamic>> rankingData = [
      {'rank': 1, 'name': 'SHOOTER', 'score': 3200},
      {'rank': 2, 'name': 'POKERKING', 'score': 2800},
      {'rank': 3, 'name': 'AI_BOT', 'score': 2500},
      {'rank': 4, 'name': 'YUKI', 'score': 2100},
      {'rank': 5, 'name': 'TAKASHI', 'score': 1800},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // 豪華なグラデーション背景
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB993D6),
                  Color(0xFF8CA6DB),
                  Color(0xFFF3E6FF)
                ],
              ),
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
                      children: const [
                        Icon(Icons.emoji_events,
                            color: Color(0xFFFFD700), size: 32),
                        SizedBox(width: 10),
                        Text(
                          '週間ランキング',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D28D9),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ランキングリスト
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: rankingData.length,
                      separatorBuilder: (context, i) =>
                          const SizedBox(height: 18),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return _TopRankCard(
                            rank: rankingData[0]['rank'],
                            name: rankingData[0]['name'],
                            score: rankingData[0]['score'],
                            color: const Color(0xFFFFD700),
                            crown: Icons.emoji_events,
                            size: 100,
                          );
                        } else if (i == 1) {
                          return _TopRankCard(
                            rank: rankingData[1]['rank'],
                            name: rankingData[1]['name'],
                            score: rankingData[1]['score'],
                            color: const Color(0xFFC0C0C0),
                            crown: Icons.emoji_events,
                            size: 90,
                          );
                        } else if (i == 2) {
                          return _TopRankCard(
                            rank: rankingData[2]['rank'],
                            name: rankingData[2]['name'],
                            score: rankingData[2]['score'],
                            color: const Color(0xFFCD7F32),
                            crown: Icons.emoji_events,
                            size: 90,
                          );
                        } else {
                          final item = rankingData[i];
                          return _OtherRankCard(
                            rank: item['rank'],
                            name: item['name'],
                            score: item['score'],
                          );
                        }
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

class _TopRankCard extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final Color color;
  final IconData crown;
  final double size;

  const _TopRankCard({
    required this.rank,
    required this.name,
    required this.score,
    required this.color,
    required this.crown,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  crown,
                  color: color,
                  size: size / 2.2,
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  '$rank 位',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score pt',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _OtherRankCard extends StatelessWidget {
  final int rank;
  final String name;
  final int score;

  const _OtherRankCard({
    required this.rank,
    required this.name,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEDE7F6),
            child: Text(
              rank.toString(),
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '$score pt',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
