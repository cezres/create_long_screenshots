import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:create_long_screenshots/image_picker/cubit/image_caches_cubit.dart';
import 'package:create_long_screenshots/screenshot_cover/cubit/screenshot_cover_cubit.dart';
import 'package:create_long_screenshots/screenshot_cover/view/screenshot_cover_page.dart';
import 'package:create_long_screenshots/screenshot_page/view/screenshot_page_view.dart';
import 'package:create_long_screenshots/screenshots/cubit/screenshots_cubit.dart';
import 'package:create_long_screenshots/web_hydrated_storage.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar.dart';
import 'package:create_long_screenshots/widgets/sidebar/sidebar_page_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

late Database kDatabase;
late BuildContext kContext;

// flutter build web --web-renderer canvaskit --release
// flutter run -d chrome --web-hostname 0.0.0.0 --web-port 41761 --web-renderer canvaskit --release

final leftSidebar = SidebarCubit(
  const SidebarState(
    selectedId: 0,
    items: [
      SidebarPageButton(
        id: 0,
        label: '封面',
        icon: Icons.image_outlined,
        selectedIcon: Icons.image,
      ),
    ],
    dividerPosition: SidebarDividerPosition.right,
  ),
);

final rightSidebar = SidebarCubit(const SidebarState(
  selectedId: -1,
  items: [],
  dividerPosition: SidebarDividerPosition.left,
));

void main() async {
  kDatabase = await databaseFactoryWeb.openDatabase('screenshots');

  HydratedBloc.storage = WebHydratedStorage();

  standardSelectionMenuItems.removeWhere(
    (element) => {
      AppFlowyEditorL10n.current.image,
      AppFlowyEditorL10n.current.table,
    }.contains(element.name),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const title = '创建长截图';
    const localizationsDelegates = [
      AppFlowyEditorLocalizations.delegate,
    ];

    final home = MultiBlocProvider(
      providers: [
        BlocProvider.value(value: kImageCaches),
        BlocProvider(
          create: (context) => ScreenshotsCubit(),
        ),
        BlocProvider(
          create: (context) => ScreenshotCoverCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          kContext = context;
          return const Material(child: MainPage());
        },
      ),
    );

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: localizationsDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // fontFamily: "NotoSansSC",
      ).useSystemChineseFont(Brightness.light),
      themeMode: ThemeMode.light,
      home: home,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: BlocProvider.value(
          value: leftSidebar,
          child: const Sidebar(),
        ),
        endDrawer: BlocProvider.value(
          value: rightSidebar,
          child: const Sidebar(),
        ),
        body: Stack(
          children: [
            Container(
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: const Padding(
                padding: EdgeInsets.only(top: 44 + 16),
                child: MainContentView(),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: CupertinoButton(
                child: const Icon(
                  CupertinoIcons.sidebar_left,
                  size: 28,
                ),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: CupertinoButton(
                child: const Icon(
                  CupertinoIcons.sidebar_right,
                  size: 28,
                ),
                onPressed: () {
                  _scaffoldKey.currentState!.openEndDrawer();
                },
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          BlocProvider.value(
            value: leftSidebar,
            child: const Sidebar(),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: const MainContentView(),
            ),
          ),
          BlocProvider.value(
            value: rightSidebar,
            child: const Sidebar(),
          ),
        ],
      ),
    );
  }
}

class MainContentView extends StatelessWidget {
  const MainContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SidebarCubit, SidebarState, int>(
      bloc: leftSidebar,
      selector: (state) => state.selectedId,
      builder: (context, selectedId) {
        if (selectedId == 0) {
          return const ScreenshotCoverPage();
        }
        final page = context
            .read<ScreenshotsCubit>()
            .state
            .pages
            .firstWhere((element) => element.id == selectedId);

        return ScreenshotPageView(cubit: page);
      },
    );
  }
}
