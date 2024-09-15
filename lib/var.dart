import 'dart:convert';

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wallzify_flutter/database.dart';
import 'package:wallzify_flutter/entity/picture.dart' as entity;
import 'package:http/http.dart' as http;

class UrlThings {
  static String domain = "ac2e-110-235-218-162.ngrok-free.app";

  static Uri generateUrl(String path, Map<String, dynamic>? headers) {
    return headers!.isEmpty
        ? Uri.https(domain, path)
        : Uri.https(domain, path, headers);
  }
}

class APIRoute {
  static Future<Map> getData(String path, Map<String, dynamic>? query) async {
    print(Uri.https(UrlThings.domain, path, query));
    http.Response res = await http.post(
      Uri.https(UrlThings.domain, path, query),
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
      Uri.https(UrlThings.domain, path, query),
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
    await AsyncWallpaper.setWallpaper(
      wallpaperLocation: wallLocation,
      url: url,
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
    print(json);
    return Picture(
        id: json['id'],
        imageUrl: json['image'],
        thumbnailUrl: json['thumbnail']);
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
    return Category(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      imageUrl: json['img'],
      thumbnailUrl: json['thumbnail'],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
