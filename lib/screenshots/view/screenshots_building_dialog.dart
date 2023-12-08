import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:create_long_screenshots/image_picker/image_picker.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshots/cubit/screenshots_cubit.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenshotsBuildingDialog extends StatefulWidget {
  const ScreenshotsBuildingDialog({super.key});

  @override
  State<ScreenshotsBuildingDialog> createState() =>
      _ScreenshotsBuildingDialogState();
}

class _ScreenshotsBuildingDialogState extends State<ScreenshotsBuildingDialog> {
  String _message = "";
  String _subMessage = "";

  @override
  void initState() {
    super.initState();

    buildScreenshots(context).onError((error, stackTrace) {
      setState(() {
        _message = "生成截图失败";
        _subMessage = error.toString();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        "正在生成截图",
        style: kDefaultTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        children: [
          Text(
            _message,
            style: kDefaultTextStyle,
          ),
          if (_subMessage.isNotEmpty)
            Text(
              _subMessage,
              style: kDefaultTextStyle,
            ),
          // CupertinoButton(
          //   child: const Text(
          //     "取消",
          //     style: kDefaultTextStyle,
          //   ),
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // )
        ],
      ),
    );
  }

  Future<void> buildScreenshots(BuildContext context) async {
    final screenshots = kContext.read<ScreenshotsCubit>();

    final Archive archive = Archive();
    final ZipEncoder encoder = ZipEncoder();

    for (var i = 0; i < screenshots.state.pages.length; i++) {
      setState(() {
        _message = "正在生成第${i + 1}张 (共${screenshots.state.pages.length}张)";
      });
      await Future.delayed(const Duration(milliseconds: 100));

      final page = screenshots.state.pages[i];

      if (!page.state.loadedContents) {
        setState(() {
          _subMessage = "加载页面数据";
        });
        await Future.delayed(const Duration(milliseconds: 60));
        await page.loadContents();

        setState(() {
          _subMessage = "加载页面资源文件";
        });
        await Future.delayed(const Duration(milliseconds: 60));
        await page.loadResources();
      }

      setState(() {
        _subMessage = "绘制页面";
      });
      await Future.delayed(const Duration(milliseconds: 60));
      // ignore: use_build_context_synchronously

      try {
        final results = await page.buildScreenshot(context);

        setState(() {
          _subMessage = "压缩图片";
        });

        await Future.delayed(const Duration(milliseconds: 60));

        final result = await imageCompress(
          results.$1,
          imageSize: results.$2,
          targetWidth: 1440,
          quality: 90,
        );

        final bytes = result.$1;

        archive.addFile(ArchiveFile('image_$i.webp', bytes.length, bytes));
      } catch (e) {
        setState(() {
          _subMessage = "绘制页面失败: $e";
        });
        await Future.delayed(const Duration(seconds: 4));
      }
    }

    setState(() {
      _message = "正在压缩图片文件";
      _subMessage = "";
    });
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = encoder.encode(archive);
    if (bytes == null) {
      return;
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    await Future.delayed(const Duration(milliseconds: 100));

    final result = await FileSaver.instance.saveFile(
      name: 'images',
      bytes: Uint8List.fromList(bytes),
      ext: 'zip',
    );
    debugPrint("result: $result");
  }
}
