import 'package:flutter/material.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_widgets.dart';

class CreateNotebookDialog extends StatefulWidget {
  final void Function(String? notebookId) close;
  const CreateNotebookDialog({
    super.key,
    required this.close,
  });

  @override
  State<CreateNotebookDialog> createState() => _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends State<CreateNotebookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool isPrivate = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.1),
      insetPadding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
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
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              offset: const Offset(3, 2),
            ),
          ],
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
                'Create Notebook',
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
          const SizedBox(height: 10),
          XWidgets.switchListTile(
            colorScheme: colorScheme,
            value: isPrivate,
            text: 'Private Notebook',
            onChanged: (value) {
              setState(() => isPrivate = value);
            },
          ),
          const SizedBox(height: 20),
          XWidgets.textBtn(
            colorScheme: colorScheme,
            text: 'Create',
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
        final result = await Notebook.createNewNotebook(
          title: _titleCtrl.text,
          description: _descCtrl.text,
          private: isPrivate,
        );
        if (result == null) {
          // ignore: use_build_context_synchronously
          XFuns.showSnackbar(context, 'Failed to create notebook');
          widget.close(null);
        } else {
          widget.close(result.id);
        }
        return;
      }
    }
  }
}
