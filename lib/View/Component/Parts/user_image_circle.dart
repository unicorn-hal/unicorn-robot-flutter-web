import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_progress_indicator.dart';
import 'package:unicorn_robot_flutter_web/gen/assets.gen.dart';

class UserImageCircle extends StatelessWidget {
  const UserImageCircle({
    super.key,
    required this.imageSize,
    required this.imageUrl,
    this.onTap,
  });

  final double imageSize;
  final String imageUrl;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(imageSize / 2),
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) =>
                        const CustomProgressIndicator(size: 16),
                    errorWidget: (context, url, error) =>
                        Assets.images.logo.image(
                      width: imageSize,
                      height: imageSize,
                    ),
                  )
                : Assets.images.logo.image(
                    width: imageSize,
                    height: imageSize,
                  ),
          ),
        ),
      ),
    );
  }
}
