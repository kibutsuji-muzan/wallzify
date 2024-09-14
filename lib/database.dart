import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:wallzify_flutter/dao/picture_dao.dart';
import 'package:wallzify_flutter/entity/picture.dart';

part 'database.g.dart';

@Database(version: 1, entities: [Picture])
abstract class AppDatabase extends FloorDatabase {
  PictureDao get pictureDao;
}
