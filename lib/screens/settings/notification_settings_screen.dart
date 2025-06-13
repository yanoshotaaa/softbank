import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common_header.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // 通知設定の状態
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _analysisCompleteEnabled = true;
  bool _rankingUpdateEnabled = true;
  bool _missionCompleteEnabled = true;
  bool _achievementUnlockedEnabled = true;
  bool _systemUpdatesEnabled = true;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Material(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          SizedBox(height: statusBarHeight),
          const CommonHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '通知設定',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '受け取りたい通知を選択してください',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 通知方法
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '通知方法',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('プッシュ通知'),
                            subtitle: const Text('アプリ内の通知を受け取る'),
                            value: _pushNotificationsEnabled,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _pushNotificationsEnabled = value;
                              });
                            },
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('メール通知'),
                            subtitle: const Text('メールで通知を受け取る'),
                            value: _emailNotificationsEnabled,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _emailNotificationsEnabled = value;
                              });
                            },
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 通知タイプ
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '通知タイプ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('分析完了'),
                            subtitle: const Text('ハンド分析が完了したとき'),
                            value: _analysisCompleteEnabled,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _analysisCompleteEnabled = value;
                              });
                            },
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('ランキング更新'),
                            subtitle: const Text('ランキングが更新されたとき'),
                            value: _rankingUpdateEnabled,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _rankingUpdateEnabled = value;
                              });
                            },
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('ミッション達成'),
                            subtitle: const Text('ミッションを達成したとき'),
                            value: _missionCompleteEnabled,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _missionCompleteEnabled = value;
                              });
                            },
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('実績解除'),
                            subtitle: const Text('新しい実績を解除したとき'),
                            value: _achievementUnlockedEnabled,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _achievementUnlockedEnabled = value;
                              });
                            },
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('システム更新'),
                            subtitle: const Text('アプリの更新情報'),
                            value: _systemUpdatesEnabled,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _systemUpdatesEnabled = value;
                              });
                            },
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 保存ボタン
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _showSaveDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '設定を保存',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知設定'),
        content: const Text('通知設定を保存しました。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ダイアログを閉じる
              Navigator.pop(context); // 通知設定画面を閉じる
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
