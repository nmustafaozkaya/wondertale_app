import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/story_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../widgets/story_card.dart';
import 'story_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
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
    final storyProv = Provider.of<StoryProvider>(context);
    final loc = AppLocalizations.of(context);
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
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.teal.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.violet.withValues(alpha: 0.15),
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
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    loc.get('myLibrary'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: false,
                ),
                if (stories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(loc),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPad + 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                        childCount: stories.length,
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

  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.violet.withValues(alpha: 0.05),
                border: Border.all(color: AppTheme.violet.withValues(alpha: 0.1)),
              ),
              child: const Text('📚', style: TextStyle(fontSize: 54)),
            ),
            const SizedBox(height: 24),
            Text(
              loc.get('noStoriesYet'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              loc.get('startFirstStory'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
