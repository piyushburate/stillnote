import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/dialogs/note_manage_access_dialog.dart';
import 'package:stillnote/screens/note/cubit/note_cubit.dart';
import 'package:stillnote/utils/extensions.dart';
import 'package:stillnote/utils/x_constants.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/utils/x_widgets.dart';

class NoteDashboardSection extends StatelessWidget {
  final NoteAccessState noteState;
  const NoteDashboardSection(this.noteState, {super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Created on',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                noteState.note.createdDatetime.toDate().toHumanReadable(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Last Modified',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                noteState.note.modifiedDatetime.toDate().getDifferences(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  XWidgets.svgIconTextBtn(
                    colorScheme: colorScheme,
                    assetName: XIcons.share,
                    text: 'Share',
                    onPressed: () => XFuns.shareLink(
                      context,
                      '${XConsts.appDomain}/note/${noteState.note.id}',
                    ),
                  ),
                  if (noteState is NoteEditorState)
                    XWidgets.svgIconTextBtn(
                      colorScheme: colorScheme,
                      assetName: XIcons.lockedBook,
                      text: 'Manage Access',
                      onPressed: () async {
                        await manageAccessDialog(
                            context, noteState as NoteEditorState);
                        // ignore: use_build_context_synchronously
                        context.read<NoteCubit>().setAccess();
                      },
                    ),
                  if (FirebaseAuth.instance.currentUser != null)
                    XWidgets.starredBtn(
                      colorScheme: colorScheme,
                      user: FirebaseAuth.instance.currentUser!,
                      type: 'note',
                      nid: noteState.note.id,
                    )
                ],
              ),
              // const SizedBox(height: 20),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Sections',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        getSectionListView(context, colorScheme),
      ],
    );
  }

  Widget getSectionListView(BuildContext context, ColorScheme colorScheme) {
    return Material(
      type: MaterialType.transparency,
      child: (noteState is NoteEditorState)
          ? getEditorSections(
              context, colorScheme, noteState as NoteEditorState)
          : getReadOnlySections(colorScheme, noteState as NoteReadOnlyState),
    );
  }

  Widget getReadOnlySections(ColorScheme colorScheme, NoteReadOnlyState state) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: state.sections.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var section = state.sections[index];
        return ListTile(
          key: ValueKey("section_list_tile_${section.id}"),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          title: Text(
            section.type.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: section.type.icon,
          trailing: section.menu(context, state),
          onTap: () => goToSectionItem(context, index),
        );
      },
    );
  }

  Widget getEditorSections(
    BuildContext context,
    ColorScheme colorScheme,
    NoteEditorState state,
  ) {
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
        context.read<NoteCubit>().reorderSectionList(state, oldIndex, newIndex);
      },
      shrinkWrap: true,
      itemCount: state.sections.length,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        var section = state.sections[index];
        return ListTile(
          key: ValueKey("section_list_tile_${section.id}"),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          title: Text(
            section.type.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: ReorderableDragStartListener(
            index: index,
            child: section.type.icon,
          ),
          trailing: section.menu(context, state),
          onTap: () => goToSectionItem(context, index),
        );
      },
    );
  }

  void goToSectionItem(BuildContext context, int index) {
    context.read<NoteCubit>().scrollToNoteViewSection(index);
  }

  Future<void> manageAccessDialog(
      BuildContext context, NoteEditorState state) async {
    return await showDialog(
      context: context,
      builder: (dialogContext) => NoteManageAccessDialog(
        note: state.note,
        close: () => Navigator.pop(dialogContext, true),
      ),
    );
  }
}
