import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/story_provider.dart';
import '../core/theme/app_theme.dart';

import '../widgets/story_card.dart';
import 'story_detail_screen.dart';
import 'subscription_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onCreateNewPressed;

  const DashboardScreen({super.key, required this.onCreateNewPressed});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final storyProv = Provider.of<StoryProvider>(context, listen: false);
      if (appState.user != null) {
        storyProv.loadUserStories(appState.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final storyProv = Provider.of<StoryProvider>(context);
    final stories = storyProv.savedStories;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Stack(
        children: [
          // Background Gradient
          Container(decoration: const BoxDecoration(gradient: AppTheme.bgGradient)),

          // Ambient Glows
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.violet.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: true,
                  elevation: 0,
                  toolbarHeight: 80,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.purple.withValues(alpha: 0.3),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: const Text('👋', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hoş Geldin!',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            appState.user?.email?.split('@').first ?? 'Kullanıcı',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quota Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: AppTheme.glassCard(
                            bgColor: AppTheme.bgCard,
                            borderColor: AppTheme.gold.withValues(alpha: 0.3),
                            radius: 28,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppTheme.goldGradient,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.gold.withValues(alpha: 0.3),
                                          blurRadius: 12,
                                        )
                                      ],
                                    ),
                                    child: const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appState.isPremium ? 'Sınırsız Sihir (Premium)' : 'Günlük Masal Hakkı',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          appState.isPremium 
                                              ? 'İstediğin kadar masal oluşturabilirsin! ✨' 
                                              : (appState.remainingQuota > 0 
                                                  ? 'Bugün ${appState.remainingQuota} masal daha oluşturabilirsin.' 
                                                  : 'Bugünlük sihrin tükendi!'),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!appState.isPremium) ...[
                                    const SizedBox(width: 16),
                                    Text(
                                      '${appState.remainingQuota}',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.gold,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (!appState.isPremium && appState.remainingQuota == 0) ...[
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          appState.adService.showRewardedAd(
                                            onUserEarnedReward: () {
                                              appState.addAdRewardBonus();
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                                        label: const Text('İzle (+1)', style: TextStyle(fontSize: 13)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.textPrimary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                                        },
                                        icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                                        label: const Text('Premium', style: TextStyle(fontSize: 13)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.gold,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Create Button
                        GestureDetector(
                          onTap: widget.onCreateNewPressed,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.violet.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  'Yeni Masal Oluştur',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Recent Stories Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Son Oluşturulanlar',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (stories.isNotEmpty)
                              Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 16),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Recent Stories List
                if (stories.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.violet.withValues(alpha: 0.05),
                            ),
                            child: const Text('✨', style: TextStyle(fontSize: 40)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz masal oluşturmadınız.\nYeni bir maceraya başlamak için\nyukarıdaki butona tıklayın!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Sadece son 3 masalı göster
                          if (index >= 3) return const SizedBox.shrink();
                          final story = stories[index];
                          return StoryCard(
                            story: story,
                            onTap: () {
                              storyProv.setCurrentStory(story);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoryDetailScreen(story: story),
                                ),
                              );
                            },
                          );
                        },
                        childCount: stories.length > 3 ? 3 : stories.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
