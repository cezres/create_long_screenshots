import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_page_button.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final kDefaultTextStyle = const TextStyle(
  // fontFamily: 'NotoSansSC',
  fontSize: 14,
  color: Colors.black,
  fontWeight: FontWeight.w400,
).useSystemChineseFont();

class SidebarCubit extends Cubit<SidebarState> {
  SidebarCubit(super.initialState);

  void selectId(int id) {
    emit(state.copyWith(selectedId: id));
  }

  void setItems(List<Widget> items) {
    var selectedId = 0;
    if (state.selectedId != 0) {
      for (var element in items) {
        if (element is SidebarPageButton) {
          if (element.id == state.selectedId) {
            selectedId = element.id;
            break;
          }
        }
      }
    }
    emit(state.copyWith(items: items, selectedId: selectedId));
  }
}

class SidebarState extends Equatable {
  const SidebarState({
    required this.selectedId,
    required this.items,
    this.dividerPosition = SidebarDividerPosition.none,
  });

  final int selectedId;
  final List<Widget> items;
  final SidebarDividerPosition dividerPosition;

  @override
  List<Object?> get props => [
        selectedId,
        items.map((e) => e.hashCode),
        dividerPosition.index,
      ];

  SidebarState copyWith({
    int? selectedId,
    List<Widget>? items,
    SidebarDividerPosition? dividerPosition,
  }) {
    return SidebarState(
      selectedId: selectedId ?? this.selectedId,
      items: items ?? this.items,
      dividerPosition: dividerPosition ?? this.dividerPosition,
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final SidebarCubit cubit = BlocProvider.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocSelector<SidebarCubit, SidebarState, SidebarDividerPosition>(
          bloc: cubit,
          selector: (state) => state.dividerPosition,
          builder: (context, dividerPosition) {
            if (dividerPosition == SidebarDividerPosition.left) {
              const VerticalDivider(thickness: 1, width: 1);
            }
            return const SizedBox.shrink();
          },
        ),
        Container(
          width: 160,
          color: const Color.fromRGBO(239, 233, 230, 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
          child: BlocSelector<SidebarCubit, SidebarState, List<Widget>>(
            bloc: cubit,
            selector: (state) => state.items,
            builder: (context, items) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: items,
              );
            },
          ),
        ),
        BlocSelector<SidebarCubit, SidebarState, SidebarDividerPosition>(
          bloc: cubit,
          selector: (state) => state.dividerPosition,
          builder: (context, dividerPosition) {
            if (dividerPosition == SidebarDividerPosition.right) {
              const VerticalDivider(thickness: 1, width: 1);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

enum SidebarDividerPosition {
  none,
  left,
  right,
}
