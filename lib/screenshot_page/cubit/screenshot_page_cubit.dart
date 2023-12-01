import 'dart:typed_data';

import 'package:create_long_screenshots/common/cached_cubit.dart';
import 'package:create_long_screenshots/image_picker/image_picker.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_content/cubit/screenshot_content_cubit.dart';
import 'package:create_long_screenshots/screenshot_cover/cubit/screenshot_cover_cubit.dart';
import 'package:create_long_screenshots/screenshots/cubit/screenshots_cubit.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sembast/sembast.dart';

part 'screenshot_page_state.dart';

class ScreenshotPageCubit extends CachedCubit<ScreenshotPageState>
    with EquatableMixin {
  ScreenshotPageCubit(this.id, {bool loadedContents = false})
      : super(ScreenshotPageInitial(loadedContents: loadedContents)) {
    load();
  }

  @override
  List<Object?> get props => [id];

  final int id;

  @override
  String get cacheKey => "page_$id";

  @override
  ScreenshotPageState? fromJson(Map<String, dynamic> json) {
    return ScreenshotPageInitial(
      title: json['title'] as String,
    );
  }

  @override
  Map<String, dynamic>? toJson(ScreenshotPageState state) {
    return {
      'title': state.title,
    };
  }

  void toggleEditing() {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  void selectContent(ScreenshotContentCubit? content) {
    if (content == null) {
      emit(state.copyWith(selectedContentIndex: -1));
      return;
    }

    final index =
        state.contents.indexWhere((element) => element.id == content.id);
    if (index < 0) {
      return;
    }
    emit(state.copyWith(selectedContentIndex: index));
  }

  void moveContentToUp(ScreenshotContentCubit content) {
    final index = state.contents.indexOf(content);
    if (index <= 0) {
      return;
    }
    final contents = [
      if (index > 1) ...state.contents.sublist(0, index - 1),
      content,
      state.contents[index - 1],
      ...state.contents.sublist(index + 1),
    ];
    emit(state.copyWith(contents: contents));
    Future.microtask(() => saveContents());
  }

  void moveContentToDown(ScreenshotContentCubit content) {
    final index = state.contents.indexOf(content);
    if (index < 0 || index >= state.contents.length - 1) {
      return;
    }
    final contents = [
      ...state.contents.sublist(0, index),
      state.contents[index + 1],
      content,
      if (index < state.contents.length - 2)
        ...state.contents.sublist(index + 2),
    ];
    emit(state.copyWith(contents: contents));
    Future.microtask(() => saveContents());
  }

  void removeContent(ScreenshotContentCubit content) async {
    emit(state.copyWith(
      contents: state.contents
          .where((element) => element.id != content.id)
          .toList(growable: false),
    ));
    await content.deleteContentAndResources();
    Future.microtask(() => saveContents());
  }

  void deletePage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          "删除页面",
          style: kDefaultTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "确定要删除这个页面吗？",
          style: kDefaultTextStyle.copyWith(
            fontSize: 14,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              "取消",
              style: kDefaultTextStyle.copyWith(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text(
              "删除",
              style: kDefaultTextStyle.copyWith(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              leftSidebar.selectId(0);

              await kContext.read<ScreenshotsCubit>().deletePage(this);
              await deleteAllContents();
              await delete();
            },
          ),
        ],
      ),
    );
  }

  void rename(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: state.title);
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          "重命名",
          style: kDefaultTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: CupertinoTextField(
          controller: controller,
          autofocus: true,
          style: kDefaultTextStyle.copyWith(
            fontSize: 16,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              "取消",
              style: kDefaultTextStyle.copyWith(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text(
              "确定",
              style: kDefaultTextStyle.copyWith(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            onPressed: () async {
              emit(state.copyWith(title: controller.text));
              Navigator.pop(context);
              await save();
            },
          ),
        ],
      ),
    );
  }

  void addContent(BuildContext context) {
    final actions = [
      ScreenshotContentType.text,
      ScreenshotContentType.image,
      ScreenshotContentType.imageGrid,
    ]
        .map(
          (e) => CupertinoActionSheetAction(
            child: Text(
              e.string,
              style: kDefaultTextStyle.copyWith(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _addContent(buildInitialScreenshotContent(e, this));
            },
          ),
        )
        .toList(growable: false);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          "添加内容",
          style: kDefaultTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: actions,
      ),
    );
  }

  void _addContent(ScreenshotContentCubit content) async {
    try {
      var newContent = await content.initialize(kContext);

      emit(state.copyWith(
        contents: [
          ...state.contents,
          newContent,
        ],
      ));
      saveContents();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  bool _isLoadingContents = false;
  bool _isLoadedContents = false;
  final _store = StoreRef<String, dynamic>.main();

  Future<void> loadContents() async {
    if (_isLoadingContents || _isLoadedContents) {
      return;
    }
    _isLoadingContents = true;
    try {
      final contents = await kDatabase.transaction((transaction) async {
        final contentsRecord = _store.record('contents_$id');
        final result = await contentsRecord.get(transaction);
        if (result is! List) {
          throw "";
        }
        final contents = <ScreenshotContentCubit>[];
        for (var element in result) {
          await Future.delayed(const Duration(milliseconds: 10));
          try {
            final content = buildScreenshotContent(element, page: this);
            await content.loadInTransaction(transaction);
            contents.add(content);
          } catch (e) {
            debugPrint(e.toString());
          }
        }
        return contents;
      });

      emit(state.copyWith(contents: contents, loadedContents: true));
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoadingContents = false;
    _isLoadedContents = true;
  }

  Future<void> saveContents() async {
    await kDatabase.transaction((transaction) async {
      final contentsRecord = _store.record('contents_$id');
      await contentsRecord.put(
        transaction,
        state.contents
            .map((e) => buildScreenshotContentJson(e))
            .toList(growable: false),
      );
    });
  }

  Future<void> deleteAllContents() async {
    await kDatabase.transaction((transaction) async {
      final contentsRecord = _store.record('contents_$id');
      await contentsRecord.delete(transaction);

      for (var element in state.contents) {
        await element.deleteContentAndResourcesInTransaction(transaction);
      }
    });
  }

  Future<void> loadResources() async {
    for (var element in state.contents) {
      await element.loadResources();
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  Future<Uint8List> buildScreenshot(
    BuildContext context, {
    int? expandHeight,
  }) async {
    final ScreenshotController controller = ScreenshotController();
    const double width = 1440;
    const double pixelRatio = 3;
    const double viewWidth = width / pixelRatio;

    // final cover = kContext.read<ScreenshotCoverCubit>().state;

    final bytes = await controller.captureFromLongWidget(
      Container(
        width: viewWidth,
        color: Theme.of(context).colorScheme.onInverseSurface,
        child: Column(
          children: [
            kContext.read<ScreenshotCoverCubit>().buildCoverScreenshot(
                  context,
                  page: this,
                  width: viewWidth,
                ),
            ...state.contents.map(
              (e) => e.buildScreenshotWidget(context, width: viewWidth),
            ),
            if (expandHeight != null) SizedBox(height: expandHeight.toDouble()),
          ],
        ),
      ),
      delay: const Duration(seconds: 3),
      pixelRatio: 3,
      context: context,
    );

    await Future.delayed(const Duration(milliseconds: 60));

    final size = ImageSizeGetter.getSize(MemoryInput(bytes));
    if (state.contents.isNotEmpty && size.height < size.width * 2) {
      // 拓展高度
      final int expandHeight = size.width * 2 - size.height;
      // ignore: use_build_context_synchronously
      return await buildScreenshot(
        context,
        expandHeight: expandHeight ~/ pixelRatio,
      );
    }
    final result = await imageCompress(
      bytes,
      imageSize: size,
      targetWidth: width.toInt(),
    );

    return result.$1;
  }
}
