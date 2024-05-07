import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/models/note.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/utils/x_functions.dart';

part 'notebook_state.dart';

class NotebookCubit extends Cubit<NotebookState> {
  String notebookId;

  NotebookCubit(this.notebookId) : super(NotebookInitialState()) {
    setAccess();
  }

  Future<void> setAccess() async {
    try {
      final auth = FirebaseAuth.instance;
      final notebook = await Notebook.fromId(notebookId);
      if (notebook != null) {
        // List<Note> noteList = await getNotes();
        if (auth.currentUser != null) {
          if (notebook.ownerUID == auth.currentUser!.uid) {
            emit(NotebookEditorState(
              notebook: notebook,
              // noteList: noteList,
            ));
            return;
          }
        }
        if (notebook.private) {
          emit(const NotebookErrorState(
            "It is a private Notebook, you dont have access to it!",
          ));
          return;
        }
        emit(NotebookReadOnlyState(
          notebook: notebook,
          // noteList: noteList,
        ));
      } else {
        emit(const NotebookErrorState('Notebook not found!'));
      }
    } catch (e) {
      emit(NotebookErrorState(e.toString()));
    }
  }

  List<Note> getNotes(QuerySnapshot<Map<String, dynamic>> snapshot) {
    List<Note> result = [];
    for (var doc in snapshot.docs) {
      if (doc.exists) {
        result.add(Note.fromSnapshot(doc));
      }
    }

    result.sort(
      (a, b) {
        return (b.createdDatetime.compareTo(a.createdDatetime));
      },
    );

    return result;
  }

  Future<Timestamp> onNotebookModified() async {
    final modifiedTimestamp = Timestamp.now();
    await FirebaseFirestore.instance
        .collection("notebooks")
        .doc(notebookId)
        .update({'modified_datetime': modifiedTimestamp});
    return modifiedTimestamp;
  }

  Future<void> updateTitleDesc(
    BuildContext context,
    NotebookEditorState state,
    String newTitle,
    String newDesc,
  ) async {
    if (newTitle.isNotEmpty && newDesc.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("notebooks")
          .doc(state.notebook.id)
          .update({
        'title': newTitle,
        'description': newDesc,
        'modified_datetime': Timestamp.now(),
      });

      state.notebook.title = newTitle;
      state.notebook.description = newDesc;
      emit(NotebookEditorState(
        notebook: state.notebook,
        // noteList: state.noteList,
      ));
      // ignore: use_build_context_synchronously
      XFuns.showSnackbar(context, "Changes Applied Successfully!");
    } else {
      XFuns.showSnackbar(context, "Failed to update changes!");
    }
    return;
  }

  Future<void> deleteNote(NotebookEditorState state, Note note) async {
    await FirebaseFirestore.instance.collection('notes').doc(note.id).delete();
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(note.id)
        .collection('sections')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(note.id)
        .collection('discuss')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    await onNotebookModified();
    await setAccess();
  }
}
