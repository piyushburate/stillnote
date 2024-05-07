import 'package:flutter/material.dart';
import 'package:stillnote/models/note.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_widgets.dart';

class CreateNoteDialog extends StatefulWidget {
  final Notebook notebook;
  final void Function(Note? noteId) close;
  const CreateNoteDialog({
    super.key,
    required this.close,
    required this.notebook,
  });

  @override
  State<CreateNoteDialog> createState() => _CreateNoteDialogState();
}

class _CreateNoteDialogState extends State<CreateNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  bool isPrivate = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    isPrivate = widget.notebook.private;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colorScheme.background.withOpacity(0.1),
      insetPadding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            left: BorderSide(width: 2, color: colorScheme.secondary),
            right: BorderSide(width: 0.3, color: colorScheme.secondary),
            top: BorderSide(width: 0.3, color: colorScheme.secondary),
            bottom: BorderSide(width: 0.3, color: colorScheme.secondary),
          ),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(4),
            right: Radius.circular(10),
          ),
        ),
        child: getCreateForm(colorScheme),
      ),
    );
  }

  Widget getCreateForm(ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Create Note',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => widget.close(null),
                iconSize: 30,
                color: colorScheme.secondary,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _titleCtrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                return null;
              } else {
                return "Title is required";
              }
            },
            autofocus: true,
            decoration: getTextFieldDecoration("Title"),
          ),
          const SizedBox(height: 20),
          XWidgets.switchListTile(
            colorScheme: colorScheme,
            value: isPrivate,
            text: 'Private Note',
            onChanged: (value) {
              setState(() => isPrivate = value);
            },
          ),
          const SizedBox(height: 20),
          XWidgets.textBtn(
            colorScheme: colorScheme,
            text: 'Create',
            onPressed: () => onSubmit(context),
            loading: loading,
          ),
        ],
      ),
    );
  }

  InputDecoration getTextFieldDecoration(String labelText) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      hintText: labelText,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    );
  }

  Future<void> onSubmit(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!loading) {
        setState(() {
          loading = true;
        });
        final result = await Note.createNewNote(
          title: _titleCtrl.text,
          private: isPrivate,
          notebookID: widget.notebook.id,
        );
        if (result == null) {
          // ignore: use_build_context_synchronously
          XFuns.showSnackbar(context, 'Failed to create note');
          widget.close(null);
        } else {
          widget.close(result);
        }
        return;
      }
    }
  }
}
