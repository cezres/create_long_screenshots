import 'package:create_long_screenshots/common/content_area.dart';
import 'package:create_long_screenshots/image_picker/cubit/image_caches_cubit.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_page/cubit/screenshot_page_cubit.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_event_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenshotPageView extends StatelessWidget {
  const ScreenshotPageView({super.key, required this.cubit});

  final ScreenshotPageCubit cubit;

  @override
  Widget build(BuildContext context) {
    kImageCaches.waitLoaded1Seconds();
    cubit.loadContents();

    return ContentAreaBuilder(builder: (context, size) {
      return Container(
        width: size.width,
        height: size.height,
        // color: Theme.of(context).colorScheme.onInverseSurface,
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) =>
              BlocBuilder<ScreenshotPageCubit, ScreenshotPageState>(
            bloc: cubit,
            builder: (context, state) {
              if (state.selectedContentIndex >= 0) {
                return cubit.state.contents[state.selectedContentIndex]
                    .buildEditor(context, constraints.maxWidth);
              }

              rightSidebar.setItems([
                SidebarEventButton(
                    label: '删除', onPressed: () => cubit.deletePage(context)),
                SidebarEventButton(
                    label: '重命名', onPressed: () => cubit.rename(context)),
                const Divider(),
                SidebarEventButton(
                    label: '添加', onPressed: () => cubit.addContent(context)),
                BlocSelector<ScreenshotPageCubit, ScreenshotPageState, bool>(
                  bloc: cubit,
                  selector: (state) => state.isEditing,
                  builder: (context, state) => SidebarEventButton(
                      label: state ? "完成" : "编辑",
                      onPressed: cubit.toggleEditing),
                ),
                const Divider(),
                SidebarEventButton(
                    label: '返回', onPressed: () => leftSidebar.selectId(0)),
              ]);

              return CustomScrollView(
                slivers: _buildSlivers(
                  context,
                  state: state,
                  width: constraints.maxWidth,
                ),
              );
            },
          ),
        ),
      );
    });
  }

  List<Widget> _buildSlivers(BuildContext context,
      {required ScreenshotPageState state, required double width}) {
    final List<Widget> slivers = [
      // SliverList.list(
      //   children: [
      //     kContext.read<ScreenshotCoverCubit>().buildCoverScreenshot(
      //           context,
      //           index: kContext
      //               .read<ScreenshotsCubit>()
      //               .state
      //               .pages
      //               .indexOf(cubit),
      //           width: width,
      //         )
      //   ],
      // )
    ];

    for (var i = 0; i < state.contents.length; i++) {
      final content = state.contents[i];
      if (state.isEditing) {
        slivers.add(
          SliverFixedExtentList.list(
            itemExtent: 40,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: i == 0
                        ? null
                        : () {
                            cubit.moveContentToUp(content);
                          },
                    child: const Icon(Icons.move_up_rounded),
                  ),
                  CupertinoButton(
                    onPressed: i == state.contents.length - 1
                        ? null
                        : () {
                            cubit.moveContentToDown(content);
                          },
                    child: const Icon(Icons.move_down_rounded),
                  ),
                  CupertinoButton(
                    child: const Icon(Icons.delete_forever_rounded),
                    onPressed: () {
                      cubit.removeContent(content);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      }
      slivers.add(content.buildSliver(context, width, state.isEditing));
    }

    return slivers;
  }
}
