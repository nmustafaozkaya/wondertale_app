import 'package:flutter/material.dart';
import '../core/services/tts_service.dart';

class TtsProvider extends ChangeNotifier {
  final TtsService _ttsService = TtsService();

  TtsState _state = TtsState.stopped;
  String _activeStoryId = '';
  double _speechRate = 0.45; // Gentle speed

  TtsState get state => _state;
  String get activeStoryId => _activeStoryId;
  double get speechRate => _speechRate;

  bool isPlaying(String storyId) => _state == TtsState.playing && _activeStoryId == storyId;
  bool isPaused(String storyId) => _state == TtsState.paused && _activeStoryId == storyId;

  TtsProvider() {
    _ttsService.initTts(
      onStart: () {
        _state = TtsState.playing;
        notifyListeners();
      },
      onCompletion: () {
        _state = TtsState.stopped;
        _activeStoryId = '';
        notifyListeners();
      },
      onError: () {
        _state = TtsState.stopped;
        _activeStoryId = '';
        notifyListeners();
      },
      onPause: () {
        _state = TtsState.paused;
        notifyListeners();
      },
      onContinue: () {
        _state = TtsState.playing;
        notifyListeners();
      },
    );
  }

  // Play narration for a given story
  Future<void> playStory({
    required String storyId,
    required String content,
    required String language,
  }) async {
    if (_activeStoryId == storyId && _state == TtsState.paused) {
      await _ttsService.speak(content, language);
    } else {
      await _ttsService.stop();
      _activeStoryId = storyId;
      await _ttsService.speak(content, language);
    }
  }

  // Pause playback
  Future<void> pause() async {
    await _ttsService.pause();
    _state = TtsState.paused;
    notifyListeners();
  }

  // Stop playback
  Future<void> stop() async {
    await _ttsService.stop();
    _state = TtsState.stopped;
    _activeStoryId = '';
    notifyListeners();
  }

  // Set Speech Rate
  Future<void> setRate(double rate) async {
    _speechRate = rate;
    await _ttsService.setRate(rate);
    notifyListeners();
  }
}
