import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('tr'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'tr': {
      'appName': 'Wondertale',
      'appTagline': 'Yapay Zeka Destekli Sihirli Masallar',
      'createStory': 'Masal Oluştur',
      'myLibrary': 'Masal Kütüphanem',
      'subscription': 'Abonelik & Haklar',
      'selectAge': 'Yaş Grubu Seçin',
      'selectTheme': 'Masal Temasını Seçin',
      'selectMood': 'Masal Amacı / Ruh Hali',
      'childNameOptional': 'Çocuğunuzun Adı (Opsiyonel)',
      'childNameHint': 'Örn: Deniz, Ali (Max 30 karakter)',
      'storyLanguage': 'Masal Dili',
      'generateButton': '✨ Masalı Yapay Zekaya Yazdır',
      'generatingTitle': 'Sihirli Masal Kaleme Alınıyor...',
      'generatingSubtitle': 'Yapay zeka peri tozu serpiyor, illüstrasyon çiziliyor!',
      'dailyLimitReached': 'Günlük Masal Limitine Ulaşıldı',
      'dailyLimitDesc': 'Bugünkü ücretsiz masal hakkınız bitti. Reklam izleyerek +1 hak kazanabilir veya Sınırsız Paket satın alabilirsiniz.',
      'watchAdForBonus': '🎬 Reklam İzle (+1 Masal Kazan)',
      'upgradeToUnlimited': '👑 Sınırsız Masal Aboneliği',
      'readStory': 'Masalı Oku',
      'listenStory': 'Sesli Dinle',
      'pauseStory': 'Duraklat',
      'resumeStory': 'Devam Et',
      'stopStory': 'Durdur',
      'speechSpeed': 'Okuma Hızı',
      'noStoriesYet': 'Henüz kaydedilmiş masalınız yok.',
      'startFirstStory': 'İlkiyle Başlayın!',
      'loginGoogle': 'Google ile Giriş Yap',
      'continueGuest': 'Misafir Olarak Devam Et',
      'loginRequired': 'Masallarınızı bulutta saklamak için giriş yapın.',
      'quotaLeft': 'Kalan Günlük Hak: ',
      'unlimitedAccess': 'Sınırsız Paket Aktif',
      'premiumPerks': '• Sınırsız Masal Üretimi\n• Reklamsız Deneyim\n• Tüm Yaş ve Temalara Erişim\n• Yüksek Çözünürlüklü İllüstrasyonlar',
      'subscribeMonthly': 'Aylık ₺49,99 ile Abone Ol',
      'restorePurchases': 'Satın Alımları Geri Yükle',
      'errorTitle': 'Bir Hata Oluştu',
      'tryAgain': 'Tekrar Dene',
      'charLimitExceeded': 'İsim en fazla 30 karakter olabilir.',
    },
    'en': {
      'appName': 'Wondertale',
      'appTagline': 'AI-Powered Magical Bedtime Stories',
      'createStory': 'Create Story',
      'myLibrary': 'My Story Library',
      'subscription': 'Subscription & Quota',
      'selectAge': 'Select Age Group',
      'selectTheme': 'Choose Story Theme',
      'selectMood': 'Choose Goal / Mood',
      'childNameOptional': "Child's Name (Optional)",
      'childNameHint': 'e.g. Leo, Mia (Max 30 chars)',
      'storyLanguage': 'Story Language',
      'generateButton': '✨ Generate Magical Story',
      'generatingTitle': 'Crafting Your Story...',
      'generatingSubtitle': 'The AI pixie dust is weaving words & drawing illustrations!',
      'dailyLimitReached': 'Daily Limit Reached',
      'dailyLimitDesc': "You've reached your free stories for today. Watch a quick ad to get +1 extra story or upgrade to Unlimited.",
      'watchAdForBonus': '🎬 Watch Ad (+1 Extra Story)',
      'upgradeToUnlimited': '👑 Get Unlimited Access',
      'readStory': 'Read Story',
      'listenStory': 'Listen Narration',
      'pauseStory': 'Pause',
      'resumeStory': 'Resume',
      'stopStory': 'Stop',
      'speechSpeed': 'Reading Speed',
      'noStoriesYet': 'No saved stories yet.',
      'startFirstStory': 'Create Your First Story!',
      'loginGoogle': 'Sign In with Google',
      'continueGuest': 'Continue as Guest',
      'loginRequired': 'Sign in to sync your stories across devices.',
      'quotaLeft': 'Daily Quota Remaining: ',
      'unlimitedAccess': 'Unlimited Premium Active',
      'premiumPerks': '• Unlimited Story Generations\n• 100% Ad-Free Experience\n• All Ages & Themes Unlocked\n• High Quality AI Illustrations',
      'subscribeMonthly': 'Subscribe for \$4.99/mo',
      'restorePurchases': 'Restore Purchases',
      'errorTitle': 'An Error Occurred',
      'tryAgain': 'Try Again',
      'charLimitExceeded': 'Name cannot exceed 30 characters.',
    }
  };

  String get(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ?? _localizedValues['tr']?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
