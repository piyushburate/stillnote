import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final String url;
  const VideoPlayerView({
    super.key,
    required this.url,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late ColorScheme colorScheme;
  late FlickManager flickManager;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      ),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    return FlickVideoPlayer(flickManager: flickManager);
  }

  Widget errorView() {
    return Container(
      height: 300,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.secondary.withValues(alpha: 0.5),
      ),
      child: const Text('Error Playing Video!'),
    );
  }
}
