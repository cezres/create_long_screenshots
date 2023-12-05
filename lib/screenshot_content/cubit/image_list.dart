import 'package:create_long_screenshots/image_picker/cubit/image_caches_cubit.dart';
import 'package:create_long_screenshots/screenshot_content/cubit/screenshot_content_cubit.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';

abstract class ImageList<S extends ImageListState>
    extends ScreenshotContentCubit<S> {
  ImageList(
    super.initialState, {
    required super.page,
    required super.id,
  });

  @override
  Map<String, dynamic>? toJson(S state) {
    return {
      'imageIds': state.imageIds,
      'crossAxisCount': state.crossAxisCount,
      'crossAxisSpacing': state.crossAxisSpacing,
      'mainAxisSpacing': state.mainAxisSpacing,
      'padding': {
        'left': state.padding.left,
        'top': state.padding.top,
        'right': state.padding.right,
        'bottom': state.padding.bottom,
      },
    };
  }

  @override
  Future<void> deleteResourcesInTransaction(Transaction transaction) {
    return kImageCaches.removeImages(state.imageIds, transaction: transaction);
  }

  @override
  Future<void> loadResources() async {
    if (state.imageIds.isNotEmpty) {
      for (var element in state.imageIds) {
        kImageCaches.loadCachedImage(element);
      }
      return kImageCaches.waitLoaded();
    }
  }

  Future<void> pickImages(BuildContext context) async {
    final images = await kImageCaches.pickImages(
      context,
      maxCompressImageWidth: 1440,
    );
    if (images.isEmpty) {
      return;
    }

    emit(buildStateWithImageIds(
        [...state.imageIds, ...images.map((e) => e.imageId)]));
    Future.microtask(() => save());
  }

  @override
  Future<ScreenshotContentCubit<S>> initialize(BuildContext context) async {
    await pickImages(context);
    if (state.imageIds.isEmpty) {
      throw Exception('No image selected');
    }
    return this;
  }

  void reorder(int oldIndex, int newIndex) {
    final imageIds = state.imageIds;
    final imageId = imageIds.removeAt(oldIndex);
    imageIds.insert(newIndex, imageId);
    emit(buildStateWithImageIds(imageIds));
    Future.microtask(() => save());
  }

  void removeImageIds(Set<int> imageIds) {
    emit(buildStateWithImageIds(state.imageIds
        .where((element) => !imageIds.contains(element))
        .toList(growable: false)));
    kImageCaches.removeImages(imageIds.toList(growable: false));
    Future.microtask(() => save());
  }

  S buildStateWithImageIds(List<int> imageIds);

  S buildStateWithListConfig({
    int? crossAxisCount,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  });
}

abstract class ImageListState extends ScreenshotContentState {
  const ImageListState({
    this.imageIds = const [],
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    super.padding,
  });

  final List<int> imageIds;

  final int crossAxisCount;

  final double crossAxisSpacing;

  final double mainAxisSpacing;

  @override
  List<Object?> get props => [
        ...super.props,
        imageIds,
        crossAxisCount,
        crossAxisSpacing,
        mainAxisSpacing
      ];
}
