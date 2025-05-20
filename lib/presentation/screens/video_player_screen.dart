import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/recording.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Recording recording;

  const VideoPlayerScreen({Key? key, required this.recording})
    : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(
      await _getFileFromPath(widget.recording.filePath),
    );

    await _controller.initialize();

    _controller.addListener(() {
      if (_controller.value.isInitialized) {
        setState(() {
          _position = _controller.value.position;
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });

    setState(() {
      _isInitialized = true;
      _duration = _controller.value.duration;
    });

    // Auto-play when ready
    _controller.play();
  }

  Future<dynamic> _getFileFromPath(String filePath) async {
    // This will vary based on platform implementation
    // For now, using a placeholder that will be replaced with actual file
    return filePath;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconTheme.of(context).copyWith(color: Colors.white),
        title: Text(
          widget.recording.fileName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child:
            _isInitialized
                ? Column(
                  children: [
                    // Video display
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),

                    // Video controls
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black,
                      child: Column(
                        children: [
                          // Progress slider
                          Slider(
                            value: _position.inMilliseconds.toDouble(),
                            min: 0.0,
                            max: _duration.inMilliseconds.toDouble(),
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Colors.grey[700],
                            onChanged: (value) {
                              setState(() {
                                _controller.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              });
                            },
                          ),

                          // Duration indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_position),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  _formatDuration(_duration),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Playback controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                color: Colors.white,
                                iconSize: 32,
                                onPressed: () {
                                  final newPosition =
                                      _position - const Duration(seconds: 10);
                                  _controller.seekTo(
                                    newPosition < Duration.zero
                                        ? Duration.zero
                                        : newPosition,
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: Icon(
                                  _isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                ),
                                color: Colors.white,
                                iconSize: 56,
                                onPressed: () {
                                  setState(() {
                                    if (_isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.forward_10),
                                color: Colors.white,
                                iconSize: 32,
                                onPressed: () {
                                  final newPosition =
                                      _position + const Duration(seconds: 10);
                                  _controller.seekTo(
                                    newPosition > _duration
                                        ? _duration
                                        : newPosition,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
