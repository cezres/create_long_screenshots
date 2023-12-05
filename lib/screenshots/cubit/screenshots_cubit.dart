import 'package:create_long_screenshots/common/cached_cubit.dart';
import 'package:create_long_screenshots/common/generate_unique_id.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_page/cubit/screenshot_page_cubit.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_page_button.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'screenshots_state.dart';

class ScreenshotsCubit extends CachedCubit<ScreenshotsState> {
  ScreenshotsCubit() : super(const ScreenshotsInitial()) {
    load().whenComplete(() {
      resetLeftSidebar();
    });
  }

  @override
  String get cacheKey => "screenshots";

  @override
  ScreenshotsState? fromJson(Map<String, dynamic> json) {
    return ScreenshotsInitial(
      pages: (json['pages'] as List)
          .map((e) => ScreenshotPageCubit(e, loadedContents: false))
          .toList(),
    );
  }

  @override
  Map<String, dynamic>? toJson(ScreenshotsState state) {
    return {
      'pages': state.pages.map((e) => e.id).toList(),
    };
  }

  void addPage() async {
    if (state.pages.length >= 9) {
      return;
    }
    final page = ScreenshotPageCubit(generateUniqueId(), loadedContents: true);
    emit(
      state.copyWith(pages: [...state.pages, page]),
    );
    CachedCubit.saveCubitList([this, page]);

    resetLeftSidebar();
  }

  Future<void> deletePage(ScreenshotPageCubit page) async {
    emit(
      state.copyWith(
        pages: state.pages
            .where((element) => element.id != page.id)
            .toList(growable: false),
      ),
    );
    await save();

    resetLeftSidebar();
  }

  void resetLeftSidebar() {
    leftSidebar.setItems([
      const SidebarPageButton(
        id: 0,
        label: '封面',
        icon: Icons.image_outlined,
        selectedIcon: Icons.image,
      ),
      const Divider(),
      ...state.pages.map(
        (e) => BlocSelector<ScreenshotPageCubit, ScreenshotPageState, String>(
          bloc: e,
          selector: (state) => state.title,
          builder: (context, title) => SidebarPageButton(
            id: e.id,
            label: title,
            icon: CupertinoIcons.square_grid_2x2,
            selectedIcon: CupertinoIcons.square_grid_2x2_fill,
          ),
        ),
      ),
    ]);
  }

  void reorder(int oldIndex, int newIndex) {
    final pages = List<ScreenshotPageCubit>.from(state.pages);
    final page = pages.removeAt(oldIndex);
    pages.insert(newIndex, page);
    emit(
      state.copyWith(
        pages: pages,
      ),
    );
    resetLeftSidebar();
  }
}
