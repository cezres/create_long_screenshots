import 'dart:typed_data';

import 'package:create_long_screenshots/common/generate_unique_id.dart';
import 'package:create_long_screenshots/common/sidebar.dart';
import 'package:create_long_screenshots/image_picker/cubit/image_caches_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_size_getter/image_size_getter.dart';

const kMaxCompressImageWidth = 300 * 3;

class SelectedImage {
  const SelectedImage({
    required this.imageId,
    // required this.bytes,
    required this.width,
    required this.height,
  });

  final int imageId;
  // final Uint8List bytes;
  final int width;
  final int height;
}

Future<Map<int, SelectedImage>> imagesPicker(
  BuildContext context, {
  int limit = 0,
  int maxCompressImageWidth = kMaxCompressImageWidth,
}) async {
  return FilePicker.platform
      .pickFiles(
    type: FileType.image,
    allowMultiple: limit == 0 || limit > 1,
  )
      .then(
    (value) {
      return _handleImageFiles(
        context,
        value: value,
        limit: limit,
        maxCompressImageWidth: maxCompressImageWidth,
      );
    },
  );
}

Future<Map<int, SelectedImage>> _handleImageFiles(
  BuildContext context, {
  required FilePickerResult? value,
  required int limit,
  required int maxCompressImageWidth,
}) async {
  if (value == null) {
    throw Exception('No file selected');
  }

  if (value.files.isEmpty) {
    throw Exception('No file selected');
  }

  return await showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text(
        '处理图片文件',
        style: kDefaultTextStyle,
      ),
      content: _ImageCompressView(
        files: value.files,
        limit: limit,
        maxCompressImageWidth: maxCompressImageWidth,
      ),
    ),
  );
}

class _ImageCompressView extends StatefulWidget {
  const _ImageCompressView({
    required this.files,
    required this.limit,
    required this.maxCompressImageWidth,
  });

  final List<PlatformFile> files;
  final int limit;
  final int maxCompressImageWidth;

  @override
  State<_ImageCompressView> createState() => _ImageCompressViewState();
}

class _ImageCompressViewState extends State<_ImageCompressView> {
  String _message = '';

  final Map<int, SelectedImage> _imageCache = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 400));

      for (var i = 0; i < widget.files.length; i++) {
        setState(() {
          _message = '${i + 1}/${widget.files.length}';
        });
        await Future.delayed(const Duration(milliseconds: 100));

        var bytes = widget.files[i].bytes;
        if (bytes == null) {
          continue;
        }

        try {
          Size size = ImageSizeGetter.getSize(MemoryInput(bytes));

          final result = await imageCompress(
            bytes,
            imageSize: size,
            targetWidth: widget.maxCompressImageWidth,
          );
          final resultImage = result.$1;
          final resultImageSize = result.$2;

          debugPrint(
              "压缩率 ${((resultImage.length.toDouble() / bytes.length.toDouble()) * 100).toStringAsFixed(2)}%  ${bytes.length} ==> ${resultImage.length}");
          if (resultImage.length < bytes.length) {
            bytes = resultImage;
            size = resultImageSize;
          }

          await Future.delayed(const Duration(milliseconds: 50));

          final imageId = generateUniqueId();

          kImageCaches.addImages({imageId: bytes});

          _imageCache[imageId] = SelectedImage(
            imageId: imageId,
            // bytes: bytes,
            width: resultImageSize.width,
            height: resultImageSize.height,
          );
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }).then((value) {
      Navigator.pop(context, _imageCache);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _message,
            style: kDefaultTextStyle,
          ),
        ],
      ),
    );
  }
}

Future<(Uint8List, Size)> imageCompress(
  Uint8List bytes, {
  required Size imageSize,
  required int targetWidth,
}) async {
  final int width;
  final int height;
  if (imageSize.width > targetWidth) {
    width = targetWidth;
    height = (imageSize.height * (targetWidth / imageSize.width)).toInt();
  } else {
    width = imageSize.width.toInt();
    height = imageSize.height.toInt();
  }
  debugPrint("${imageSize.width}x${imageSize.height} ==> ${width}x$height");

  Uint8List result;
  try {
    result = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: width,
      minHeight: height,
      format: CompressFormat.webp,
    );
  } catch (e) {
    await Future.delayed(const Duration(milliseconds: 50));
    result = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: width,
      minHeight: height,
      format: CompressFormat.jpeg,
    );
  }
  return (result, Size(width, height));

  // final command = img.Command();
  // command.decodeImage(bytes);
  // command.copyResize(width: 1024);
  // command.encodeJpg(quality: 95);
  // await command.executeThread();

  // if (command.outputBytes == null) {
  //   throw Exception("ImageCompress: command.outputBytes is null");
  // }
  // return command.outputBytes!;
}
