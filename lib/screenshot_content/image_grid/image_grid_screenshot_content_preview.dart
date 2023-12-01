import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/screenshot_content/image_grid/image_grid_screenshot_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageGridScreenshotContentPreview extends StatelessWidget {
  const ImageGridScreenshotContentPreview({
    super.key,
    required this.cubit,
    required this.width,
  });

  final ImageGridScreenshotContentCubit cubit;

  final double width;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageGridScreenshotContentCubit,
        ImageGridScreenshotContentState>(
      bloc: cubit,
      builder: (context, state) {
        final contentWidth = width -
            state.padding.horizontal -
            (state.crossAxisCount - 1) * state.crossAxisSpacing;
        final itemWidth = contentWidth / state.crossAxisCount;
        final itemHeight = itemWidth / state.childAspectRatio;
        final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: state.crossAxisCount,
          crossAxisSpacing: state.crossAxisSpacing,
          mainAxisSpacing: state.mainAxisSpacing,
          childAspectRatio: state.childAspectRatio,
          mainAxisExtent: itemHeight,
        );

        if (state.imageIds.isEmpty) {
          return SliverPadding(
            padding: state.padding,
            sliver: SliverGrid.builder(
              gridDelegate: gridDelegate,
              itemCount: state.crossAxisCount * 2,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  cubit.page.selectContent(cubit);
                },
                child: Container(
                  color: Colors.grey[300],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: state.padding,
          sliver: SliverGrid.builder(
            gridDelegate: gridDelegate,
            itemCount: state.imageIds.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                cubit.page.selectContent(cubit);
              },
              child: CachedImageBuilder(
                imageId: state.imageIds[index],
                builder: (context, image) => image == null
                    ? Container(
                        color: Colors.grey[300],
                      )
                    : Image.memory(
                        image,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
