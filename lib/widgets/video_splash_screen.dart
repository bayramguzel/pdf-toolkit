import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';

class VideoSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const VideoSplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  Timer? _autoSkipTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    // Auto-skip after 2 seconds
    _autoSkipTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/splash.mp4');
      await _controller.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      // Start playing
      await _controller.setLooping(false);
      await _controller.play();

      // Listen for video completion
      _controller.addListener(() {
        if (_controller.value.isInitialized &&
            _controller.value.position >= _controller.value.duration) {
          widget.onComplete();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        // Skip to main app if video fails
        widget.onComplete();
      }
    }
  }

  @override
  void dispose() {
    _autoSkipTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || !_isInitialized) {
      return Container(color: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          // Skip button in the top right corner
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: TextButton(
              onPressed: () {
                _autoSkipTimer?.cancel();
                widget.onComplete();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)?.skip ?? 'Skip',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
