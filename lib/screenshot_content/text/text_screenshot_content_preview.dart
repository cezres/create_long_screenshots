import 'package:create_long_screenshots/screenshot_content/text/text_screenshot_content.dart';
import 'package:create_long_screenshots/screenshot_content/text/text_screenshot_content_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextScreenshotContentPreview extends StatelessWidget {
  const TextScreenshotContentPreview({
    super.key,
    required this.cubit,
    required this.width,
    required this.isEditing,
  });

  final TextScreenshotContentCubit cubit;
  final double width;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        GestureDetector(
          onTap: () {
            cubit.page.selectContent(cubit);
          },
          child: BlocBuilder<TextScreenshotContentCubit,
              TextScreenshotContentState>(
            bloc: cubit,
            builder: (context, state) => _buildContent(
              context,
              state: state,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContent(BuildContext context,
      {required TextScreenshotContentState state}) {
    // if (state.documentJson.isEmpty) {
    //   return const Padding(
    //     padding: EdgeInsets.all(8.0),
    //     child: Text("点击以编辑文本"),
    //   );
    // }
    return AppFlowyEditorBuilder(
      cubit: cubit,
      editable: false,
      focusNode: null,
    );
    // return FutureBuilder(
    //   initialData: false,
    //   future: Future.delayed(const Duration(milliseconds: 400))
    //       .then((value) => true),
    //   builder: (context, snapshot) => snapshot.requireData
    //       ? AppFlowyEditorBuilder(
    //           cubit: cubit,
    //           editable: false,
    //           focusNode: null,
    //         )
    //       : Container(
    //           color: Colors.grey[300],
    //           height: 80,
    //         ),
    // );
  }
}
