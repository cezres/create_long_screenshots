import 'package:create_long_screenshots/common/cached_cubit.dart';
import 'package:create_long_screenshots/common/generate_unique_id.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_content/image/image_screenshot_content.dart';
import 'package:create_long_screenshots/screenshot_content/image_grid/image_grid_screenshot_content.dart';
import 'package:create_long_screenshots/screenshot_content/text/text_screenshot_content.dart';
import 'package:create_long_screenshots/screenshot_content/text2/text2_screenshot_content.dart';
import 'package:create_long_screenshots/screenshot_page/cubit/screenshot_page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';

abstract class ScreenshotContentCubit<State> extends CachedCubit<State> {
  ScreenshotContentCubit(
    super.initialState, {
    required this.page,
    required this.id,
  });

  final ScreenshotPageCubit page;

  ScreenshotContentType get type;

  final int id;

  @override
  String get cacheKey => 'content_${page.cacheKey}_$id';

  Widget buildSliver(BuildContext context, double width, bool isEditing);

  Widget buildEditor(BuildContext context, double width);

  Future<void> deleteContentAndResources() async {
    await kDatabase.transaction(
        (transaction) => deleteContentAndResourcesInTransaction(transaction));
  }

  Future<void> deleteContentAndResourcesInTransaction(
      Transaction transaction) async {
    await deleteInTransaction(transaction);
    await deleteResourcesInTransaction(transaction);
  }

  Future<void> deleteResourcesInTransaction(Transaction transaction) async {}

  Widget buildScreenshotWidget(BuildContext context, {required double width});

  Future<void> loadResources() async {}

  Future<ScreenshotContentCubit<State>> initialize(BuildContext context);
}

enum ScreenshotContentType {
  text,
  image,
  imageGrid,
  text2,
  ;

  String get string {
    switch (this) {
      case ScreenshotContentType.text:
        return '文本';
      case ScreenshotContentType.image:
        return '图片';
      case ScreenshotContentType.imageGrid:
        return '图片 - 网格';
      case ScreenshotContentType.text2:
        return '文本2';
    }
  }
}

ScreenshotContentCubit buildInitialScreenshotContent(
  ScreenshotContentType type,
  ScreenshotPageCubit page,
) {
  return buildScreenshotContent(
    {
      'type': type.index,
      'id': generateUniqueId(),
    },
    page: page,
  );
}

ScreenshotContentCubit buildScreenshotContent(Map<String, dynamic> json,
    {required ScreenshotPageCubit page}) {
  final type = json['type'] as int;
  final id = json['id'] as int;
  switch (type) {
    case 0:
      return TextScreenshotContentCubit(page: page, id: id);
    case 1:
      return ImageScreenshotContentCubit(page: page, id: id);
    case 2:
      return ImageGridScreenshotContentCubit(page: page, id: id);
    case 3:
      return Text2ScreenshotContentCubit(page: page, id: id);
    default:
      throw UnimplementedError();
  }
}

Map<String, dynamic> buildScreenshotContentJson(ScreenshotContentCubit cubit) {
  return {
    'type': cubit.type.index,
    'id': cubit.id,
  };
}
