import 'dart:typed_data';

import 'package:create_long_screenshots/image_picker/cubit/image_caches_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CachedImageBuilder extends StatelessWidget {
  const CachedImageBuilder({
    super.key,
    required this.imageId,
    required this.builder,
  });

  final int imageId;
  final Widget Function(BuildContext context, Uint8List? image) builder;

  @override
  Widget build(BuildContext context) {
    if (imageId == 0) {
      return builder(context, null);
    }
    final imageCache = kImageCaches.state.imageCache;
    final cachedImage = imageCache[imageId];
    if (cachedImage != null) {
      return builder(context, cachedImage);
    }

    kImageCaches.loadCachedImage(imageId);

    return BlocBuilder<ImageCachesCubit, ImageCachesState>(
      bloc: kImageCaches,
      buildWhen: (previous, current) =>
          previous.imageCache[imageId]?.length !=
          current.imageCache[imageId]?.length,
      builder: (context, state) => builder(context, state.imageCache[imageId]),
    );
  }
}
