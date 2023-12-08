// import 'package:flutter/material.dart';
// import 'package:quill_html_editor/quill_html_editor.dart';

// class Text2Editor extends StatefulWidget {
//   const Text2Editor({
//     super.key,
//     required this.text,
//     required this.editable,
//     this.padding = EdgeInsets.zero,
//     this.backgroundColor = Colors.white,
//     this.controller,
//     this.onSelectionChanged,
//   });

//   final String text;
//   final bool editable;
//   final EdgeInsets padding;
//   final Color backgroundColor;
//   final QuillEditorController? controller;
//   final dynamic Function(SelectionModel)? onSelectionChanged;

//   @override
//   State<Text2Editor> createState() => _Text2EditorState();
// }

// class _Text2EditorState extends State<Text2Editor> {
//   late QuillEditorController controller;

//   final _editorTextStyle = const TextStyle(
//     fontSize: 18,
//     color: Colors.black,
//     fontWeight: FontWeight.normal,
//     fontFamily: 'Roboto',
//   );
//   final _hintTextStyle = const TextStyle(
//     fontSize: 18,
//     color: Colors.black38,
//     fontWeight: FontWeight.normal,
//   );

//   @override
//   void initState() {
//     super.initState();
//     controller = widget.controller ?? QuillEditorController();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return QuillHtmlEditor(
//       text: widget.text,
//       controller: controller,
//       minHeight: widget.editable ? 200 : 44,
//       isEnabled: widget.editable,
//       ensureVisible: widget.editable,
//       autoFocus: false,
//       textStyle: _editorTextStyle,
//       hintTextStyle: _hintTextStyle,
//       padding: widget.padding,
//       backgroundColor: widget.backgroundColor,
//       inputAction: InputAction.newline,
//       onSelectionChanged: widget.onSelectionChanged,
//       loadingBuilder: (context) {
//         return const Center(
//           child: CircularProgressIndicator(
//             strokeWidth: 1,
//             color: Colors.red,
//           ),
//         );
//       },
//     );
//   }
// }
