class AppLanguage {
  final String code;
  final String name;
  final String flag;

  const AppLanguage({required this.code, required this.name, required this.flag});
}

class AppConstants {
  static const String appName = 'Wondertale';
  static const String appTagline = 'Magic Bedtime Stories for Children';

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
    AppLanguage(code: 'en', name: 'English', flag: '🇬🇧'),
    AppLanguage(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
    AppLanguage(code: 'ar', name: 'العربية', flag: '🇸🇦'),
  ];

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
      'labelDe': 'Weltraum-Abenteuer',
      'labelAr': 'مغامرة الفضاء',
      'descTr': 'Yıldızlar ve gezegenler arası macera',
      'descEn': 'Journey through stars and planets',
      'descDe': 'Reise durch Sterne und Planeten',
      'descAr': 'رحلة بين النجوم والكواكب',
    },
    {
      'id': 'forest',
      'icon': '🌲',
      'labelTr': 'Büyülü Orman',
      'labelEn': 'Enchanted Forest',
      'labelDe': 'Zauberwald',
      'labelAr': 'الغابة السحرية',
      'descTr': 'Konuşan ağaçlar ve sevimli dostlar',
      'descEn': 'Talking trees and friendly animals',
      'descDe': 'Sprechende Bäume und freundliche Tiere',
      'descAr': 'أشجار متكلمة وحيوانات لطيفة',
    },
    {
      'id': 'underwater',
      'icon': '🌊',
      'labelTr': 'Deniz Altı',
      'labelEn': 'Underwater',
      'labelDe': 'Unterwasserwelt',
      'labelAr': 'عالم تحت الماء',
      'descTr': 'Renkli balıklar ve gizli hazineler',
      'descEn': 'Colorful fish and hidden treasures',
      'descDe': 'Bunte Fische und verborgene Schätze',
      'descAr': 'أسماك ملونة وكنوز مخفية',
    },
    {
      'id': 'kingdom',
      'icon': '🏰',
      'labelTr': 'Büyülü Krallık',
      'labelEn': 'Magical Kingdom',
      'labelDe': 'Magisches Königreich',
      'labelAr': 'المملكة السحرية',
      'descTr': 'Prensesler, şövalyeler ve sihirli şatolar',
      'descEn': 'Castles, knights, and magic spells',
      'descDe': 'Schlösser, Ritter und Zaubersprüche',
      'descAr': 'قلاع، فرسان وتعوذات سحرية',
    },
    {
      'id': 'dinosaurs',
      'icon': '🦕',
      'labelTr': 'Sevimli Dinozorlar',
      'labelEn': 'Friendly Dinosaurs',
      'labelDe': 'Freundliche Dinosaurier',
      'labelAr': 'الديناصورات الودودة',
      'descTr': 'Dev ama eğlenceli dinozor dostlar',
      'descEn': 'Giant yet gentle prehistoric pals',
      'descDe': 'Riesige, aber sanfte Urzeitfreunde',
      'descAr': 'أصدقاء عصور ما قبل التاريخ',
    },
    {
      'id': 'unicorn',
      'icon': '🦄',
      'labelTr': 'Sihirli Tekboynuzlar',
      'labelEn': 'Magical Unicorns',
      'labelDe': 'Magische Einhörner',
      'labelAr': 'وحيد القرن السحري',
      'descTr': 'Işıltılı gökkuşakları ve peri tozu',
      'descEn': 'Sparkly rainbows and fairy dust',
      'descDe': 'Glitzernde Regenbogen & Feenstaub',
      'descAr': 'قوس قزح وغبار الجنيات',
    },
    {
      'id': 'pirates',
      'icon': '🏴‍☠️',
      'labelTr': 'Hazine Adası',
      'labelEn': 'Treasure Island',
      'labelDe': 'Schatzinsel',
      'labelAr': 'جزيرة الكنز',
      'descTr': 'Sevimli korsanlar ve gizemli haritalar',
      'descEn': 'Friendly pirates and secret maps',
      'descDe': 'Freundliche Piraten und Geheimkarten',
      'descAr': 'قرصان ودودين وخرائط سرية',
    },
    {
      'id': 'toys',
      'icon': '🧸',
      'labelTr': 'Canlanan Oyuncaklar',
      'labelEn': 'Living Toys',
      'labelDe': 'Lebendige Spielzeuge',
      'labelAr': 'ألعاب حية',
      'descTr': 'Gece yarısı eğlenen sevimli oyuncaklar',
      'descEn': 'Cute teddy bears coming alive at night',
      'descDe': 'Kuscheltiere erwachen zum Leben',
      'descAr': 'دمى ترفرف بالحياة ليلاً',
    },
    {
      'id': 'clouds',
      'icon': '☁️',
      'labelTr': 'Bulut Şehri',
      'labelEn': 'Cloud Kingdom',
      'labelDe': 'Wolkenkönigreich',
      'labelAr': 'مملكة السحاب',
      'descTr': 'Yumuşacık bulut şatoları ve melekler',
      'descEn': 'Soft cloud castles and sleepy angels',
      'descDe': 'Weiche Wolkenschlösser & Engel',
      'descAr': 'قلاع سحابية ملائكية',
    },
    {
      'id': 'superhero',
      'icon': '🦸',
      'labelTr': 'Minik Süper Kahraman',
      'labelEn': 'Little Superhero',
      'labelDe': 'Kleiner Superheld',
      'labelAr': 'البطل الخارق الصغير',
      'descTr': 'Pelerinli sevimli iyilik kahramanı',
      'descEn': 'Bedtime capes and gentle powers',
      'descDe': 'Umhänge & sanfte Heldenkräfte',
      'descAr': 'عباءات سحرية وقوة لطيفة',
    },
  ];

  static const List<Map<String, String>> moods = [
    {
      'id': 'calming',
      'icon': '🌙',
      'labelTr': 'Sakinleştirici',
      'labelEn': 'Calming',
      'labelDe': 'Beruhigend',
      'labelAr': 'مهدئ',
      'descTr': 'Uyku öncesi huzurlu ve rahatlatıcı',
      'descEn': 'Peaceful bedtime relaxation',
      'descDe': 'Friedliche Entspannung vor dem Schlafen',
      'descAr': 'استرخاء هادئ قبل النوم',
    },
    {
      'id': 'fun',
      'icon': '🎈',
      'labelTr': 'Eğlenceli',
      'labelEn': 'Fun & Cheerful',
      'labelDe': 'Lustig & Fröhlich',
      'labelAr': 'ممتع ومبهج',
      'descTr': 'Kahkahalar ve neşe dolu',
      'descEn': 'Full of joy and laughter',
      'descDe': 'Voller Freude und Lachen',
      'descAr': 'مليء بالبهجة والضحك',
    },
    {
      'id': 'courage',
      'icon': '🦁',
      'labelTr': 'Cesaret Aşılayan',
      'labelEn': 'Encouraging Courage',
      'labelDe': 'Mut machend',
      'labelAr': 'مشجع على الشجاعة',
      'descTr': 'Özgüven ve cesaret kazandırıcı',
      'descEn': 'Building confidence and bravery',
      'descDe': 'Baut Selbstvertrauen und Mut auf',
      'descAr': 'بناء الثقة والشجاعة',
    },
    {
      'id': 'sharing',
      'icon': '🤝',
      'labelTr': 'Paylaşmayı Öğreten',
      'labelEn': 'Teaching Sharing',
      'labelDe': 'Teilen lernen',
      'labelAr': 'تعليم المشاركة',
      'descTr': 'Dostluk, sevgi ve paylaşım',
      'descEn': 'Friendship, love, and generosity',
      'descDe': 'Freundschaft, Liebe und Großzügigkeit',
      'descAr': 'الصداقة، المحبة والكرم',
    },
    {
      'id': 'habits',
      'icon': '🦷',
      'labelTr': 'Sağlıklı Alışkanlıklar',
      'labelEn': 'Healthy Habits',
      'labelDe': 'Gesunde Gewohnheiten',
      'labelAr': 'عادات صحية',
      'descTr': 'Diş fırçalama ve erken uyuma',
      'descEn': 'Brushing teeth and early bedtime',
      'descDe': 'Zähneputzen & früh schlafen',
      'descAr': 'تنظيف الأسنان والنوم المبكر',
    },
    {
      'id': 'curiosity',
      'icon': '🦉',
      'labelTr': 'Merak & Keşif',
      'labelEn': 'Curiosity & Science',
      'labelDe': 'Neugier & Entdeckung',
      'labelAr': 'الفضول والاكتشاف',
      'descTr': 'Doğa, bilim ve yıldızları öğrenme',
      'descEn': 'Exploring nature and stars',
      'descDe': 'Natur und Sterne erkunden',
      'descAr': 'استكشاف الطبيعة والنجوم',
    },
    {
      'id': 'family',
      'icon': '❤️',
      'labelTr': 'Aile Sevgisi',
      'labelEn': 'Family & Love',
      'labelDe': 'Familienliebe',
      'labelAr': 'حب العائلة',
      'descTr': 'Sıcak sarılmalar ve güvende hissetme',
      'descEn': 'Warm hugs and feeling safe',
      'descDe': 'Warme Umarmungen & Geborgenheit',
      'descAr': 'عناق دافئ وشعور بالأمان',
    },
    {
      'id': 'sleep',
      'icon': '💤',
      'labelTr': 'Derin Uyku Ninni',
      'labelEn': 'Deep Sleep Lullaby',
      'labelDe': 'Tiefschlaf-Wiegenlied',
      'labelAr': 'نوم عميق',
      'descTr': 'Yağmur sesi ve tatlı rüyalar',
      'descEn': 'Gentle rain and sweet dreams',
      'descDe': 'Sanfter Regen & süße Träume',
      'descAr': 'صخب المطر وهدوء الأحلام',
    },
  ];

  static String getThemeLabel(Map<String, String> theme, String langCode) {
    switch (langCode) {
      case 'de':
        return theme['labelDe'] ?? theme['labelEn'] ?? theme['labelTr'] ?? '';
      case 'ar':
        return theme['labelAr'] ?? theme['labelEn'] ?? theme['labelTr'] ?? '';
      case 'en':
        return theme['labelEn'] ?? theme['labelTr'] ?? '';
      case 'tr':
      default:
        return theme['labelTr'] ?? theme['labelEn'] ?? '';
    }
  }

  static String getThemeDesc(Map<String, String> theme, String langCode) {
    switch (langCode) {
      case 'de':
        return theme['descDe'] ?? theme['descEn'] ?? theme['descTr'] ?? '';
      case 'ar':
        return theme['descAr'] ?? theme['descEn'] ?? theme['descTr'] ?? '';
      case 'en':
        return theme['descEn'] ?? theme['descTr'] ?? '';
      case 'tr':
      default:
        return theme['descTr'] ?? theme['descEn'] ?? '';
    }
  }

  static String getMoodLabel(Map<String, String> mood, String langCode) {
    switch (langCode) {
      case 'de':
        return mood['labelDe'] ?? mood['labelEn'] ?? mood['labelTr'] ?? '';
      case 'ar':
        return mood['labelAr'] ?? mood['labelEn'] ?? mood['labelTr'] ?? '';
      case 'en':
        return mood['labelEn'] ?? mood['labelTr'] ?? '';
      case 'tr':
      default:
        return mood['labelTr'] ?? mood['labelEn'] ?? '';
    }
  }

  static String getMoodDesc(Map<String, String> mood, String langCode) {
    switch (langCode) {
      case 'de':
        return mood['descDe'] ?? mood['descEn'] ?? mood['descTr'] ?? '';
      case 'ar':
        return mood['descAr'] ?? mood['descEn'] ?? mood['descTr'] ?? '';
      case 'en':
        return mood['descEn'] ?? mood['descTr'] ?? '';
      case 'tr':
      default:
        return mood['descTr'] ?? mood['descEn'] ?? '';
    }
  }

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
