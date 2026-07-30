import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_provider.dart';
import '../models/story_model.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';

class TtsAudioBar extends StatelessWidget {
  final StoryModel story;

  const TtsAudioBar({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    final tts = Provider.of<TtsProvider>(context);
    final loc = AppLocalizations.of(context);

    final isThisPlaying = tts.isPlaying(story.id);
    final isThisPaused = tts.isPaused(story.id);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1338).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Play/Pause Button ─────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  if (isThisPlaying) {
                    tts.pause();
                  } else {
                    tts.playStory(
                      storyId: story.id,
                      content: story.content,
                      language: story.language,
                    );
                  }
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Icon(
                    isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ── Details & Slider ──────────────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isThisPlaying
                          ? loc.get('pauseStory')
                          : isThisPaused
                              ? 'Duraklatıldı'
                              : loc.get('listenStory'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${loc.get('speechSpeed')}: ${(tts.speechRate * 2).toStringAsFixed(1)}x',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                              activeTrackColor: AppTheme.gold,
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                              thumbColor: AppTheme.gold,
                            ),
                            child: Slider(
                              value: tts.speechRate,
                              min: 0.25,
                              max: 0.75,
                              onChanged: (val) => tts.setRate(val),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Stop Button ───────────────────────────────────────────────
              if (isThisPlaying || isThisPaused)
                IconButton(
                  onPressed: () => tts.stop(),
                  icon: const Icon(Icons.stop_circle_rounded, color: Colors.white70, size: 28),
                  tooltip: loc.get('stopStory'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
