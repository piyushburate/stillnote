import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/dialogs/ytvideo_url_get_dialog.dart';
import 'package:stillnote/screens/note/cubit/note_cubit.dart';
import 'package:stillnote/screens/note/note_sections/note_section.dart';
import 'package:stillnote/screens/note/note_sections/note_section_type.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YtVideoBoxSection extends NoteSection {
  String url;
  late YoutubePlayerController _controller;
  YtVideoBoxSection({
    required super.id,
    required super.noteId,
    required this.url,
  }) : super(type: NoteSectionType.ytVideoBox);

  @override
  Widget widget(BuildContext context, bool isEditable) {
    final colorScheme = Theme.of(context).colorScheme;
    if (url.isNotEmpty) {
      try {
        _controller = YoutubePlayerController.fromVideoId(
          videoId: YoutubePlayerController.convertUrlToId(url)!,
          params: const YoutubePlayerParams(
            mute: true,
            showFullscreenButton: kIsWeb,
          ),
        );
        return Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: YoutubePlayer(
              gestureRecognizers: const {},
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),
        );
      } catch (e) {
        return Container(
          height: 300,
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colorScheme.secondary.withOpacity(0.5),
          ),
          child: const Text('Error playing YouTube video!'),
        );
      }
    }
    return Container(
      height: 300,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.secondary.withOpacity(0.5),
      ),
      child: const Text('Youtube Video URL not set!'),
    );
  }

  factory YtVideoBoxSection.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document, String noteId) {
    final data = document.data()!;
    return YtVideoBoxSection(id: document.id, noteId: noteId, url: data['url']);
  }

  @override
  Map<String, dynamic> get json {
    return {'type': type.name, 'url': url};
  }

  @override
  void update(Map<String, dynamic> data) {
    url = data['url'];
  }

  Future<bool> getYtVideoUrlGetDialog(BuildContext context) async {
    String? result = await showDialog(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        return YtVideoUrlGetDialog(
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
  Widget? menu(BuildContext context, NoteAccessState state) {
    final colorScheme = Theme.of(context).colorScheme;
    var itemList = <PopupMenuEntry>[
      PopupMenuItem(
        child: const Row(
          children: [
            SvgIcon(XIcons.copy),
            SizedBox(width: 10),
            Text("Copy YT Video URL"),
          ],
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: url));
          XFuns.showSnackbar(context, 'Youtube Video URL copied successfully!');
        },
      ),
    ];
    if (state is NoteEditorState) {
      itemList.addAll([
        PopupMenuItem(
          onTap: () => setYtVideoUrl(context),
          child: const Row(
            children: [
              SvgIcon(XIcons.youtube),
              SizedBox(width: 10),
              Text("Set YT video URL"),
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
            surfaceTintColor: colorScheme.surface,
            icon: const SvgIcon(XIcons.moreVert),
            itemBuilder: (context) => itemList,
          );
  }

  Future<void> setYtVideoUrl(BuildContext context) async {
    await getYtVideoUrlGetDialog(context).then((value) {
      if (value) {
        XFuns.showSnackbar(context, 'URL updated successfully!');
        context.read<NoteCubit>().setAccess();
      }
    });
  }

  @override
  void initialAction(BuildContext context) => setYtVideoUrl(context);
}
