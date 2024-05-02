import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/dialogs/add_note_section_dialog.dart';
import 'package:stillnote/models/note.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/models/safe_timer.dart';
import 'package:stillnote/screens/note/note_sections/note_section.dart';
import 'package:stillnote/screens/note/note_sections/note_section_type.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  final String noteId;
  final ItemScrollController noteViewItemScroller = ItemScrollController();
  final SafeTimer _titleUpdaterTimer = SafeTimer(const Duration(seconds: 3));
  NoteCubit(this.noteId) : super(NoteInitialState()) {
    setAccess();
  }

  void setAccess() async {
    try {
      final auth = FirebaseAuth.instance;
      final note = await Note.fromId(noteId);
      if (note != null) {
        final notebook = await Notebook.fromId(note.notebookId);
        if (notebook != null) {
          List<String> sectionList = List.from(note.sectionList);
          final sections = await getSections(sectionList);
          if (auth.currentUser != null) {
            if (notebook.ownerUID == auth.currentUser!.uid) {
              emit(NoteEditorState(
                note: note,
                notebook: notebook,
                sections: sections,
              ));
              return;
            }
          }
          if (note.private) {
            emit(const NoteErrorState(
              "It is a private Note, you dont have access to it!",
            ));
            return;
          }
          emit(NoteReadOnlyState(
            note: note,
            notebook: notebook,
            sections: sections,
          ));
        } else {
          emit(const NoteErrorState("Note not found"));
        }
      } else {
        emit(const NoteErrorState("Note not found"));
      }
    } catch (e) {
      emit(NoteErrorState(e.toString()));
    }
  }

  Future<List<NoteSection>> getSections(List<String> sectionList,
      [List<NoteSection>? oldSections]) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("notes")
        .doc(noteId)
        .collection("sections")
        .get();
    List<NoteSection> oldList = oldSections ?? [];
    List<NoteSection> newList = [];
    final docs = snapshot.docs;
    for (var docID in sectionList) {
      try {
        final doc = docs.firstWhere((e) => e.id == docID);
        if (doc.exists) {
          final index = oldList.indexWhere((e) => e.id == docID);
          if (index < 0) {
            final section = NoteSection.fromSnapshot(doc, noteId);
            if (section != null) {
              newList.add(section);
            }
          } else {
            final section = oldList[index];
            final data = doc.data();
            if (data.isNotEmpty) {
              section.update(data);
            }
            newList.add(section);
          }
        }
        // ignore: empty_catches
      } catch (e) {}
    }
    return newList;
  }

  void reorderSectionList(
    NoteEditorState state,
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item1 = state.note.sectionList.removeAt(oldIndex);
    state.note.sectionList.insert(newIndex, item1);
    final item2 = state.sections.removeAt(oldIndex);
    state.sections.insert(newIndex, item2);
    FirebaseFirestore.instance
        .collection("notes")
        .doc(noteId)
        .update({'section_list': state.note.sectionList});
    onNoteModified();
    emit(NoteEditorState(
      note: state.note,
      notebook: state.notebook,
      sections: state.sections,
    ));
  }

  void deleteNoteSection(NoteEditorState state, String sectionID) async {
    state.note.sectionList.remove(sectionID);
    state.sections.removeWhere((e) => e.id == sectionID);
    await FirebaseFirestore.instance
        .collection("notes")
        .doc(state.note.id)
        .update({'section_list': state.note.sectionList});
    await FirebaseFirestore.instance
        .collection("notes")
        .doc(state.note.id)
        .collection("sections")
        .doc(sectionID)
        .delete();
    onNoteModified();
    emit(NoteEditorState(
      note: state.note,
      notebook: state.notebook,
      sections: state.sections,
    ));
  }

  void showCreateSectionDialog(
      BuildContext context, NoteEditorState state) async {
    NoteSectionType? result = await showDialog(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        return AddNoteSectionDialog(
          close: (noteSectionType) =>
              Navigator.pop(dialogContext, noteSectionType),
        );
      },
    );
    // ignore: use_build_context_synchronously
    createSection(context, state, result);
  }

  Future<void> createSection(BuildContext context, NoteEditorState state,
      NoteSectionType? noteSectionType) async {
    if (noteSectionType != null) {
      final firestore = FirebaseFirestore.instance;
      var ref = await firestore
          .collection("notes")
          .doc(state.note.id)
          .collection("sections")
          .add(noteSectionType.getJson());
      var doc = await ref.get();
      if (doc.exists) {
        state.note.sectionList.add(doc.id);
        await firestore
            .collection("notes")
            .doc(state.note.id)
            .update({'section_list': state.note.sectionList});
      }
      final newSection = NoteSection.fromSnapshot(doc, noteId);
      if (newSection != null) {
        state.sections.add(newSection);
      } else {
        state.note.sectionList.removeLast();
        // ignore: use_build_context_synchronously
        XFuns.showSnackbar(context, "Error creating new section!");
      }
      emit(NoteEditorState(
        note: state.note,
        notebook: state.notebook,
        sections: state.sections,
      ));
      onNoteModified();
      scrollToNoteViewSection(state.sections.length);
      // ignore: use_build_context_synchronously
      state.sections.last.initialAction(context);
    }
  }

  void scrollToNoteViewSection(int index,
      [Duration duration = Durations.short4]) {
    try {
      if (noteViewItemScroller.isAttached) {
        noteViewItemScroller.scrollTo(index: index, duration: duration);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> onNoteModified() async {
    if (state is NoteEditorState) {
      final noteState = state as NoteEditorState;
      final modifiedTimestamp = Timestamp.now();
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection("notes")
          .doc(noteState.note.id)
          .update({'modified_datetime': modifiedTimestamp});
      await firestore
          .collection("notebooks")
          .doc(noteState.note.notebookId)
          .update({'modified_datetime': modifiedTimestamp});
    }
    return;
  }

  void updateTitle(
    BuildContext context,
    NoteEditorState state,
    String newTitle,
  ) {
    if (newTitle.isNotEmpty) {
      _titleUpdaterTimer.run(() async {
        await FirebaseFirestore.instance
            .collection("notes")
            .doc(state.note.id)
            .update({'title': newTitle});
        state.note.title = newTitle;
        // ignore: use_build_context_synchronously
        XFuns.showSnackbar(context, "Title Updated");
      });
    }
  }
}
