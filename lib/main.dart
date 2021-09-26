import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:photo_app/pages/photo_list.dart';
import 'package:photo_app/providers/user_provider.dart';

void main() async {
  // Flutterの初期化処理を待つ
  WidgetsFlutterBinding.ensureInitialized();

  // アプリ起動時にFirebaseの初期化処理を入れる
  // initializeApp()の返り値がFutureなので非同期処理なのでawaitする
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // ログイン状態に応じて表示する画面を切り替える
      home: Consumer(
        builder: (context, watch, child) {
          // ユーザ情報を取得
          final asyncUser = watch(userProvider);

          return asyncUser.when(
            data: (User? data) {
              return data == null ? LoginPage() : PhotoListPage();
            },
            loading: () {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
            error: (e, stackTrace) {
              return Scaffold(
                body: Center(
                  child: Text(e.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
