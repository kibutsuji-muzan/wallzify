import 'dart:convert';

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:wallzify/database.dart';
import 'package:wallzify/entity/picture.dart' as entity;
import 'package:http/http.dart' as http;

class UrlThings {
  static String domain = "47.129.197.134";

  static Uri generateUrl(String path, Map<String, dynamic>? headers) {
    return headers!.isEmpty
        ? Uri.http(domain, path)
        : Uri.http(domain, path, headers);
  }
}

class APIRoute {
  static Future<Map> getData(String path, Map<String, dynamic>? query) async {
    http.Response res = await http.post(
      Uri.http(UrlThings.domain, path, query),
      body: {'width': '600'},
    );
    debugPrint(res.body);
    Map response;
    try {
      response = jsonDecode(res.body);
    } catch (e) {
      return {};
    }
    return response;
  }

  static Future<Map> getCategoryData(
      String path, Map<String, dynamic>? query) async {
    http.Response res = await http.get(
      Uri.http(UrlThings.domain, path, query),
    );
    debugPrint(res.body);
    Map response;
    try {
      response = jsonDecode(res.body);
    } catch (e) {
      return {};
    }
    return response;
  }
}

class DatabaseThings {
  static late AppDatabase database;
  static initDB() async {
    database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }

  static getAllEntity() {
    return database.pictureDao.getAllPictures();
  }
}

class WallpaperThings {
  static void setWallpaper(
      {required String url, required int wallLocation}) async {
    var file = await DefaultCacheManager().getSingleFile(url);
    await AsyncWallpaper.setWallpaperFromFile(
      filePath: file.path,
      wallpaperLocation: wallLocation,
      goToHome: false,
      toastDetails: ToastDetails.wallpaperChooser(),
      errorToastDetails: ToastDetails.error(),
    );
  }
}

class DBPictureList extends ChangeNotifier {
  List<entity.Picture> _list = [];
  bool _like = false;
  List<entity.Picture> get list => _list;
  bool get like => _like;

  initDB() async {
    await DatabaseThings.initDB();
    _list = await DatabaseThings.getAllEntity();
    notifyListeners();
  }

  updateDB(entity.Picture pic) {
    DatabaseThings.database.pictureDao.insertPicture(pic);
    _list.add(pic);
    notifyListeners();
  }

  removeEntity(entity.Picture pic) {
    DatabaseThings.database.pictureDao.deletePicture(pic);
    _list.removeWhere(
      (element) => element.id == pic.id,
    );
    notifyListeners();
  }

  void updateLike(String id) {
    if (_list.where((element) => element.id == id).isEmpty) {
      _like = false;
    } else {
      _like = true;
    }
    notifyListeners();
  }
}

class PictureList extends ChangeNotifier {
  List<Picture> _list = [];
  List<Picture> get list => _list;

  void updateList(List l) {
    l.forEach(
      (element) {
        if (_list.where((elem) => elem.id == element['id']).isEmpty) {
          _list.add(
            Picture.fromJson(json: element),
          );
        }
      },
    );
    notifyListeners();
  }
}

class CategoryPictureList extends ChangeNotifier {
  List<Picture> _catList = [];

  List<Picture> get catList => _catList;
  List<Picture> get list => _catList;

  updateList(List l) {
    l.forEach(
      (element) {
        if (_catList.where((elem) => elem.id == element['id']).isEmpty) {
          _catList.add(Picture.fromJson(json: element));
        }
      },
    );
    notifyListeners();
  }
}

class PictureIndex extends ChangeNotifier {
  int _pagePosition = 0;
  int get pagePosition => _pagePosition;

  updateIndex(int i) {
    _pagePosition = i;
    notifyListeners();
  }
}

class navIndex extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void update({required int i}) {
    _index = i;
    notifyListeners();
  }
}

class CurrentPage extends ChangeNotifier {
  int _pageIndex = 0;
  late StatefulNavigationShell _navigationShell;
  int get pageIndex => _pageIndex;

  void changePage(int index) {
    _navigationShell.goBranch(
      index,
      initialLocation: index == _navigationShell.currentIndex,
    );
    _pageIndex = index;
    notifyListeners();
  }

  void back() {
    _navigationShell.goBranch(
      _pageIndex,
      initialLocation: _pageIndex == _navigationShell.currentIndex,
    );
    notifyListeners();
  }

  void setNavigation(StatefulNavigationShell navigationShell) {
    _navigationShell = navigationShell;
  }
}

class Picture {
  String id;
  String imageUrl;
  String thumbnailUrl;
  Picture(
      {required this.id, required this.imageUrl, required this.thumbnailUrl});

  factory Picture.fromJson({required Map json}) {
    String img = 'https://drive.google.com/uc?export=download&id=${json['id']}';
    return Picture(
        id: json['id'], imageUrl: img, thumbnailUrl: json['thumbnail']);
  }
}

class Category {
  String id;
  String name;
  String desc;
  String imageUrl;
  String thumbnailUrl;
  Category({
    required this.id,
    required this.name,
    required this.desc,
    required this.imageUrl,
    required this.thumbnailUrl,
  });

  factory Category.fromJson({required Map json}) {
    String img = 'https://drive.google.com/uc?export=download&id=${json['id']}';
    return Category(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      imageUrl: img,
      thumbnailUrl: json['thumbnail'],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
