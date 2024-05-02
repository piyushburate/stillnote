import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/utils/x_widgets.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class ImageSelectorDialog extends StatefulWidget {
  final void Function(String? url) close;
  const ImageSelectorDialog({
    super.key,
    required this.close,
  });

  @override
  State<ImageSelectorDialog> createState() => _ImageSelectorDialogState();
}

class _ImageSelectorDialogState extends State<ImageSelectorDialog> {
  final _urlCtrl = TextEditingController();
  ImageProvider? _imageProvider;
  String? imagePath;
  bool isValidated = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Image',
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
          controller: _urlCtrl,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (!isValidated) {
              return "Invalid URL or Error fetching image!";
            }
            return null;
          },
          onChanged: (value) async {
            isValidated = false;
            if (value.isNotEmpty) {
              final response = await http.head(Uri.parse(value));
              if (response.statusCode == 200) {
                imagePath = value;
                _imageProvider = NetworkImage(imagePath!);
                isValidated = true;
              }
            }
            setState(() {});
          },
          decoration: getTextFieldDecoration("Paste Image URL Here"),
        ),
        const SizedBox(height: 15),
        const Text("OR", textAlign: TextAlign.center),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          onPressed: () async {
            FilePickerResult? result =
                await FilePicker.platform.pickFiles(type: FileType.image);

            if (result != null) {
              if (kIsWeb) {
                var bytes = result.files.first.bytes;
                if (bytes != null) _imageProvider = MemoryImage(bytes);
              } else {
                var path = result.files.first.path;
                if (path != null) _imageProvider = FileImage(File(path));
              }
              imagePath = null;
              setState(() {});
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary.withOpacity(0.5),
            foregroundColor: colorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
          icon: const SvgIcon(XIcons.image),
          label: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Choose Image"),
          ),
        ),
        (_imageProvider != null)
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(border: Border.all(width: 0.2)),
                height: 200,
                child: Image(image: _imageProvider!),
              )
            : const SizedBox(),
        const SizedBox(height: 40),
        XWidgets.textBtn(
          colorScheme: colorScheme,
          text: 'Select',
          loading: loading,
          onPressed: () => onSubmit(context),
        ),
      ],
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
    setState(() => loading = true);
    if (imagePath != null) {
      if (imagePath!.isNotEmpty) {
        widget.close(imagePath);
        return;
      }
    }
    if (_imageProvider != null) {
      widget.close(null);
      return;
    }
    setState(() => loading = false);
    return;
  }
}
