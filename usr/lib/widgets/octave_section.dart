import 'package:flutter/material.dart';
import '../models/note.dart';
import 'piano_key.dart';

class OctaveSection extends StatelessWidget {
  final int octaveNumber;
  final double whiteKeyWidth;
  final double whiteKeyHeight;
  final double blackKeyWidth;
  final double blackKeyHeight;

  const OctaveSection({
    super.key,
    required this.octaveNumber,
    required this.whiteKeyWidth,
    required this.whiteKeyHeight,
    required this.blackKeyWidth,
    required this.blackKeyHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Define notes for this octave
    // C, D, E, F, G, A, B are white keys
    // C#, D#, F#, G#, A# are black keys
    
    final whiteNotes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    final blackNotes = ['C#', 'D#', 'F#', 'G#', 'A#'];
    
    // Helper to create note objects
    PianoNote createNote(String name, NoteType type, int index) {
      return PianoNote(
        id: "$name$octaveNumber",
        name: name,
        octave: octaveNumber,
        type: type,
        soundFile: "${name.replaceAll('#', 's')}$octaveNumber.mp3",
        indexInOctave: index,
      );
    }

    List<Widget> whiteKeys = [];
    for (int i = 0; i < whiteNotes.length; i++) {
      whiteKeys.add(PianoKey(
        note: createNote(whiteNotes[i], NoteType.white, i),
        width: whiteKeyWidth,
        height: whiteKeyHeight,
      ));
    }

    // Black keys positioning
    // C# is between C and D (index 0 and 1 of white keys)
    // D# is between D and E (index 1 and 2)
    // No black key between E and F
    // F# is between F and G
    // G# is between G and A
    // A# is between A and B
    
    // We use a Stack to overlay black keys
    return SizedBox(
      width: whiteKeyWidth * 7 + 14, // 7 keys + margins
      height: whiteKeyHeight,
      child: Stack(
        children: [
          // Layer 1: White Keys
          Row(
            children: whiteKeys,
          ),
          // Layer 2: Black Keys
          // Positions are relative to white key widths
          // C#
          Positioned(
            left: whiteKeyWidth * 0.65, 
            child: PianoKey(
              note: createNote('C#', NoteType.black, 0),
              width: blackKeyWidth,
              height: blackKeyHeight,
            ),
          ),
          // D#
          Positioned(
            left: whiteKeyWidth * 1.75, 
            child: PianoKey(
              note: createNote('D#', NoteType.black, 1),
              width: blackKeyWidth,
              height: blackKeyHeight,
            ),
          ),
          // F#
          Positioned(
            left: whiteKeyWidth * 3.75, 
            child: PianoKey(
              note: createNote('F#', NoteType.black, 2),
              width: blackKeyWidth,
              height: blackKeyHeight,
            ),
          ),
          // G#
          Positioned(
            left: whiteKeyWidth * 4.80, 
            child: PianoKey(
              note: createNote('G#', NoteType.black, 3),
              width: blackKeyWidth,
              height: blackKeyHeight,
            ),
          ),
          // A#
          Positioned(
            left: whiteKeyWidth * 5.85, 
            child: PianoKey(
              note: createNote('A#', NoteType.black, 4),
              width: blackKeyWidth,
              height: blackKeyHeight,
            ),
          ),
        ],
      ),
    );
  }
}
