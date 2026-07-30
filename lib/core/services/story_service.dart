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
    final hero = childName.trim().isNotEmpty
        ? childName.trim()
        : (language == 'tr' ? 'Sevimli Kahraman' : 'Little Hero');
    final isTr = language == 'tr';

    String title;
    String content;

    if (theme == 'space') {
      title = isTr
          ? '$hero ve Sihirli Yıldız Macerası'
          : '$hero and the Magic Star';
      content = isTr
          ? 'Bir zamanlar, gökyüzünün en parlak köşesinde $hero adında cesur bir çocuk yaşardı. Gece olduğunda penceresinden yıldızlara bakar, onlara gülümserdi.\n\nBir akşam, gökyüzünden gümüş kanatlı küçük bir yıldız süzülüp $hero\'in odasına kondu. "Merhaba!" dedi yıldız sevinçle. "Gezegenler arası tatlı bir uyku macerasına çıkmaya hazır mısın?"\n\n$hero sevinçle başını salladı. Birlikte yumuşacık bulutların üzerine bastılar, Samanyolu\'nun renkli ışıkları arasında süzüldüler. Bütün uyku perileri $hero\'e tatlı rüyalar diledi. $hero yatağına döndüğünde gözlerini kapattı ve huzur dolu bir uykuya daldı.'
          : 'Once upon a time, in a bright peaceful town, lived a curious child named $hero. Every night, $hero would gaze at the twinkling stars from the window.\n\nOne evening, a friendly silver star floated right down into $hero\'s room. "Hello $hero!" sang the star. "Would you like to join me on a peaceful journey across the gentle cosmos?"\n\n$hero smiled warmly and nodded. Together, they drifted across soft pastel clouds and listened to the calming lullaby of the galaxy. $hero tucked back into bed, feeling completely safe, happy, and ready for sweet dreams.';
    } else {
      title = isTr
          ? '$hero ve Büyülü Orman Dostları'
          : '$hero and the Enchanted Forest';
      content = isTr
          ? 'Güneşin altın gibi parıldadığı güzel bir günde, $hero yeşil ağaçlarla dolu büyülü bir ormana adım attı. Ormanda kuşlar neşeyle şarkı söylüyordu.\n\n$hero adımlarını atarken sevimli bir yavru tavşan karşısına çıktı. Tavşan, "Merhaba $hero! Bizimle meşe palamudu paylaşmak ister misin?" dedi. $hero sevinçle gülümsedi ve ormandaki tüm sevimli dostlarıyla yemeğini paylaştı.\n\nPaylaşmanın verdiği mutlulukla $hero\'in kalbi sıcacık oldu. Akşam olduğunda tatlı orman rüzgarı eserken $hero huzurla gözlerini kapattı.'
          : 'On a golden sunlit morning, $hero stepped into an enchanted forest filled with ancient singing trees and friendly little woodland creatures.\n\nA fluffy little bunny hopped over to $hero with a big bright smile. "Welcome $hero! Will you join our picnic today?" asked the bunny. $hero happily shared apples and stories with every animal in the forest.\n\nHeart filled with warmth, generosity, and joy, $hero waved goodbye to the forest friends and settled down for a cozy, peaceful night.';
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
