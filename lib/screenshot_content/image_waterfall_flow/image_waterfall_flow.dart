import 'package:create_long_screenshots/screenshot_content/cubit/image_list.dart';
import 'package:create_long_screenshots/screenshot_content/cubit/screenshot_content_cubit.dart';
import 'package:create_long_screenshots/screenshot_content/image_waterfall_flow/image_waterfall_flow_editor.dart';
import 'package:create_long_screenshots/screenshot_content/image_waterfall_flow/image_waterfall_flow_preivew.dart';
import 'package:flutter/material.dart';

class ImageWaterfallFlow extends ImageList<ImageWaterfallFlowState> {
  ImageWaterfallFlow({required super.page, required super.id})
      : super(const ImageWaterfallFlowState());

  @override
  Widget buildEditor(BuildContext context, double width) {
    return ImageWaterfallFlowEditor(cubit: this);
  }

  @override
  Widget buildScreenshotWidget(BuildContext context, {required double width}) {
    // TODO: implement buildScreenshotWidget
    throw UnimplementedError();
  }

  @override
  Widget buildSliver(BuildContext context, double width, bool isEditing) {
    return ImageWaterfallFlowPreview(cubit: this);
  }

  @override
  ImageWaterfallFlowState? fromJson(Map<String, dynamic> json) {
    return ImageWaterfallFlowState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(ImageWaterfallFlowState state) {
    return state.toJson();
  }

  @override
  ScreenshotContentType get type => ScreenshotContentType.imageWaterfallFlow;

  @override
  ImageWaterfallFlowState buildStateWithPadding(EdgeInsets padding) =>
      state.copyWith(padding: padding);

  @override
  ImageWaterfallFlowState buildStateWithImageIds(List<int> imageIds) =>
      state.copyWith(imageIds: imageIds);

  @override
  ImageWaterfallFlowState buildStateWithListConfig(
          {int? crossAxisCount,
          double? crossAxisSpacing,
          double? mainAxisSpacing}) =>
      state.copyWith(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      );
}

class ImageWaterfallFlowState extends ImageListState {
  const ImageWaterfallFlowState({
    super.padding,
    super.imageIds,
    super.crossAxisCount,
    super.crossAxisSpacing,
    super.mainAxisSpacing,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageIds': imageIds,
      'crossAxisCount': crossAxisCount,
      'crossAxisSpacing': crossAxisSpacing,
      'mainAxisSpacing': mainAxisSpacing,
      'padding': {
        'left': padding.left,
        'right': padding.right,
        'top': padding.top,
        'bottom': padding.bottom,
      },
    };
  }

  static ImageWaterfallFlowState fromJson(Map<String, dynamic> json) {
    return ImageWaterfallFlowState(
      imageIds: (json['imageIds'] as List).cast<int>(),
      crossAxisCount: json['crossAxisCount'] as int,
      crossAxisSpacing: json['crossAxisSpacing'] as double,
      mainAxisSpacing: json['mainAxisSpacing'] as double,
      padding: EdgeInsets.only(
        left: json['padding']['left'] as double,
        right: json['padding']['right'] as double,
        top: json['padding']['top'] as double,
        bottom: json['padding']['bottom'] as double,
      ),
    );
  }

  ImageWaterfallFlowState copyWith({
    List<int>? imageIds,
    int? crossAxisCount,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    EdgeInsets? padding,
  }) {
    return ImageWaterfallFlowState(
      imageIds: imageIds ?? this.imageIds,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      padding: padding ?? this.padding,
    );
  }
}
