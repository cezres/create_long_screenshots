import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SidebarEventButton extends StatelessWidget {
  const SidebarEventButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 4),
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: kDefaultTextStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
