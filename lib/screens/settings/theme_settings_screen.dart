import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common_header.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final selectedTheme =
        profileProvider.getPreference<String>('theme', 'system');

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Material(
      color: Theme.of(context).colorScheme.background,
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
                    Text(
                      'テーマ設定',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'アプリの見た目をカスタマイズ',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // テーマモード
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
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
                            'テーマモード',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RadioListTile<String>(
                            title: const Text('システム設定に従う'),
                            value: 'system',
                            groupValue: selectedTheme,
                            onChanged: (value) async {
                              HapticFeedback.lightImpact();
                              if (value != null) {
                                await profileProvider.setPreference(
                                    'theme', value);
                              }
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                          RadioListTile<String>(
                            title: const Text('ライトモード'),
                            value: 'light',
                            groupValue: selectedTheme,
                            onChanged: (value) async {
                              HapticFeedback.lightImpact();
                              if (value != null) {
                                await profileProvider.setPreference(
                                    'theme', value);
                              }
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                          RadioListTile<String>(
                            title: const Text('ダークモード'),
                            value: 'dark',
                            groupValue: selectedTheme,
                            onChanged: (value) async {
                              HapticFeedback.lightImpact();
                              if (value != null) {
                                await profileProvider.setPreference(
                                    'theme', value);
                              }
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
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
}
