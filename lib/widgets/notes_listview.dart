import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/dialogs/create_note_dialog.dart';
import 'package:stillnote/models/note.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/screens/notebook/cubit/notebook_cubit.dart';

class NotesListview extends StatefulWidget {
  final bool showActions;
  final bool showCreateBtn;
  final Notebook? notebook;
  final List<Note> list;
  final Future<void> Function()? refreshFun;
  final NotebookEditorState? notebookState;
  final String? title;
  final bool scrollable;
  const NotesListview({
    super.key,
    required this.list,
    this.notebook,
    this.refreshFun,
    this.showCreateBtn = false,
    this.showActions = false,
    this.notebookState,
    this.title,
    this.scrollable = true,
  });

  @override
  State<NotesListview> createState() => _NotesListviewState();
}

class _NotesListviewState extends State<NotesListview> {
  late ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: (widget.showCreateBtn && widget.notebook != null)
          ? FloatingActionButton.extended(
              onPressed: () async {
                String? noteId = await showDialog(
                  context: context,
                  useSafeArea: true,
                  builder: (dialogContext) {
                    return CreateNoteDialog(
                      close: (noteId) => Navigator.pop(dialogContext, noteId),
                      notebook: widget.notebook!,
                    );
                  },
                );
                // ignore: use_build_context_synchronously
                await widget.refreshFun!();
                if (noteId != null && noteId.isNotEmpty) {
                  // ignore: use_build_context_synchronously
                  context.push('/note/$noteId');
                }
              },
              label: const Text('New Note'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: (widget.refreshFun == null)
          ? getMainView()
          : RefreshIndicator(
              onRefresh: () => widget.refreshFun!(),
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: getMainView(),
            ),
    );
  }

  Widget getMainView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      physics: widget.scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        if (widget.showActions) _buildActions(),
        if (widget.showActions) const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.list.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: _buildNoteItem(widget.list[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [],
    );
  }

  Widget _buildNoteItem(Note note) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: colorScheme.primary.withOpacity(0.2),
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
        trailing: note.menu(context, notebookState: widget.notebookState),
      ),
    );
  }
}
