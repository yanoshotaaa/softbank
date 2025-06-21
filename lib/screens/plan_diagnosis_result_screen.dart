import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'plan_application_screen.dart';

class PlanDiagnosisResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> answers;

  const PlanDiagnosisResultScreen({
    super.key,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final result = _calculateResult(answers);
    final recommendedPlan = result['recommended_plan'] as Map<String, dynamic>?;
    final analysis = result['analysis'] as Map<String, dynamic>?;
    final userProfile = result['user_profile'] as Map<String, dynamic>?;
    final scoreBreakdown = result['score_breakdown'] as Map<String, dynamic>?;
    final comparison = result['comparison'] as Map<String, dynamic>?;
    final alternativePlans = (result['alternative_plans'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    if (recommendedPlan == null) {
      return const Scaffold(
        body: Center(
          child: Text('診断結果を取得できませんでした。'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          '診断結果',
          style: TextStyle(
            fontFamily: 'Noto Sans JP',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              HapticFeedback.mediumImpact();
              // TODO: 共有機能の実装
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー部分
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'あなたに最適なプランは',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recommendedPlan['name'] as String? ?? '不明なプラン',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '適合度: ${((comparison?['recommended_plan_score'] as num? ?? 0) / 10 * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // プラン詳細
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'プラン詳細',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    context,
                    [
                      _buildDetailItem('月額料金', '¥${recommendedPlan['price']}'),
                      _buildDetailItem(
                          'データ容量', recommendedPlan['data'] as String? ?? '不明'),
                      _buildDetailItem(
                          '主な機能',
                          (recommendedPlan['features'] as List<dynamic>?)
                                  ?.join('、') ??
                              '不明'),
                    ],
                  ),
                ],
              ),
            ),

            // 分析結果
            if (analysis != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '分析結果',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildAnalysisCard(
                      context,
                      (analysis['strengths'] as List<dynamic>?)
                              ?.cast<String>() ??
                          [],
                      (analysis['weaknesses'] as List<dynamic>?)
                              ?.cast<String>() ??
                          [],
                      (analysis['suitable_for'] as List<dynamic>?)
                              ?.cast<String>() ??
                          [],
                    ),
                  ],
                ),
              ),
            ],

            // スコア内訳
            if (scoreBreakdown != null) ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'スコア内訳',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildScoreBreakdownCard(context, scoreBreakdown),
                  ],
                ),
              ),
            ],

            // 代替プラン
            if (alternativePlans.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '代替プラン',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...alternativePlans.map((plan) => _buildAlternativePlanCard(
                          context,
                          plan['plan'] as Map<String, dynamic>? ?? {},
                          plan['score'] as int? ?? 0,
                        )),
                  ],
                ),
              ),
            ],

            // 申し込みボタン
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            PlanApplicationScreen(plan: recommendedPlan),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'このプランに申し込む',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontFamily: 'Noto Sans JP',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Noto Sans JP',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, List<String> strengths,
      List<String> weaknesses, List<String> suitableFor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...strengths.map<Widget>((strength) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strength,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'Noto Sans JP',
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        ...weaknesses.map<Widget>((weakness) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.error,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    weakness,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'Noto Sans JP',
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        ...suitableFor.map<Widget>((suitable) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suitable,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'Noto Sans JP',
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildScoreBreakdownCard(
      BuildContext context, Map<String, dynamic> breakdown) {
    final entries = breakdown.entries.toList();
    final totalScore = entries.fold<int>(0, (sum, e) => sum + (e.value as int));

    return _buildDetailCard(
      context,
      entries.map((entry) {
        final score = entry.value as int;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '$score / ${totalScore > 0 ? totalScore : 'N/A'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalScore > 0 ? score / totalScore : 0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColorForScore(score / (totalScore == 0 ? 1 : totalScore)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForScore(double score) {
    if (score < 0.3) return Colors.red;
    if (score < 0.6) return Colors.orange;
    return Colors.green;
  }

  Widget _buildAlternativePlanCard(
      BuildContext context, Map<String, dynamic> plan, int score) {
    final _primaryColor = Theme.of(context).primaryColor;
    final _backgroundColor = const Color(0xFFF9FAFB);
    final _textPrimaryColor = const Color(0xFF1F2937);
    final _textSecondaryColor = const Color(0xFF6B7280);
    final _successColor = const Color(0xFF10B981);
    final _warningColor = const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryColor.withOpacity(0.1),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan['name'] as String? ?? '不明なプラン',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Noto Sans JP',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '適合度: ${((score as num? ?? 0) / 10 * 100).round()}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Noto Sans JP',
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            context,
            [
              _buildDetailItem('月額料金', '¥${plan['price']}'),
              _buildDetailItem('データ容量', plan['data'] as String? ?? '不明'),
              _buildDetailItem('主な機能',
                  (plan['features'] as List<dynamic>?)?.join('、') ?? '不明'),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateResult(List<Map<String, dynamic>> answers) {
    // スコア計算ロジック
    int dataScore = 0;
    int callScore = 0;
    int optionScore = 0;
    int discountScore = 0;

    // データ使用量
    final dataUsageAnswer = answers.firstWhere(
      (a) => a['question_id'] == 1,
      orElse: () => {'answer_value': 0},
    );
    final dataUsage = dataUsageAnswer['answer_value'] as int;
    if (dataUsage < 5) dataScore = 1;
    if (dataUsage >= 5 && dataUsage < 20) dataScore = 2;
    if (dataUsage >= 20 && dataUsage < 50) dataScore = 3;
    if (dataUsage >= 50) dataScore = 4;

    // 通話時間
    final callUsageAnswer = answers.firstWhere(
      (a) => a['question_id'] == 2,
      orElse: () => {'answer_value': 'short'},
    );
    final callUsage = callUsageAnswer['answer_value'] as String;
    if (callUsage == 'short') callScore = 1;
    if (callUsage == 'medium') callScore = 2;
    if (callUsage == 'long') callScore = 3;

    // オプション
    final optionsAnswer = answers.firstWhere(
      (a) => a['question_id'] == 3,
      orElse: () => {'answer_value': []},
    );
    final options = optionsAnswer['answer_value'] as List;
    optionScore = options.length;

    // 割引
    final discountsAnswer = answers.firstWhere(
      (a) => a['question_id'] == 4,
      orElse: () => {'answer_value': []},
    );
    final discounts = discountsAnswer['answer_value'] as List;
    discountScore = discounts.length;

    int totalScore = dataScore + callScore + optionScore + discountScore;

    // スコアに基づいてプランを推奨
    Map<String, dynamic> recommendedPlan;
    if (totalScore <= 4) {
      recommendedPlan = {
        'name': 'ミニフィットプラン+',
        'price': '3,278',
        'data': '~3GB',
        'features': ['データくりこし', '5G対応'],
      };
    } else if (totalScore <= 8) {
      recommendedPlan = {
        'name': 'メリハリ無制限+',
        'price': '7,238',
        'data': '無制限',
        'features': ['YouTube Premium 6ヶ月無料', 'テザリング'],
      };
    } else {
      recommendedPlan = {
        'name': 'ペイトク無制限',
        'price': '9,625',
        'data': '無制限',
        'features': ['PayPayポイント高還元', '5G対応'],
      };
    }

    return {
      'recommended_plan': recommendedPlan,
      'analysis': {
        'strengths': ['コストパフォーマンスが高い', 'データ容量が十分'],
        'weaknesses': ['通話料が高い可能性がある'],
        'suitable_for': ['データ利用が多い方', '動画視聴が多い方'],
      },
      'score_breakdown': {
        'データ使用量': dataScore,
        '通話時間': callScore,
        'オプション利用': optionScore,
        '割引適用': discountScore,
      },
      'comparison': {
        'current_plan_score': 5,
        'recommended_plan_score': totalScore,
      },
      'alternative_plans': [
        {
          'plan': {
            'name': 'スマホデビュープラン+',
            'price': '2,266',
            'data': '4GB',
            'features': ['国内通話かけ放題(1回5分以内)'],
          },
          'score': 3,
        }
      ]
    };
  }
}
