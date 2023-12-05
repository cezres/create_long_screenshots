import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content_editor.dart';
import 'package:create_long_screenshots/screenshot_content/image_waterfall_flow/image_waterfall_flow.dart';
import 'package:create_long_screenshots/screenshot_content/image_waterfall_flow/image_waterfall_flow_preivew.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_event_button.dart';
import 'package:flutter/material.dart';

class ImageWaterfallFlowEditor extends StatelessWidget {
  const ImageWaterfallFlowEditor({super.key, required this.cubit});

  final ImageWaterfallFlow cubit;

  @override
  Widget build(BuildContext context) {
    rightSidebar.setItems([
      SidebarEventButton(
        label: '间距',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ScreenshotContentPaddingEditorDialog(
              padding: cubit.state.padding,
              onPaddingChanged: (padding) {
                // cubit.updatePadding(padding);
              },
            ),
          );
        },
      ),
      SidebarEventButton(
        label: '间距',
        onPressed: () {
          // showDialog(
          //   context: context,
          //   builder: (context) =>
          //       ScreenshotContentGridEditorDialog(cubit: cubit),
          // );
        },
      ),
      SidebarEventButton(
        label: '添加',
        onPressed: () {
          cubit.pickImages(context);
        },
      ),
      const Divider(),
      SidebarEventButton(
          label: '返回', onPressed: () => cubit.page.selectContent(null)),
    ]);

    return CustomScrollView(
      slivers: [
        ImageWaterfallFlowPreview(cubit: cubit),
      ],
    );
  }
}
