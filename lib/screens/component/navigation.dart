import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/screens/categories_page.dart';
import 'package:wallzify_flutter/screens/category_page.dart';
import 'package:wallzify_flutter/screens/component/navbar.dart';
import 'package:wallzify_flutter/screens/favorite_page.dart';
import 'package:wallzify_flutter/screens/home_page.dart';
import 'package:wallzify_flutter/screens/wallpaper_page.dart';
import 'package:wallzify_flutter/var.dart';

class AppNavigation {
  AppNavigation._();

  static final _rootKey = GlobalKey<NavigatorState>();
  static final _homePageKey = GlobalKey<NavigatorState>();
  static final _categoriesPageKey = GlobalKey<NavigatorState>();
  static final _favoritePageKey = GlobalKey<NavigatorState>();

  static final ScrollController hcontroller = ScrollController();
  static final ScrollController ccontroller = ScrollController();
  static final ScrollController cacontroller = ScrollController();
  static final ScrollController fcontroller = ScrollController();

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        // parentNavigatorKey: _rootKey,
        pageBuilder: (context, state, navigationShell) {
          return MaterialPage(
            maintainState: true,
            child: PageViewGo(
              state: state,
              navigationShell: navigationShell,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homePageKey,
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => HomePage(
                  controller: hcontroller,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _categoriesPageKey,
            routes: [
              GoRoute(
                  path: '/categories',
                  name: 'categories',
                  builder: (context, state) =>
                      CategoriesPage(controller: ccontroller),
                  routes: [
                    GoRoute(
                      path: 'category',
                      name: 'category',
                      builder: (context, state) {
                        Category cat = state.extra as Category;
                        return CategoryPage(
                          controller: cacontroller,
                          category: cat,
                        );
                      },
                    )
                  ]),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _favoritePageKey,
            routes: [
              GoRoute(
                path: '/favorite',
                name: 'favorite',
                builder: (context, state) =>
                    FavoritePage(controller: fcontroller),
              )
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/wall/:index',
        name: 'wall',
        builder: (context, state) {
          print(state.extra);
          int index = int.parse(state.pathParameters['index']!);
          String? catId = state.extra as String?;
          return WallpaperPage(
            catId: catId,
            index: index,
            // listType: listType,
          );
        },
      ),
    ],
  );

  static GoRouter get router => _router;
}

class PageViewGo extends StatefulWidget {
  GoRouterState state;
  StatefulNavigationShell navigationShell;
  PageViewGo({super.key, required this.navigationShell, required this.state});

  @override
  State<PageViewGo> createState() => _PageViewGoState();
}

class _PageViewGoState extends State<PageViewGo> {
  @override
  void initState() {
    super.initState();

    Provider.of<CurrentPage>(context, listen: false)
        .setNavigation(widget.navigationShell);
    Provider.of<DBPictureList>(context, listen: false).initDB();
  }

  void goBranch(int index) {
    context.read<CurrentPage>().changePage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.navigationShell,
        Material(
          type: MaterialType.transparency,
          child: NavBar(
            switchBranch: goBranch,
            scontrollers: [
              AppNavigation.hcontroller,
              AppNavigation.ccontroller,
              AppNavigation.cacontroller,
              AppNavigation.fcontroller,
            ],
          ),
        ),
      ],
    );
  }
}
