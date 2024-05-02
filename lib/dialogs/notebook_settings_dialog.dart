import 'package:flutter/material.dart';
import 'package:stillnote/screens/notebook/cubit/notebook_cubit.dart';
import 'package:stillnote/utils/x_widgets.dart';

class NotebookSettingsDialog extends StatefulWidget {
  final void Function(String? newTitle, String? newDesc) close;
  final NotebookEditorState state;
  const NotebookSettingsDialog({
    super.key,
    required this.close,
    required this.state,
  });

  @override
  State<NotebookSettingsDialog> createState() => _NotebookSettingsDialogState();
}

class _NotebookSettingsDialogState extends State<NotebookSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.state.notebook.title;
    _descCtrl.text = widget.state.notebook.description;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.background.withOpacity(0.1),
      insetPadding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            left: BorderSide(width: 4, color: colorScheme.secondary),
            right: BorderSide(width: 0.3, color: colorScheme.secondary),
            top: BorderSide(width: 0.3, color: colorScheme.secondary),
            bottom: BorderSide(width: 0.3, color: colorScheme.secondary),
          ),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(4),
            right: Radius.circular(10),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.3),
              offset: const Offset(3, 2),
            ),
          ],
        ),
        child: getMainView(context, colorScheme),
      ),
    );
  }

  Widget getMainView(BuildContext context, ColorScheme colorScheme) {
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
                'Notebook Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => widget.close(null, null),
                iconSize: 30,
                color: colorScheme.secondary,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _titleCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Title is required';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            autofocus: true,
            decoration: getTextFieldDecoration("Title"),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Description is required';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.newline,
            minLines: 3,
            maxLines: 10,
            decoration: getTextFieldDecoration("Description"),
          ),
          const SizedBox(height: 20),
          XWidgets.textBtn(
            colorScheme: colorScheme,
            text: 'Apply Changes',
            loading: loading,
            onPressed: () => onSubmit(context),
          ),
        ],
      ),
    );
  }

  InputDecoration getTextFieldDecoration(String labelText) {
    return InputDecoration(
      border: const OutlineInputBorder(),
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
        widget.close(_titleCtrl.text, _descCtrl.text);
        return;
      }
    }
  }
}
