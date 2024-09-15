import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:wallzify_flutter/screens/component/picture_grid.dart';
import 'package:wallzify_flutter/screens/component/shrimmer.dart';
import 'package:wallzify_flutter/var.dart';

class CategoryPage extends StatefulWidget {
  final ScrollController controller;
  final Category category;
  const CategoryPage({
    super.key,
    required this.controller,
    required this.category,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final StreamController<List<dynamic>> _dataStreamController =
      StreamController<List<dynamic>>();
  Stream<List<dynamic>> get dataStream => _dataStreamController.stream;
  final List<dynamic> _currentItems = [];
  int _currentPage = 1;
  late final ScrollController _scrollController;
  bool _isFetchingData = false;

  Future<void> _fetchPaginatedData() async {
    if (_isFetchingData) {
      return;
    }
    try {
      _isFetchingData = true;
      setState(() {});

      final items = await getData();
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
    context.read<CategoryPictureList>().catList.clear();
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

  getData() async {
    var res = await APIRoute.getCategoryData(
      'c/${widget.category.id}/getCategory',
      (_currentPage == 1) ? null : {'page': _currentPage.toString()},
    );
    setData(res['result']);
    _currentPage++;
    setState(() {});
  }

  setData(List l) => context.read<CategoryPictureList>().updateList(l);

  @override
  Widget build(BuildContext context) {
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
                  top: MediaQuery.of(context).size.height * 0.1, left: 32),
              child: Text(
                widget.category.name.capitalize(),
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
                      text: 'System optimized wallpapers\n',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'Recommendations ↘',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
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
                      PictureGrid(
                        constraints: constraints,
                        dataStream: dataStream,
                        catId: widget.category.id,
                      ),
                      const SizedBox(
                        height: 10,
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
