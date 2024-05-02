import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stillnote/models/note.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_widgets.dart';

class NoteManageAccessDialog extends StatefulWidget {
  final Note note;
  final void Function() close;
  const NoteManageAccessDialog({
    super.key,
    required this.close,
    required this.note,
  });

  @override
  State<NoteManageAccessDialog> createState() => _NoteManageAccessDialogState();
}

class _NoteManageAccessDialogState extends State<NoteManageAccessDialog> {
  final _formKey = GlobalKey<FormState>();
  bool isPrivate = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    isPrivate = widget.note.private;
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
          border: Border.fromBorderSide(
            BorderSide(width: 0.3, color: colorScheme.secondary),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                'Manage Access',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => widget.close(),
                iconSize: 30,
                color: colorScheme.secondary,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 30),
          XWidgets.switchListTile(
            colorScheme: colorScheme,
            value: isPrivate,
            text: 'Private Note',
            onChanged: (value) {
              setState(() => isPrivate = value);
            },
          ),
          const SizedBox(height: 20),
          const Text(
              '*Note: If Turned OFF Anyone can access it using link or by search, else only owner can access it.'),
          const SizedBox(height: 20),
          XWidgets.textBtn(
            colorScheme: colorScheme,
            text: 'Save Changes',
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
        await FirebaseFirestore.instance
            .collection('notes')
            .doc(widget.note.id)
            .update({'private': isPrivate});
        // ignore: use_build_context_synchronously
        XFuns.showSnackbar(context, 'Changes Applied!');
        widget.close();
        return;
      }
    }
  }
}
