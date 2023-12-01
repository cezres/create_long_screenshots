import 'package:create_long_screenshots/common/content_area.dart';
import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_cover/cubit/screenshot_cover_cubit.dart';
import 'package:create_long_screenshots/screenshot_cover/view/screenshot_cover_text_view.dart';
import 'package:create_long_screenshots/screenshots/cubit/screenshots_cubit.dart';
import 'package:create_long_screenshots/screenshots/view/screenshots_building_dialog.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_event_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenshotCoverPage extends StatelessWidget {
  const ScreenshotCoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    rightSidebar.setItems([
      SidebarEventButton(
        label: "设置封面",
        onPressed: () {
          kContext.read<ScreenshotCoverCubit>().pickCoverImage(kContext);
        },
      ),
      SidebarEventButton(
        label: "添加分页",
        onPressed: () {
          kContext.read<ScreenshotsCubit>().addPage();
        },
      ),
      SidebarEventButton(
        label: "生成截图",
        onPressed: () {
          showDialog(
            context: kContext,
            barrierDismissible: false,
            builder: (context) => const ScreenshotsBuildingDialog(),
          );
        },
      ),
    ]);

    return ContentArea(
      child: BlocBuilder<ScreenshotsCubit, ScreenshotsState>(
        buildWhen: (previous, current) =>
            previous.numberOfRow != current.numberOfRow ||
            previous.numberOfColumn != current.numberOfColumn,
        builder: (context, state) => Center(
          child: AspectRatio(
            aspectRatio: state.numberOfRow / state.numberOfColumn,
            child: Stack(
              children: [
                Positioned.fill(
                  child: BlocSelector<ScreenshotCoverCubit,
                      ScreenshotCoverState, int>(
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
                  ),
                ),
                Positioned.fill(
                  child: ScreenshotCoverTextView(
                    numberOfRow: state.numberOfRow,
                    numberOfColumn: state.numberOfColumn,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
