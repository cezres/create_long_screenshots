import 'package:create_long_screenshots/common/sidebar.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:create_long_screenshots/screenshot_page/cubit/screenshot_page_cubit.dart';
import 'package:create_long_screenshots/screenshots/cubit/screenshots_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenshotCoverTextView extends StatelessWidget {
  const ScreenshotCoverTextView({
    super.key,
    required this.numberOfRow,
    required this.numberOfColumn,
    this.spacing = 4,
    this.runSpacing = 4,
  });

  final double spacing;
  final double runSpacing;

  final int numberOfRow;
  final int numberOfColumn;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - spacing * (numberOfRow - 1)) / numberOfRow;
        final itemHeight =
            (constraints.maxHeight - runSpacing * (numberOfColumn - 1)) /
                numberOfColumn;

        return BlocSelector<ScreenshotsCubit, ScreenshotsState,
            List<ScreenshotPageCubit>>(
          selector: (state) => state.pages,
          builder: (context, state) {
            final children = state
                .map(
                  (e) => GestureDetector(
                    onTap: () {
                      leftSidebar.selectId(e.id);
                    },
                    child: Container(
                      width: itemWidth,
                      height: itemHeight,
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: BlocSelector<ScreenshotPageCubit,
                            ScreenshotPageState, String>(
                          bloc: e,
                          selector: (state) => state.title,
                          builder: (context, state) => Text(
                            state,
                            style: kDefaultTextStyle.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false);

            return Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              children: children,
            );
          },
        );
      },
    );
  }
}
