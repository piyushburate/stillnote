import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/screens/note/cubit/note_cubit.dart';
import 'package:stillnote/screens/note/note_sections/note_section.dart';
import 'package:stillnote/screens/note/note_sections/note_section_type.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';
import 'package:stillnote/widgets/video_player_view.dart';

class VideoBoxSection extends NoteSection {
  String url;
  VideoBoxSection({
    required super.id,
    required super.noteId,
    required this.url,
  }) : super(type: NoteSectionType.videoBox);

  @override
  Widget widget(BuildContext context, bool isEditable) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!url.isNotEmpty) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: VideoPlayerView(url: url),
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
      child: const Text('Video not set!'),
    );
  }

  factory VideoBoxSection.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document, String noteId) {
    final data = document.data()!;
    return VideoBoxSection(id: document.id, noteId: noteId, url: data['url']);
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
            Text("Copy Video URL"),
          ],
        ),
        onTap: () {
          XFuns.copyText(url);
          XFuns.showSnackbar(context, 'Video URL copied successfully!');
        },
      ),
    ];
    if (state is NoteEditorState) {
      itemList.addAll([
        PopupMenuItem(
          onTap: () => getVideoSelector(context),
          child: const Row(
            children: [
              SvgIcon(XIcons.video),
              SizedBox(width: 10),
              Text("Select Video"),
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
            context.read<NoteCubit>().deleteNoteSection(state, this);
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

  @override
  Future<void> deleteResources(NoteEditorState state) async {
    try {
      if (url.isNotEmpty) {
        await FirebaseStorage.instance
            .ref('/notes/$noteId/$id/video.mp4')
            .delete();
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initialAction(BuildContext context) => getVideoSelector(context);

  Future<void> getVideoSelector(BuildContext context) async {
    // String? result = await showDialog(
    //   context: context,
    //   useSafeArea: true,
    //   builder: (dialogContext) {
    //     return ImageSelectorDialog(
    //       uploadFolderPath: '/notes/$noteId/$id/video.mp4',
    //       close: (String? url) => Navigator.pop(dialogContext, url),
    //     );
    //   },
    // );
    // if (result != null && result.isNotEmpty) {
    //   await FirebaseFirestore.instance
    //       .collection("notes")
    //       .doc(noteId)
    //       .collection("sections")
    //       .doc(id)
    //       .update({'url': result});
    //   // ignore: use_build_context_synchronously
    //   await context.read<NoteCubit>().onNoteModified();
    //   // ignore: use_build_context_synchronously
    //   XFuns.showSnackbar(context, 'Video updated successfully!');
    //   // ignore: use_build_context_synchronously
    //   context.read<NoteCubit>().setAccess();
    // }
  }
}
