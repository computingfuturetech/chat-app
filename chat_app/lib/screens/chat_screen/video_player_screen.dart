import 'package:chat_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: _controller.value.isPlaying
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(
                            _controller,
                          ),
                        ),
                        VideoProgressIndicator(_controller,
                            allowScrubbing: true,
                            padding: const EdgeInsets.all(0),
                            colors: VideoProgressColors(
                              playedColor: primartColor,
                              bufferedColor: Colors.white.withOpacity(0.5),
                              backgroundColor: Colors.white.withOpacity(0.2),
                            ))
                      ],
                    )
                  : Container(),
            ),
            _controller.value.isPlaying
                ? Container()
                : Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: 0,
                    child: ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 50,
                              ),
                            ),
                          ),
                        ]),
                  ),
          ],
        ),
      ),
    );
  }
}
