import 'package:flutter/material.dart';

class Mission {
  final String id;
  final String title;
  final String description;
  final int reward;
  final int progress;
  final int target;
  final bool isCompleted;
  final String category;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.progress,
    required this.target,
    required this.isCompleted,
    required this.category,
  });
}

class MissionScreen extends StatefulWidget {
  const MissionScreen({Key? key}) : super(key: key);

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  List<Mission> _getMissions() {
    return [
      Mission(
        id: '1',
        title: '初めての勝利',
        description: '最初のハンドで勝利する',
        reward: 100,
        progress: 0,
        target: 1,
        isCompleted: false,
        category: 'beginner',
      ),
      Mission(
        id: '2',
        title: '連続勝利',
        description: '3回連続で勝利する',
        reward: 300,
        progress: 0,
        target: 3,
        isCompleted: false,
        category: 'intermediate',
      ),
      Mission(
        id: '3',
        title: 'GTOマスター',
        description: 'GTO推奨アクションを10回実行する',
        reward: 500,
        progress: 0,
        target: 10,
        isCompleted: false,
        category: 'advanced',
      ),
      Mission(
        id: '4',
        title: 'レンジマスター',
        description: '推奨レンジ内で20回プレイする',
        reward: 400,
        progress: 0,
        target: 20,
        isCompleted: false,
        category: 'intermediate',
      ),
      Mission(
        id: '5',
        title: 'ポットコントロール',
        description: '平均ポットサイズを1000以上にする',
        reward: 600,
        progress: 0,
        target: 1000,
        isCompleted: false,
        category: 'advanced',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final missions = _getMissions();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ミッション', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '現在のミッションポイント',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: 0.3,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  '次のレベルまで: 700pt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: missions.length,
              itemBuilder: (context, index) {
                final mission = missions[index];
                return _buildMissionCard(mission);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final progress = mission.progress / mission.target;
    final isInProgress = mission.progress > 0 && !mission.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(mission.category).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(mission.category),
                  color: _getCategoryColor(mission.category),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.description,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(mission.category),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${mission.reward}pt',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '進捗: ${mission.progress}/${mission.target}',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    if (mission.isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Container(
                      height: 6,
                      width: MediaQuery.of(context).size.width * 0.8 * progress,
                      decoration: BoxDecoration(
                        color: isInProgress
                            ? Colors.orange
                            : mission.isCompleted
                                ? Colors.green
                                : Colors.grey,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'beginner':
        return Icons.star_border;
      case 'intermediate':
        return Icons.star_half;
      case 'advanced':
        return Icons.star;
      default:
        return Icons.flag;
    }
  }
}
