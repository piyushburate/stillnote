import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/models/note.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/screens/notebook/cubit/notebook_cubit.dart';

class NotesListview extends StatelessWidget {
  final List<Note> list;
  final Notebook? notebook;
  final NotebookEditorState? notebookState;
  final String? title;
  final bool scrollable;
  const NotesListview({
    super.key,
    required this.list,
    this.notebook,
    this.notebookState,
    this.title,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 5),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(colorScheme),
              _buildNoteItem(context, colorScheme, list[index])
            ],
          );
        }
        return _buildNoteItem(context, colorScheme, list[index]);
      },
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoteItem(
      BuildContext context, ColorScheme colorScheme, Note note) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: colorScheme.primary.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        title: Text(
          note.title,
          maxLines: 3,
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
        tileColor: colorScheme.surface,
        onTap: () => context.push('/note/${note.id}'),
        trailing: note.menu(context, notebookState: notebookState),
      ),
    );
  }
}
