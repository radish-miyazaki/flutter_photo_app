import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_app/components/photo_grid.dart';
import 'package:photo_app/models/photo.dart';
import 'package:photo_app/pages/login.dart';
import 'package:photo_app/pages/photo_detail.dart';
import 'package:photo_app/providers/photo_provider.dart';
import 'package:photo_app/repositories/photo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoListPage extends StatefulWidget {
  @override
  _PhotoListPageState createState() => _PhotoListPageState();
}

class _PhotoListPageState extends State<PhotoListPage> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      initialPage: context.read(photoListIndexProvider).state,
    );
  }

  void _onPageChanged(int index) =>
      setState(() => context.read(photoListIndexProvider).state = index);

  void _onTapBottomNavigationItem(int index) {
    _controller.animateToPage(
      // 表示するWidgetの番号
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    context.read(photoListIndexProvider).state = index;
  }

  void _onTapPhoto(Photo photo, List<Photo> photoList) {
    final initialIndex = photoList.indexOf(photo);

    Navigator.of(context).push(
      MaterialPageRoute(
        // ProviderScopeを用いてScopeProviderの値を上書きできる
        // ここでは、最初に表示する画像の番号を指定
        builder: (_) => ProviderScope(
          overrides: [
            photoViewInitialIndexProvider.overrideWithValue(initialIndex),
          ],
          child: PhotoDetailPage(),
        ),
      ),
    );
  }

  Future<void> _onLogout() async {
    // ログアウト処理
    await FirebaseAuth.instance.signOut();

    // ログアウトに成功したらログイン画面に戻す
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  Future<void> _onAddPhoto() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    // 画像ファイルが選択された場合
    if (result != null) {
      final User user = FirebaseAuth.instance.currentUser!;
      final PhotoRepository repository = PhotoRepository(user);
      final File file = File(result.files.single.path!);
      await repository.addPhoto(file);
    }
  }

  Future<void> _onTapFav(Photo photo) async {
    final photoRepository = context.read(photoRepositoryProvider);
    final togglePhoto = photo.toggleIsFavorite();
    await photoRepository!.updatePhoto(togglePhoto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo App'),
        actions: [
          IconButton(
            // TODO: ログアウト処理
            onPressed: () => _onLogout(),
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (int index) => _onPageChanged(index),
        children: [
          // 「すべての画像」を表示する部分
          Consumer(
            builder: (context, watch, child) {
              final asyncPhotoList = watch(photoListProvider);
              return asyncPhotoList.when(
                data: (List<Photo> photoList) {
                  return PhotoGrid(
                    onTap: (photo) => _onTapPhoto(photo, photoList),
                    photoList: photoList,
                    onTapFav: (photo) => _onTapFav(photo),
                  );
                },
                loading: () {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                error: (e, stackTrace) {
                  return Center(
                    child: Text(e.toString()),
                  );
                },
              );
            },
          ),
          // 「お気に入り登録した画像」を表示する部分
          Consumer(
            builder: (context, watch, child) {
              final asyncPhotoList = watch(favoritePhotoListProvider);
              return asyncPhotoList.when(
                data: (List<Photo> photoList) {
                  return PhotoGrid(
                    onTap: (photo) => _onTapPhoto(photo, photoList),
                    photoList: photoList,
                    onTapFav: (photo) => _onTapFav(photo),
                  );
                },
                loading: () {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                error: (e, stackTrace) {
                  return Center(
                    child: Text(e.toString()),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddPhoto(),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Consumer(
        builder: (context, watch, child) {
          // 現在のページを取得
          final photoIndex = watch(photoListIndexProvider).state;

          return BottomNavigationBar(
            onTap: (int index) => _onTapBottomNavigationItem(index),
            currentIndex: photoIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                label: 'フォト',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'お気に入り',
              ),
            ],
          );
        },
      ),
    );
  }
}
