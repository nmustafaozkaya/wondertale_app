import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/story_provider.dart';
import '../core/theme/app_theme.dart';

import 'subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final storyProv = Provider.of<StoryProvider>(context);
    final isTr = appState.language == 'tr';
    
    final email = appState.user?.email ?? 'Ziyaretçi';
    final name = email.split('@').first;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            pinned: true,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Text(
                'Profil',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Avatar & User Info
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.glassCard(
                      bgColor: AppTheme.bgCard,
                      borderColor: AppTheme.violet.withValues(alpha: 0.1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Premium Card (Ödeme Yeri)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.glassCard(
                        bgColor: appState.isPremium ? AppTheme.bgCard : AppTheme.gold.withValues(alpha: 0.1),
                        borderColor: AppTheme.gold,
                        radius: 28,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
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
                            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.isPremium ? 'Premium Aktif' : 'Wondertale Premium',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appState.isPremium 
                                    ? 'Sınırsız masalların tadını çıkarıyorsunuz.' 
                                    : 'Sınırsız masal oluşturmak için Premium\'a geç!',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                if (!appState.isPremium) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text(
                                        'Hemen İncele',
                                        style: TextStyle(
                                          color: AppTheme.gold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, color: AppTheme.gold, size: 16),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Settings Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ayarlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Language Toggle
                  Container(
                    decoration: AppTheme.glassCard(
                      bgColor: AppTheme.bgCard,
                      borderColor: AppTheme.violet.withValues(alpha: 0.1),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.violet.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.language_rounded, color: AppTheme.violet),
                      ),
                      title: const Text('Dil / Language', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                      subtitle: Text(isTr ? 'Türkçe' : 'English', style: const TextStyle(color: AppTheme.textSecondary)),
                      trailing: Switch(
                        value: isTr,
                        activeTrackColor: AppTheme.violet.withValues(alpha: 0.5),
                        activeThumbColor: AppTheme.violet,
                        onChanged: (val) {
                          final newLang = val ? 'tr' : 'en';
                          appState.setLanguage(newLang);
                          storyProv.setStoryLanguage(newLang);
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sign Out
                  Container(
                    decoration: AppTheme.glassCard(
                      bgColor: AppTheme.bgCard,
                      borderColor: Colors.redAccent.withValues(alpha: 0.1),
                    ),
                    child: ListTile(
                      onTap: () {
                        appState.signOut();
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      ),
                      title: const Text('Çıkış Yap', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
