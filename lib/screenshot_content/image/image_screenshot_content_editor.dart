import 'package:create_long_screenshots/common/sidebar.dart';
import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_event_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageScreenshotContentEditor extends StatelessWidget {
  const ImageScreenshotContentEditor({
    super.key,
    required this.cubit,
    required this.width,
  });

  final ImageScreenshotContentCubit cubit;
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
      const Divider(),
      SidebarEventButton(
          label: '返回', onPressed: () => cubit.page.selectContent(null)),
    ]);

    return GestureDetector(
      onTap: () {
        cubit.pickCoverImage(context);
      },
      child: Center(
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return BlocBuilder<ImageScreenshotContentCubit,
        ImageScreenshotContentState>(
      bloc: cubit,
      builder: (context, state) => Padding(
        padding: state.padding,
        child: CachedImageBuilder(
          imageId: state.imageId,
          builder: (context, image) => image == null
              ? AspectRatio(
                  aspectRatio: state.width.toDouble() / state.height.toDouble(),
                  child: Container(
                    color: Colors.grey[300],
                  ),
                )
              : Image.memory(
                  image,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}

class ScreenshotContentPaddingEditorDialog extends StatelessWidget {
  const ScreenshotContentPaddingEditorDialog({
    super.key,
    required this.padding,
    required this.onPaddingChanged,
  });

  final EdgeInsets padding;
  final void Function(EdgeInsets padding) onPaddingChanged;

  @override
  Widget build(BuildContext context) {
    final topController = TextEditingController();
    final leftController = TextEditingController();
    final rightController = TextEditingController();
    final bottomController = TextEditingController();
    return CupertinoAlertDialog(
      title: Text(
        "编辑间距",
        style: kDefaultTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInputView(
            context,
            controller: topController,
            title: "上",
            placeholder: padding.top.toInt(),
          ),
          _buildInputView(
            context,
            controller: bottomController,
            title: "下",
            placeholder: padding.bottom.toInt(),
          ),
          _buildInputView(
            context,
            controller: leftController,
            title: "左",
            placeholder: padding.left.toInt(),
          ),
          _buildInputView(
            context,
            controller: rightController,
            title: "右",
            placeholder: padding.right.toInt(),
          ),
        ],
      ),
      actions: [
        CupertinoButton(
          child: Text(
            "取消",
            style: kDefaultTextStyle.copyWith(
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoButton(
          child: Text(
            "确定",
            style: kDefaultTextStyle.copyWith(
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            final top = int.tryParse(topController.text) ?? padding.top;
            final bottom =
                int.tryParse(bottomController.text) ?? padding.bottom;
            final left = int.tryParse(leftController.text) ?? padding.left;
            final right = int.tryParse(rightController.text) ?? padding.right;
            onPaddingChanged(
              EdgeInsets.fromLTRB(
                left.toDouble(),
                top.toDouble(),
                right.toDouble(),
                bottom.toDouble(),
              ),
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
              // fontWeight: FontWeight.w400,
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
            style: kDefaultTextStyle.copyWith(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
