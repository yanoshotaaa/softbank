import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common_header.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  String _selectedTheme = 'system';
  bool _useDynamicColor = true;
  double _fontSize = 1.0;

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
                      'テーマ設定',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'アプリの見た目をカスタマイズ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // テーマモード
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
                            'テーマモード',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          RadioListTile<String>(
                            title: const Text('システム設定に従う'),
                            value: 'system',
                            groupValue: _selectedTheme,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedTheme = value!;
                              });
                            },
                            activeColor: const Color(0xFF2C3E50),
                          ),
                          RadioListTile<String>(
                            title: const Text('ライトモード'),
                            value: 'light',
                            groupValue: _selectedTheme,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedTheme = value!;
                              });
                            },
                            activeColor: const Color(0xFF2C3E50),
                          ),
                          RadioListTile<String>(
                            title: const Text('ダークモード'),
                            value: 'dark',
                            groupValue: _selectedTheme,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedTheme = value!;
                              });
                            },
                            activeColor: const Color(0xFF2C3E50),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // カラーテーマ
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
                            'カラーテーマ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('ダイナミックカラー'),
                            subtitle: const Text('システムのカラーテーマに合わせる'),
                            value: _useDynamicColor,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _useDynamicColor = value;
                              });
                            },
                            activeColor: const Color(0xFF2C3E50),
                          ),
                          if (!_useDynamicColor) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'カラーパレット',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildColorOption(const Color(0xFF2C3E50)),
                                _buildColorOption(const Color(0xFF34495E)),
                                _buildColorOption(const Color(0xFF7F8C8D)),
                                _buildColorOption(const Color(0xFF27AE60)),
                                _buildColorOption(const Color(0xFFF39C12)),
                                _buildColorOption(const Color(0xFFE74C3C)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // フォントサイズ
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
                            'フォントサイズ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('小'),
                              Text('中'),
                              Text('大'),
                              Text('特大'),
                            ],
                          ),
                          Slider(
                            value: _fontSize,
                            min: 0.8,
                            max: 1.2,
                            divisions: 4,
                            label: _getFontSizeLabel(_fontSize),
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _fontSize = value;
                              });
                            },
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'プレビュー: このテキストのサイズが変更されます',
                              style: TextStyle(
                                fontSize: 16 * _fontSize,
                              ),
                            ),
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

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // カラー選択の処理
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
      ),
    );
  }

  String _getFontSizeLabel(double size) {
    if (size <= 0.9) return '小';
    if (size <= 1.0) return '中';
    if (size <= 1.1) return '大';
    return '特大';
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('テーマ設定'),
        content: const Text('テーマ設定を保存しました。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ダイアログを閉じる
              Navigator.pop(context); // テーマ設定画面を閉じる
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
