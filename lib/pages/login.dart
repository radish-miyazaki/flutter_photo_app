import 'package:flutter/material.dart';
import 'package:photo_app/pages/photo_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // バリデーションのKeyとなるFormKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TextFormFieldから値を取得するためのController
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _onLogIn() async {
    try {
      // バリデーションを走らせる
      if (_formKey.currentState?.validate() != true) {
        return;
      }

      final String email = _emailController.text;
      final String password = _passwordController.text;

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PhotoListPage(),
        ),
      );
    } catch (_) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ログインに失敗しました。'),
            content: Text('メールアドレス、またはパスワードが誤っている可能性があります。'),
          );
        },
      );
    }
  }

  Future<void> _onRegister() async {
    try {
      if (_formKey.currentState?.validate() != true) {
        return;
      }

      // メールアドレス・パスワードで新規登録
      final String email = _emailController.text;
      final String password = _passwordController.text;

      FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 画像一覧画面に切り替え
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PhotoListPage(),
        ),
      );
    } catch (_) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ユーザー登録に失敗しました。'),
            content: Text('時間を空けてから、再度お試しください。'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Photo App',
                  style: Theme.of(context).textTheme.headline3,
                ),
                SizedBox(height: 16),
                // メールアドレスの入力フィールド
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'メールアドレス'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value?.isEmpty == true) {
                      return 'メールアドレスを入力してください。';
                    }
                  },
                ),
                SizedBox(height: 8),
                // パスワードの入力フィールド
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'パスワード'),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (String? value) {
                    if (value?.isEmpty == true) {
                      return 'パスワードを入力してください。';
                    }
                  },
                ),
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  color: Colors.blue,
                  child: TextButton(
                    onPressed: () => _onLogIn(),
                    child: Text(
                      'ログイン',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  color: Colors.blue,
                  child: TextButton(
                    onPressed: () => _onRegister(),
                    child: Text(
                      '新規登録',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
