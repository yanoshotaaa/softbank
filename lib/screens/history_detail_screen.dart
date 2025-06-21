import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/analysis_history.dart';
import '../widgets/common_header.dart';

class HistoryDetailScreen extends StatefulWidget {
  final AnalysisHistory history;

  const HistoryDetailScreen({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  // カラーパレットの定義
  static const _primaryColor = Color(0xFF2C3E50);
  static const _secondaryColor = Color(0xFF34495E);
  static const _backgroundColor = Color(0xFFFAFAFA);
  static const _textPrimaryColor = Color(0xFF2C3E50);
  static const _textSecondaryColor = Color(0xFF7F8C8D);
  static const _successColor = Color(0xFF27AE60);
  static const _warningColor = Color(0xFFF39C12);
  static const _errorColor = Color(0xFFE74C3C);

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  late TextEditingController _notesController;
  late List<String> _tags;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _notesController = TextEditingController(text: widget.history.notes ?? '');
    _tags = List.from(widget.history.tags);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() async {
    final updatedHistory = AnalysisHistory(
      id: widget.history.id,
      analyzedAt: widget.history.analyzedAt,
      handDescription: widget.history.handDescription,
      winRate: widget.history.winRate,
      analysisResult: widget.history.analysisResult,
      handDetails: widget.history.handDetails,
      imagePath: widget.history.imagePath,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      tags: _tags,
    );

    await context.read<AnalysisHistoryProvider>().updateHistory(updatedHistory);

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('変更を保存しました')),
      );
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Widget _buildHeader() {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final winRateColor =
        widget.history.winRate >= 0.5 ? _successColor : _warningColor;
    final resultColor = widget.history.analysisResult == '適切なプレイ'
        ? _successColor
        : _warningColor;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shadowColor: _primaryColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.8),
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.history.handDescription,
                          style: const TextStyle(
                            fontFamily: 'Noto Sans JP',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: resultColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: resultColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.history.analysisResult,
                          style: TextStyle(
                            fontFamily: 'Noto Sans JP',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: resultColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: _textSecondaryColor.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(widget.history.analyzedAt),
                        style: TextStyle(
                          fontFamily: 'Noto Sans JP',
                          fontSize: 12,
                          color: _textSecondaryColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailItem('ポジション',
                                widget.history.handDetails['position']),
                            _buildDetailItem(
                                'スタック', widget.history.handDetails['stack']),
                            _buildDetailItem(
                                'アクション', widget.history.handDetails['action']),
                            _buildDetailItem(
                                '相手', widget.history.handDetails['opponent']),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: winRateColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: winRateColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '勝率: ',
                                style: TextStyle(
                                  fontFamily: 'Noto Sans JP',
                                  fontSize: 16,
                                  color: _textSecondaryColor,
                                ),
                              ),
                              Text(
                                '${(widget.history.winRate * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontFamily: 'Noto Sans JP',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: winRateColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Noto Sans JP',
            fontSize: 10,
            color: _textSecondaryColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Noto Sans JP',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 4,
          shadowColor: _primaryColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.8),
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'メモ',
                        style: TextStyle(
                          fontFamily: 'Noto Sans JP',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textPrimaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleEdit,
                        icon: Icon(
                          _isEditing ? Icons.save : Icons.edit,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isEditing) ...[
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'メモを入力してください...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _notesController.text =
                                  widget.history.notes ?? '';
                            });
                          },
                          child: const Text('キャンセル'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('保存'),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.history.notes ?? 'メモがありません',
                        style: TextStyle(
                          fontFamily: 'Noto Sans JP',
                          fontSize: 14,
                          color: widget.history.notes != null
                              ? _textPrimaryColor
                              : _textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shadowColor: _primaryColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.8),
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'タグ',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map((tag) => Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: _primaryColor.withOpacity(0.1),
                            deleteIconColor: _primaryColor,
                            labelStyle: const TextStyle(color: _primaryColor),
                          )),
                      ActionChip(
                        label: const Text('+ タグ追加'),
                        onPressed: () {
                          _showAddTagDialog();
                        },
                        backgroundColor: _secondaryColor.withOpacity(0.1),
                        labelStyle: const TextStyle(color: _secondaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTagDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タグを追加'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'タグ名を入力してください',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              _addTag(textController.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // 背景グラデーション
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _primaryColor.withOpacity(0.05),
                  _backgroundColor,
                ],
              ),
            ),
          ),
          // 共通ヘッダー
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: const CommonHeader(
              title: '分析詳細',
              showBackButton: true,
            ),
          ),
          // コンテンツ
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 56,
              bottom: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildNotesSection(),
                  const SizedBox(height: 16),
                  _buildTagsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
