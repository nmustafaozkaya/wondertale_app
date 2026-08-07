import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';

class AdService {
  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
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

  String get _rewardedAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917';
    }
    return Platform.isIOS
        ? AppConstants.iosRewardedAdUnitId
        : AppConstants.androidRewardedAdUnitId;
  }

  String get _interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/4423841671'
          : 'ca-app-pub-3940256099942544/1033173712';
    }
    return Platform.isIOS
        ? AppConstants.iosInterstitialAdUnitId
        : AppConstants.androidInterstitialAdUnitId;
  }

  // Load Rewarded Ad (tries RewardedAd first, then RewardedInterstitialAd)
  void loadRewardedAd({Function()? onAdLoaded}) {
    final adUnitId = _rewardedAdUnitId;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedInterstitialAd = null;
          _isRewardedAdLoaded = true;
          debugPrint('RewardedAd loaded successfully!');
          if (onAdLoaded != null) onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error. Trying RewardedInterstitialAd fallback...');
          _loadRewardedInterstitialAdFallback(adUnitId, onAdLoaded);
        },
      ),
    );
  }

  void _loadRewardedInterstitialAdFallback(String adUnitId, Function()? onAdLoaded) {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _rewardedAd = null;
          _isRewardedAdLoaded = true;
          debugPrint('RewardedInterstitialAd loaded successfully!');
          if (onAdLoaded != null) onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedInterstitialAd also failed: $error');
          _rewardedAd = null;
          _rewardedInterstitialAd = null;
          _isRewardedAdLoaded = false;
        },
      ),
    );
  }

  // Load Standard Interstitial Ad
  void loadInterstitialAd() {
    final adUnitId = _interstitialAdUnitId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('InterstitialAd loaded successfully!');
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  // Show Rewarded Ad and trigger callback ONLY when reward is actually earned from watching
  void showRewardedAd({
    required Function() onUserEarnedReward,
    Function(String message)? onAdNotReady,
  }) {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('RewardedAd failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          loadRewardedAd();
          if (onAdNotReady != null) {
            onAdNotReady('Reklam gösterilemedi, lütfen tekrar deneyin.');
          }
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('User earned reward via RewardedAd');
          onUserEarnedReward();
        },
      );
    } else if (_rewardedInterstitialAd != null && _isRewardedAdLoaded) {
      _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedInterstitialAd = null;
          _isRewardedAdLoaded = false;
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('RewardedInterstitialAd failed to show: $error');
          ad.dispose();
          _rewardedInterstitialAd = null;
          _isRewardedAdLoaded = false;
          loadRewardedAd();
          if (onAdNotReady != null) {
            onAdNotReady('Reklam gösterilemedi, lütfen tekrar deneyin.');
          }
        },
      );

      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('User earned reward via RewardedInterstitialAd');
          onUserEarnedReward();
        },
      );
    } else {
      debugPrint('Rewarded ad is loading or not ready yet.');
      loadRewardedAd();
      if (onAdNotReady != null) {
        onAdNotReady('Reklam yükleniyor, lütfen 2-3 saniye sonra tekrar deneyin!');
      }
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
    _rewardedInterstitialAd?.dispose();
    _interstitialAd?.dispose();
  }
}
