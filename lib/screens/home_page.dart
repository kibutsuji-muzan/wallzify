import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:http/http.dart' as http;
import 'package:wallzify_flutter/var.dart';

class HomePage extends StatefulWidget {
  final ScrollController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> getData() async {
    http.Response res = await http.post(
      UrlThings.generateUrl('index/', {}),
      body: {'width': '600'},
    );
    List response;
    try {
      response = jsonDecode(res.body);
    } catch (e) {
      log(e.toString());
      return;
    }
    context.read<PictureList>().list.clear();
    response.forEach(
      (e) => context.read<PictureList>().list.add(Picture.fromJson(json: e)),
    );
  }

  @override
  void initState() {
    // getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<PictureList>();
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
            FutureBuilder(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.2,
                      ),
                      child: const CupertinoActivityIndicator(radius: 20.0),
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: Column(
                        children: [
                          if (state.list.isEmpty)
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
                            ),
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
                            itemCount: state.list.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Provider.of<PictureIndex>(context,
                                          listen: false)
                                      .updateIndex(index);
                                  context.pushNamed('wall', pathParameters: {
                                    'index': index.toString()
                                  });
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: CachedNetworkImage(
                                    imageUrl: state.list[index].thumbnailUrl,
                                    fit: BoxFit.cover,
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
