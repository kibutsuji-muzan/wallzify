import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String adUnitId = 'ca-app-pub-1821470381672343/2207897024';

class UrlThings {
  static String domain = "0fee-110-235-218-225.ngrok-free.app";

  static Uri generateUrl(String path, Map<String, dynamic>? headers) {
    return headers!.isEmpty
        ? Uri.https(domain, path)
        : Uri.https(domain, path, headers);
  }
}

class WallpaperThings {
  static void setWallpaper(
      {required String url, required int wallLocation}) async {
    await AsyncWallpaper.setWallpaper(
      wallpaperLocation: wallLocation,
      url: url,
      goToHome: false,
      toastDetails: ToastDetails.success(),
      errorToastDetails: ToastDetails.error(),
    );
  }
}

class PictureList extends ChangeNotifier {
  List<Picture> _list = [];
  List<Picture> _catList = [];
  List<Picture> get list => _list;
  List<Picture> get catList => _catList;

  update({required List<Picture> l}) {
    _list = l;
    notifyListeners();
  }

  updateCategory({required List<Picture> l}) {
    _catList = l;
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
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void requestNotificationPermissions() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
// }

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

  void changePage(
    int index,
  ) {
    _navigationShell.goBranch(
      index,
      initialLocation: index == _navigationShell.currentIndex,
    );
    _pageIndex = index;
    notifyListeners();
  }

  void setNavigation(StatefulNavigationShell navigationShell) {
    _navigationShell = navigationShell;
  }
}

class Picture {
  String imageUrl;
  String thumbnailUrl;
  Picture({required this.imageUrl, required this.thumbnailUrl});

  factory Picture.fromJson({required Map json}) {
    print(json);
    return Picture(imageUrl: json['image'], thumbnailUrl: json['thumbnail']);
  }
}

class Category {
  String id;
  String name;
  String desc;
  String imageUrl;
  Category({
    required this.id,
    required this.name,
    required this.desc,
    required this.imageUrl,
  });

  factory Category.fromJson({required Map json}) {
    return Category(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      imageUrl: json['img'],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
