import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/dialogs/image_selector_dialog.dart';
import 'package:stillnote/screens/note/cubit/note_cubit.dart';
import 'package:stillnote/screens/note/note_sections/note_section.dart';
import 'package:stillnote/screens/note/note_sections/note_section_type.dart';
import 'package:stillnote/utils/x_constants.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class ImageBoxSection extends NoteSection {
  String url;
  ImageBoxSection({
    required super.id,
    required super.noteId,
    required this.url,
  }) : super(type: NoteSectionType.imageBox);

  Future<bool> getImageSelector(BuildContext context) async {
    String? result = await showDialog(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        return ImageSelectorDialog(
          close: (String? url) => Navigator.pop(dialogContext, url),
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("notes")
          .doc(noteId)
          .collection("sections")
          .doc(id)
          .update({'url': result});
      // ignore: use_build_context_synchronously
      await context.read<NoteCubit>().onNoteModified();
      return true;
    }
    return false;
  }

  @override
  Widget widget(BuildContext context, bool isEditable) {
    final colorScheme = Theme.of(context).colorScheme;

    if (url.isNotEmpty) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image(
            image: NetworkImage(url),
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(XConsts.onErrorImageAsset);
            },
          ),
        ),
      );
    }
    return Container(
      height: 300,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.secondary.withOpacity(0.5),
      ),
      child: const Text('Image not set!'),
    );
  }

  factory ImageBoxSection.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document, String noteId) {
    final data = document.data()!;
    return ImageBoxSection(id: document.id, noteId: noteId, url: data['url']);
  }

  @override
  Map<String, dynamic> get json {
    return {'type': type.name, 'url': url};
  }

  @override
  void update(Map<String, dynamic> data) {
    url = data['url'];
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
            Text("Copy Image URL"),
          ],
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: url));
          XFuns.showSnackbar(context, 'Image URL copied successfully!');
        },
      ),
    ];
    if (state is NoteEditorState) {
      itemList.addAll([
        PopupMenuItem(
          onTap: () {
            imageSelector(context);
          },
          child: const Row(
            children: [
              SvgIcon(XIcons.image),
              SizedBox(width: 10),
              Text("Select Image"),
            ],
          ),
        ),
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
      ]);
    }
    return (itemList.isEmpty)
        ? null
        : PopupMenuButton(
            tooltip: "",
            icon: const SvgIcon(XIcons.moreVert),
            surfaceTintColor: colorScheme.surface,
            itemBuilder: (context) => itemList,
          );
  }

  Future<void> imageSelector(BuildContext context) async {
    await getImageSelector(context).then((value) {
      if (value) {
        XFuns.showSnackbar(context, 'Image updated successfully!');
        context.read<NoteCubit>().setAccess();
      }
    });
  }

  @override
  void initialAction(BuildContext context) => imageSelector(context);
}
