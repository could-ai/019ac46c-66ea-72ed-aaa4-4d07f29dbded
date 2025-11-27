import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/note.dart';

class RecordedEvent {
  final String noteId;
  final int timestamp; // milliseconds since start

  RecordedEvent(this.noteId, this.timestamp);
}

class PianoProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  // We use a pool of players for polyphony (playing multiple notes at once)
  final List<AudioPlayer> _playerPool = List.generate(10, (_) => AudioPlayer());
  int _currentPlayerIndex = 0;

  bool _isRecording = false;
  bool _isPlayingBack = false;
  bool _showLabels = true;
  double _volume = 1.0;
  
  // Metronome
  bool _isMetronomeOn = false;
  int _bpm = 100;
  Timer? _metronomeTimer;

  // Recording
  final List<RecordedEvent> _recordedEvents = [];
  DateTime? _recordingStartTime;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlayingBack => _isPlayingBack;
  bool get showLabels => _showLabels;
  bool get isMetronomeOn => _isMetronomeOn;
  int get bpm => _bpm;
  double get volume => _volume;
  List<RecordedEvent> get recordedEvents => _recordedEvents;

  // Settings
  void toggleLabels() {
    _showLabels = !_showLabels;
    notifyListeners();
  }

  void setVolume(double val) {
    _volume = val;
    notifyListeners();
  }

  // Audio Logic
  Future<void> playNote(PianoNote note) async {
    // Visual feedback logic could go here if we tracked active keys in provider
    
    // Audio Playback
    // In a real app with assets, we would do:
    // await _playerPool[_currentPlayerIndex].play(AssetSource('sounds/${note.soundFile}'), volume: _volume);
    
    // Since we don't have assets, we'll just log it or try to play a placeholder if available.
    // For this demo, we assume assets exist.
    try {
      // Cycling through players to allow polyphony
      final player = _playerPool[_currentPlayerIndex];
      await player.setVolume(_volume);
      await player.stop(); // Stop previous sound on this channel
      
      // NOTE: Users need to add actual .mp3 or .wav files to assets/sounds/
      // e.g., C4.mp3, Db4.mp3, etc.
      // await player.play(AssetSource('sounds/${note.name}${note.octave}.mp3'));
      
      // For demo purposes without assets, we just print
      debugPrint("Playing note: ${note.displayName}");
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }

    _currentPlayerIndex = (_currentPlayerIndex + 1) % _playerPool.length;

    // Recording Logic
    if (_isRecording && _recordingStartTime != null) {
      final timestamp = DateTime.now().difference(_recordingStartTime!).inMilliseconds;
      _recordedEvents.add(RecordedEvent(note.id, timestamp));
      notifyListeners();
    }
  }

  // Recording Control
  void startRecording() {
    _isRecording = true;
    _recordedEvents.clear();
    _recordingStartTime = DateTime.now();
    notifyListeners();
  }

  void stopRecording() {
    _isRecording = false;
    _recordingStartTime = null;
    notifyListeners();
  }

  // Playback Control
  void playRecording(List<PianoNote> allNotes) async {
    if (_recordedEvents.isEmpty) return;
    
    _isPlayingBack = true;
    notifyListeners();

    final startTime = DateTime.now();
    
    // Sort events just in case
    _recordedEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (var event in _recordedEvents) {
      if (!_isPlayingBack) break; // Stop if cancelled

      final now = DateTime.now();
      final elapsed = now.difference(startTime).inMilliseconds;
      final waitTime = event.timestamp - elapsed;

      if (waitTime > 0) {
        await Future.delayed(Duration(milliseconds: waitTime));
      }

      if (!_isPlayingBack) break;

      // Find note and play
      try {
        final note = allNotes.firstWhere((n) => n.id == event.noteId);
        playNote(note);
      } catch (e) {
        // Note not found
      }
    }

    _isPlayingBack = false;
    notifyListeners();
  }

  void stopPlayback() {
    _isPlayingBack = false;
    notifyListeners();
  }

  // Metronome
  void toggleMetronome() {
    _isMetronomeOn = !_isMetronomeOn;
    if (_isMetronomeOn) {
      _startMetronome();
    } else {
      _metronomeTimer?.cancel();
    }
    notifyListeners();
  }

  void setBpm(int newBpm) {
    _bpm = newBpm.clamp(30, 300);
    if (_isMetronomeOn) {
      _metronomeTimer?.cancel();
      _startMetronome();
    }
    notifyListeners();
  }

  void _startMetronome() {
    final interval = 60000 / _bpm;
    _metronomeTimer = Timer.periodic(Duration(milliseconds: interval.round()), (timer) {
      // Play tick sound
      // _audioPlayer.play(AssetSource('sounds/metronome_tick.mp3'));
      debugPrint("Tick");
    });
  }
}
