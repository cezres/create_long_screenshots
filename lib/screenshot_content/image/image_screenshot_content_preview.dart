import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageScreenshotContentPreview extends StatelessWidget {
  const ImageScreenshotContentPreview({
    super.key,
    required this.cubit,
    required this.width,
    required this.isEditing,
  });

  final ImageScreenshotContentCubit cubit;
  final double width;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageScreenshotContentCubit,
        ImageScreenshotContentState>(
      bloc: cubit,
      builder: (context, state) => SliverPadding(
        padding: state.padding,
        sliver: _buildSliverImageView(context, state: state),
      ),
    );
  }

  Widget _buildSliverImageView(BuildContext context,
      {required ImageScreenshotContentState state}) {
    final imageWidth = width - state.padding.left - state.padding.right;
    final double imageHeight;

    if (isEditing) {
      // imageHeight = imageWidth * 0.5;
      imageHeight = 120;
    } else {
      final double imageRatio =
          state.width.toDouble() / state.height.toDouble();
      imageHeight = (imageWidth / imageRatio).ceilToDouble();
    }

    return SliverFixedExtentList.list(
      itemExtent: imageHeight,
      children: [
        GestureDetector(
          onTap: () {
            cubit.page.selectContent(cubit);
          },
          child: CachedImageBuilder(
            imageId: state.imageId,
            builder: (context, image) {
              return image == null
                  ? Container(
                      height: imageHeight,
                      color: Colors.grey[300],
                    )
                  : Image.memory(
                      image,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    );
            },
          ),
        )
      ],
    );
  }
}
