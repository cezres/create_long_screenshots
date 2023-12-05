import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/screenshot_content/image_waterfall_flow/image_waterfall_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class ImageWaterfallFlowPreview extends StatelessWidget {
  const ImageWaterfallFlowPreview({
    super.key,
    required this.cubit,
  });

  final ImageWaterfallFlow cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageWaterfallFlow, ImageWaterfallFlowState>(
      bloc: cubit,
      builder: (context, state) => SliverPadding(
        padding: state.padding,
        sliver: SliverWaterfallFlow(
          delegate: SliverChildBuilderDelegate(
            (context, index) => GestureDetector(
              onTap: () {
                cubit.page.selectContent(cubit);
              },
              child: CachedImageBuilder(
                imageId: state.imageIds[index],
                builder: (context, image) => image == null
                    ? Container(color: Colors.grey[300])
                    : Image.memory(image, fit: BoxFit.cover),
              ),
            ),
            childCount: state.imageIds.length,
          ),
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: state.mainAxisSpacing,
            crossAxisSpacing: state.crossAxisSpacing,
            crossAxisCount: state.crossAxisCount,
          ),
        ),
      ),
    );
  }
}
