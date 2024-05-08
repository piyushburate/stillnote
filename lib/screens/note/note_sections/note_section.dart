import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stillnote/screens/note/cubit/note_cubit.dart';
import 'package:stillnote/screens/note/note_sections/code_view_box_section.dart';
import 'package:stillnote/screens/note/note_sections/image_box_section.dart';
import 'package:stillnote/screens/note/note_sections/note_section_type.dart';
import 'package:stillnote/screens/note/note_sections/text_box_section.dart';
import 'package:stillnote/screens/note/note_sections/video_box.section.dart';
import 'package:stillnote/screens/note/note_sections/yt_video_box_section.dart';

class NoteSection {
  final String id;
  final String noteId;
  final NoteSectionType type;

  NoteSection({
    required this.id,
    required this.noteId,
    required this.type,
  });

  static NoteSection? fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document, String noteId) {
    final data = document.data()!;
    final type = data['type'];
    if (type == NoteSectionType.textBox.name) {
      return TextBoxSection.fromSnapshot(document, noteId);
    }
    if (type == NoteSectionType.imageBox.name) {
      return ImageBoxSection.fromSnapshot(document, noteId);
    }
    if (type == NoteSectionType.videoBox.name) {
      return VideoBoxSection.fromSnapshot(document, noteId);
    }
    if (type == NoteSectionType.ytVideoBox.name) {
      return YtVideoBoxSection.fromSnapshot(document, noteId);
    }
    if (type == NoteSectionType.codeViewBox.name) {
      return CodeViewBoxSection.fromSnapshot(document, noteId);
    }
    return null;
  }

  Widget widget(BuildContext context, bool isEditable) {
    throw UnimplementedError();
  }

  Map<String, dynamic> get json {
    throw UnimplementedError();
  }

  void update(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  Widget? menu(BuildContext context, NoteAccessState state) {
    throw UnimplementedError();
  }

  Future<void> deleteResources(NoteEditorState state) async {}

  void initialAction(BuildContext context) {}
}
