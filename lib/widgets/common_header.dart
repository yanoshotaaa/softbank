import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  const Text('=SoftBank',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('称号一覧'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                _buildTitleItem('ルーキー', '初めてアプリを利用した', true),
                                _buildTitleItem(
                                    'ポーカーマスター', '100回以上プレイした', true),
                                _buildTitleItem(
                                    'GTOプレイヤー', 'GTO適合率80%以上を達成', false),
                                _buildTitleItem('チャンピオン', 'ランキング1位を獲得', false),
                                _buildTitleItem('連勝王', '10回連続で勝利した', false),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('閉じる'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.military_tech,
                        size: 28, color: Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('通知'),
                          content: const Text('通知機能は今後実装予定です。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('閉じる'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.notifications_none,
                        size: 28, color: Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('設定'),
                          content: const Text('設定画面は今後実装予定です。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('閉じる'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.settings,
                        size: 28, color: Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 称号アイテムを構築するヘルパーメソッド
  Widget _buildTitleItem(String title, String condition, bool unlocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFF8B5CF6).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? Icons.military_tech : Icons.lock_outline,
              color: unlocked ? const Color(0xFF8B5CF6) : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: unlocked ? Colors.black87 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  condition,
                  style: TextStyle(
                    fontSize: 12,
                    color: unlocked ? Colors.black54 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle, color: Color(0xFF8B5CF6), size: 20)
          else
            const Icon(Icons.radio_button_unchecked,
                color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
