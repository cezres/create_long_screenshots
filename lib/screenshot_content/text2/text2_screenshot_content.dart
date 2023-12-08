// import 'package:create_long_screenshots/image_picker/view/cached_image_view.dart';
// import 'package:create_long_screenshots/screenshot_content/cubit/screenshot_content_cubit.dart';
// import 'package:create_long_screenshots/screenshot_content/text2/text2_editor.dart';
// import 'package:create_long_screenshots/screenshot_content/text2/text2_screenshot_content_editor.dart';
// import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class Text2ScreenshotContentCubit
//     extends ScreenshotContentCubit<Text2ScreenshotContentState> {
//   Text2ScreenshotContentCubit({
//     required super.page,
//     required super.id,
//   }) : super(const Text2ScreenshotContentState());

//   @override
//   Widget buildEditor(BuildContext context, double width) {
//     return Text2ScreenshotContentEditor(cubit: this);
//   }

//   @override
//   Widget buildScreenshotWidget(BuildContext context, {required double width}) {
//     return Text2Editor(
//       text: state.documentText,
//       editable: false,
//       padding: state.padding,
//     );
//   }

//   @override
//   Widget buildSliver(BuildContext context, double width, bool isEditing) {
//     return SliverList.list(
//       children: [
//         BlocBuilder<Text2ScreenshotContentCubit, Text2ScreenshotContentState>(
//           bloc: this,
//           builder: (context, state) {
//             // return RichText(
//             //   text: WidgetSpan(
//             //     child: Text2Editor(
//             //       text: state.documentText,
//             //       editable: false,
//             //       padding: state.padding,
//             //     ),
//             //   ),
//             // );
//             return CachedImageBuilder(
//               imageId: state.imageId,
//               builder: (context, image) {
//                 return image == null
//                     ? GestureDetector(
//                         onTap: () {
//                           page.selectContent(this);
//                         },
//                         child: Container(
//                           color: Colors.grey[300],
//                           height: 44,
//                           child: const Center(
//                             child: Text(
//                               "点击以编辑文本",
//                               style: kDefaultTextStyle,
//                             ),
//                           ),
//                         ),
//                       )
//                     : Image.memory(image);
//               },
//             );
//           },
//         )
//       ],
//     );
//   }

//   @override
//   Text2ScreenshotContentState? fromJson(Map<String, dynamic> json) {
//     return Text2ScreenshotContentState(
//       documentText: json['documentText'],
//       padding: EdgeInsets.only(
//         left: json['padding']['left'],
//         right: json['padding']['right'],
//         top: json['padding']['top'],
//         bottom: json['padding']['bottom'],
//       ),
//     );
//   }

//   @override
//   Future<ScreenshotContentCubit<Text2ScreenshotContentState>> initialize(
//       BuildContext context) {
//     return Future.value(this);
//   }

//   @override
//   Map<String, dynamic>? toJson(Text2ScreenshotContentState state) {
//     return {
//       'documentText': state.documentText,
//       'padding': {
//         'left': state.padding.left,
//         'right': state.padding.right,
//         'top': state.padding.top,
//         'bottom': state.padding.bottom,
//       },
//     };
//   }

//   @override
//   ScreenshotContentType get type => ScreenshotContentType.text2;

//   void setup({
//     String? documentText,
//     EdgeInsets? padding,
//     int? imageId,
//     int? imageWidth,
//     int? imageHeight,
//   }) {
//     emit(state.copyWith(
//       documentText: documentText,
//       padding: padding,
//       imageId: imageId,
//       imageWidth: imageWidth,
//     ));
//     Future.microtask(() => save());
//   }

//   @override
//   Text2ScreenshotContentState buildStateWithPadding(EdgeInsets padding) =>
//       state.copyWith(padding: padding);
// }

// class Text2ScreenshotContentState extends ScreenshotContentState {
//   const Text2ScreenshotContentState({
//     this.documentText = "点击以输入文本",
//     super.padding,
//     this.imageId = 0,
//     this.imageWidth = 0,
//     this.imageHeight = 0,
//   });

//   final String documentText;
//   final int imageId;
//   final int imageWidth;
//   final int imageHeight;

//   @override
//   List<Object?> get props => [
//         ...super.props,
//         documentText,
//         imageId,
//         imageWidth,
//         imageHeight,
//       ];

//   Text2ScreenshotContentState copyWith({
//     String? documentText,
//     EdgeInsets? padding,
//     int? imageId,
//     int? imageWidth,
//     int? imageHeight,
//   }) {
//     return Text2ScreenshotContentState(
//       documentText: documentText ?? this.documentText,
//       padding: padding ?? this.padding,
//       imageId: imageId ?? this.imageId,
//       imageWidth: imageWidth ?? this.imageWidth,
//       imageHeight: imageHeight ?? this.imageHeight,
//     );
//   }
// }
