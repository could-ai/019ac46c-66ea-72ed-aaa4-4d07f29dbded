enum NoteType { white, black }

class PianoNote {
  final String id;
  final String name;
  final int octave;
  final NoteType type;
  final String soundFile;
  
  // Position in the octave (0-11)
  final int indexInOctave;

  PianoNote({
    required this.id,
    required this.name,
    required this.octave,
    required this.type,
    required this.soundFile,
    required this.indexInOctave,
  });

  String get displayName => "$name$octave";
}
