import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_app/models/photo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhotoRepository {
  final User user;

  PhotoRepository(this.user);

  List<Photo> _queryToPhotoList(QuerySnapshot query) {
    return query.docs.map((doc) {
      return Photo(
        id: doc.id,
        imageURL: doc.get('imageURL'),
        imagePath: doc.get('imagePath'),
        isFavorite: doc.get('isFavorite'),
        createdAt: (doc.get('createdAt') as Timestamp).toDate(),
      );
    }).toList();
  }

  Stream<List<Photo>> getPhotoList() {
    return FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _queryToPhotoList(snapshot));
  }

  Map<String, dynamic> _photoMap(Photo photo) {
    return {
      'imageURL': photo.imageURL,
      'imagePath': photo.imagePath,
      'isFavorite': photo.isFavorite,
      'createdAt': photo.createdAt == null
          ? Timestamp.now()
          : Timestamp.fromDate(photo.createdAt!),
    };
  }

  Future<void> addPhoto(File file) async {
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final String fileName =
        file.path.split('/').last; // '/'で分割し生成した配列の最後の要素をファイル名とする
    final String path = '${timestamp}_$fileName';
    final TaskSnapshot task = await FirebaseStorage.instance
        .ref()
        .child('users/${user.uid}/photos') // フォルダ名
        .child(path) // ファイル名
        .putFile(file); // 保存する画像ファイル

    // アップロードした画像のURLを取得
    final String imageURL = await task.ref.getDownloadURL();

    // アップロードした画像の保存先を取得
    final String imagePath = task.ref.fullPath;

    final Photo photo = Photo(
      imageURL: imageURL,
      imagePath: imagePath,
      isFavorite: false,
    );

    // FireStoreにデータを保存
    await FirebaseFirestore.instance
        .collection('users/${user.uid}/photos') // コレクション
        .doc()
        .set(_photoMap(photo));
  }

  Future<void> updatePhoto(Photo photo) async {
    await FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .doc(photo.id)
        .update(_photoMap(photo));
  }

  Future<void> deletePhoto(Photo photo) async {
    // Cloud Firestoreのデータを削除
    await FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .doc(photo.id)
        .delete();

    // Storageのデータを削除
    await FirebaseStorage.instance.ref().child(photo.imagePath).delete();
  }
}
