import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:wallzify_flutter/var.dart';

class WallBottomSheet extends StatefulWidget {
  const WallBottomSheet({super.key, required this.index});
  final int index;
  @override
  State<WallBottomSheet> createState() => WallBottomSheetState();
}

class WallBottomSheetState extends State<WallBottomSheet> {
  @override
  Widget build(BuildContext context) {
    var state = context.watch<PictureList>();
    return Padding(
      padding: const EdgeInsets.all(14),
      child: DraggableScrollableSheet(
        initialChildSize: 0.35,
        maxChildSize: 1,
        minChildSize: 0.35,
        snap: true,
        builder: (context, scrollController) {
          return Material(
            color: Colors.white.withOpacity(0),
            surfaceTintColor: Colors.white.withOpacity(0),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 550,
                  width: MediaQuery.of(context).size.width,
                  constraints:
                      const BoxConstraints(maxWidth: 600, minHeight: 550),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(11, 10, 10, 1),
                    borderRadius: BorderRadiusDirectional.all(
                      Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                        child: Text(
                          'Wallzify',
                          style: TextStyle(
                            fontFamily: 'Megrim',
                            color: WallzifyColors.white,
                            fontSize: 35,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text.rich(
                          style: TextStyle(
                            color: WallzifyColors.white,
                            fontSize: 12,
                          ),
                          const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Set ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'wallpaper',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'According to\nyour ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'preference ↘',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 28,
                      ),
                      _eButton(
                        1,
                        'Home Screen',
                        state.list[context.watch<PictureIndex>().pagePosition]
                            .imageUrl,
                      ),
                      _eButton(
                        2,
                        'Lock Screen',
                        state.list[context.watch<PictureIndex>().pagePosition]
                            .imageUrl,
                      ),
                      _button(
                        3,
                        'Set To Both',
                        state.list[context.watch<PictureIndex>().pagePosition]
                            .imageUrl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _button(int i, String txt, String url) {
    return TextButton(
      onPressed: () {
        WallpaperThings.setWallpaper(
          url: url,
          wallLocation: i,
        );
        Provider.of<CurrentPage>(context, listen: false).changePage(0);
      },
      style: TextButton.styleFrom(
        fixedSize: Size.fromWidth(MediaQuery.of(context).size.width),
        surfaceTintColor: Colors.white,
        overlayColor: Colors.white,
      ),
      child: Text(
        txt,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _eButton(int i, String txt, String url) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: WallzifyColors.grey,
        overlayColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        fixedSize: Size.fromWidth(MediaQuery.of(context).size.width),
      ),
      onPressed: () {
        WallpaperThings.setWallpaper(
          url: url,
          wallLocation: i,
        );
        context.pop();
        // Provider.of<CurrentPage>(context, listen: false).changePage(0);
      },
      child: Text(
        txt,
        style: TextStyle(
          color: WallzifyColors.white,
        ),
      ),
    );
  }
}
