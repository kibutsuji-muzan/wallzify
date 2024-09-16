import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallzify/colors.dart';
import 'package:wallzify/screens/component/picture_grid.dart';
import 'package:wallzify/screens/component/shrimmer.dart';
import 'package:wallzify/var.dart';
import 'package:wallzify/entity/picture.dart' as entity;

class FavoritePage extends StatefulWidget {
  final ScrollController controller;
  const FavoritePage({super.key, required this.controller});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final StreamController<List<dynamic>> _dataStreamController =
      StreamController<List<dynamic>>();
  Stream<List<dynamic>> get dataStream => _dataStreamController.stream;
  final List<dynamic> _currentItems = [];
  late final ScrollController _scrollController;
  bool _isFetchingData = false;

  Future<void> _fetchPaginatedData() async {
    if (_isFetchingData) {
      return;
    }
    try {
      _isFetchingData = true;
      setState(() {});

      final items = [];
      _currentItems.addAll(items);
      _dataStreamController.add(_currentItems);
    } catch (e) {
      _dataStreamController.addError(e);
    } finally {
      _isFetchingData = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller;
    _fetchPaginatedData();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (currentScroll == maxScroll) {
        _fetchPaginatedData();
      }
    });
  }

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
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
                left: 32,
                right: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wallzify',
                    style: TextStyle(
                      fontFamily: 'Megrim',
                      color: WallzifyColors.white,
                      fontSize: 40,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final Uri url = UrlThings.generateUrl('/p/policy/', {});
                      print(url);
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    },
                    icon: const Icon(
                      Icons.privacy_tip_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
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
                        PictureGrid(
                          constraints: constraints,
                          dataStream: dataStream,
                          catId: null,
                        ),
                      if (_isFetchingData)
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height * 0.75),
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 22.0),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Shimmer(
                              linearGradient: shimmerGradient,
                              child: ShimmerLoading(
                                isLoading: true,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        WallzifyColors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  width: MediaQuery.of(context).size.width *
                                      ((constraints.maxWidth < 600)
                                          ? 0.42
                                          : 0.3),
                                  height: MediaQuery.of(context).size.height *
                                      ((constraints.maxWidth < 600)
                                          ? 0.3
                                          : 0.3),
                                ),
                              ),
                            );
                          },
                        ),
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