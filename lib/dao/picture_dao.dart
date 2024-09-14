import 'package:floor/floor.dart';
import 'package:wallzify_flutter/entity/picture.dart';

@dao
abstract class PictureDao {
  @Query('SELECT * FROM Picture')
  Future<List<Picture>> getAllPictures();

  // @Query('SELECT name FROM Person')
  // Stream<List<String>> findAllPeopleName();

  @Query('SELECT * FROM Picture WHERE id = :id')
  Stream<Picture?> getPictureById(String id);

  @insert
  Future<void> insertPicture(Picture pic);

  @delete
  Future<void> deletePicture(Picture pic);
}
