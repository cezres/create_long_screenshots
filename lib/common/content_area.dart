// import 'package:create_long_screenshots/common/is_mobileBrowser.dart';
import 'package:flutter/widgets.dart';

bool? _isMobile;

class ContentArea extends StatelessWidget {
  const ContentArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ContentAreaBuilder(builder: (context, size) => child);
  }
}

class ContentAreaBuilder extends StatelessWidget {
  const ContentAreaBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, Size size) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _isMobile ??= constraints.maxHeight > constraints.maxWidth;

        if (_isMobile!) {
          return builder(
            context,
            Size(constraints.maxWidth, constraints.maxHeight),
          );
        }
        final width = constraints.maxWidth > constraints.maxHeight
            ? constraints.maxHeight
            : constraints.maxWidth;
        return Center(
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: builder(
              context,
              Size(width, constraints.maxHeight),
            ),
          ),
        );
      },
    );
  }
}
