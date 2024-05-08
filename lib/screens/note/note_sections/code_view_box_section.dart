import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/dialogs/choose_codeview_language_dialog.dart';
import 'package:stillnote/models/code_view_language.dart';
import 'package:stillnote/models/safe_timer.dart';
import 'package:stillnote/screens/note/cubit/note_cubit.dart';
import 'package:stillnote/screens/note/note_sections/note_section.dart';
import 'package:stillnote/screens/note/note_sections/note_section_type.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/code_view_editor.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class CodeViewBoxSection extends NoteSection {
  late CodeController _controller;
  CodeViewLanguage lang;
  final SafeTimer _timer = SafeTimer(const Duration(seconds: 1));
  CodeViewBoxSection({
    required super.id,
    required super.noteId,
    String initialCode = "",
    required this.lang,
  }) : super(type: NoteSectionType.codeViewBox) {
    _controller = _buildController(initialCode);
  }

  CodeController _buildController(String initialCode) {
    return CodeController(
      language: lang.mode,
      text: initialCode,
      params: const EditorParams(),
      modifiers: const [
        IndentModifier(),
        TabModifier(),
        CloseBlockModifier(),
      ],
    );
  }

  factory CodeViewBoxSection.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document, String noteId) {
    final data = document.data()!;
    return CodeViewBoxSection(
      id: document.id,
      noteId: noteId,
      initialCode: data['code'],
      lang:
          CodeViewLanguage.values.firstWhere((e) => e.langCode == data['lang']),
    );
  }

  String get code => _controller.text;

  @override
  Widget widget(BuildContext context, bool isEditable) {
    return CodeViewEditor(
      initialCode: code,
      language: lang,
      editable: isEditable,
      controller: _controller,
      onChanged: (value) {
        _timer.run(() async {
          await FirebaseFirestore.instance
              .collection("notes")
              .doc(noteId)
              .collection("sections")
              .doc(id)
              .update({'code': code});
          // ignore: use_build_context_synchronously
          context.read<NoteCubit>().onNoteModified();
        });
      },
    );
  }

  @override
  Map<String, dynamic> get json {
    return {'type': type.name, 'code': code, 'lang': lang.name};
  }

  @override
  void update(Map<String, dynamic> data) {
    lang = CodeViewLanguage.values.firstWhere((e) => e.name == data['lang']);
    _controller = _buildController(code);
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
            Text("Copy Code"),
          ],
        ),
        onTap: () {
          XFuns.copyText(code);
          XFuns.showSnackbar(context, 'Code copied!');
        },
      ),
      if (state is NoteEditorState)
        PopupMenuItem(
          child: const Row(
            children: [
              SvgIcon(XIcons.code),
              SizedBox(width: 10),
              Text("Change Language"),
            ],
          ),
          onTap: () => getCodeViewLanguageSelector(context),
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
          onTap: () {
            context.read<NoteCubit>().deleteNoteSection(state, this);
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

  @override
  void initialAction(BuildContext context) =>
      getCodeViewLanguageSelector(context);

  Future<void> getCodeViewLanguageSelector(BuildContext context) async {
    CodeViewLanguage? result = await showDialog(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        return ChooseCodeViewLanguageDialog(
          close: (CodeViewLanguage? codeViewLanguage) =>
              Navigator.pop(dialogContext, codeViewLanguage),
        );
      },
    );
    if (result != null) {
      await FirebaseFirestore.instance
          .collection("notes")
          .doc(noteId)
          .collection("sections")
          .doc(id)
          .update({'lang': result.langCode});
      // ignore: use_build_context_synchronously
      context.read<NoteCubit>().onNoteModified();
      XFuns.showSnackbar(
        // ignore: use_build_context_synchronously
        context, 'Code language changed to ${result.title}',
      );
      // ignore: use_build_context_synchronously
      context.read<NoteCubit>().setAccess();
    }
  }
}
