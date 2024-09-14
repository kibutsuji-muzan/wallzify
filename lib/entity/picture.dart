import 'package:floor/floor.dart';

@entity
class Picture {
  @primaryKey
  final String id;
  String imageUrl;
  String thumbnailUrl;

  Picture(
      {required this.id, required this.imageUrl, required this.thumbnailUrl});
}
