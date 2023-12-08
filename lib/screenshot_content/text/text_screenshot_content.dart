import 'package:create_long_screenshots/screenshot_content/cubit/screenshot_content_cubit.dart';
import 'package:create_long_screenshots/screenshot_content/text/text_screenshot_content_editor.dart';
import 'package:create_long_screenshots/screenshot_content/text/text_screenshot_content_preview.dart';
import 'package:flutter/material.dart';

class TextScreenshotContentCubit
    extends ScreenshotContentCubit<TextScreenshotContentState> {
  TextScreenshotContentCubit({
    required super.page,
    required super.id,
  }) : super(const TextScreenshotContentState());

  @override
  ScreenshotContentType get type => ScreenshotContentType.text;

  @override
  Widget buildSliver(BuildContext context, double width, bool isEditing) {
    return TextScreenshotContentPreview(
      key: ValueKey(id),
      cubit: this,
      width: width,
      isEditing: isEditing,
    );
  }

  @override
  Widget buildEditor(BuildContext context, double width) {
    return TextScreenshotContentEditor(cubit: this, width: width);
  }

  @override
  Widget buildScreenshotWidget(BuildContext context, {required double width}) {
    return AppFlowyEditorBuilder(
      cubit: this,
      editable: false,
      focusNode: null,
    );
  }

  @override
  TextScreenshotContentState? fromJson(Map<String, dynamic> json) {
    return TextScreenshotContentState(
      documentJson: json,
    );
  }

  @override
  Map<String, dynamic>? toJson(TextScreenshotContentState state) {
    return state.documentJson;
  }

  @override
  Future<ScreenshotContentCubit<TextScreenshotContentState>> initialize(
      BuildContext context) async {
    page.selectContent(this);
    return this;
  }

  void updateDocumentJson(Map<String, dynamic> documentJson) {
    emit(state.copyWith(documentJson: documentJson));
    save();
  }

  @override
  TextScreenshotContentState buildStateWithPadding(EdgeInsets padding) =>
      state.copyWith(padding: padding);
}

class TextScreenshotContentState extends ScreenshotContentState {
  const TextScreenshotContentState({
    this.documentJson = const {
      'document': {
        'type': 'page',
        'children': [
          {
            'type': 'paragraph',
            'data': {
              'delta': [
                {
                  'insert': '点击以编辑文本',
                },
              ],
            }
          }
        ],
      }
    },
    super.padding,
  });

  final Map<String, dynamic> documentJson;

  @override
  List<Object?> get props => [
        ...super.props,
        documentJson,
      ];

  TextScreenshotContentState copyWith({
    Map<String, dynamic>? documentJson,
    EdgeInsets? padding,
  }) {
    return TextScreenshotContentState(
      documentJson: documentJson ?? this.documentJson,
      padding: padding ?? this.padding,
    );
  }
}
