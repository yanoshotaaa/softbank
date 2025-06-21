import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/analysis_history.dart';
import '../../providers/mission_provider.dart';
import '../../home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // 最初のフレームが描画された後にデータ読み込みを実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    // プロフィール、履歴を読み込み
    final profileProvider = context.read<ProfileProvider>();
    final historyProvider = context.read<AnalysisHistoryProvider>();

    await Future.wait([
      profileProvider.loadProfile(),
      historyProvider.loadHistories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ローディング中
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ユーザーがログインしている場合
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // ユーザーがログインしていない場合
        return const LoginScreen();
      },
    );
  }
}
