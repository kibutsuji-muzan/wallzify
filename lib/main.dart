import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:wallzify_flutter/screens/component/navigation.dart';
import 'package:wallzify_flutter/var.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseThings.initDB();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => navIndex()),
          ChangeNotifierProvider(create: (context) => CurrentPage()),
          ChangeNotifierProvider(create: (context) => PictureList()),
          ChangeNotifierProvider(create: (context) => PictureIndex()),
          ChangeNotifierProvider(create: (context) => CategoryPictureList()),
          ChangeNotifierProvider(create: (context) => DBPictureList()),
        ],
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: WallzifyColors.white,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      routerConfig: AppNavigation.router,
    );
  }
}
