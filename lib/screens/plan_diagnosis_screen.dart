import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'plan_diagnosis_result_screen.dart';

class PlanDiagnosisScreen extends StatefulWidget {
  const PlanDiagnosisScreen({super.key});

  @override
  State<PlanDiagnosisScreen> createState() => _PlanDiagnosisScreenState();
}

class _PlanDiagnosisScreenState extends State<PlanDiagnosisScreen> {
  final _primaryColor = const Color(0xFF8B5CF6);
  final _backgroundColor = const Color(0xFFF9FAFB);
  final _textPrimaryColor = const Color(0xFF1F2937);
  final _textSecondaryColor = const Color(0xFF6B7280);

  int _currentStep = 0;
  final PageController _pageController = PageController();
  final List<Map<String, dynamic>> _answers = [];
  final Set<String> _selectedMultipleChoices = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'title': '現在の利用状況',
      'subtitle': '現在の携帯電話の利用状況を教えてください',
      'type': 'single_choice',
      'options': [
        {'text': 'ソフトバンク', 'value': 'softbank'},
        {'text': '他社（au/ドコモ）', 'value': 'other'},
        {'text': 'MVNO', 'value': 'mvno'},
        {'text': '未契約', 'value': 'none'},
      ],
    },
    {
      'title': 'データ通信量',
      'subtitle': '月間のデータ通信量はどのくらいですか？',
      'type': 'single_choice',
      'options': [
        {'text': '1GB未満', 'value': 'under_1gb'},
        {'text': '1GB〜3GB', 'value': '1_3gb'},
        {'text': '3GB〜7GB', 'value': '3_7gb'},
        {'text': '7GB〜20GB', 'value': '7_20gb'},
        {'text': '20GB以上', 'value': 'over_20gb'},
      ],
    },
    {
      'title': '通話利用',
      'subtitle': '月間の通話時間はどのくらいですか？',
      'type': 'single_choice',
      'options': [
        {'text': 'ほとんど使わない', 'value': 'rare'},
        {'text': '30分未満', 'value': 'under_30min'},
        {'text': '30分〜1時間', 'value': '30min_1hour'},
        {'text': '1時間〜3時間', 'value': '1_3hours'},
        {'text': '3時間以上', 'value': 'over_3hours'},
      ],
    },
    {
      'title': '利用シーン',
      'subtitle': '主にどのような用途で使用しますか？（複数選択可）',
      'type': 'multiple_choice',
      'options': [
        {'text': 'SNS・メッセージ', 'value': 'social'},
        {'text': '動画視聴', 'value': 'video'},
        {'text': 'ゲーム', 'value': 'game'},
        {'text': '音楽ストリーミング', 'value': 'music'},
        {'text': 'Webブラウジング', 'value': 'web'},
        {'text': 'ビジネス利用', 'value': 'business'},
      ],
    },
    {
      'title': '予算',
      'subtitle': '月々の携帯電話料金の予算はどのくらいですか？',
      'type': 'single_choice',
      'options': [
        {'text': '3,000円未満', 'value': 'under_3000'},
        {'text': '3,000円〜5,000円', 'value': '3000_5000'},
        {'text': '5,000円〜8,000円', 'value': '5000_8000'},
        {'text': '8,000円〜10,000円', 'value': '8000_10000'},
        {'text': '10,000円以上', 'value': 'over_10000'},
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleAnswer(dynamic answer) {
    setState(() {
      if (_currentStep < _questions.length) {
        _answers.add({
          'question': _questions[_currentStep]['title'],
          'answer': answer,
        });

        if (_currentStep < _questions.length - 1) {
          _currentStep++;
          _pageController.animateToPage(
            _currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _showResults();
        }
      }
    });
  }

  void _handleMultipleChoice(String value) {
    setState(() {
      if (_selectedMultipleChoices.contains(value)) {
        _selectedMultipleChoices.remove(value);
      } else {
        _selectedMultipleChoices.add(value);
      }
    });
  }

  void _submitMultipleChoice() {
    if (_selectedMultipleChoices.isNotEmpty) {
      _handleAnswer(_selectedMultipleChoices.toList());
      _selectedMultipleChoices.clear();
    }
  }

  void _showResults() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PlanDiagnosisResultScreen(answers: _answers),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        maintainState: true,
        fullscreenDialog: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'プラン診断',
          style: TextStyle(
            fontFamily: 'Noto Sans JP',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _textPrimaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          // プログレスバー
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '質問 ${_currentStep + 1}/${_questions.length}',
                      style: TextStyle(
                        color: _textSecondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Noto Sans JP',
                      ),
                    ),
                    Text(
                      '${((_currentStep + 1) / _questions.length * 100).toInt()}%',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Noto Sans JP',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _questions.length,
                    backgroundColor: _primaryColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          // 質問コンテンツ
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                final isMultipleChoice = question['type'] == 'multiple_choice';
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['title'],
                        style: TextStyle(
                          color: _textPrimaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Noto Sans JP',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question['subtitle'],
                        style: TextStyle(
                          color: _textSecondaryColor,
                          fontSize: 16,
                          fontFamily: 'Noto Sans JP',
                        ),
                      ),
                      const SizedBox(height: 32),
                      ...question['options'].map<Widget>((option) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOptionCard(
                            option['text'],
                            isSelected: isMultipleChoice &&
                                _selectedMultipleChoices
                                    .contains(option['value']),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              if (isMultipleChoice) {
                                _handleMultipleChoice(option['value']);
                              } else {
                                _handleAnswer(option['value']);
                              }
                            },
                          ),
                        );
                      }).toList(),
                      if (isMultipleChoice) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedMultipleChoices.isEmpty
                                ? null
                                : () {
                                    HapticFeedback.mediumImpact();
                                    _submitMultipleChoice();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              '次へ進む',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Noto Sans JP',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    String text, {
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected ? _primaryColor : _primaryColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? _primaryColor : _textPrimaryColor,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: 'Noto Sans JP',
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: _primaryColor,
                  size: 24,
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: _textSecondaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
