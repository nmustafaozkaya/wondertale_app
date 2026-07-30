import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/story_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../widgets/option_chip.dart';
import 'generation_screen.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();

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
    final isTr = appState.language == 'tr';
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
                  expandedHeight: 72,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                          child: const Text(
                            'Wondertale',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Language Toggle
                        GestureDetector(
                          onTap: () {
                            final newLang = appState.language == 'tr' ? 'en' : 'tr';
                            appState.setLanguage(newLang);
                            storyProv.setStoryLanguage(newLang);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            child: Text(
                              appState.language == 'tr' ? '🇹🇷 TR' : '🇬🇧 EN',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      _AgeSelector(storyProv: storyProv, isTr: isTr),
                      const SizedBox(height: 28),

                      // ── Section: Theme ────────────────────────────────────
                      _SectionHeader(emoji: '🎨', title: loc.get('selectTheme')),
                      const SizedBox(height: 14),
                      Wrap(
                        children: AppConstants.themes.map((t) {
                          // if customPrompt is active, don't show any theme as selected
                          final isSelected = storyProv.customPrompt.isEmpty && storyProv.selectedTheme == t['id'];
                          return OptionChip(
                            label: isTr ? t['labelTr']! : t['labelEn']!,
                            subtitle: isTr ? t['descTr']! : t['descEn']!,
                            icon: t['icon'],
                            isSelected: isSelected,
                            onTap: () {
                              _customPromptController.clear();
                              storyProv.setTheme(t['id']!);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Custom Topic Input
                      TextField(
                        controller: _customPromptController,
                        maxLength: 100,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                        onChanged: storyProv.setCustomPrompt,
                        decoration: InputDecoration(
                          hintText: isTr ? 'Veya kendi konunu yaz... (Örn: Mars\'a giden mor bir dinozor)' : 'Or write your own topic...',
                          counterStyle: const TextStyle(color: AppTheme.textSecondary),
                          prefixIcon: const Icon(Icons.edit_rounded, color: AppTheme.violet),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Section: Mood ─────────────────────────────────────
                      _SectionHeader(emoji: '🌈', title: loc.get('selectMood')),
                      const SizedBox(height: 14),
                      Wrap(
                        children: AppConstants.moods.map((m) {
                          final isSelected = storyProv.selectedMood == m['id'];
                          return OptionChip(
                            label: isTr ? m['labelTr']! : m['labelEn']!,
                            subtitle: isTr ? m['descTr']! : m['descEn']!,
                            icon: m['icon'],
                            isSelected: isSelected,
                            onTap: () => storyProv.setMood(m['id']!),
                          );
                        }).toList(),
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

                          if (!appState.isPremium && appState.adService.isInterstitialAdLoaded) {
                            appState.adService.showInterstitialAd(
                              onAdClosed: navigate,
                            );
                          } else {
                            navigate();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
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
                  color: Colors.white,
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
      decoration: BoxDecoration(
        color: const Color(0xFF0F1338),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                if (!appState.isPremium)
                  Text(
                    '3 ücretsiz masal / gün',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
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
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
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

// ── Age Selector ──────────────────────────────────────────────────────────────
class _AgeSelector extends StatelessWidget {
  final StoryProvider storyProv;
  final bool isTr;
  const _AgeSelector({required this.storyProv, required this.isTr});

  @override
  Widget build(BuildContext context) {
    final ages = [
      {'id': '2-4', 'emoji': '🍼', 'label': isTr ? '2-4 Yaş' : '2-4 Years'},
      {'id': '5-7', 'emoji': '🎒', 'label': isTr ? '5-7 Yaş' : '5-7 Years'},
      {'id': '8-10', 'emoji': '📚', 'label': isTr ? '8-10 Yaş' : '8-10 Years'},
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
                color: selected ? null : const Color(0xFF0F1338),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.1),
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
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? Colors.white : Colors.white60,
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
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                  color: widget.canGenerate ? Colors.white : Colors.white38,
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
