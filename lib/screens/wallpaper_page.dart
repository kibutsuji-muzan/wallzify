import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:wallzify_flutter/var.dart';

class WallpaperPage extends StatefulWidget {
  final int index;
  const WallpaperPage({
    super.key,
    required this.index,
  });

  @override
  State<WallpaperPage> createState() => _WallpaperPageState();
}

class _WallpaperPageState extends State<WallpaperPage>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInBack,
      reverseCurve: Curves.easeInBack,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WallzifyColors.black,
      body: Stack(
        children: [
          WallSlider(
            controller: _controller,
            index: widget.index,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22.0),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, (animation.value * 150)),
                child: child,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 600, minHeight: 65),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset('assets/icons/download.svg'),
                      ),
                      ElevatedButton(
                          onPressed: () => showModalBottomSheet(
                                context: context,
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 0, 0),
                                isScrollControlled: true,
                                builder: (context) =>
                                    BottomSheet(index: widget.index),
                              ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            backgroundColor: WallzifyColors.buttonGrey,
                            surfaceTintColor: WallzifyColors.white,
                            foregroundColor: WallzifyColors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: SvgPicture.asset(
                                    'assets/icons/wallpaper.svg'),
                              ),
                              Text(
                                'Set Wallpaper',
                                style: TextStyle(
                                  color: WallzifyColors.black,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: SvgPicture.asset(
                          'assets/icons/back.svg',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class WallSlider extends StatefulWidget {
  final AnimationController controller;
  int index;
  WallSlider({super.key, required this.controller, required this.index});

  @override
  State<WallSlider> createState() => _WallSliderState();
}

class _WallSliderState extends State<WallSlider> {
  late PageController pageController;
  int activePage = 0;

  @override
  void initState() {
    pageController = PageController(
      viewportFraction: 1,
      initialPage: widget.index,
    );
    activePage = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var state = context.read<PictureList>();
    return PageView.builder(
      pageSnapping: true,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      allowImplicitScrolling: true,
      controller: pageController,
      itemCount: state.list.length,
      onPageChanged: (page) {
        setState(() {
          activePage = page;
        });
        context.read<PictureIndex>().updateIndex(page);
      },
      itemBuilder: (context, index) {
        bool active = index == activePage;
        return slider(index, active);
      },
    );
  }

  AnimatedContainer slider(pagePosition, active) {
    var state = context.watch<PictureList>();
    double margin = active ? 0 : 22;
    double radius = active ? 8 : 22;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      margin: EdgeInsets.all(margin),
      child: GestureDetector(
        onTap: () => !(widget.controller.status.isCompleted)
            ? widget.controller.forward()
            : widget.controller.reverse(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CachedNetworkImage(
            imageUrl: state.list[pagePosition].imageUrl,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            placeholder: (context, url) => Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: state.list[pagePosition].thumbnailUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomSheet extends StatefulWidget {
  const BottomSheet({super.key, required this.index});
  final int index;
  @override
  State<BottomSheet> createState() => BottomSheetState();
}

class BottomSheetState extends State<BottomSheet> {
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

// Set wallpaper According to
// your preference
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
