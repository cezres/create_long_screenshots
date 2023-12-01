import 'package:create_long_screenshots/common/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SidebarPageButton extends StatelessWidget {
  const SidebarPageButton({
    super.key,
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.onPressed,
  });
  final int id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: () {
          final SidebarCubit cubit = BlocProvider.of(context);
          cubit.selectId(id);

          onPressed?.call();
        },
        child: BlocSelector<SidebarCubit, SidebarState, int>(
          selector: (state) => state.selectedId,
          builder: (context, selectedLabel) {
            if (selectedLabel == id) {
              return _buildSelectedButton(context);
            } else {
              return _buildUnselectedButton(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSelectedButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              selectedIcon,
              size: 18,
            ),
          ),
          Text(
            label,
            style: kDefaultTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildUnselectedButton(BuildContext context) {
    return MouseEnterBuilder(builder: (context, isEntering, child) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: isEntering
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                icon,
                size: 18,
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: kDefaultTextStyle,
              ),
            ),
          ],
        ),
      );
    });
  }
}
