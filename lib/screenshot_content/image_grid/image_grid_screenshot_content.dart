import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/screenshot_content/cubit/image_list.dart';
import 'package:create_long_screenshots/screenshot_content/cubit/screenshot_content_cubit.dart';
import 'package:create_long_screenshots/screenshot_content/image_grid/image_grid_screenshot_content_editor.dart';
import 'package:create_long_screenshots/screenshot_content/image_grid/image_grid_screenshot_content_preview.dart';
import 'package:flutter/material.dart';

class ImageGridScreenshotContentCubit
    extends ImageList<ImageGridScreenshotContentState> {
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

  void moveImage(int oldIndex, int newIndex) {
    final imageId = state.imageIds[oldIndex];
    final imageIds = state.imageIds.toList();
    imageIds.removeAt(oldIndex);
    imageIds.insert(newIndex, imageId);
    emit(state.copyWith(imageIds: imageIds));
    Future.microtask(() => save());
  }

  @override
  ImageGridScreenshotContentState buildStateWithPadding(EdgeInsets padding) {
    return state.copyWith(padding: padding);
  }

  @override
  ImageGridScreenshotContentState buildStateWithImageIds(List<int> imageIds) =>
      state.copyWith(imageIds: imageIds);

  @override
  ImageGridScreenshotContentState buildStateWithListConfig(
      {int? crossAxisCount,
      double? crossAxisSpacing,
      double? mainAxisSpacing}) {
    return state.copyWith(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
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

class ImageGridScreenshotContentState extends ImageListState {
  const ImageGridScreenshotContentState({
    super.imageIds,
    super.crossAxisCount,
    super.crossAxisSpacing,
    super.mainAxisSpacing,
    super.padding,
    this.childAspectRatio = 1,
  });

  final double childAspectRatio;

  @override
  List<Object?> get props => [
        ...super.props,
        childAspectRatio,
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
