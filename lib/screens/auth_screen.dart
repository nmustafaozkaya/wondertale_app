import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../core/constants/app_constants.dart';
import '../widgets/language_selector_sheet.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _floatController;
  late Animation<double> _glowAnim;
  late Animation<double> _floatAnim;

  final List<_Star> _stars = List.generate(
    60,
    (i) => _Star(
      x: math.Random().nextDouble(),
      y: math.Random().nextDouble(),
      size: math.Random().nextDouble() * 2.5 + 0.5,
      opacity: math.Random().nextDouble() * 0.7 + 0.2,
    ),
  );

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _floatAnim = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final currentLang = AppConstants.supportedLanguages.firstWhere(
      (l) => l.code == appState.language,
      orElse: () => AppConstants.supportedLanguages.first,
    );

    return Scaffold(
      body: Stack(
        children: [
          // ── Deep Magical Night Sky Background ─────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B0720), Color(0xFF140D36), Color(0xFF1E114D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Star field ────────────────────────────────────────────────────
          CustomPaint(
            size: size,
            painter: _StarfieldPainter(_stars),
          ),

          // ── Purple glow blobs ─────────────────────────────────────────────
          Positioned(
            top: -80,
            left: -60,
            child: AnimatedBuilder(
              animation: _glowAnim,
              builder: (context, child) => Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.violet.withValues(alpha: _glowAnim.value * 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: AnimatedBuilder(
              animation: _glowAnim,
              builder: (context, child) => Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.pink.withValues(alpha: _glowAnim.value * 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  // ── Top Language Selector ──────────────────────────────────
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () => showLanguageSelectorSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(currentLang.flag, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                currentLang.code.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Logo ──────────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (context, child) => Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.violet.withValues(alpha: _glowAnim.value * 0.7),
                                blurRadius: 50,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: AppTheme.pink.withValues(alpha: _glowAnim.value * 0.35),
                                blurRadius: 80,
                                spreadRadius: 16,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('📖', style: TextStyle(fontSize: 58)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Title with gradient ────────────────────────────────────
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.primaryGradient.createShader(bounds),
                    child: Text(
                      loc.get('appName'),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Tagline ───────────────────────────────────────────────
                  Text(
                    loc.get('appTagline'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Feature Badges ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _badge('🎭', _badge1Label(appState.language)),
                      const SizedBox(width: 10),
                      _badge('🎨', _badge2Label(appState.language)),
                      const SizedBox(width: 10),
                      _badge('🔊', _badge3Label(appState.language)),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ── High-Contrast Google Sign-In Button ───────────────────
                  _ScaleButton(
                    onTap: appState.signInWithGoogle,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('G', style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4285F4),
                              )),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            loc.get('loginGoogle'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── High-Contrast Guest Button ────────────────────────────
                  _ScaleButton(
                    onTap: appState.signInAnonymously,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xFF281C54),
                        border: Border.all(
                          color: AppTheme.violet.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.violet.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            color: AppTheme.purple,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            loc.get('continueGuest'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    loc.get('loginRequired'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _badge1Label(String lang) {
    switch (lang) {
      case 'de': return 'KI-Stories';
      case 'ar': return 'قصص AI';
      case 'en': return 'AI Stories';
      default: return 'AI Masallar';
    }
  }

  String _badge2Label(String lang) {
    switch (lang) {
      case 'de': return 'Illustration';
      case 'ar': return 'رسومات';
      case 'en': return 'Illustration';
      default: return 'İllüstrasyon';
    }
  }

  String _badge3Label(String lang) {
    switch (lang) {
      case 'de': return 'Vorlesen';
      case 'ar': return 'صوتي';
      case 'en': return 'Audio Voice';
      default: return 'Sesli Okuma';
    }
  }

  Widget _badge(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Interactive Scale Button ──────────────────────────────────────────────────
class _ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _ScaleButton({required this.child, required this.onTap});

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
    )..value = 1.0;
    _scale = _ctrl;
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
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ── Star Painter ─────────────────────────────────────────────────────────────
class _Star {
  final double x, y, size, opacity;
  const _Star({required this.x, required this.y, required this.size, required this.opacity});
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  _StarfieldPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        Paint()..color = Colors.white.withValues(alpha: s.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
