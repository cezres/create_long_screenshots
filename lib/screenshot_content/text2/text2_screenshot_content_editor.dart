import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content_editor.dart';
import 'package:create_long_screenshots/screenshot_content/text2/text2_editor.dart';
import 'package:create_long_screenshots/screenshot_content/text2/text2_screenshot_content.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_event_button.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class Text2ScreenshotContentEditor extends StatefulWidget {
  const Text2ScreenshotContentEditor({
    super.key,
    required this.cubit,
  });

  final Text2ScreenshotContentCubit cubit;

  @override
  State<Text2ScreenshotContentEditor> createState() =>
      _Text2ScreenshotContentEditorState();
}

class _Text2ScreenshotContentEditorState
    extends State<Text2ScreenshotContentEditor> {
  final controller = QuillEditorController();

  late EdgeInsets padding;

  late final Widget _toolbar;

  // bool _tag = true;

  @override
  void initState() {
    super.initState();

    padding = widget.cubit.state.padding;
    _toolbar = _buildToolbar();

    rightSidebar.setItems([
      SidebarEventButton(
        label: '间距',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ScreenshotContentPaddingEditorDialog(
              padding: padding,
              onPaddingChanged: (padding) async {
                // setState(() {
                //   _tag = !_tag;
                //   this.padding = padding;
                // });
                this.padding = padding;
                save();
              },
            ),
          );
        },
      ),
      const Divider(),
      SidebarEventButton(
        label: '返回',
        onPressed: save,
      ),
    ]);
  }

  void save() async {
    await controller.getText().then((value) {
      widget.cubit.setup(documentText: value, padding: padding);
    });

    widget.cubit.page.selectContent(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _toolbar,
        Expanded(
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Text2Editor(
                text: widget.cubit.state.documentText,
                editable: true,
                controller: controller,
                padding: padding,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return ToolBar(
      controller: controller,
      padding: const EdgeInsets.all(8),
      iconSize: 25,
      iconColor: Colors.black87,
      activeIconColor: const Color.fromARGB(255, 58, 62, 60),
      crossAxisAlignment: WrapCrossAlignment.start,
      direction: Axis.horizontal,
      toolBarConfig: const [
        ToolBarStyle.clean,
        ToolBarStyle.bold,
        ToolBarStyle.italic,
        ToolBarStyle.underline,
        ToolBarStyle.strike,
        ToolBarStyle.headerOne,
        ToolBarStyle.headerTwo,
        ToolBarStyle.color,
        ToolBarStyle.background,
        ToolBarStyle.blockQuote,
        ToolBarStyle.codeBlock,
        ToolBarStyle.listOrdered,
        ToolBarStyle.listBullet,
        ToolBarStyle.separator,
        ToolBarStyle.addTable,
        ToolBarStyle.editTable,
      ],
    );
  }
}
