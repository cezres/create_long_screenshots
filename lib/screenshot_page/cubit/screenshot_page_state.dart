part of 'screenshot_page_cubit.dart';

sealed class ScreenshotPageState extends Equatable {
  const ScreenshotPageState({
    required this.title,
    required this.contents,
    this.isEditing = false,
    this.loadedContents = false,
    this.selectedContentIndex = -1,
  });

  final String title;

  final List<ScreenshotContentCubit> contents;

  final bool isEditing;

  final bool loadedContents;

  final int selectedContentIndex;

  @override
  List<Object> get props => [
        title,
        contents.map((e) => e.id).toList(growable: false),
        isEditing,
        loadedContents,
        selectedContentIndex,
      ];

  ScreenshotPageState copyWith({
    String? title,
    List<ScreenshotContentCubit>? contents,
    bool? isEditing,
    bool? loadedContents,
    int? selectedContentIndex,
  }) {
    return ScreenshotPageInitial(
      title: title ?? this.title,
      contents: contents ?? this.contents,
      isEditing: isEditing ?? this.isEditing,
      loadedContents: loadedContents ?? this.loadedContents,
      selectedContentIndex: selectedContentIndex ?? this.selectedContentIndex,
    );
  }
}

final class ScreenshotPageInitial extends ScreenshotPageState {
  const ScreenshotPageInitial({
    super.title = '未命名',
    super.contents = const [],
    super.isEditing = false,
    super.loadedContents = false,
    super.selectedContentIndex = -1,
  });
}
