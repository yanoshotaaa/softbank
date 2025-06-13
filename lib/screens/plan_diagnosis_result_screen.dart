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
      BuildContext context, Map<String, dynamic> scoreBreakdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...scoreBreakdown.entries.map<Widget>((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    _getScoreLabel(entry.key),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.value}点',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Noto Sans JP',
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (entry.value as num) / 3,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          (entry.value as num) >= 2
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getScoreLabel(String key) {
    switch (key) {
      case 'data_usage':
        return 'データ使用量';
      case 'call_usage':
        return '通話使用量';
      case 'budget':
        return '予算';
      case 'use_cases':
        return '使用用途';
      default:
        return key;
    }
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
    // プランの定義
    final plans = <String, Map<String, dynamic>>{
      'basic': <String, dynamic>{
        'name': 'ベーシックプラン',
        'price': 2980,
        'data': '3GB',
        'features': <String>['シンプルな料金体系', '必要最小限の機能', '安定した通信品質'],
        'conditions': <String, List<String>>{
          'data_usage': <String>['少ない'],
          'call_usage': <String>['少ない'],
          'budget': <String>['安い'],
          'use_cases': <String>['メール', 'SNS']
        },
        'analysis': <String, List<String>>{
          'strengths': <String>['コストパフォーマンスが良い', 'シンプルで分かりやすい'],
          'weaknesses': <String>['データ容量が限定的', '機能が限定的'],
          'suitable_for': <String>['データ使用量が少ない方', 'シンプルな使い方の方']
        }
      },
      'standard': <String, dynamic>{
        'name': 'スタンダードプラン',
        'price': 4980,
        'data': '20GB',
        'features': <String>['バランスの取れた機能', '快適な通信速度', '充実したサービス'],
        'conditions': <String, List<String>>{
          'data_usage': <String>['普通'],
          'call_usage': <String>['普通'],
          'budget': <String>['普通'],
          'use_cases': <String>['Web閲覧', '動画視聴', 'オンラインゲーム']
        },
        'analysis': <String, List<String>>{
          'strengths': <String>['バランスの取れた機能', '十分なデータ容量'],
          'weaknesses': <String>['プレミアム機能は限定的', '料金がやや高め'],
          'suitable_for': <String>['一般的な使い方の方', '家族で利用する方']
        }
      },
      'premium': <String, dynamic>{
        'name': 'プレミアムプラン',
        'price': 7980,
        'data': '無制限',
        'features': <String>['最速通信速度', '充実した特典', 'プレミアムサポート'],
        'conditions': <String, List<String>>{
          'data_usage': <String>['多い', '非常に多い'],
          'call_usage': <String>['多い', '非常に多い'],
          'budget': <String>['高い'],
          'use_cases': <String>['4K動画視聴', 'クラウドゲーム', 'リモートワーク']
        },
        'analysis': <String, List<String>>{
          'strengths': <String>['無制限データ', '最速通信速度', '充実した特典'],
          'weaknesses': <String>['料金が高い', '一部機能は過剰'],
          'suitable_for': <String>['大容量データを使用する方', 'ビジネス利用の方']
        }
      }
    };

    // ユーザーの回答を取得
    final dataUsage = answers[1]['answer'] as String?;
    final callUsage = answers[2]['answer'] as String?;
    final budget = answers[4]['answer'] as String?;
    final useCases =
        (answers[3]['answer'] as List<dynamic>?)?.cast<String>() ?? [];

    // 各プランのスコアを計算
    Map<String, int> scores = {};
    Map<String, Map<String, dynamic>> analysis = {};

    plans.forEach((planId, plan) {
      int score = 0;
      final conditions = plan['conditions'] as Map<String, List<String>>;
      final planAnalysis = plan['analysis'] as Map<String, List<String>>;

      // データ使用量の評価（重み: 3）
      if (conditions['data_usage']?.contains(dataUsage) ?? false) {
        score += 3;
      } else {
        // 近い条件の場合、部分点を付与
        if (dataUsage == '普通' && planId == 'basic') score += 1;
        if (dataUsage == '多い' && planId == 'standard') score += 1;
        if (dataUsage == '非常に多い' && planId == 'standard') score += 2;
      }

      // 通話使用量の評価（重み: 2）
      if (conditions['call_usage']?.contains(callUsage) ?? false) {
        score += 2;
      } else {
        // 近い条件の場合、部分点を付与
        if (callUsage == '普通' && planId == 'basic') score += 1;
        if (callUsage == '多い' && planId == 'standard') score += 1;
      }

      // 予算の評価（重み: 4）
      if (conditions['budget']?.contains(budget) ?? false) {
        score += 4;
      } else {
        // 予算が近い場合、部分点を付与
        if (budget == '普通' && planId == 'basic') score += 2;
        if (budget == '高い' && planId == 'standard') score += 2;
        if (budget == '普通' && planId == 'premium') score += 1;
      }

      // 使用用途の評価（重み: 1/用途）
      int useCaseScore = 0;
      for (var useCase in useCases) {
        if (conditions['use_cases']?.contains(useCase) ?? false) {
          useCaseScore++;
        }
      }
      score += useCaseScore;

      // プランごとの特徴に基づく調整
      if (planId == 'basic' && useCases.length <= 2) score += 1;
      if (planId == 'standard' && useCases.length >= 3) score += 1;
      if (planId == 'premium' && useCases.length >= 4) score += 1;

      scores[planId] = score;

      // プランごとの詳細分析
      analysis[planId] = {
        'strengths': planAnalysis['strengths'] ?? [],
        'weaknesses': planAnalysis['weaknesses'] ?? [],
        'suitable_for': planAnalysis['suitable_for'] ?? [],
        'score_breakdown': {
          'data_usage':
              conditions['data_usage']?.contains(dataUsage) ?? false ? 3 : 0,
          'call_usage':
              conditions['call_usage']?.contains(callUsage) ?? false ? 2 : 0,
          'budget': conditions['budget']?.contains(budget) ?? false ? 4 : 0,
          'use_cases': useCaseScore
        }
      };
    });

    // 最適なプランを決定（スコアが最も高いプラン）
    String recommendedPlanId =
        scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // 代替プランの提案（スコアが推奨プランの80%以上の場合）
    List<Map<String, dynamic>> alternativePlans = [];
    final recommendedScore = scores[recommendedPlanId]!;
    scores.forEach((planId, score) {
      if (planId != recommendedPlanId && score >= recommendedScore * 0.8) {
        alternativePlans.add({
          'plan': plans[planId],
          'score': score,
          'analysis': analysis[planId]
        });
      }
    });

    // ユーザープロファイルの分析
    Map<String, dynamic> userProfile = {
      'usage_pattern': {
        'data': dataUsage,
        'call': callUsage,
        'budget': budget,
        'primary_use_cases': useCases.take(2).toList()
      },
      'needs_analysis': {
        'data_priority': dataUsage == '多い' || dataUsage == '非常に多い',
        'call_priority': callUsage == '多い' || callUsage == '非常に多い',
        'budget_sensitive': budget == '安い' || budget == '普通',
        'feature_focused': useCases.length > 2
      }
    };

    return {
      'recommended_plan': plans[recommendedPlanId],
      'alternative_plans': alternativePlans,
      'analysis': analysis[recommendedPlanId],
      'user_profile': userProfile,
      'score_breakdown': analysis[recommendedPlanId]?['score_breakdown'],
      'comparison': {
        'recommended_plan_score': scores[recommendedPlanId],
        'average_score': scores.values.reduce((a, b) => a + b) / scores.length,
        'score_difference': scores[recommendedPlanId]! -
            (scores.values.reduce((a, b) => a + b) -
                    scores[recommendedPlanId]!) /
                (scores.length - 1)
      }
    };
  }
}
