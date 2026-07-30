import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused }

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  TtsState _ttsState = TtsState.stopped;

  TtsState get ttsState => _ttsState;

  // Initialize TTS configuration
  Future<void> initTts({
    required Function() onStart,
    required Function() onCompletion,
    required Function() onError,
    required Function() onPause,
    required Function() onContinue,
  }) async {
    await _flutterTts.setSpeechRate(0.45); // Gentle, calm reading speed for bedtime
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setStartHandler(() {
      _ttsState = TtsState.playing;
      onStart();
    });

    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
      onCompletion();
    });

    _flutterTts.setErrorHandler((msg) {
      _ttsState = TtsState.stopped;
      onError();
    });

    _flutterTts.setPauseHandler(() {
      _ttsState = TtsState.paused;
      onPause();
    });

    _flutterTts.setContinueHandler(() {
      _ttsState = TtsState.playing;
      onContinue();
    });
  }

  // Speak story text with appropriate language
  Future<void> speak(String text, String languageCode) async {
    final ttsLang = languageCode == 'en' ? 'en-US' : 'tr-TR';
    await _flutterTts.setLanguage(ttsLang);

    if (text.isNotEmpty) {
      _ttsState = TtsState.playing;
      await _flutterTts.speak(text);
    }
  }

  // Pause speech
  Future<void> pause() async {
    await _flutterTts.pause();
    _ttsState = TtsState.paused;
  }

  // Stop speech
  Future<void> stop() async {
    await _flutterTts.stop();
    _ttsState = TtsState.stopped;
  }

  // Set Speech Rate
  Future<void> setRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }
}
