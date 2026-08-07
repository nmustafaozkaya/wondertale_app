import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../core/theme/app_theme.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/app_localizations.dart';
import '../widgets/language_selector_sheet.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final loc = AppLocalizations.of(context);
    final name = appState.userName;
    final email = appState.user?.email ?? loc.get('guestUser');

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Text(
                loc.get('profile'),
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
                            image: appState.userPhotoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(appState.userPhotoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: appState.userPhotoUrl == null
                              ? const Icon(Icons.person_rounded, color: Colors.white, size: 36)
                              : null,
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
                  
                  // Language Tile
                  Builder(
                    builder: (ctx) {
                      final currentLang = AppConstants.supportedLanguages.firstWhere(
                        (l) => l.code == appState.language,
                        orElse: () => AppConstants.supportedLanguages.first,
                      );

                      return Container(
                        decoration: AppTheme.glassCard(
                          bgColor: AppTheme.bgCard,
                          borderColor: AppTheme.violet.withValues(alpha: 0.1),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            onTap: () => showLanguageSelectorSheet(ctx),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.violet.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.language_rounded, color: AppTheme.violet),
                            ),
                            title: Text(loc.get('appLanguage'), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                            subtitle: Text('${currentLang.flag} ${currentLang.name}', style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 16),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sign Out
                  Container(
                    decoration: AppTheme.glassCard(
                      bgColor: AppTheme.bgCard,
                      borderColor: Colors.redAccent.withValues(alpha: 0.1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      clipBehavior: Clip.antiAlias,
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
                        title: Text(loc.get('signOut'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                      ),
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
