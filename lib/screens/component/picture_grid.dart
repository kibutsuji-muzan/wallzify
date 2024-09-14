import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallzify_flutter/colors.dart';
import 'package:wallzify_flutter/screens/component/shrimmer.dart';
import 'package:wallzify_flutter/var.dart';

class PictureGrid extends StatefulWidget {
  var list;
  final BoxConstraints constraints;
  PictureGrid({super.key, required this.list, required this.constraints});

  @override
  State<PictureGrid> createState() => _PictureGridState();
}

class _PictureGridState extends State<PictureGrid> {
  @override
  Widget build(BuildContext context) {
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
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Provider.of<PictureIndex>(context, listen: false)
                .updateIndex(index);
            context
                .pushNamed('wall', pathParameters: {'index': index.toString()});
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: CachedNetworkImage(
              imageUrl: widget.list[index].thumbnailUrl,
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
                        ((widget.constraints.maxWidth < 600) ? 0.42 : 0.3),
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
  }
}
