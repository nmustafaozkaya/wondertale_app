class AppConstants {
  static const String appName = 'Wondertale';
  static const String appTagline = 'Magic Bedtime Stories for Children';

  // Free Tier Rules
  static const int freeDailyQuota = 2; // 2 free stories per day
  static const int adRewardBonus = 1;  // +1 extra story per rewarded ad

  // Options definitions
  static const List<String> ageGroups = ['2-4', '5-7', '8-10'];

  static const List<Map<String, String>> themes = [
    {
      'id': 'space',
      'icon': '🚀',
      'labelTr': 'Uzay Macerası',
      'labelEn': 'Space Adventure',
      'descTr': 'Yıldızlar ve gezegenler arası macera',
      'descEn': 'Journey through stars and planets'
    },
    {
      'id': 'forest',
      'icon': '🌲',
      'labelTr': 'Büyülü Orman',
      'labelEn': 'Enchanted Forest',
      'descTr': 'Konuşan ağaçlar ve sevimli dostlar',
      'descEn': 'Talking trees and friendly animals'
    },
    {
      'id': 'underwater',
      'icon': '🌊',
      'labelTr': 'Deniz Altı',
      'labelEn': 'Underwater',
      'descTr': 'Renkli balıklar ve gizli hazineler',
      'descEn': 'Colorful fish and hidden treasures'
    },
    {
      'id': 'kingdom',
      'icon': '🏰',
      'labelTr': 'Büyülü Krallık',
      'labelEn': 'Magical Kingdom',
      'descTr': 'Prensesler, şövalyeler ve sihirli şatolar',
      'descEn': 'Castles, knights, and magic spells'
    },
    {
      'id': 'dinosaurs',
      'icon': '🦕',
      'labelTr': 'Sevimli Dinozorlar',
      'labelEn': 'Friendly Dinosaurs',
      'descTr': 'Dev ama eğlenceli dinozor dostlar',
      'descEn': 'Giant yet gentle prehistoric pals'
    },
  ];

  static const List<Map<String, String>> moods = [
    {
      'id': 'calming',
      'icon': '🌙',
      'labelTr': 'Sakinleştirici',
      'labelEn': 'Calming',
      'descTr': 'Uyku öncesi huzurlu ve rahatlatıcı',
      'descEn': 'Peaceful bedtime relaxation'
    },
    {
      'id': 'fun',
      'icon': '🎈',
      'labelTr': 'Eğlenceli',
      'labelEn': 'Fun & Cheerful',
      'descTr': 'Kahkahalar ve neşe dolu',
      'descEn': 'Full of joy and laughter'
    },
    {
      'id': 'courage',
      'icon': '🦁',
      'labelTr': 'Cesaret Aşılayan',
      'labelEn': 'Encouraging Courage',
      'descTr': 'Özgüven ve cesaret kazandırıcı',
      'descEn': 'Building confidence and bravery'
    },
    {
      'id': 'sharing',
      'icon': '🤝',
      'labelTr': 'Paylaşmayı Öğreten',
      'labelEn': 'Teaching Sharing',
      'descTr': 'Dostluk, sevgi ve paylaşım',
      'descEn': 'Friendship, love, and generosity'
    },
  ];

  // AdMob Unit IDs
  static const String androidRewardedAdUnitId = 'ca-app-pub-8252438794686125/7082765702';
  static const String iosRewardedAdUnitId = 'ca-app-pub-8252438794686125/9864273499';
  
  static const String androidInterstitialAdUnitId = 'ca-app-pub-8252438794686125/9780513014';
  static const String iosInterstitialAdUnitId = 'ca-app-pub-8252438794686125/4665973041';
  
  static const String androidBannerAdUnitId = 'ca-app-pub-8252438794686125/9708929043';
  static const String iosBannerAdUnitId = 'ca-app-pub-8252438794686125/1830439024';

  // In-App Purchase Product ID
  static const String premiumSubscriptionId = 'wondertale_unlimited_monthly';
}
