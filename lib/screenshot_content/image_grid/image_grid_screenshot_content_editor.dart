import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content_editor.dart';
import 'package:create_long_screenshots/screenshot_content/image_grid/grid_config_editor_dialog.dart';
import 'package:create_long_screenshots/screenshot_content/image_grid/image_grid_screenshot_content.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_event_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderables/reorderables.dart';

class ImageGridScreenshotContentEditor extends StatelessWidget {
  const ImageGridScreenshotContentEditor({
    super.key,
    required this.cubit,
    required this.width,
  });

  final ImageGridScreenshotContentCubit cubit;
  final double width;

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
                cubit.updatePadding(padding);
              },
            ),
          );
        },
      ),
      SidebarEventButton(
        label: '网格',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => GridConfigEditorDialog(cubit: cubit),
          );
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

    return Container(
      color: Colors.white,
      child: BlocBuilder<ImageGridScreenshotContentCubit,
          ImageGridScreenshotContentState>(
        bloc: cubit,
        builder: (context, state) =>
            _buildImageViews(context, state: state, width: width),
      ),
    );
  }

  Widget _buildImageViews(
    BuildContext context, {
    required ImageGridScreenshotContentState state,
    required double width,
  }) {
    final contentWidth = width -
        state.padding.horizontal -
        (state.crossAxisCount - 1) * state.crossAxisSpacing;
    final itemWidth = contentWidth / state.crossAxisCount;
    final itemHeight = itemWidth / state.childAspectRatio;

    final children = state.imageIds
        .map(
          (e) => GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: Text(
                    "删除图片",
                    style: kDefaultTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "确定要删除这张图片吗？",
                    style: kDefaultTextStyle,
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text(
                        "取消",
                        style: kDefaultTextStyle,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text(
                        "确定",
                        style: kDefaultTextStyle.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: () {
                        cubit.removeImageIds({e});
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            child: CachedImageBuilder(
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
          ),
        )
        .toList();

    return SingleChildScrollView(
      padding: state.padding,
      child: ReorderableWrap(
        spacing: state.crossAxisSpacing,
        runSpacing: state.mainAxisSpacing,
        onReorder: (oldIndex, newIndex) {
          cubit.moveImage(oldIndex, newIndex);
        },
        children: children,
      ),
    );
  }
}
