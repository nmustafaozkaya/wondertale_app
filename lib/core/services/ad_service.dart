import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';

class AdService {
  RewardedInterstitialAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  // Initialize Mobile Ads SDK
  static Future<void> initSdk() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob Initialization Error: $e');
    }
  }

  // Load Rewarded Interstitial Ad
  void loadRewardedAd({Function()? onAdLoaded}) {
    final adUnitId = Platform.isIOS
        ? AppConstants.iosRewardedAdUnitId
        : AppConstants.androidRewardedAdUnitId;

    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          if (onAdLoaded != null) onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedInterstitialAd failed to load: $error');
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
        },
      ),
    );
  }

  // Load Standard Interstitial Ad
  void loadInterstitialAd() {
    final adUnitId = Platform.isIOS
        ? AppConstants.iosInterstitialAdUnitId
        : AppConstants.androidInterstitialAdUnitId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  // Show Rewarded Ad and trigger callback when reward earned
  void showRewardedAd({required Function() onUserEarnedReward}) {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          // Reload next ad for future use
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          loadRewardedAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onUserEarnedReward();
        },
      );
    } else {
      debugPrint('Rewarded ad is not ready yet. Granting reward for test simulation.');
      onUserEarnedReward();
      loadRewardedAd();
    }
  }

  // Show Interstitial Ad (e.g., after generating story or reading)
  void showInterstitialAd({Function()? onAdClosed}) {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          loadInterstitialAd();
          if (onAdClosed != null) onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          loadInterstitialAd();
          if (onAdClosed != null) onAdClosed();
        },
      );
      _interstitialAd!.show();
    } else {
      loadInterstitialAd();
      if (onAdClosed != null) onAdClosed();
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
