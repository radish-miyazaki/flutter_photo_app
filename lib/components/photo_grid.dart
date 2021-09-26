import 'package:flutter/material.dart';
import 'package:photo_app/models/photo.dart';

class PhotoGrid extends StatelessWidget {
  final void Function(Photo photo) onTap;
  final void Function(Photo photo) onTapFav;
  final List<Photo> photoList;

  const PhotoGrid({
    Key? key,
    required this.onTap,
    required this.onTapFav,
    required this.photoList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      padding: EdgeInsets.all(8),
      children: photoList.map((Photo photo) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              // INFO: Widgetをタップ可能にする
              child: InkWell(
                onTap: () => onTap(photo),
                child: Image.network(
                  photo.imageURL,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () => onTapFav(photo),
                icon: Icon(
                  photo.isFavorite == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                color: Colors.pinkAccent,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
