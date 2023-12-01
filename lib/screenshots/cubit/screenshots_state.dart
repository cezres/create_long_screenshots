part of 'screenshots_cubit.dart';

sealed class ScreenshotsState extends Equatable {
  const ScreenshotsState({
    required this.pages,
  });

  final List<ScreenshotPageCubit> pages;

  @override
  List<Object> get props => [
        pages.map((e) => e.id),
      ];

  ScreenshotsState copyWith({
    List<ScreenshotPageCubit>? pages,
  }) {
    return ScreenshotsInitial(
      pages: pages ?? this.pages,
    );
  }

  int get numberOfRow {
    switch (pages.length) {
      case 2:
      // case 3:
      case 4:
        return 2;
      case 3:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
        return 3;
      default:
        return 1;
    }
  }

  int get numberOfColumn {
    switch (pages.length) {
      // case 3:
      case 4:
      case 5:
      case 6:
        return 2;
      case 7:
      case 8:
      case 9:
        return 3;
      default:
        return 1;
    }
  }
}

final class ScreenshotsInitial extends ScreenshotsState {
  const ScreenshotsInitial({
    super.pages = const [],
  });
}
