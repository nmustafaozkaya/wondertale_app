import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/story_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../widgets/option_chip.dart';
import '../widgets/language_selector_sheet.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/app_back_button.dart';
import 'generation_screen.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();
  bool _isCustomTopicUnlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storyProv = Provider.of<StoryProvider>(context, listen: false);
      if (storyProv.childName.isNotEmpty) {
        _nameController.text = storyProv.childName;
      }
      if (storyProv.customPrompt.isNotEmpty) {
        _customPromptController.text = storyProv.customPrompt;
        setState(() {
          _isCustomTopicUnlocked = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final storyProv = Provider.of<StoryProvider>(context);
    final loc = AppLocalizations.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Stack(
        children: [
          // Background gradient
          Container(decoration: const BoxDecoration(gradient: AppTheme.bgGradient)),

          // Subtle glow top-right
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.violet.withValues(alpha: 0.18),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // ── App Bar ─────────────────────────────────────────────────
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: false,
                  floating: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  leading: const AppBackButton(),
                  title: ShaderMask(
                    shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                    child: const Text(
                      'Wondertale',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    // Language Selector Button
                    GestureDetector(
                      onTap: () => showLanguageSelectorSheet(context),
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.violet.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.violet.withValues(alpha: 0.08),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              AppConstants.supportedLanguages.firstWhere(
                                (l) => l.code == appState.language,
                                orElse: () => AppConstants.supportedLanguages.first,
                              ).flag,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              appState.language.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textSecondary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Quota Card ───────────────────────────────────────
                      _QuotaCard(appState: appState, loc: loc),
                      const SizedBox(height: 28),

                      // ── Section: Age ──────────────────────────────────────
                      _SectionHeader(emoji: '🎂', title: loc.get('selectAge')),
                      const SizedBox(height: 14),
                      _AgeSelector(storyProv: storyProv, langCode: appState.language),
                      const SizedBox(height: 28),

                      // ── Section: Theme ────────────────────────────────────
                      _SectionHeader(emoji: '🎨', title: loc.get('selectTheme')),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.7,
                        ),
                        itemCount: AppConstants.themes.length,
                        itemBuilder: (context, index) {
                          final t = AppConstants.themes[index];
                          final isSelected = storyProv.customPrompt.isEmpty && storyProv.selectedTheme == t['id'];
                          return OptionChip(
                            label: AppConstants.getThemeLabel(t, appState.language),
                            subtitle: AppConstants.getThemeDesc(t, appState.language),
                            icon: t['icon'],
                            isSelected: isSelected,
                            onTap: () {
                              _customPromptController.clear();
                              storyProv.setTheme(t['id']!);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Custom Topic Input (Locked behind Video Ad if Non-Premium)
                      if (!appState.isPremium && !_isCustomTopicUnlocked)
                        GestureDetector(
                          onTap: () {
                            appState.adService.showRewardedAd(
                              onUserEarnedReward: () {
                                appState.addAdRewardBonus();
                                setState(() {
                                  _isCustomTopicUnlocked = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('🎉 Özel Konu Yazma Kilidi Açıldı!'),
                                    backgroundColor: AppTheme.teal,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              onAdNotReady: (msg) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(msg),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.gold.withValues(alpha: 0.1),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gold.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.lock_rounded, color: AppTheme.gold, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Kendi Konunu Yaz',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Video izleyerek özel konu yazma hakkını aç',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.goldGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '🎬 Video İzle & Aç',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        TextField(
                          controller: _customPromptController,
                          maxLength: 100,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                          onChanged: storyProv.setCustomPrompt,
                          decoration: InputDecoration(
                            hintText: _customPromptHint(appState.language),
                            counterStyle: const TextStyle(color: AppTheme.textSecondary),
                            prefixIcon: const Icon(Icons.edit_rounded, color: AppTheme.violet),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.teal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: AppTheme.teal, size: 14),
                                  SizedBox(width: 4),
                                  Text('Açık', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.teal)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),

                      // ── Section: Mood ─────────────────────────────────────
                      _SectionHeader(emoji: '🌈', title: loc.get('selectMood')),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.7,
                        ),
                        itemCount: AppConstants.moods.length,
                        itemBuilder: (context, index) {
                          final m = AppConstants.moods[index];
                          final isSelected = storyProv.selectedMood == m['id'];
                          return OptionChip(
                            label: AppConstants.getMoodLabel(m, appState.language),
                            subtitle: AppConstants.getMoodDesc(m, appState.language),
                            icon: m['icon'],
                            isSelected: isSelected,
                            onTap: () => storyProv.setMood(m['id']!),
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Child Name ────────────────────────────────────────
                      _SectionHeader(emoji: '👑', title: loc.get('childNameOptional')),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _nameController,
                        maxLength: 30,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                        onChanged: storyProv.setChildName,
                        decoration: InputDecoration(
                          hintText: loc.get('childNameHint'),
                          counterStyle: const TextStyle(color: AppTheme.textSecondary),
                          prefixIcon: const Icon(Icons.face_rounded, color: AppTheme.gold),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Generate Button ───────────────────────────────────
                      _GenerateButton(
                        canGenerate: appState.canGenerateStory,
                        loc: loc,
                        onTap: () {
                          if (!appState.canGenerateStory) {
                            _showLimitDialog(context, appState, loc);
                            return;
                          }
                          storyProv.setStoryLanguage(appState.language);
                          
                          void navigate() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GenerationScreen()),
                            );
                          }

                          // Play Rewarded or Interstitial Ad for non-premium users on generation
                          if (!appState.isPremium) {
                            if (appState.adService.isRewardedAdLoaded) {
                              appState.adService.showRewardedAd(
                                onUserEarnedReward: () {
                                  appState.addAdRewardBonus();
                                  navigate();
                                },
                              );
                            } else {
                              appState.adService.showInterstitialAd(
                                onAdClosed: navigate,
                              );
                            }
                          } else {
                            navigate();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      const BannerAdWidget(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLimitDialog(BuildContext context, AppStateProvider appState, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.glassCard(
            borderColor: AppTheme.gold.withValues(alpha: 0.3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                loc.get('dailyLimitReached'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                loc.get('dailyLimitDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Kapat', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        appState.adService.showRewardedAd(
                          onUserEarnedReward: () => appState.addAdRewardBonus(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          loc.get('watchAdForBonus'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quota Card ────────────────────────────────────────────────────────────────
class _QuotaCard extends StatelessWidget {
  final AppStateProvider appState;
  final AppLocalizations loc;
  const _QuotaCard({required this.appState, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: AppTheme.glassCard(
        bgColor: AppTheme.bgCard,
        borderColor: AppTheme.gold.withValues(alpha: 0.3),
        radius: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.isPremium
                      ? loc.get('unlimitedAccess')
                      : '${loc.get('quotaLeft')}${appState.remainingQuota}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (!appState.isPremium)
                  Text(
                    loc.get('dailyQuotaSub'),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
          if (!appState.isPremium)
            GestureDetector(
              onTap: () {
                appState.adService.showRewardedAd(
                  onUserEarnedReward: () {
                    appState.addAdRewardBonus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🎉 +1 Masal Hakkı Eklendi!'),
                        backgroundColor: AppTheme.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '+ İzle',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  const _SectionHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.violet.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _customPromptHint(String lang) {
  switch (lang) {
    case 'de':
      return 'Oder schreibe dein eigenes Thema...';
    case 'ar':
      return 'أو اكتب موضوعك الخاص...';
    case 'en':
      return 'Or write your own topic...';
    case 'tr':
    default:
      return 'Veya kendi konunu yaz... (Örn: Mars\'a giden mor bir dinozor)';
  }
}

// ── Age Selector ──────────────────────────────────────────────────────────────
class _AgeSelector extends StatelessWidget {
  final StoryProvider storyProv;
  final String langCode;
  const _AgeSelector({required this.storyProv, required this.langCode});

  String _ageLabel(String ageId, String lang) {
    switch (lang) {
      case 'de':
        return '$ageId Jahre';
      case 'ar':
        return '$ageId سنوات';
      case 'en':
        return '$ageId Years';
      case 'tr':
      default:
        return '$ageId Yaş';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ages = [
      {'id': '2-4', 'emoji': '🍼', 'label': _ageLabel('2-4', langCode)},
      {'id': '5-7', 'emoji': '🎒', 'label': _ageLabel('5-7', langCode)},
      {'id': '8-10', 'emoji': '📚', 'label': _ageLabel('8-10', langCode)},
    ];

    return Row(
      children: ages.map((a) {
        final selected = storyProv.selectedAge == a['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => storyProv.setAge(a['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: selected ? AppTheme.primaryGradient : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppTheme.violet.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.violet.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Text(a['emoji']!, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 6),
                  Text(
                    a['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Generate Button ───────────────────────────────────────────────────────────
class _GenerateButton extends StatefulWidget {
  final bool canGenerate;
  final VoidCallback onTap;
  final AppLocalizations loc;
  const _GenerateButton({required this.canGenerate, required this.onTap, required this.loc});

  @override
  State<_GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<_GenerateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(scale: _ctrl.value, child: child),
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: widget.canGenerate
              ? AppTheme.glowButton(radius: 20)
              : BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.violet.withValues(alpha: 0.2)),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.canGenerate)
                const Text('✨', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                widget.canGenerate
                    ? widget.loc.get('generateButton')
                    : '🔒  ${widget.loc.get('generateButton')}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: widget.canGenerate ? Colors.white : AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
