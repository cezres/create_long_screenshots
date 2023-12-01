import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/screenshot_cover/cubit/screenshot_cover_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenshotCoverImageView extends StatelessWidget {
  const ScreenshotCoverImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ScreenshotCoverCubit, ScreenshotCoverState, int>(
      selector: (state) => state.imageId,
      builder: (context, state) => CachedImageBuilder(
        imageId: state,
        builder: (context, image) => image == null
            ? const SizedBox.shrink()
            : Image.memory(
                image,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
