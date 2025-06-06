import 'package:flutter/material.dart';
import 'package:stillnote/utils/x_widgets.dart';

class YtVideoUrlGetDialog extends StatefulWidget {
  final void Function(String? url) close;
  const YtVideoUrlGetDialog({super.key, required this.close});

  @override
  State<YtVideoUrlGetDialog> createState() => _YtVideoUrlGetDialogState();
}

class _YtVideoUrlGetDialogState extends State<YtVideoUrlGetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  bool loading = false;
  bool isValidated = false;

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
          border: Border.fromBorderSide(
            BorderSide(width: 0.3, color: colorScheme.secondary),
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
                'Set Video URL',
                textAlign: TextAlign.center,
                maxLines: 2,
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
            controller: _urlCtrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                return null;
              } else {
                return "Invalid URL!";
              }
            },
            autofocus: true,
            decoration:
                getTextFieldDecoration("Paste YouTube video URL here..."),
          ),
          const SizedBox(height: 20),
          XWidgets.textBtn(
            colorScheme: colorScheme,
            loading: loading,
            text: 'Set URL',
            onPressed: () => onSubmit(context),
          )
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
    setState(() {
      loading = true;
    });
    if (_formKey.currentState?.validate() ?? false) {
      widget.close(_urlCtrl.text);
      return;
    }
    setState(() {
      loading = false;
    });
  }
}
