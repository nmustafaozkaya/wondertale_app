import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../providers/app_state_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../widgets/tts_audio_bar.dart';
import '../widgets/app_back_button.dart';
import '../widgets/banner_ad_widget.dart';

class StoryDetailScreen extends StatefulWidget {
  final StoryModel story;

  const StoryDetailScreen({
    super.key,
    required this.story,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  double _fontSize = 17.0;
  static int _storyReadCounter = 0;

  void _handleBack(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    if (!appState.isPremium) {
      _storyReadCounter++;
      // Her 2 okumadan birinde geçiş reklamı göster
      if (_storyReadCounter % 2 == 0 && appState.adService.isInterstitialAdLoaded) {
        appState.adService.showInterstitialAd(
          onAdClosed: () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        );
        return;
      }
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  String _getThemeIcon(String themeId) {
    final found = AppConstants.themes.firstWhere(
      (t) => t['id'] == themeId,
      orElse: () => {'icon': '✨'},
    );
    return found['icon'] ?? '✨';
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final themeIcon = _getThemeIcon(story.theme);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgLight,
        body: Stack(
          children: [
            // Background Gradient
            Container(decoration: const BoxDecoration(gradient: AppTheme.bgGradient)),

            CustomScrollView(
              slivers: [
                // ── Image Header ──────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 320.0,
                  pinned: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: AppTheme.bgLight,
                  leading: AppBackButton(onPressed: () => _handleBack(context)),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.format_size_rounded, color: Colors.white, size: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        _fontSize = _fontSize >= 22 ? 15.0 : _fontSize + 2.0;
                      });
                    },
                    tooltip: 'Yazı Boyutu',
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildStoryImageHeader(story, themeIcon),
                      // Gradient overlay to blend with background
                      Positioned(
                        bottom: -1,
                        left: 0,
                        right: 0,
                        height: 120,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, AppTheme.bgLight],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Story Content ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, bottomPad + 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTag('${story.ageGroup} Yaş', AppTheme.gold),
                          _buildTag(story.language.toUpperCase(), AppTheme.teal),
                          if (story.childName.isNotEmpty)
                            _buildTag('👑 ${story.childName}', AppTheme.pink),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 24),
                      Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Story Body
                      Text(
                        story.content,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: 1.85,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const BannerAdWidget(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky TTS Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TtsAudioBar(story: story),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPlaceholderBanner(String icon) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text(
              'Wondertale AI',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryImageHeader(StoryModel story, String themeIcon) {
    if (story.imageBase64 != null && story.imageBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(story.imageBase64!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderBanner(themeIcon),
        );
      } catch (_) {}
    }

    final prompt = 'cute storybook watercolor illustration for children story titled ${story.title}, theme ${story.theme}, bedtime story art style';
    final encodedPrompt = Uri.encodeComponent(prompt);
    final seed = story.id.hashCode.abs();
    final aiImageUrl = 'https://image.pollinations.ai/prompt/$encodedPrompt?width=800&height=600&seed=$seed&nologo=true';

    return Image.network(
      aiImageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildPlaceholderBanner(themeIcon),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '✨ AI Çizimi Hazırlanıyor...',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderBanner(themeIcon);
      },
    );
  }
}
