import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CommonHeader({
    Key? key,
    this.title,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

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
                  if (showBackButton) ...[
                    GestureDetector(
                      onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (title != null)
                    Text(
                      title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2C3E50),
                      ),
                    )
                  else
                    const Text(
                      '=SoftBank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                ],
              ),
              if (!showBackButton)
                Row(
                  children: [
                    _buildIconWithBadge(
                      context: context,
                      icon: Icons.military_tech,
                      badgeCount: 2,
                      onTap: () => _showAchievementsDialog(context),
                    ),
                    const SizedBox(width: 14),
                    _buildIconWithBadge(
                      context: context,
                      icon: Icons.notifications_none,
                      badgeCount: 3,
                      onTap: () => _showNotificationsDialog(context),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () => _showSettingsDialog(context),
                      child: const Icon(
                        Icons.settings,
                        size: 28,
                        color: Color(0xFF2C3E50),
                      ),
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

  // バッジ付きアイコンを構築するヘルパーメソッド
  Widget _buildIconWithBadge({
    required BuildContext context,
    required IconData icon,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, size: 28, color: const Color(0xFF2C3E50)),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
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
                  ? const Color(0xFF2C3E50).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? Icons.military_tech : Icons.lock_outline,
              color: unlocked ? const Color(0xFF2C3E50) : Colors.grey,
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
            const Icon(Icons.check_circle, color: Color(0xFF2C3E50), size: 20)
          else
            const Icon(Icons.radio_button_unchecked,
                color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  // 通知アイテムを構築するヘルパーメソッド
  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isNew,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFF8B5CF6).withOpacity(0.05) : null,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (isNew)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF8B5CF6),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // 設定アイテムを構築するヘルパーメソッド
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF8B5CF6),
                size: 20,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 称号ダイアログを表示
  void _showAchievementsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.military_tech, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            const Text('称号一覧'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  '獲得済み: 2/5',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildTitleItem('ルーキー', '初めてアプリを利用した', true),
                    _buildTitleItem('ポーカーマスター', '100回以上プレイした', true),
                    _buildTitleItem('GTOプレイヤー', 'GTO適合率80%以上を達成', false),
                    _buildTitleItem('チャンピオン', 'ランキング1位を獲得', false),
                    _buildTitleItem('連勝王', '10回連続で勝利した', false),
                  ],
                ),
              ),
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
  }

  // 通知ダイアログを表示
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            const Text('通知'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              _buildNotificationItem(
                title: 'ミッション達成！',
                message: '「10回分析する」ミッションを達成しました。報酬を受け取りましょう。',
                time: '30分前',
                icon: Icons.flag,
                iconColor: Colors.green,
                isNew: true,
              ),
              _buildNotificationItem(
                title: '新しい称号獲得！',
                message: '「ポーカーマスター」の称号を獲得しました。',
                time: '2時間前',
                icon: Icons.military_tech,
                iconColor: const Color(0xFF8B5CF6),
                isNew: true,
              ),
              _buildNotificationItem(
                title: 'アップデート情報',
                message: 'アプリがバージョン1.2.0にアップデートされました。新機能をチェックしましょう。',
                time: '昨日',
                icon: Icons.system_update,
                iconColor: Colors.blue,
                isNew: true,
              ),
              _buildNotificationItem(
                title: 'ランキング更新',
                message: 'あなたのランキングが5位に上昇しました。おめでとうございます！',
                time: '3日前',
                icon: Icons.emoji_events,
                iconColor: Colors.amber,
                isNew: false,
              ),
              _buildNotificationItem(
                title: 'ウェルカムボーナス',
                message: '初回ログインボーナスとして100ポイントを獲得しました。',
                time: '1週間前',
                icon: Icons.card_giftcard,
                iconColor: Colors.red,
                isNew: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('すべて既読にする'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  // 設定ダイアログを表示
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.settings, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            const Text('設定'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingItem(
                icon: Icons.person,
                title: 'プロフィール設定',
                description: 'ユーザー名、アバター、自己紹介を編集',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('プロフィール設定は今後実装予定です')),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.notifications_active,
                title: '通知設定',
                description: '通知のオン/オフを切り替え',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('通知設定は今後実装予定です')),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.color_lens,
                title: 'テーマ設定',
                description: 'ダークモード/ライトモードを切り替え',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('テーマ設定は今後実装予定です')),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.language,
                title: '言語設定',
                description: 'アプリの表示言語を変更',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('言語設定は今後実装予定です')),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'ヘルプとサポート',
                description: 'よくある質問、お問い合わせ',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ヘルプとサポートは今後実装予定です')),
                  );
                },
              ),
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
  }
}
