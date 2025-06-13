import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common_header.dart';
import 'profile_edit_screen.dart';
import 'password_change_screen.dart';
import 'notification_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'help_support_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Material(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          SizedBox(height: statusBarHeight),
          CommonHeader(
            title: 'アカウント設定',
            showBackButton: true,
            onBackPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'アカウント設定',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'アカウントの設定を管理できます',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // プロフィール設定
                    _buildSection(
                      title: 'プロフィール設定',
                      items: [
                        _buildSettingItem(
                          icon: Icons.person,
                          title: 'プロフィール編集',
                          subtitle: 'ユーザー名やアバターを変更',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ProfileEditScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                      position: offsetAnimation, child: child);
                                },
                                maintainState: true,
                                fullscreenDialog: false,
                              ),
                            );
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.lock,
                          title: 'パスワード変更',
                          subtitle: 'アカウントのパスワードを変更',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const PasswordChangeScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                      position: offsetAnimation, child: child);
                                },
                                maintainState: true,
                                fullscreenDialog: false,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 通知設定
                    _buildSection(
                      title: '通知設定',
                      items: [
                        _buildSettingItem(
                          icon: Icons.notifications,
                          title: '通知設定',
                          subtitle: 'プッシュ通知やメール通知の設定',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const NotificationSettingsScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                      position: offsetAnimation, child: child);
                                },
                                maintainState: true,
                                fullscreenDialog: false,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 表示設定
                    _buildSection(
                      title: '表示設定',
                      items: [
                        _buildSettingItem(
                          icon: Icons.palette,
                          title: 'テーマ設定',
                          subtitle: 'アプリの見た目をカスタマイズ',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ThemeSettingsScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                      position: offsetAnimation, child: child);
                                },
                                maintainState: true,
                                fullscreenDialog: false,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // サポート
                    _buildSection(
                      title: 'サポート',
                      items: [
                        _buildSettingItem(
                          icon: Icons.help,
                          title: 'ヘルプ・サポート',
                          subtitle: 'よくある質問やお問い合わせ',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const HelpSupportScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                      position: offsetAnimation, child: child);
                                },
                                maintainState: true,
                                fullscreenDialog: false,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // アカウント管理
                    _buildSection(
                      title: 'アカウント管理',
                      items: [
                        _buildSettingItem(
                          icon: Icons.logout,
                          title: 'ログアウト',
                          subtitle: 'アカウントからログアウト',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showLogoutDialog(context);
                          },
                          isDestructive: true,
                        ),
                        _buildSettingItem(
                          icon: Icons.delete_forever,
                          title: 'アカウント削除',
                          subtitle: 'アカウントを完全に削除',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showDeleteAccountDialog(context);
                          },
                          isDestructive: true,
                        ),
                      ],
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

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color iconColor =
        isDestructive ? Colors.red : const Color(0xFF8B5CF6);
    final Color textColor = isDestructive ? Colors.red : Colors.black;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isDestructive) const Divider(height: 1),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('アカウントからログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: ログアウト処理を実装
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text(
          'アカウントを削除すると、すべてのデータが完全に削除され、復元することはできません。\n\n'
          '本当にアカウントを削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: アカウント削除処理を実装
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }
}
