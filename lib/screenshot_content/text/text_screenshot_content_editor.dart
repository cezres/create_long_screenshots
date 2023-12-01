import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:create_long_screenshots/common/is_mobileBrowser.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content_editor.dart';
import 'package:create_long_screenshots/screenshot_content/text/text_screenshot_content.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_event_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextScreenshotContentEditor extends StatelessWidget {
  const TextScreenshotContentEditor({
    super.key,
    required this.cubit,
    required this.width,
  });

  final TextScreenshotContentCubit cubit;
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
    return Container(
      color: Colors.white,
      child: AppFlowyEditorBuilder(
        cubit: cubit,
        editable: true,
        focusNode: null,
      ),
    );
  }
}

class AppFlowyEditorBuilder extends StatefulWidget {
  const AppFlowyEditorBuilder({
    super.key,
    required this.cubit,
    required this.editable,
    required this.focusNode,
  });

  final TextScreenshotContentCubit cubit;
  final bool editable;
  final FocusNode? focusNode;

  @override
  State<AppFlowyEditorBuilder> createState() => _AppFlowyEditorBuilderState();
}

class _AppFlowyEditorBuilderState extends State<AppFlowyEditorBuilder>
    with WidgetsBindingObserver {
  late final EditorScrollController editorScrollController;
  late EditorState editorState;
  StreamSubscription? _subscription;

  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    if (!widget.editable) {
      _subscription = widget.cubit.stream.listen((event) {
        setState(() {
          _setupEditorState(event);
        });
      });
    }
    _setupEditorState(widget.cubit.state);

    editorScrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: false,
    );
  }

  void _setupEditorState(TextScreenshotContentState state) {
    if (widget.cubit.state.documentJson.isEmpty) {
      editorState = EditorState.blank();
    } else {
      editorState = EditorState(
        document: Document.fromJson(widget.cubit.state.documentJson),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    // WidgetsBinding.instance.removeObserver(this);

    if (widget.editable) {
      var documentJson = editorState.document.toJson();

      Future.delayed(const Duration(milliseconds: 80)).whenComplete(() {
        try {
          final document = documentJson['document'] as Map<String, dynamic>;
          final children = document['children'] as List<dynamic>;
          for (var element in children) {
            final data = element['data'] as Map<String, dynamic>;
            final delta = data['delta'] as List;
            if (delta.isNotEmpty) {
              widget.cubit.updateDocumentJson(documentJson);
              return;
            }
          }
        } catch (e) {
          //
        }

        if (widget.cubit.state.documentJson.isNotEmpty) {
          widget.cubit.updateDocumentJson({});
        }
      });
    }

    _subscription?.cancel();
    editorScrollController.dispose();
    editorState.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget editor = AppFlowyEditor(
      editorState: editorState,
      editorScrollController: editorScrollController,
      editorStyle: isMobileBrowser()
          ? _buildMobileEditorStyle()
          : _buildDesktopEditorStyle(),
      editable: widget.editable,
      shrinkWrap: !widget.editable,
      focusNode: widget.focusNode,
    );

    if (widget.editable) {
      if (isMobileBrowser()) {
        editor = _buildMoble(editor);
      } else {
        editor = _buildDesktop(editor);
      }
    }
    return BlocSelector<TextScreenshotContentCubit, TextScreenshotContentState,
        EdgeInsets>(
      bloc: widget.cubit,
      selector: (state) => state.padding,
      builder: (context, padding) {
        return Padding(
          padding: padding,
          child: editor,
        );
      },
    );
  }

  Widget _buildDesktop(Widget editor) {
    return FloatingToolbar(
      items: [
        ...headingItems,
        ...markdownFormatItems.where((element) => element.id != 'editor.code'),
        quoteItem,
        bulletedListItem,
        numberedListItem,
        buildTextColorItem(),
        buildHighlightColorItem(),
      ],
      editorState: editorState,
      editorScrollController: editorScrollController,
      textDirection: TextDirection.ltr,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: editor,
      ),
    );
  }

  Widget _buildMoble(Widget editor) {
    return Column(
      children: [
        Expanded(
          child: editor,
        ),
        ValueListenableBuilder(
          valueListenable: _isKeyboardVisible,
          builder: (context, value, child) => MobileToolbar(
            editorState: editorState,
            toolbarItems: [
              textDecorationMobileToolbarItem,
              buildTextAndBackgroundColorMobileToolbarItem(),
              headingMobileToolbarItem,
              todoListMobileToolbarItem,
              listMobileToolbarItem,
              // linkMobileToolbarItem,
              quoteMobileToolbarItem,
              dividerMobileToolbarItem,
              // codeMobileToolbarItem,
            ],
          ),
        )
      ],
    );
  }

  EditorStyle _buildDesktopEditorStyle() {
    const double fontSize = 18;
    return EditorStyle.desktop(
      padding: const EdgeInsets.all(0),
      cursorColor: Colors.blue,
      selectionColor: Colors.grey.shade300,
      textStyleConfiguration: TextStyleConfiguration(
        text: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
        ),
        bold: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        italic: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
        ),
        underline: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          decoration: TextDecoration.underline,
        ),
        strikethrough: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          decoration: TextDecoration.lineThrough,
        ),
        href: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          color: Colors.lightBlue,
          decoration: TextDecoration.underline,
        ),
        code: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          // fontFamily: 'monospace',
          color: Colors.red,
          backgroundColor: const Color.fromARGB(98, 0, 195, 255),
        ),
      ),
    );
  }

  EditorStyle _buildMobileEditorStyle() {
    const double fontSize = 18;
    return EditorStyle.mobile(
      padding: const EdgeInsets.all(0),
      cursorColor: Colors.blue,
      selectionColor: Colors.grey.shade300,
      textStyleConfiguration: TextStyleConfiguration(
        text: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
        ),
        bold: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        italic: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
        ),
        underline: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          decoration: TextDecoration.underline,
        ),
        strikethrough: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          decoration: TextDecoration.lineThrough,
        ),
        href: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          color: Colors.lightBlue,
          decoration: TextDecoration.underline,
        ),
        code: kDefaultTextStyle.copyWith(
          fontSize: fontSize,
          // fontFamily: 'monospace',
          color: Colors.red,
          backgroundColor: const Color.fromARGB(98, 0, 195, 255),
        ),
      ),
    );
  }
}
