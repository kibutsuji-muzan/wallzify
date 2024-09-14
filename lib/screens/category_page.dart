import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:wallzify_flutter/screens/component/picture_grid.dart';
import 'package:wallzify_flutter/screens/component/shrimmer.dart';
import 'package:wallzify_flutter/var.dart';
import 'package:http/http.dart' as http;

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
  List<Picture> list = [];

  Future<void> getData() async {
    http.Response res = await http.post(
      UrlThings.generateUrl('category/${widget.category.id}/getCategory/', {}),
      body: {'width': MediaQuery.of(context).size.width.ceil().toString()},
    );
    List response;
    try {
      response = jsonDecode(res.body);
    } catch (e) {
      log(e.toString());
      return;
    }
    setData(response);
  }

  void setData(List response) {
    var state = Provider.of<CategoryPictureList>(context, listen: false);
    state.catList.clear();
    response.forEach(
      (element) => state.catList.add(
        Picture.fromJson(json: element),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<CategoryPictureList>();
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
                return FutureBuilder(
                  future: getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: GridView.builder(
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
                          itemCount: 6,
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
                      );
                    }
                    return Center(
                      child: Column(
                        children: [
                          if (state.catList.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.2,
                              ),
                              child: Text(
                                'Some Error Have Occured',
                                style: TextStyle(
                                  color: WallzifyColors.white.withOpacity(0.4),
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            )
                          else
                            PictureGrid(
                                list: state.list, constraints: constraints)
                        ],
                      ),
                    );
                  },
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
