import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common_header.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'アプリの使い方を教えてください',
      'answer': 'アプリの使い方については、以下の手順で操作できます：\n\n'
          '1. ホーム画面で「分析開始」をタップ\n'
          '2. ポーカーハンドを入力\n'
          '3. 分析結果を確認\n'
          '4. 詳細な解説を読む\n\n'
          'より詳しい使い方は、チュートリアルをご覧ください。',
    },
    {
      'question': '分析結果はどのように見ればいいですか？',
      'answer': '分析結果は以下の要素で構成されています：\n\n'
          '• ハンドの強さ\n'
          '• 推奨アクション\n'
          '• 期待値（EV）\n'
          '• 詳細な解説\n\n'
          '各要素の見方については、分析結果画面のヘルプアイコンから確認できます。',
    },
    {
      'question': 'プレミアム会員の特典は何ですか？',
      'answer': 'プレミアム会員になると、以下の特典が利用できます：\n\n'
          '• 無制限のハンド分析\n'
          '• 詳細な統計データ\n'
          '• カスタム分析レポート\n'
          '• 広告非表示\n'
          '• 優先サポート\n\n'
          'プレミアム会員の詳細は、アカウント設定からご確認ください。',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Material(
      color: const Color(0xFFFAFAFA),
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
                      'ヘルプ・サポート',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'よくある質問やお問い合わせ方法をご案内します',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // FAQセクション
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
                            'よくある質問',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._faqItems.map((item) => _buildFaqItem(
                                question: item['question'],
                                answer: item['answer'],
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // お問い合わせセクション
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
                            'お問い合わせ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildContactItem(
                            icon: Icons.email,
                            title: 'メールサポート',
                            subtitle: '24時間受付',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // メールアプリを起動
                            },
                          ),
                          const Divider(),
                          _buildContactItem(
                            icon: Icons.chat,
                            title: 'チャットサポート',
                            subtitle: '平日 10:00-18:00',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // チャットサポートを起動
                            },
                          ),
                          const Divider(),
                          _buildContactItem(
                            icon: Icons.phone,
                            title: '電話サポート',
                            subtitle: '平日 10:00-18:00',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // 電話アプリを起動
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // アプリ情報
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
                            'アプリ情報',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoItem(
                            icon: Icons.info_outline,
                            title: 'バージョン',
                            value: '1.0.0',
                          ),
                          const Divider(),
                          _buildInfoItem(
                            icon: Icons.update,
                            title: '最終更新日',
                            value: '2024年3月15日',
                          ),
                          const Divider(),
                          _buildInfoItem(
                            icon: Icons.code,
                            title: '開発元',
                            value: 'SoftBank Corp.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // その他のリンク
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
                            'その他',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLinkItem(
                            icon: Icons.description,
                            title: '利用規約',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // 利用規約を表示
                            },
                          ),
                          const Divider(),
                          _buildLinkItem(
                            icon: Icons.privacy_tip,
                            title: 'プライバシーポリシー',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // プライバシーポリシーを表示
                            },
                          ),
                          const Divider(),
                          _buildLinkItem(
                            icon: Icons.star,
                            title: 'アプリを評価する',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // アプリストアを開く
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
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ),
      ],
      iconColor: const Color(0xFF8B5CF6),
      collapsedIconColor: const Color(0xFF8B5CF6),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B5CF6)),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B5CF6)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
