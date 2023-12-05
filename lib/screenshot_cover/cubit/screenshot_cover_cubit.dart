import 'package:create_long_screenshots/common/cached_cubit.dart';
import 'package:create_long_screenshots/image_picker/cubit/image_caches_cubit.dart';
import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_page/cubit/screenshot_page_cubit.dart';
import 'package:create_long_screenshots/screenshots/cubit/screenshots_cubit.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'screenshot_cover_state.dart';

class ScreenshotCoverCubit extends CachedCubit<ScreenshotCoverState> {
  ScreenshotCoverCubit()
      : super(ScreenshotCoverInitial(
          backgroundColor: Colors.black.withOpacity(0.4),
        )) {
    load();
  }

  @override
  String get cacheKey => "cover";

  @override
  ScreenshotCoverState? fromJson(Map<String, dynamic> json) {
    return ScreenshotCoverInitial(
      imageId: json['imageId'] as int,
      backgroundColor: Color(json['backgroundColor'] as int),
      textColor: Color(json['textColor'] as int),
      textFontSizeIndex: json['textFontSizeIndex'] as int,
      textFontWeightIndex: json['textFontWeightIndex'] as int,
    );
  }

  @override
  Map<String, dynamic>? toJson(ScreenshotCoverState state) {
    return {
      'imageId': state.imageId,
      'backgroundColor': state.backgroundColor.value,
      'textColor': state.textColor.value,
      'textFontSizeIndex': state.textFontSizeIndex,
      'textFontWeightIndex': state.textFontWeightIndex,
    };
  }

  void pickCoverImage(BuildContext context) async {
    final ids = await kImageCaches.pickImages(
      context,
      limit: 1,
      maxCompressImageWidth: 1920,
    );
    if (ids.isEmpty) {
      return;
    }
    final image = ids.first;
    emit(state.copyWith(imageId: image.imageId));
    save();
  }

  Widget buildCoverScreenshot(BuildContext context,
      {required ScreenshotPageCubit page, required double width}) {
    final index = kContext.read<ScreenshotsCubit>().state.pages.indexOf(page);

    final screenshots = kContext.read<ScreenshotsCubit>();

    final imageWidth = width * screenshots.state.numberOfRow;
    final imageHeight = width * screenshots.state.numberOfColumn;

    final indexOfRow = index % screenshots.state.numberOfRow;
    final indexOfColumn = ((index) / screenshots.state.numberOfRow).floor();

    return SizedBox(
      width: width,
      height: width,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: indexOfRow * -width,
              top: indexOfColumn * -width,
              width: imageWidth,
              height: imageHeight,
              child: CachedImageBuilder(
                imageId: state.imageId,
                builder: (context, image) => image == null
                    ? const SizedBox.shrink()
                    : Image.memory(
                        image,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned.fill(
              child: Container(
                // width: itemWidth,
                // height: itemHeight,
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Text(
                    page.state.title,
                    style: kDefaultTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: 24 * 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
