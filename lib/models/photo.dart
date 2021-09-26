class Photo {
  final String? id;
  final String imageURL;
  final String imagePath;
  final bool isFavorite;
  final DateTime? createdAt;

  Photo({
    this.id,
    required this.imageURL,
    required this.imagePath,
    required this.isFavorite,
    this.createdAt,
  });

  // お気に入り登録状況を切り替える
  Photo toggleIsFavorite() {
    return Photo(
      id: id,
      imageURL: imageURL,
      imagePath: imagePath,
      isFavorite: !isFavorite,
      createdAt: createdAt,
    );
  }
}
