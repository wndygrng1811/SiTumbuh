import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerPage extends StatefulWidget {
  final String title;
  final String videoUrl;

  const YoutubePlayerPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    String videoId = _getYoutubeId(widget.videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
        isLive: false,
        forceHD: true,
        disableDragSeek: false,
        enableCaption: false,
        hideControls: false,
        startAt: 0,
      ),
    );
  }

  String _getYoutubeId(String url) {
    String videoId = '';
    if (url.contains('watch?v=')) {
      videoId = url.split('watch?v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      videoId = url.split('youtu.be/')[1].split('?')[0];
    } else if (url.contains('embed/')) {
      videoId = url.split('embed/')[1].split('?')[0];
    } else if (url.contains('shorts/')) {
      videoId = url.split('shorts/')[1].split('?')[0];
    } else {
      videoId = url;
    }
    videoId = videoId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    return videoId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}
