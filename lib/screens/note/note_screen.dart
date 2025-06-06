import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/screens/error_page.dart';
import 'package:stillnote/screens/note/comps/note_dashboard_section.dart';
import 'package:stillnote/screens/note/comps/note_discuss_section.dart';
import 'package:stillnote/screens/note/comps/note_main_section.dart';
import 'package:stillnote/screens/note/cubit/note_cubit.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/utils/x_widgets.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class NoteScreen extends StatefulWidget {
  final String id;
  const NoteScreen(this.id, {super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
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

    return BlocProvider(
      create: (context) => NoteCubit(widget.id),
      child: BlocBuilder<NoteCubit, NoteState>(
        builder: (context, state) {
          if (state is NoteInitialState) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator.adaptive()));
          }
          if (state is NoteErrorState) {
            return ErrorPage(errorMsg: state.message);
          }
          if (state is NoteAccessState) {
            final dashboardSection = NoteDashboardSection(state);
            final notesSection = NoteMainSection(state);
            final discussSection = NoteDiscussSection(widget.id);
            return Title(
              color: colorScheme!.primary,
              title: 'Note',
              child: Scaffold(
                backgroundColor: colorScheme!.surface,
                appBar: AppBar(
                  title: Text(state.notebook.title),
                  actions: [
                    XWidgets.profileBtn(context),
                    SizedBox(width: screenWidth! / 70),
                  ],
                  leading: XWidgets.backBtn(context),
                ),
                floatingActionButton: Padding(
                  padding: EdgeInsets.only(
                    right: !XFuns.isWideScreen(screenWidth!)
                        ? screenWidth! * 0.26
                        : 0,
                  ),
                  child: (selectedIndex == 1)
                      ? getCreateNoteSectionBtn(context)
                      : null,
                ),
                body: XFuns.isWideScreen(screenWidth!)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                              width: (screenWidth!) * 0.26,
                              child: dashboardSection),
                          Expanded(
                            child: Material(
                              type: MaterialType.transparency,
                              shape: Border.symmetric(
                                vertical: BorderSide(
                                  width: 1,
                                  color: colorScheme!.secondary
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: notesSection,
                            ),
                          ),
                          SizedBox(
                            width: screenWidth! * 0.26,
                            child: discussSection,
                          ),
                        ],
                      ),
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

  Widget getCreateNoteSectionBtn(BuildContext context) {
    return BlocBuilder<NoteCubit, NoteState>(builder: (context, state) {
      return (state is NoteEditorState)
          ? FloatingActionButton(
              onPressed: () async {
                context
                    .read<NoteCubit>()
                    .showCreateSectionDialog(context, state);
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox();
    });
  }
}
