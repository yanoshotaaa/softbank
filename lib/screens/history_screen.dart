import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_history_provider.dart';
import '../models/analysis_history.dart' show AnalysisHistory;

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalysisHistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('分析履歴'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.histories.isEmpty
              ? const Center(child: Text('履歴がありません'))
              : ListView.builder(
                  itemCount: provider.histories.length,
                  itemBuilder: (context, index) {
                    final AnalysisHistory history = provider.histories[index];
                    return ListTile(
                      title: Text(history.handDescription ?? 'No Description'),
                      subtitle: Text(history.analysisResult ?? ''),
                    );
                  },
                ),
    );
  }
}
