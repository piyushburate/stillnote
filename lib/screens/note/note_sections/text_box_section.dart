import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/models/safe_timer.dart';
import 'package:stillnote/screens/note/cubit/note_cubit.dart';
import 'package:stillnote/screens/note/note_sections/note_section.dart';
import 'package:stillnote/screens/note/note_sections/note_section_type.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class TextBoxSection extends NoteSection {
  final TextEditingController _controller = TextEditingController();
  final SafeTimer _timer = SafeTimer(const Duration(seconds: 3));
  TextBoxSection({
    required super.id,
    required super.noteId,
    String text = "",
  }) : super(type: NoteSectionType.textBox) {
    _controller.text = text;
  }

  factory TextBoxSection.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document, String noteId) {
    final data = document.data()!;
    return TextBoxSection(id: document.id, noteId: noteId, text: data['text']);
  }

  String get text => _controller.text;

  @override
  Widget widget(BuildContext context, bool isEditable) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _controller,
      readOnly: !isEditable,
      style: TextStyle(
        fontSize: 16,
        color: colorScheme.primary,
      ),
      onChanged: (value) {
        _timer.run(() async {
          await FirebaseFirestore.instance
              .collection("notes")
              .doc(noteId)
              .collection("sections")
              .doc(id)
              .update({'text': value});
          // ignore: use_build_context_synchronously
          context.read<NoteCubit>().onNoteModified();
          // ignore: use_build_context_synchronously
          XFuns.showSnackbar(context, "Saved");
        });
      },
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintText: "Type your text here...",
      ),
    );
  }

  @override
  Map<String, dynamic> get json {
    return {'type': type.name, 'text': text};
  }

  @override
  void update(Map<String, dynamic> data) {
    _controller.text = data['text'];
  }

  @override
  Widget? menu(BuildContext context, NoteAccessState state) {
    final colorScheme = Theme.of(context).colorScheme;
    var itemList = <PopupMenuEntry>[
      PopupMenuItem(
        child: const Row(
          children: [
            SvgIcon(XIcons.copy),
            SizedBox(width: 10),
            Text("Copy Text"),
          ],
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: text));
          XFuns.showSnackbar(context, 'TextBox text copied successfully!');
        },
      ),
      if (state is NoteEditorState)
        PopupMenuItem(
          child: const Row(
            children: [
              SvgIcon(XIcons.bin),
              SizedBox(width: 10),
              Text("Delete"),
            ],
          ),
          onTap: () async {
            context.read<NoteCubit>().deleteNoteSection(state, id);
          },
        ),
    ];
    return PopupMenuButton(
      tooltip: "",
      icon: const SvgIcon(XIcons.moreVert),
      surfaceTintColor: colorScheme.surface,
      itemBuilder: (context) => itemList,
    );
  }
}
