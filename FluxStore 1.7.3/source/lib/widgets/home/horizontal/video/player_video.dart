import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:video_player/video_player.dart';

import 'video_controller.dart';

class PlayerVideo extends StatefulWidget {
  final config;

  PlayerVideo({this.config});

  @override
  _StateVideoLayout createState() => _StateVideoLayout();
}

class _StateVideoLayout extends State<PlayerVideo> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.config["url"])
      ..initialize()
      ..setLooping(true).then((_) {});

    if (widget.config["autoPlay"] == true) _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            _controller.value.initialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(
                    height: MediaQuery.of(context).size.width * 0.5,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: Colors.black),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 40,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    ),
                  ),
            if (widget.config['showControl'] == true)
              VideoController(
                controller: _controller,
              ),
            if (widget.config["autoPlay"] == true)
              VisibilityDetector(
                key: Key("loading_video"),
                child: Container(height: 1),
                onVisibilityChanged: (VisibilityInfo info) {
                  if (info.visibleFraction == 1.0) {
                    _controller.play();
                  } else {
                    _controller.pause();
                  }
                },
              )
          ],
        ),
      ),
    );
  }
}
