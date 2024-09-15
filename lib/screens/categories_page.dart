import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:flutter/rendering.dart';
import 'package:wallzify_flutter/screens/component/navbar.dart';
import 'package:wallzify_flutter/screens/component/shrimmer.dart';
import 'package:wallzify_flutter/var.dart';
import 'package:http/http.dart' as http;

class CategoriesPage extends StatefulWidget {
  final ScrollController controller;
  const CategoriesPage({super.key, required this.controller});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> list = [];

  Future<void> getData() async {
    http.Response res = await http.get(UrlThings.generateUrl('category', {}));
    List response;
    try {
      response = jsonDecode(res.body);
    } catch (e) {
      log(e.toString());
      return;
    }

    list.clear();
    response.forEach(
      (elem) => list.add(Category.fromJson(json: elem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) => context.read<CurrentPage>().back(),
      child: Scaffold(
        backgroundColor: WallzifyColors.black,
        appBar: AppBar(
          backgroundColor: WallzifyColors.black,
          surfaceTintColor: WallzifyColors.black,
          toolbarHeight: 0,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                        text: 'Immersive ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: 'category ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: 'of\nwallpapers ↘',
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
              Center(
                child: FutureBuilder(
                  future: getData(),
                  builder: (context, snapshot) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                for (int i = 0; i < 6; i++)
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Shimmer(
                                      linearGradient: shimmerGradient,
                                      child: ShimmerLoading(
                                        isLoading: true,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: WallzifyColors.white
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              ((constraints.maxWidth < 600)
                                                  ? 0.9
                                                  : 0.46),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              ((constraints.maxWidth < 600)
                                                  ? 0.25
                                                  : 0.18),
                                        ),
                                      ),
                                    ),
                                  ),
                              ]);
                        }
                        return Wrap(
                          alignment: WrapAlignment.start,
                          children: [
                            for (final a in list)
                              GestureDetector(
                                onTap: () =>
                                    context.pushNamed('category', extra: a),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      ((constraints.maxWidth < 600)
                                          ? 0.9
                                          : 0.46),
                                  height: MediaQuery.of(context).size.height *
                                      ((constraints.maxWidth < 600)
                                          ? 0.25
                                          : 0.18),
                                  child: LocationListItem(
                                    imageUrl: a.imageUrl,
                                    thumbnailUrl: a.thumbnailUrl,
                                    name: a.name,
                                    desc: a.desc,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LocationListItem extends StatefulWidget {
  LocationListItem({
    super.key,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.name,
    required this.desc,
  });

  final String imageUrl;
  final String thumbnailUrl;
  final String name;
  final String desc;

  @override
  State<LocationListItem> createState() => _LocationListItemState();
}

class _LocationListItemState extends State<LocationListItem> {
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            _buildParallaxBackground(context),
            _buildTitleAndSubtitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          key: _backgroundImageKey,
          fit: BoxFit.cover,
          placeholder: (context, url) => Stack(
            children: [
              CachedNetworkImage(
                imageUrl: widget.thumbnailUrl,
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
          // placeholder: (context, url) => Shimmer(
          //   linearGradient: shimmerGradient,
          //   child: ShimmerLoading(
          //     isLoading: true,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         color: WallzifyColors.white.withOpacity(0.1),
          //         borderRadius: BorderRadius.circular(22),
          //       ),
          //       width: MediaQuery.of(context).size.width,
          //       height: MediaQuery.of(context).size.height,
          //     ),
          //   ),
          // ),
        ),
      ],
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              widget.desc,
              softWrap: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
        listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
      0,
      transform:
          Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class Parallax extends SingleChildRenderObjectWidget {
  const Parallax({
    super.key,
    required Widget background,
  }) : super(child: background);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParallax(scrollable: Scrollable.of(context));
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderParallax renderObject) {
    renderObject.scrollable = Scrollable.of(context);
  }
}

class ParallaxParentData extends ContainerBoxParentData<RenderBox> {}

class RenderParallax extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin {
  RenderParallax({
    required ScrollableState scrollable,
  }) : _scrollable = scrollable;

  ScrollableState _scrollable;

  ScrollableState get scrollable => _scrollable;

  set scrollable(ScrollableState value) {
    if (value != _scrollable) {
      if (attached) {
        _scrollable.position.removeListener(markNeedsLayout);
      }
      _scrollable = value;
      if (attached) {
        _scrollable.position.addListener(markNeedsLayout);
      }
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ParallaxParentData) {
      child.parentData = ParallaxParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    // Force the background to take up all available width
    // and then scale its height based on the image's aspect ratio.
    final background = child!;
    final backgroundImageConstraints =
        BoxConstraints.tightFor(width: size.width);
    background.layout(backgroundImageConstraints, parentUsesSize: true);

    // Set the background's local offset, which is zero.
    (background.parentData as ParallaxParentData).offset = Offset.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Get the size of the scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;

    // Calculate the global position of this list item.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final backgroundOffset =
        localToGlobal(size.centerLeft(Offset.zero), ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final scrollFraction =
        (backgroundOffset.dy / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final background = child!;
    final backgroundSize = background.size;
    final listItemSize = size;
    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
        background,
        (background.parentData as ParallaxParentData).offset +
            offset +
            Offset(0.0, childRect.top));
  }
}
