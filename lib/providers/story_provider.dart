import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../core/services/story_service.dart';

enum GenerationStatus { idle, generating, success, error }

class StoryProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();

  // Wizard selections
  String _selectedAge = '5-7';
  String _selectedTheme = 'space';
  String _customPrompt = '';
  String _selectedMood = 'calming';
  String _childName = '';
  String _storyLanguage = 'tr';

  GenerationStatus _status = GenerationStatus.idle;
  String? _errorMessage;
  StoryModel? _currentStory;
  List<StoryModel> _savedStories = [];

  // Getters
  String get selectedAge => _selectedAge;
  String get selectedTheme => _selectedTheme;
  String get customPrompt => _customPrompt;
  String get selectedMood => _selectedMood;
  String get childName => _childName;
  String get storyLanguage => _storyLanguage;
  GenerationStatus get status => _status;
  String? get errorMessage => _errorMessage;
  StoryModel? get currentStory => _currentStory;
  List<StoryModel> get savedStories => _savedStories;

  // Setters for wizard
  void setAge(String age) {
    _selectedAge = age;
    notifyListeners();
  }

  void setTheme(String theme) {
    _selectedTheme = theme;
    _customPrompt = ''; // Clear custom prompt when a preset theme is chosen
    notifyListeners();
  }

  void setCustomPrompt(String prompt) {
    _customPrompt = prompt;
    notifyListeners();
  }

  void setMood(String mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void setChildName(String name) {
    // Enforce strict max 30 char limit
    if (name.length <= 30) {
      _childName = name;
      notifyListeners();
    }
  }

  void setStoryLanguage(String lang) {
    _storyLanguage = lang;
    notifyListeners();
  }

  // Trigger story generation
  Future<bool> generateStory({required String? uid}) async {
    _status = GenerationStatus.generating;
    _errorMessage = null;
    notifyListeners();

    try {
      final story = await _storyService.generateStory(
        ageGroup: _selectedAge,
        theme: _customPrompt.isNotEmpty ? _customPrompt : _selectedTheme,
        mood: _selectedMood,
        childName: _childName,
        language: _storyLanguage,
      );

      _currentStory = story;
      _savedStories.insert(0, story);
      _status = GenerationStatus.success;

      // Save to Firestore asynchronously if user is authenticated
      if (uid != null && uid.isNotEmpty) {
        _storyService.saveStoryToFirestore(uid, story);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _status = GenerationStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load saved stories from Firestore
  Future<void> loadUserStories(String? uid) async {
    if (uid == null || uid.isEmpty) return;
    final stories = await _storyService.getUserStories(uid);
    if (stories.isNotEmpty) {
      _savedStories = stories;
      notifyListeners();
    }
  }

  void setCurrentStory(StoryModel story) {
    _currentStory = story;
    notifyListeners();
  }
}
