import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/screens/error_page.dart';
import 'package:stillnote/screens/notebook/comps/notebook_dashboard_section.dart';
import 'package:stillnote/screens/notebook/comps/notebook_discuss_section.dart';
import 'package:stillnote/screens/notebook/comps/notebook_notes_section.dart';
import 'package:stillnote/screens/notebook/cubit/notebook_cubit.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/utils/x_widgets.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class NotebookScreen extends StatefulWidget {
  final String id;
  const NotebookScreen(this.id, {super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  int selectedIndex = 1;
  double? screenWidth;
  ColorScheme? colorScheme;
  final List<(String, String)> navs = [
    ('Dashboard', XIcons.dashboard),
    ('Notes', XIcons.notes),
    ('Discuss', XIcons.chat),
  ];
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    colorScheme = Theme.of(context).colorScheme;

    return BlocProvider<NotebookCubit>(
      create: (context) => NotebookCubit(widget.id),
      child: BlocBuilder<NotebookCubit, NotebookState>(
        builder: (context, state) {
          if (state is NotebookInitialState) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is NotebookErrorState) {
            return ErrorPage(errorMsg: state.message);
          }
          if (state is NotebookAccessState) {
            XFuns.bucketAddNotebookToRecent(widget.id);
            final dashboardSection = NotebookDashboardSection(state);
            final notesSection = NotebookNotesSection(state);
            final discussSection = NotebookDiscussSection(widget.id);
            return Title(
              color: colorScheme!.primary,
              title: 'Notebook',
              child: Scaffold(
                appBar: AppBar(
                  title: Text(state.notebook.title),
                  actions: [
                    XWidgets.profileBtn(context),
                    SizedBox(width: screenWidth! / 70),
                  ],
                  leading: XWidgets.backBtn(context),
                ),
                body: XFuns.isWideScreen(screenWidth!)
                    ? Row(
                        children: [
                          if (!XFuns.isMobileScreen(screenWidth!))
                            getSidebar(context),
                          Expanded(
                            child: IndexedStack(
                              index: selectedIndex,
                              sizing: StackFit.expand,
                              children: [
                                dashboardSection,
                                notesSection,
                                discussSection,
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(children: [
                        SizedBox(
                            width: (screenWidth!) * 0.26,
                            child: dashboardSection),
                        Expanded(child: notesSection),
                        Container(
                          width: screenWidth! * 0.26,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                width: 1,
                                color: colorScheme!.primary
                                    .withValues(alpha: 0.23),
                              ),
                            ),
                          ),
                          child: discussSection,
                        ),
                      ]),
                bottomNavigationBar: XFuns.isMobileScreen(screenWidth!)
                    ? getBottombar(context)
                    : null,
              ),
            );
          }
          return const Scaffold(body: SizedBox());
        },
      ),
    );
  }

  Widget getBottombar(BuildContext context) {
    return Material(
      shape: Border(
        top: BorderSide(
            width: 1, color: colorScheme!.secondary.withValues(alpha: 0.3)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() => selectedIndex = value),
        destinations: List.generate(
          navs.length,
          (index) => NavigationDestination(
            icon: SvgIcon(
              navs[index].$2,
              color: colorScheme!.onSurface
                  .withValues(alpha: (selectedIndex == index) ? 1 : 0.5),
            ),
            label: navs[index].$1,
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
          color: colorScheme!.secondary.withValues(alpha: 0.5),
        ),
      ),
      child: NavigationRail(
        leading: const SizedBox(height: 10),
        selectedIndex: selectedIndex,
        labelType: NavigationRailLabelType.all,
        onDestinationSelected: (value) => setState(() => selectedIndex = value),
        destinations: List.generate(
          navs.length,
          (index) => NavigationRailDestination(
            icon: SvgIcon(
              navs[index].$2,
              color: colorScheme!.onSurface
                  .withValues(alpha: (selectedIndex == index) ? 1 : 0.3),
            ),
            label: Text(navs[index].$1),
          ),
        ),
      ),
    );
  }
}
