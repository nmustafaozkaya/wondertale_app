import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/story_model.dart';

class StoryService {
  static bool get _firebaseReady {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  FirebaseFunctions? get _functions =>
      _firebaseReady ? FirebaseFunctions.instance : null;
  FirebaseFirestore? get _firestore =>
      _firebaseReady ? FirebaseFirestore.instance : null;

  // Call Cloud Function to generate AI story & illustration
  Future<StoryModel> generateStory({
    required String ageGroup,
    required String theme,
    required String mood,
    required String childName,
    required String language,
  }) async {
    if (!_firebaseReady) {
      return _generateFallbackStory(
        ageGroup: ageGroup,
        theme: theme,
        mood: mood,
        childName: childName,
        language: language,
      );
    }
    try {
      final HttpsCallable callable =
          _functions!.httpsCallable('generateStory');
      final response = await callable.call(<String, dynamic>{
        'ageGroup': ageGroup,
        'theme': theme,
        'mood': mood,
        'childName': childName,
        'language': language,
      });

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(response.data);
      return StoryModel.fromMap(data);
    } catch (e) {
      debugPrint('Cloud Function error, using fallback offline generator: $e');
      return _generateFallbackStory(
        ageGroup: ageGroup,
        theme: theme,
        mood: mood,
        childName: childName,
        language: language,
      );
    }
  }

  // Save story to user's Firestore collection
  Future<void> saveStoryToFirestore(String uid, StoryModel story) async {
    if (!_firebaseReady) return;
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('stories')
          .doc(story.id)
          .set(story.toMap());
    } catch (e) {
      debugPrint('Error saving story to Firestore: $e');
    }
  }

  // Fetch user's story library from Firestore
  Future<List<StoryModel>> getUserStories(String uid) async {
    if (!_firebaseReady) return [];
    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('stories')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user stories: $e');
      return [];
    }
  }

  // Graceful local story generator when Cloud Function is unavailable
  StoryModel _generateFallbackStory({
    required String ageGroup,
    required String theme,
    required String mood,
    required String childName,
    required String language,
  }) {
    String defaultHero;
    switch (language) {
      case 'de':
        defaultHero = 'Kleine Held';
        break;
      case 'ar':
        defaultHero = 'البطل الصغير';
        break;
      case 'en':
        defaultHero = 'Little Hero';
        break;
      case 'tr':
      default:
        defaultHero = 'Sevimli Kahraman';
        break;
    }

    final hero = childName.trim().isNotEmpty ? childName.trim() : defaultHero;

    String title;
    String content;

    if (theme == 'space') {
      switch (language) {
        case 'de':
          title = '$hero und der Zauberstern';
          content = 'Es war einmal ein mutiges Kind namens $hero. Jede Nacht schaute $hero zu den leuchtenden Sternen auf und träumte von großen Abenteuern.\n\nEines Abends schwebte ein silberner Stern sanft in $hero\'s Zimmer. "Hallo!" rief der Stern freundlich. "Möchtest du eine Reise durch das ruhige Weltall machen?"\n\n$hero lächelte glücklich und nickte. Zusammen flogen sie über weiche Wolken und hörten dem sanften Wiegenlied der Planeten zu.\n\nAuf ihrer Reise trafen sie kleine glitzernde Kometen, die leise Lieder sangen. Der Mond wünschte $hero eine wunderschöne Nacht.\n\nVoller Freude und Geborgenheit kehrte $hero in sein kuscheliges Bett zurück und schlief friedlich mit den schönsten Träumen ein.';
          break;
        case 'ar':
          title = '$hero والنجمة السحرية';
          content = 'في يوم من الأيام، عاش طفل شجاع اسمه $hero. في كل ليلة، كان $hero ينظر إلى النجوم المتلألئة في السماء ويتخيل مغامرات رائعة.\n\nوفي أحد الأيام، هبطت نجمة فضية لطيفة إلى غرفة $hero. وقالت: "مرحباً $hero! هل تحب أن تخوض معي مغامرة هادئة بين الكواكب؟"\n\nابتسم $hero وسار مع النجمة بين السحب الناعمة. شاهدوا الكواكب الملونة واستمعوا إلى أنغام المجرة الهادئة.\n\nالتقوا بكويكبات صغيرة لامعة تعزف ألحاناً لطيفة، ورحب بهم القمر بابتسامة دافئة.\n\nوعندما عاد $hero إلى سريره، أغمض عينيه ونام بنوم هادئ وأحلام سعيدة جداً.';
          break;
        case 'en':
          title = '$hero and the Magic Star';
          content = 'Once upon a time, in a bright peaceful town, lived a curious child named $hero. Every night, $hero would gaze at the twinkling stars from the window and imagine grand magical journeys.\n\nOne evening, a friendly silver star floated right down into $hero\'s room. "Hello $hero!" sang the star warmly. "Would you like to join me on a peaceful journey across the gentle cosmos?"\n\n$hero smiled warmly and nodded. Together, they drifted across soft pastel clouds and listened to the calming lullaby of the galaxy.\n\nAlong the way, they met playful little shooting stars that painted soft golden ribbons across the night sky. The glowing moon waved gently, wishing $hero the sweetest night.\n\n$hero tucked back into bed feeling safe, happy, and fell into a deep, cozy sleep.';
          break;
        case 'tr':
        default:
          title = '$hero ve Sihirli Yıldız Macerası';
          content = 'Bir zamanlar, gökyüzünün en parlak köşesinde $hero adında meraklı ve cesur bir çocuk yaşardı. Her gece penceresinden parıldayan yıldızları izler, onların dünyasını hayal ederdi.\n\nBir akşam, gökyüzünden gümüş kanatlı sevimli bir yıldız süzülüp $hero\'in odasına kondu. "Merhaba!" dedi yıldız neşeyle. "Gezegenler arası tatlı ve huzurlu bir uyku macerasına çıkmaya hazır mısın?"\n\n$hero sevinçle gülümsedi. Birlikte pamuk gibi yumuşacık bulutların üzerine bastılar, Samanyolu\'nun renkli ışıkları arasında süzüldüler.\n\nYolda altın saçlı tatlı kuyruklu yıldızlarla karşılaştılar. Yıldızlar $hero için neşeli ninniler söyledi. Ay dede gülümseyerek $hero\'e tatlı rüyalar diledi.\n\nYüreği mutlulukla dolan $hero sıcacık yatağına döndü, gözlerini kapattı ve huzur dolu derin bir uykuya daldı.';
          break;
      }
    } else {
      switch (language) {
        case 'de':
          title = '$hero und die Zauberwald-Freunde';
          content = 'An einem sonnigen Morgen betrat $hero einen zauberhaften Wald voller singender Bäume und bunter Blumen.\n\nEin kleines Hässchen hüpfte zu $hero und sagte: "Hallo $hero! Willkommen in unserem Wald!" $hero teilte leckere Äpfel mit allen Waldtieren.\n\nGemeinsam tanzten sie unter den goldenen Sonnenstrahlen und lauschten den sanften Melodien des Baches.\n\nGlücklich und zufrieden winkte $hero den Tieren zum Abschied und schlief am Abend friedlich in seinem Bett ein.';
          break;
        case 'ar':
          title = '$hero وأصدقاء الغابة السحرية';
          content = 'في صباح مشرق، دخل $hero إلى غابة سحرية ملونة بالأشجار الجميلة والحيوانات اللطيفة.\n\nجاء أرنب صغير لطيف وقال: "أهلاً بك يا $hero في غابتنا!" شارك $hero طعامه مع الحيوانات وسط فرحة كبيرة.\n\nلعبوا معاً تحت أشعة الشمس الذهبية واستمعوا إلى صوت خرير الماء العذب.\n\nوعندما حل المساء، عاد $hero إلى سريره الدافيء ونام في أمان وهدوء تام.';
          break;
        case 'en':
          title = '$hero and the Enchanted Forest';
          content = 'On a golden sunlit morning, $hero stepped into an enchanted forest filled with ancient singing trees and friendly woodland creatures.\n\nA fluffy little bunny hopped over to $hero with a bright smile. "Welcome $hero! Will you join our picnic today?" asked the bunny. $hero happily shared fresh apples and laughter with everyone.\n\nThey played under the dappled sunlight, listened to the gentle rustle of leaves, and watched butterflies dance in harmony.\n\nHeart filled with warmth and peace, $hero waved goodbye to the forest friends and settled down for a cozy night.';
          break;
        case 'tr':
        default:
          title = '$hero ve Büyülü Orman Dostları';
          content = 'Güneşin altın gibi parıldadığı güzel bir günde, $hero yeşil ağaçlarla dolu büyülü bir ormana adım attı. Ormanda kuşlar neşeyle şarkı söylüyordu.\n\n$hero adımlarını atarken sevimli bir yavru tavşan karşısına çıktı. Tavşan, "Merhaba $hero! Bizimle meşe palamudu paylaşmak ister misin?" dedi. $hero sevinçle gülümsedi ve tüm sevimli dostlarıyla ekmeğini paylaştı.\n\nRengarenk kelebeklerin dansını izlediler, tatlı dere suyunun şırıltısını dinlediler. Ormanın tüm sevimli canlıları $hero\'e teşekkür etti.\n\nPaylaşmanın verdiği mutlulukla $hero\'in kalbi sıcacık oldu. Akşam olduğunda tatlı orman rüzgarı eserken $hero yatağında huzurla gözlerini kapattı.';
          break;
      }
    }

    return StoryModel(
      id: 'story_local_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      illustrationPrompt: 'Cute watercolor illustration of $hero in $theme',
      imageBase64: null,
      theme: theme,
      mood: mood,
      ageGroup: ageGroup,
      childName: childName,
      language: language,
      createdAt: DateTime.now(),
    );
  }
}
