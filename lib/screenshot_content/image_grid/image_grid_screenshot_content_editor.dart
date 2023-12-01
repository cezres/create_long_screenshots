import 'package:create_long_screenshots/common/sidebar.dart';
import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content_editor.dart';
import 'package:create_long_screenshots/screenshot_content/image_grid/image_grid_screenshot_content.dart';
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
            builder: (context) =>
                ScreenshotContentGridEditorDialog(cubit: cubit),
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
                  title: const Text("删除图片"),
                  content: const Text("确定要删除这张图片吗？"),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text("取消"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text("确定"),
                      onPressed: () {
                        cubit.removeImage(e);
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

class ScreenshotContentGridEditorDialog extends StatefulWidget {
  const ScreenshotContentGridEditorDialog({
    super.key,
    required this.cubit,
  });

  final ImageGridScreenshotContentCubit cubit;

  @override
  State<ScreenshotContentGridEditorDialog> createState() =>
      _ScreenshotContentGridEditorDialogState();
}

class _ScreenshotContentGridEditorDialogState
    extends State<ScreenshotContentGridEditorDialog> {
  late final ValueNotifier<double> childAspectRatio;

  @override
  void initState() {
    super.initState();

    childAspectRatio = ValueNotifier(widget.cubit.state.childAspectRatio);
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCountController = TextEditingController();
    final crossAxisSpacingController = TextEditingController();
    final mainAxisSpacingController = TextEditingController();
    return CupertinoAlertDialog(
      title: const Text("编辑间距"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInputView(
            context,
            controller: crossAxisCountController,
            title: "列数量",
            placeholder: widget.cubit.state.crossAxisCount,
          ),
          _buildInputView(
            context,
            controller: crossAxisSpacingController,
            title: "列间距",
            placeholder: widget.cubit.state.crossAxisSpacing.toInt(),
          ),
          _buildInputView(
            context,
            controller: mainAxisSpacingController,
            title: "行间距",
            placeholder: widget.cubit.state.mainAxisSpacing.toInt(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              "宽高比",
              style: kDefaultTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: childAspectRatio,
            builder: (context, value, child) => CupertinoSegmentedControl(
              children: {
                1 / 1: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text("1:1"),
                ),
                1 / 2: const Text("1:2"),
                3 / 4: const Text("3:4"),
                4 / 3: const Text("4:3"),
                9 / 16: const Text("9:16"),
                16 / 9: const Text("16:9"),
              },
              groupValue: value,
              onValueChanged: (value) {
                childAspectRatio.value = value;
              },
            ),
          ),
        ],
      ),
      actions: [
        CupertinoButton(
          child: const Text("取消"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoButton(
          child: const Text("确定"),
          onPressed: () {
            Navigator.pop(context);

            widget.cubit.updateGrid(
              crossAxisCount: int.tryParse(crossAxisCountController.text),
              crossAxisSpacing:
                  double.tryParse(crossAxisSpacingController.text),
              mainAxisSpacing: double.tryParse(mainAxisSpacingController.text),
              childAspectRatio: childAspectRatio.value,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInputView(
    BuildContext context, {
    required TextEditingController controller,
    required String title,
    required int placeholder,
  }) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            title,
            style: kDefaultTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: CupertinoTextField(
            controller: controller,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                ),
              ),
            ),
            placeholder: "$placeholder",
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
