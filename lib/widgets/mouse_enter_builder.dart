import 'package:flutter/material.dart';

class MouseEnterBuilder extends StatefulWidget {
  const MouseEnterBuilder({
    super.key,
    this.child,
    required this.builder,
  });

  final Widget? child;
  final Widget Function(BuildContext context, bool isEntering, Widget? child)
      builder;

  @override
  State<MouseEnterBuilder> createState() => _MouseEnterBuilderState();
}

class _MouseEnterBuilderState extends State<MouseEnterBuilder> {
  bool isEntering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isEntering = true),
      onExit: (_) => setState(() => isEntering = false),
      child: widget.builder(context, isEntering, widget.child),
    );
  }
}
