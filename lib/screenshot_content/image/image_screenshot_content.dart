import 'package:create_long_screenshots/image_picker/cubit/image_caches_cubit.dart';
import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/screenshot_content/cubit/screenshot_content_cubit.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content_editor.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content_preview.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ImageScreenshotContentCubit
    extends ScreenshotContentCubit<ImageScreenshotContentState> {
  ImageScreenshotContentCubit({
    required super.page,
    required super.id,
  }) : super(const ImageScreenshotContentState());

  @override
  ScreenshotContentType get type => ScreenshotContentType.image;

  @override
  ImageScreenshotContentState? fromJson(Map<String, dynamic> json) =>
      ImageScreenshotContentState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ImageScreenshotContentState state) =>
      state.toJson();

  @override
  Widget buildSliver(BuildContext context, double width, bool isEditing) {
    return ImageScreenshotContentPreview(
        cubit: this, width: width, isEditing: isEditing);
  }

  @override
  Widget buildEditor(BuildContext context, double width) {
    return ImageScreenshotContentEditor(cubit: this, width: width);
  }

  @override
  Widget buildScreenshotWidget(BuildContext context, {required double width}) {
    return Padding(
      padding: state.padding,
      child: CachedImageBuilder(
        imageId: state.imageId,
        builder: (context, image) =>
            image == null ? const SizedBox.shrink() : Image.memory(image),
      ),
    );
  }

  @override
  Future<void> loadResources() async {
    if (state.imageId > 0) {
      kImageCaches.loadCachedImage(state.imageId);
      await kImageCaches.waitLoaded();
    }
  }

  @override
  Future<ScreenshotContentCubit<ImageScreenshotContentState>> initialize(
      BuildContext context) async {
    await pickCoverImage(context);
    if (state.imageId <= 0) {
      throw Exception('No image selected');
    }
    return this;
  }

  Future<void> pickCoverImage(BuildContext context) async {
    final ids = await kImageCaches.pickImages(
      context,
      limit: 1,
      maxCompressImageWidth: 1440,
    );
    if (ids.isEmpty) {
      return;
    }
    final image = ids.first;

    if (state.imageId != 0) {
      kImageCaches.removeImages([state.imageId]);
    }

    emit(state.copyWith(
      imageId: image.imageId,
      width: image.width,
      height: image.height,
    ));
    Future.microtask(() => save());
  }

  void updatePadding(EdgeInsets padding) {
    emit(state.copyWith(padding: padding));
    Future.microtask(() => save());
  }
}

class ImageScreenshotContentState extends Equatable {
  const ImageScreenshotContentState({
    this.imageId = 0,
    this.width = 100,
    this.height = 50,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final int imageId;
  final int width;
  final int height;
  final EdgeInsets padding;

  @override
  List<Object?> get props => [
        imageId,
        width,
        height,
        padding.top,
        padding.left,
        padding.right,
        padding.bottom,
      ];

  ImageScreenshotContentState copyWith({
    int? imageId,
    int? width,
    int? height,
    EdgeInsets? padding,
  }) {
    return ImageScreenshotContentState(
      imageId: imageId ?? this.imageId,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      'imageId': imageId,
      'width': width,
      'height': height,
      'padding': {
        'left': padding.left,
        'top': padding.top,
        'right': padding.right,
        'bottom': padding.bottom,
      },
    };
  }

  static ImageScreenshotContentState? fromJson(Map<String, dynamic> json) {
    return ImageScreenshotContentState(
      imageId: json['imageId'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      padding: EdgeInsets.fromLTRB(
        json['padding']['left'] as double,
        json['padding']['top'] as double,
        json['padding']['right'] as double,
        json['padding']['bottom'] as double,
      ),
    );
  }
}
