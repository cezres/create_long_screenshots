// import 'dart:typed_data';
// import 'dart:ui';

// import 'package:create_long_screenshots/common/generate_unique_id.dart';
// import 'package:create_long_screenshots/image_picker/cubit/image_caches_cubit.dart';
// import 'package:create_long_screenshots/image_picker/image_picker.dart';
// import 'package:create_long_screenshots/main.dart';
// import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content_editor.dart';
// import 'package:create_long_screenshots/screenshot_content/text2/text2_editor.dart';
// import 'package:create_long_screenshots/screenshot_content/text2/text2_screenshot_content.dart';
// import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
// import 'package:create_long_screenshots/widgets/sidebar/sidebar_event_button.dart';
// import 'package:file_saver/file_saver.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:image_size_getter/image_size_getter.dart';
// import 'package:quill_html_editor/quill_html_editor.dart';
// import 'package:screenshot/screenshot.dart';

// class Text2ScreenshotContentEditor extends StatefulWidget {
//   const Text2ScreenshotContentEditor({
//     super.key,
//     required this.cubit,
//   });

//   final Text2ScreenshotContentCubit cubit;

//   @override
//   State<Text2ScreenshotContentEditor> createState() =>
//       _Text2ScreenshotContentEditorState();
// }

// class _Text2ScreenshotContentEditorState
//     extends State<Text2ScreenshotContentEditor> {
//   final controller = QuillEditorController();

//   late EdgeInsets padding;

//   late final Widget _toolbar;

//   // bool _tag = true;

//   final ScreenshotController screenshotController = ScreenshotController();

//   final GlobalKey repaintBoundaryKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();

//     padding = widget.cubit.state.padding;
//     _toolbar = _buildToolbar();

//     rightSidebar.setItems([
//       SidebarEventButton(
//         label: '间距',
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (context) => ScreenshotContentPaddingEditorDialog(
//               padding: padding,
//               onPaddingChanged: (padding) async {
//                 // setState(() {
//                 //   _tag = !_tag;
//                 //   this.padding = padding;
//                 // });
//                 this.padding = padding;
//                 save();
//               },
//             ),
//           );
//         },
//       ),
//       const Divider(),
//       SidebarEventButton(
//         label: '保存',
//         onPressed: save,
//       ),
//     ]);
//   }

//   void save() async {
//     showCupertinoDialog(
//       context: context,
//       builder: (context) => CupertinoAlertDialog(
//         title: Text(
//           '正在保存',
//           style: kDefaultTextStyle.copyWith(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: const CupertinoActivityIndicator(),
//       ),
//     );

//     await Future.delayed(const Duration(milliseconds: 100));

//     final documentText = await controller.getText();

//     // final bytes = await screenshotController.capture(
//     //   pixelRatio: 3,
//     //   delay: const Duration(milliseconds: 100),
//     // );
//     // if (bytes == null) {
//     //   return;
//     // }
//     // final bytes = await capturePng();

//     final bytes = await screenshotController.captureFromWidget(
//       Container(
//         color: Colors.white,
//         width: 330,
//         padding: padding,
//         child: Directionality(
//           textDirection: TextDirection.ltr,
//           child: HtmlWidget(
//             documentText,
//             // textStyle: kDefaultTextStyle,
//             renderMode: RenderMode.column,
//           ),
//         ),
//       ),
//       pixelRatio: 3,
//       delay: const Duration(seconds: 2),
//       context: context,
//     );

//     final result = await FileSaver.instance.saveFile(
//       name: 'images',
//       bytes: Uint8List.fromList(bytes),
//       ext: 'png',
//     );
//     debugPrint("result: $result");

//     Navigator.pop(context);

//     return;

//     // Size size = ImageSizeGetter.getSize(MemoryInput(bytes));

//     // final results = await imageCompress(
//     //   bytes,
//     //   imageSize: size,
//     //   targetWidth: 1200,
//     // );

//     // final imageId = generateUniqueId();
//     // kImageCaches.addImages({imageId: results.$1});

//     Navigator.pop(context);

//     widget.cubit.setup(
//       documentText: documentText,
//       padding: padding,
//       // imageId: imageId,
//       // imageWidth: size.width.toInt(),
//       // imageHeight: size.height.toInt(),
//     );

//     widget.cubit.page.selectContent(null);
//   }

//   Future<Uint8List> capturePng() async {
//     final boundary = repaintBoundaryKey.currentContext!.findRenderObject()
//         as RenderRepaintBoundary;
//     var image = await boundary.toImage();
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//     Uint8List pngBytes = byteData!.buffer.asUint8List();
//     return pngBytes;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Screenshot(
//     //   child: child,
//     //   controller: controller,
//     // );
//     return RepaintBoundary(
//       key: repaintBoundaryKey,
//       child: Column(
//         children: [
//           _toolbar,
//           Expanded(
//             child: Container(
//               color: Colors.white,
//               child: SingleChildScrollView(
//                 child: Text2Editor(
//                   text: widget.cubit.state.documentText,
//                   editable: true,
//                   controller: controller,
//                   padding: padding,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToolbar() {
//     return ToolBar(
//       controller: controller,
//       padding: const EdgeInsets.all(8),
//       iconSize: 25,
//       iconColor: Colors.black87,
//       activeIconColor: const Color.fromARGB(255, 58, 62, 60),
//       crossAxisAlignment: WrapCrossAlignment.start,
//       direction: Axis.horizontal,
//       toolBarConfig: const [
//         ToolBarStyle.clean,
//         ToolBarStyle.bold,
//         ToolBarStyle.italic,
//         ToolBarStyle.underline,
//         ToolBarStyle.strike,
//         ToolBarStyle.headerOne,
//         ToolBarStyle.headerTwo,
//         ToolBarStyle.color,
//         ToolBarStyle.background,
//         ToolBarStyle.blockQuote,
//         ToolBarStyle.codeBlock,
//         ToolBarStyle.listOrdered,
//         ToolBarStyle.listBullet,
//         ToolBarStyle.separator,
//         ToolBarStyle.addTable,
//         ToolBarStyle.editTable,
//       ],
//     );
//   }
// }
