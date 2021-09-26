import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_app/models/photo.dart';
import 'package:photo_app/providers/user_provider.dart';
import 'package:photo_app/repositories/photo_repository.dart';

// PhotoProviderからPhotoRepositoryを渡す
final photoRepositoryProvider = Provider.autoDispose((ref) {
  final user = ref.watch(userProvider).data?.value;
  return user == null ? null : PhotoRepository(user);
});

// フォトリストの状態を管理するためのProvider（firebaseから受け取るので、StreamProvider）
final photoListProvider = StreamProvider.autoDispose((ref) {
  // ref.watch() を使うことで他のProviderのデータを取得できる
  final photoRepository = ref.watch(photoRepositoryProvider);

  return photoRepository == null
      ? Stream.value(<Photo>[])
      : photoRepository.getPhotoList();
});

// 更新可能なデータを渡したいときに用いるStateProvider
final photoListIndexProvider = StateProvider.autoDispose((ref) {
  return 0;
});

// 状況に応じて渡すデータを切り替えるときに用いるScopedProvider
final photoViewInitialIndexProvider = ScopedProvider<int>(null);

// photoListProviderのデータを元に、お気に入り登録されたデータのみを受け渡せるようにする
final favoritePhotoListProvider = Provider.autoDispose((ref) {
  return ref.watch(photoListProvider).whenData(
    (List<Photo> data) {
      return data.where((photo) => photo.isFavorite == true).toList();
    },
  );
});
