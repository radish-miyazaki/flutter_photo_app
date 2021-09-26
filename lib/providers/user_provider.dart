import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Streamをデータとして渡したいときに用いるStreamProvider
// ユーザの状態を管理するためのProvider（firebaseから受け取るので、StreamProvider）
final userProvider = StreamProvider.autoDispose((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
