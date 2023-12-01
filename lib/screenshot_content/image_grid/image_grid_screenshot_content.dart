import 'package:create_long_screenshots/image_picker/cubit/image_caches_cubit.dart';
import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/screenshot_content/cubit/screenshot_content_cubit.dart';
import 'package:create_long_screenshots/screenshot_content/image_grid/image_grid_screenshot_content_editor.dart';
import 'package:create_long_screenshots/screenshot_content/image_grid/image_grid_screenshot_content_preview.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';

class ImageGridScreenshotContentCubit
    extends ScreenshotContentCubit<ImageGridScreenshotContentState> {
  ImageGridScreenshotContentCubit({required super.page, required super.id})
      : super(const ImageGridScreenshotContentState());

  @override
  Widget buildSliver(BuildContext context, double width, bool isEditing) {
    return ImageGridScreenshotContentPreview(cubit: this, width: width);
  }

  @override
  Widget buildEditor(BuildContext context, double width) {
    return ImageGridScreenshotContentEditor(cubit: this, width: width);
  }

  @override
  Widget buildScreenshotWidget(BuildContext context, {required double width}) {
    final contentWidth = width -
        state.padding.horizontal -
        (state.crossAxisCount - 1) * state.crossAxisSpacing;
    final itemWidth = contentWidth / state.crossAxisCount;
    final itemHeight = itemWidth / state.childAspectRatio;

    final children = state.imageIds
        .map(
          (e) => CachedImageBuilder(
            imageId: e,
            builder: (context, image) => image == null
                ? Container(
                    width: itemWidth,
                    height: itemHeight,
                    color: Colors.grey[300],
                  )
                : Image.memory(
                    image,
                    fit: BoxFit.cover,
                    width: itemWidth,
                    height: itemHeight,
                  ),
          ),
        )
        .toList();

    return Padding(
      padding: state.padding,
      child: SizedBox(
        width: width - state.padding.horizontal,
        child: Wrap(
          spacing: state.crossAxisSpacing,
          runSpacing: state.mainAxisSpacing,
          children: children,
        ),
      ),
    );
  }

  @override
  ImageGridScreenshotContentState? fromJson(Map<String, dynamic> json) =>
      ImageGridScreenshotContentState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ImageGridScreenshotContentState state) =>
      state.toJson();

  @override
  ScreenshotContentType get type => ScreenshotContentType.imageGrid;

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

  @override
  Future<ScreenshotContentCubit<ImageGridScreenshotContentState>> initialize(
      BuildContext context) async {
    await pickImages(context);
    if (state.imageIds.isEmpty) {
      throw Exception('No image selected');
    }
    return this;
  }

  Future<void> pickImages(BuildContext context) async {
    final images = await kImageCaches.pickImages(
      context,
      maxCompressImageWidth: 1440,
    );
    if (images.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        imageIds: [...state.imageIds, ...images.map((e) => e.imageId)],
      ),
    );
    Future.microtask(() => save());
  }

  void removeImage(int imageId) {
    emit(
      state.copyWith(
        imageIds: state.imageIds
            .where((element) => element != imageId)
            .toList(growable: false),
      ),
    );
    kImageCaches.removeImages([imageId]);
    Future.microtask(() => save());
  }

  void moveImage(int oldIndex, int newIndex) {
    final imageId = state.imageIds[oldIndex];
    final imageIds = state.imageIds.toList();
    imageIds.removeAt(oldIndex);
    imageIds.insert(newIndex, imageId);
    emit(state.copyWith(imageIds: imageIds));
    Future.microtask(() => save());
  }

  void updatePadding(EdgeInsets padding) {
    emit(state.copyWith(padding: padding));
    Future.microtask(() => save());
  }

  void updateGrid({
    int? crossAxisCount,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    double? childAspectRatio,
  }) {
    emit(state.copyWith(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
    ));
    Future.microtask(() => save());
  }
}

class ImageGridScreenshotContentState extends Equatable {
  const ImageGridScreenshotContentState({
    this.imageIds = const [],
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.childAspectRatio = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final List<int> imageIds;

  final int crossAxisCount;

  final double crossAxisSpacing;

  final double mainAxisSpacing;

  final double childAspectRatio;

  final EdgeInsets padding;

  @override
  List<Object?> get props => [
        imageIds,
        crossAxisCount,
        crossAxisSpacing,
        mainAxisSpacing,
        childAspectRatio,
        padding,
      ];

  ImageGridScreenshotContentState copyWith({
    List<int>? imageIds,
    int? crossAxisCount,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    double? childAspectRatio,
    EdgeInsets? padding,
  }) {
    return ImageGridScreenshotContentState(
      imageIds: imageIds ?? this.imageIds,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      padding: padding ?? this.padding,
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      'imageIds': imageIds,
      'crossAxisCount': crossAxisCount,
      'crossAxisSpacing': crossAxisSpacing,
      'mainAxisSpacing': mainAxisSpacing,
      'childAspectRatio': childAspectRatio,
      'padding': {
        'left': padding.left,
        'top': padding.top,
        'right': padding.right,
        'bottom': padding.bottom,
      },
    };
  }

  static ImageGridScreenshotContentState? fromJson(Map<String, dynamic> json) {
    return ImageGridScreenshotContentState(
      imageIds: (json['imageIds'] as List).cast(),
      crossAxisCount: json['crossAxisCount'] as int,
      crossAxisSpacing: json['crossAxisSpacing'] as double,
      mainAxisSpacing: json['mainAxisSpacing'] as double,
      childAspectRatio: json['childAspectRatio'] as double,
      padding: EdgeInsets.fromLTRB(
        json['padding']['left'] as double,
        json['padding']['top'] as double,
        json['padding']['right'] as double,
        json['padding']['bottom'] as double,
      ),
    );
  }
}
