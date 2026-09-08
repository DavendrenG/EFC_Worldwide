import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Plays a VOD item. Premium items show an upgrade gate instead of the
/// player until entitlements are wired up in phase two.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.video});

  final VideoItem video;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _initialising = false;
  String? _error;

  bool get _locked => widget.video.isPremium;

  @override
  void initState() {
    super.initState();
    if (!_locked) _prepare();
  }

  Future<void> _prepare() async {
    final url = widget.video.streamUrl;
    if (url == null || url.isEmpty) {
      setState(() => _error = 'No stream is attached to this item yet.');
      return;
    }
    setState(() => _initialising = true);
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _controller = c;
        _initialising = false;
      });
      await c.play();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initialising = false;
        _error = 'This video could not be played.';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _stage() {
    if (_locked) {
      return Container(
        height: 210,
        color: Colors.black,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline,
                  color: EfcColors.brass, size: 26),
              const SizedBox(height: 10),
              Text(
                'PREMIUM',
                style: EfcText.display(size: 18, color: EfcColors.brass),
              ),
              const SizedBox(height: 6),
              Text(
                'Full fights and the historic archive are part of the '
                'premium tier.',
                textAlign: TextAlign.center,
                style: EfcText.body(size: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_initialising) {
      return const SizedBox(height: 210, child: LoadingState());
    }

    if (_error != null) {
      return SizedBox(
        height: 210,
        child: ErrorState(message: _error!, onRetry: _prepare),
      );
    }

    final c = _controller;
    if (c == null) {
      return const SizedBox(height: 210, child: LoadingState());
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
          child: VideoPlayer(c),
        ),
        VideoProgressIndicator(
          c,
          allowScrubbing: true,
          colors: const VideoProgressColors(
            playedColor: EfcColors.blood,
            bufferedColor: EfcColors.line,
            backgroundColor: EfcColors.steel,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                c.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: EfcColors.bone,
              ),
              onPressed: () => _togglePlayback(c),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _togglePlayback(VideoPlayerController c) async {
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    return Scaffold(
      appBar: AppBar(title: Text(v.kind.label.toUpperCase())),
      body: ListView(
        children: [
          _stage(),
          Padding(
            padding: const EdgeInsets.all(EfcSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Pill(
                      v.tierLabel,
                      variant:
                          v.isPremium ? PillVariant.brass : PillVariant.free,
                    ),
                    const SizedBox(width: 8),
                    UtilityLabel(v.durationLabel, size: 10),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  v.title.toUpperCase(),
                  style: EfcText.display(size: 24, height: 1.0),
                ),
                if (v.eventName != null) ...[
                  const SizedBox(height: 8),
                  UtilityLabel(v.eventName!, size: 10.5, letterSpacing: 1.2),
                ],
                if (_locked) ...[
                  const SizedBox(height: 18),
                  EfcButton(
                    label: 'See premium options',
                    onPressed: () => ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        backgroundColor: EfcColors.steel,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Subscriptions are scoped for phase two.',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
