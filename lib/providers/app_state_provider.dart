import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';
import '../core/services/auth_service.dart';
import '../core/services/ad_service.dart';
import '../core/services/iap_service.dart';

class AppStateProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AdService _adService = AdService();
  final IapService _iapService = IapService();

  User? _user;
  String _language = 'tr'; // Default Turkish
  bool _isDarkTheme = true; // Magical Dark Theme default
  int _dailyQuotaUsed = 0;
  int _bonusQuotaEarned = 0;
  bool _isPremium = false;
  String _todayDateStr = '';

  User? get user => _user;
  String get language => _language;
  bool get isDarkTheme => _isDarkTheme;
  bool get isPremium => _isPremium;
  AdService get adService => _adService;
  IapService get iapService => _iapService;

  int get remainingQuota {
    if (_isPremium) return 999;
    final totalAvailable = AppConstants.freeDailyQuota + _bonusQuotaEarned;
    final left = totalAvailable - _dailyQuotaUsed;
    return left < 0 ? 0 : left;
  }

  bool get canGenerateStory => _isPremium || remainingQuota > 0;

  AppStateProvider() {
    _initProvider();
  }

  Future<void> _initProvider() async {
    _todayDateStr = DateTime.now().toIso8601String().substring(0, 10);
    final prefs = await SharedPreferences.getInstance();

    _language = prefs.getString('language') ?? 'tr';
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? true;

    // Quota tracking from Local Storage
    final savedDate = prefs.getString('quota_date') ?? '';
    if (savedDate == _todayDateStr) {
      _dailyQuotaUsed = prefs.getInt('daily_quota_used') ?? 0;
      _bonusQuotaEarned = prefs.getInt('bonus_quota_earned') ?? 0;
    } else {
      // New day: reset quota
      _dailyQuotaUsed = 0;
      _bonusQuotaEarned = 0;
      await prefs.setString('quota_date', _todayDateStr);
      await prefs.setInt('daily_quota_used', 0);
      await prefs.setInt('bonus_quota_earned', 0);
    }

    _isPremium = prefs.getBool('is_premium') ?? false;

    // Listen to Auth State
    _authService.authStateChanges.listen((newUser) {
      _user = newUser;
      notifyListeners();
    });

    // Initialize Services
    _adService.loadRewardedAd();
    _adService.loadInterstitialAd();
    _iapService.initialize(onPurchaseStatusChanged: (isSubscribed) {
      setPremiumStatus(isSubscribed);
    });

    notifyListeners();
  }

  // Toggle Language
  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  // Toggle Theme
  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }

  // Increment Used Quota after story generation
  Future<void> consumeQuota() async {
    if (_isPremium) return;
    _dailyQuotaUsed++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_quota_used', _dailyQuotaUsed);
    notifyListeners();
  }

  // Add bonus quota after watching rewarded ad
  Future<void> addAdRewardBonus() async {
    _bonusQuotaEarned += AppConstants.adRewardBonus;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bonus_quota_earned', _bonusQuotaEarned);
    notifyListeners();
  }

  // Update Premium Subscription status
  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', status);
    notifyListeners();
  }

  // Auth helper methods
  Future<void> signInAnonymously() async {
    await _authService.signInAnonymously();
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
