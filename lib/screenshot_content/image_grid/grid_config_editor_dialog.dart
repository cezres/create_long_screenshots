import 'package:create_long_screenshots/screenshot_content/image_grid/image_grid_screenshot_content.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GridConfigEditorDialog extends StatefulWidget {
  const GridConfigEditorDialog({
    super.key,
    required this.cubit,
  });

  final ImageGridScreenshotContentCubit cubit;

  @override
  State<GridConfigEditorDialog> createState() => _GridConfigEditorDialogState();
}

class _GridConfigEditorDialogState extends State<GridConfigEditorDialog> {
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
      title: Text(
        "编辑间距",
        style: kDefaultTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                  child: Text(
                    "1:1",
                    style: kDefaultTextStyle,
                  ),
                ),
                1 / 2: const Text(
                  "1:2",
                  style: kDefaultTextStyle,
                ),
                3 / 4: const Text(
                  "3:4",
                  style: kDefaultTextStyle,
                ),
                4 / 3: const Text(
                  "4:3",
                  style: kDefaultTextStyle,
                ),
                9 / 16: const Text(
                  "9:16",
                  style: kDefaultTextStyle,
                ),
                16 / 9: const Text(
                  "16:9",
                  style: kDefaultTextStyle,
                ),
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
          child: const Text(
            "取消",
            style: kDefaultTextStyle,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoButton(
          child: Text(
            "确定",
            style: kDefaultTextStyle.copyWith(color: Colors.blue),
          ),
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
