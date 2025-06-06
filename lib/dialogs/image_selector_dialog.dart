import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/utils/x_widgets.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class ImageSelectorDialog extends StatefulWidget {
  final void Function(String? url) close;
  final String uploadFolderPath;
  const ImageSelectorDialog({
    super.key,
    required this.close,
    required this.uploadFolderPath,
  });

  @override
  State<ImageSelectorDialog> createState() => _ImageSelectorDialogState();
}

class _ImageSelectorDialogState extends State<ImageSelectorDialog> {
  final _urlCtrl = TextEditingController();
  ImageProvider? imageProvider;
  String? imagePath;
  XFile? selectedFile;
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
      backgroundColor: colorScheme.surface.withValues(alpha: 0.1),
      insetPadding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(width: 0.3, color: colorScheme.secondary),
          borderRadius: BorderRadius.circular(10),
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
              return "Invalid URL or Error while fetching image!";
            }
            return null;
          },
          onChanged: (value) async {
            isValidated = false;
            if (value.isNotEmpty) {
              final response = await http.head(Uri.parse(value));
              if (response.statusCode == 200) {
                imagePath = value;
                imageProvider = NetworkImage(imagePath!);
                selectedFile = XFile(value);
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
                if (bytes != null) {
                  imageProvider = MemoryImage(bytes);
                  selectedFile = result.files.first.xFile;
                }
              } else {
                var path = result.files.first.path;
                if (path != null) {
                  imageProvider = FileImage(File(path));
                  selectedFile = result.files.first.xFile;
                }
              }
              imagePath = null;
              setState(() {});
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary.withValues(alpha: 0.5),
            foregroundColor: colorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
          icon: const SvgIcon(XIcons.image, invert: true),
          label: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Choose Image",
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ),
        (imageProvider != null)
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(border: Border.all(width: 0.2)),
                height: 200,
                child: Image(image: imageProvider!),
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
    if (selectedFile != null) {
      try {
        var firestorage = FirebaseStorage.instance;
        var ref = firestorage.ref(widget.uploadFolderPath);
        await ref.putData(await selectedFile!.readAsBytes());
        // ignore: use_build_context_synchronously
        XFuns.showSnackbar(context, 'Image Uploaded!');
        final url = await ref.getDownloadURL();
        widget.close(url);
        return;
      } catch (e) {
        // ignore: use_build_context_synchronously
        XFuns.showSnackbar(context, 'Error uploading image');
        widget.close(null);
      }
    }
    setState(() => loading = false);
    return;
  }
}
