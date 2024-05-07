import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/dialogs/create_note_dialog.dart';
import 'package:stillnote/models/note.dart';
import 'package:stillnote/screens/notebook/cubit/notebook_cubit.dart';
import 'package:stillnote/widgets/notes_listview.dart';

class NotebookNotesSection extends StatelessWidget {
  final NotebookAccessState notebookState;
  const NotebookNotesSection(this.notebookState, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Note? note = await showDialog(
            context: context,
            useSafeArea: true,
            builder: (dialogContext) {
              return CreateNoteDialog(
                close: (noteId) => Navigator.pop(dialogContext, noteId),
                notebook: notebookState.notebook,
              );
            },
          );
          if (note != null) {
            // ignore: use_build_context_synchronously
            await context.read<NotebookCubit>().onNotebookModified();
            // ignore: use_build_context_synchronously
            await context.read<NotebookCubit>().setAccess();
            // ignore: use_build_context_synchronously
            context.push('/note/${note.id}');
          }
        },
        label: const Text('New Note'),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("notes")
              .where("notebook_id", isEqualTo: notebookState.notebook.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              notebookState.noteList =
                  context.read<NotebookCubit>().getNotes(snapshot.data!);
            }
            if (notebookState.noteList == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return NotesListview(
              title: 'Notes',
              list: notebookState.noteList!,
              notebook: notebookState.notebook,
              notebookState: (notebookState is NotebookEditorState)
                  ? (notebookState as NotebookEditorState)
                  : null,
            );
          }),
    );
  }
}
