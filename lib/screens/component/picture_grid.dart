import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallzify/colors.dart';
import 'package:wallzify/screens/component/shrimmer.dart';
import 'package:wallzify/var.dart';

class PictureGrid extends StatefulWidget {
  final BoxConstraints constraints;
  final Stream dataStream;
  final String? catId;
  const PictureGrid({
    super.key,
    required this.constraints,
    required this.dataStream,
    required this.catId,
  });

  @override
  State<PictureGrid> createState() => _PictureGridState();
}

class _PictureGridState extends State<PictureGrid> {
  get state {
    int index = Provider.of<CurrentPage>(context, listen: false).pageIndex;
    switch (index) {
      case 0:
        return context.watch<PictureList>();
      case 1:
        return context.watch<CategoryPictureList>();
      case 2:
        return context.watch<DBPictureList>();
    }
  }

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.dataStream,
        builder: (context, snapshot) {
          return GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height * 0.75),
            ),
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            itemCount: state.list.length,
            itemBuilder: (context, index) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer(
                  linearGradient: shimmerGradient,
                  child: ShimmerLoading(
                    isLoading: true,
                    child: Container(
                      decoration: BoxDecoration(
                        color: WallzifyColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      width: MediaQuery.of(context).size.width *
                          ((widget.constraints.maxWidth < 600) ? 0.42 : 0.3),
                      height: MediaQuery.of(context).size.height *
                          ((widget.constraints.maxWidth < 600) ? 0.3 : 0.3),
                    ),
                  ),
                );
              }
              return GestureDetector(
                onTap: () {
                  Provider.of<PictureIndex>(context, listen: false)
                      .updateIndex(index);
                  context.pushNamed(
                    'wall',
                    pathParameters: {'index': index.toString()},
                    extra: widget.catId,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: CachedNetworkImage(
                    imageUrl: state.list[index].thumbnailUrl,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width *
                        ((widget.constraints.maxWidth < 600) ? 0.42 : 0.3),
                    height: MediaQuery.of(context).size.height *
                        ((widget.constraints.maxWidth < 600) ? 0.3 : 0.3),
                    placeholder: (context, url) => Shimmer(
                      linearGradient: shimmerGradient,
                      child: ShimmerLoading(
                        isLoading: true,
                        child: Container(
                          decoration: BoxDecoration(
                            color: WallzifyColors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          width: MediaQuery.of(context).size.width *
                              ((widget.constraints.maxWidth < 600)
                                  ? 0.42
                                  : 0.3),
                          height: MediaQuery.of(context).size.height *
                              ((widget.constraints.maxWidth < 600) ? 0.3 : 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
