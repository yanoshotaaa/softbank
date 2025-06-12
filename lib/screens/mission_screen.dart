import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = 56;
    final List<Map<String, dynamic>> missions = [
      {'title': '10ハンド分析', 'desc': '10回分のハンドを分析しよう', 'done': true},
      {'title': 'VIPバッジ獲得', 'desc': 'VIPランクに到達しよう', 'done': false},
      {'title': '初勝利', 'desc': '初めての勝利を記録しよう', 'done': true},
      {'title': '連勝チャレンジ', 'desc': '3連勝を達成しよう', 'done': false},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // 落ち着いたグラデーション背景
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFA18CD1),
                  Color(0xFFC6B6E5),
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF3E6FF), Color(0xFFEDE7F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                              color: Colors.white.withOpacity(0.7), width: 2.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.flag, color: Colors.green, size: 28),
                                SizedBox(width: 10),
                                Text(
                                  'ミッション',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: missions.length,
                              separatorBuilder: (context, i) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final item = missions[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.7)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item['done']
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: item['done']
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['desc'],
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (item['done'])
                                        const Icon(Icons.emoji_events,
                                            color: Colors.amber, size: 20),
                                    ],
                                  ),
                                );
                              },
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
    );
  }
}
