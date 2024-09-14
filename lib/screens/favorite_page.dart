import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:wallzify_flutter/dao/picture_dao.dart';
import 'package:wallzify_flutter/database.dart';
import 'package:wallzify_flutter/screens/component/picture_grid.dart';
import 'package:wallzify_flutter/screens/component/shrimmer.dart';
import 'package:wallzify_flutter/var.dart';
import 'package:wallzify_flutter/entity/picture.dart' as entity;

class FavoritePage extends StatefulWidget {
  final ScrollController controller;
  const FavoritePage({super.key, required this.controller});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    List<entity.Picture> list = context.watch<DBPictureList>().list;
    return Scaffold(
      backgroundColor: WallzifyColors.black,
      appBar: AppBar(
        backgroundColor: WallzifyColors.black,
        surfaceTintColor: WallzifyColors.black,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        controller: widget.controller,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1, left: 32),
              child: Text(
                'Wallzify',
                style: TextStyle(
                  fontFamily: 'Megrim',
                  color: WallzifyColors.white,
                  fontSize: 40,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text.rich(
                style: TextStyle(
                  color: WallzifyColors.white,
                  fontSize: 14,
                ),
                const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Your ',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'downloaded and favourite\n',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: 'images added here ↘ ',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: Column(
                    children: [
                      if (list.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.13,
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.3),
                            child: Column(
                              children: [
                                SvgPicture.asset('assets/icons/save.svg'),
                                const SizedBox(
                                  height: 25,
                                ),
                                Text(
                                  'No items currently\nadded here',
                                  style: TextStyle(
                                    color:
                                        WallzifyColors.white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      else
                        PictureGrid(constraints: constraints, list: list),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
// Your downloaded and favourite
// images added here