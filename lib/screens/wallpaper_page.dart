import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:wallzify_flutter/screens/component/file_storage.dart';
import 'package:wallzify_flutter/var.dart';
import 'package:wallzify_flutter/screens/component/bottom_sheet.dart';
import 'package:wallzify_flutter/entity/picture.dart' as entity;

class WallpaperPage extends StatefulWidget {
  final int index;
  WallpaperPage({
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

  createWatermark() async {
    FileStorage.getExternalDocumentPath();
    var state = Provider.of<PictureList>(context, listen: false);
    var file = await DefaultCacheManager().getSingleFile(
      state.list[Provider.of<PictureIndex>(context, listen: false).pagePosition]
          .imageUrl,
    );
    var img = await ImageWatermark.addTextWatermark(
      imgBytes: await file.readAsBytes(),
      watermarkText: 'Wallzify',
      color: Colors.white,
      dstX: 100,
      dstY: 150,
      font: ImageFont.readOtherFontZip(await loadAsset()),
    );
    FileStorage.downloadAndSaveImage(img);
    print(await loadAsset());
  }

  Future<Uint8List> loadAsset() async {
    ByteData a = await rootBundle.load('assets/fonts/Megrim.zip');
    return a.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) => context.read<CurrentPage>().back(),
      child: Scaffold(
        backgroundColor: WallzifyColors.black,
        body: Stack(
          children: [
            WallSlider(
              controller: _controller,
              index: widget.index,
              func: createWatermark,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, (animation.value * 200)),
                  child: child,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 600, minHeight: 65),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => createWatermark(),
                          icon: SvgPicture.asset('assets/icons/download.svg'),
                        ),
                        ElevatedButton(
                            onPressed: () => showModalBottomSheet(
                                  context: context,
                                  backgroundColor:
                                      const Color.fromRGBO(0, 0, 0, 0),
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      WallBottomSheet(index: widget.index),
                                ),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            button(
                              index: widget.index,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                'assets/icons/share.svg',
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<CurrentPage>().back();
                              },
                              icon: SvgPicture.asset(
                                'assets/icons/back.svg',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class WallSlider extends StatefulWidget {
  final AnimationController controller;
  int index;
  Function func;
  WallSlider({
    super.key,
    required this.controller,
    required this.index,
    required this.func,
  });

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

  get state {
    int index = Provider.of<CurrentPage>(context, listen: false).pageIndex;
    switch (index) {
      case 0:
        return Provider.of<PictureList>(context, listen: false);
      case 1:
        return Provider.of<CategoryPictureList>(context, listen: false);
      case 2:
        return Provider.of<DBPictureList>(context, listen: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      pageSnapping: true,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      // allowImplicitScrolling: true,
      controller: pageController,
      itemCount: state.list.length,
      onPageChanged: (page) {
        context.read<DBPictureList>().updateLike(state.list[page].id);
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

class button extends StatefulWidget {
  int index;
  button({super.key, required this.index});

  @override
  State<button> createState() => _buttonState();
}

class _buttonState extends State<button> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool clicked = false;
  List<entity.Picture> list = [];

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    initList();
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () => func());
  }

  get ostate {
    int index = Provider.of<CurrentPage>(context, listen: false).pageIndex;
    switch (index) {
      case 0:
        return Provider.of<PictureList>(context, listen: false);
      case 1:
        return Provider.of<CategoryPictureList>(context, listen: false);
      case 2:
        return Provider.of<DBPictureList>(context, listen: false);
    }
  }

  void func() => Provider.of<DBPictureList>(context, listen: false).updateLike(
        ostate.list[widget.index].id,
      );

  initList() async => list = await DatabaseThings.getAllEntity();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = context.read<DBPictureList>();
    return IconButton(
      onPressed: () {
        int page =
            Provider.of<PictureIndex>(context, listen: false).pagePosition;
        List pic = ostate.list;
        print(pic);
        print(ostate);
        var ent = pic[page];
        entity.Picture? a =
            state.list.where((element) => element.id == ent.id).firstOrNull;

        if (a == null) {
          state.updateDB(
            entity.Picture(
              id: ent.id,
              imageUrl: ent.imageUrl,
              thumbnailUrl: ent.thumbnailUrl,
            ),
          );
        } else {
          if (Provider.of<CurrentPage>(context, listen: false).pageIndex == 2) {
            context.pop();
          }
          state.removeEntity(
            entity.Picture(
              id: ent.id,
              imageUrl: ent.imageUrl,
              thumbnailUrl: ent.thumbnailUrl,
            ),
          );
        }
        context.read<DBPictureList>().updateLike(pic[page].id);

        _controller.forward().then((value) {
          _controller.reverse();
        });
      },
      isSelected: context.watch<DBPictureList>().like,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _controller.value * 1 + 1,
            child: SvgPicture.asset(
              'assets/icons/heart.svg',
              color: Colors.white,
              width: 30,
            ),
          );
        },
      ),
      selectedIcon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _controller.value * 1 + 1,
            child: SvgPicture.asset(
              'assets/Heart.svg',
              width: 30,
            ),
          );
        },
      ),
    );
  }
}
