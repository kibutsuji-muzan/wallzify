import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:wallzify_flutter/screens/component/picture_grid.dart';
import 'package:wallzify_flutter/screens/component/shrimmer.dart';
import 'package:wallzify_flutter/var.dart';

class HomePage extends StatefulWidget {
  final ScrollController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    _isFetchingData = true;
    setState(() {});
    try {
      final items = await fetchData();
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

  fetchData() async {
    var res = await APIRoute.getData(
      'index/',
      (_currentPage == 1) ? null : {'page': _currentPage.toString()},
    );
    setData(res['result']);
    _currentPage++;
    setState(() {});
  }

  setData(List l) => context.read<PictureList>().updateList(l);

  refresh() {
    context.read<PictureList>().list.clear();
    _currentPage = 1;
    _fetchPaginatedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WallzifyColors.black,
      appBar: AppBar(
        backgroundColor: WallzifyColors.black,
        surfaceTintColor: WallzifyColors.black,
        toolbarHeight: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.delayed(const Duration(seconds: 1), refresh()),
        color: WallzifyColors.white,
        backgroundColor: WallzifyColors.black,
        child: SingleChildScrollView(
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
                          catId: null,
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
                              childAspectRatio: MediaQuery.of(context)
                                      .size
                                      .width /
                                  (MediaQuery.of(context).size.height * 0.75),
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 22.0),
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
      ),
    );
  }
}
