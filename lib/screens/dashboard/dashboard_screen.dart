import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/screens/dashboard/pages/notebooks_page.dart';
import 'package:stillnote/screens/dashboard/pages/home_page.dart';
import 'package:stillnote/screens/dashboard/pages/search_page.dart';
import 'package:stillnote/screens/dashboard/pages/starred_page.dart';
import 'package:stillnote/utils/extensions.dart';
import 'package:stillnote/utils/x_constants.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/utils/x_router.dart';
import 'package:stillnote/utils/x_widgets.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ColorScheme? colorScheme;
  double? screenWidth;
  late int selectedIndex;
  final List<(String, String)> navs = [
    ('home', XIcons.home),
    ('search', XIcons.search),
    ('notebooks', XIcons.book),
    ('starred', XIcons.star),
  ];
  late void Function() delListner;

  @override
  void initState() {
    super.initState();
    final title = XRouter.currentUri.pathSegments.last;
    selectedIndex = navs.indexWhere((e) => e.$1 == title);
    if (selectedIndex == -1) selectedIndex = 0;
    delListner = () => changePage();
  }

  @override
  void dispose() {
    XRouter.routerDel.removeListener(delListner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    colorScheme = Theme.of(context).colorScheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      XRouter.routerDel.addListener(delListner);
    });
    return Title(
      title: navs[selectedIndex].$1.toTitleCase(),
      color: colorScheme!.primary,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(XConsts.appName),
          actions: [
            XWidgets.profileBtn(context),
            SizedBox(width: screenWidth! / 70),
          ],
          automaticallyImplyLeading: false,
        ),
        body: Row(
          children: [
            if (!XFuns.isTabletScreen(screenWidth!)) getSidebar(context),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: const [
                  HomePage(),
                  SearchPage(),
                  NotebooksPage(),
                  StarredPage(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            XFuns.isTabletScreen(screenWidth!) ? getBottombar(context) : null,
      ),
    );
  }

  Widget getBottombar(BuildContext context) {
    return Material(
      shape: Border(
          top: BorderSide(
              width: 1, color: colorScheme!.secondary.withOpacity(0.3))),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() => selectedIndex = value);
          changeUrl(context);
        },
        destinations: List.generate(
          navs.length,
          (index) => NavigationDestination(
            icon: SvgIcon(
              navs[index].$2,
              color: colorScheme!.onSurface
                  .withOpacity((selectedIndex == index) ? 1 : 0.5),
            ),
            label: navs[index].$1.toTitleCase(),
          ),
        ),
      ),
    );
  }

  Widget getSidebar(BuildContext context) {
    return Material(
      shape: Border(
        right: BorderSide(
          width: 1,
          color: colorScheme!.secondary.withOpacity(0.5),
        ),
      ),
      child: NavigationRail(
        leading: const SizedBox(height: 10),
        selectedIndex: selectedIndex,
        labelType: NavigationRailLabelType.all,
        onDestinationSelected: (value) {
          setState(() => selectedIndex = value);
          changeUrl(context);
        },
        destinations: List.generate(
          navs.length,
          (index) => NavigationRailDestination(
            icon: SvgIcon(
              navs[index].$2,
              color: colorScheme!.onSurface
                  .withOpacity((selectedIndex == index) ? 1 : 0.3),
            ),
            label: Text(navs[index].$1.toTitleCase()),
          ),
        ),
      ),
    );
  }

  void changeUrl(BuildContext context) {
    final title = navs[selectedIndex].$1;
    if (title != XRouter.currentUri.pathSegments.last) {
      context.go('/dashboard/$title');
    }
  }

  void changePage() {
    final title = XRouter.currentUri.pathSegments.last;
    final newIndex = navs.indexWhere((e) => e.$1 == title);
    if (newIndex != -1 && newIndex < navs.length) {
      setState(() => selectedIndex = newIndex);
    }
  }
}
