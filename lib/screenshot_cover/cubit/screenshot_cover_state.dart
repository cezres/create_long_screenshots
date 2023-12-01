part of 'screenshot_cover_cubit.dart';

const _kScreenshotCoverTextFontSizeList = <double>[
  16,
  18,
  20,
  22,
  24,
  26,
  28,
  30,
  32,
];

const _kScreenshotCoverTextFontWeightList = [
  FontWeight.w400,
  FontWeight.w500,
  FontWeight.w600,
  FontWeight.w700,
  FontWeight.w800,
];

sealed class ScreenshotCoverState extends Equatable {
  const ScreenshotCoverState({
    this.imageId = 0,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
    this.textFontSizeIndex = 4,
    this.textFontWeightIndex = 2,
  });

  final int imageId;

  final Color backgroundColor;

  final Color textColor;

  final int textFontSizeIndex;

  final int textFontWeightIndex;

  @override
  List<Object> get props => [
        imageId,
        backgroundColor,
        textColor,
        textFontSizeIndex,
        textFontWeightIndex,
      ];

  ScreenshotCoverState copyWith({
    int? imageId,
    Color? backgroundColor,
    Color? textColor,
    int? textFontSizeIndex,
    int? textFontWeightIndex,
  }) {
    return ScreenshotCoverInitial(
      imageId: imageId ?? this.imageId,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      textFontSizeIndex: textFontSizeIndex ?? this.textFontSizeIndex,
      textFontWeightIndex: textFontWeightIndex ?? this.textFontWeightIndex,
    );
  }

  TextStyle get textStyle {
    return kDefaultTextStyle.copyWith(
      color: textColor,
      fontSize: _kScreenshotCoverTextFontSizeList[textFontSizeIndex],
      fontWeight: _kScreenshotCoverTextFontWeightList[textFontWeightIndex],
    );
  }
}

final class ScreenshotCoverInitial extends ScreenshotCoverState {
  const ScreenshotCoverInitial({
    super.imageId = 0,
    super.backgroundColor = Colors.transparent,
    super.textColor = Colors.white,
    super.textFontSizeIndex = 4,
    super.textFontWeightIndex = 2,
  });
}
