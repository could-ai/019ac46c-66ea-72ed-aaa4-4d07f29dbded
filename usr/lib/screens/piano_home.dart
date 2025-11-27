import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/piano_provider.dart';
import '../widgets/octave_section.dart';
import '../models/note.dart';

class PianoHome extends StatefulWidget {
  const PianoHome({super.key});

  @override
  State<PianoHome> createState() => _PianoHomeState();
}

class _PianoHomeState extends State<PianoHome> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to middle octaves after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(600); // Approximate middle C
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PianoProvider>(context);
    
    // Responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > screenHeight;
    
    final whiteKeyWidth = isLandscape ? 60.0 : 45.0;
    final whiteKeyHeight = isLandscape ? 250.0 : 200.0;
    final blackKeyWidth = whiteKeyWidth * 0.6;
    final blackKeyHeight = whiteKeyHeight * 0.6;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Pro Piano Studio"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(provider.showLabels ? Icons.label : Icons.label_off),
            onPressed: provider.toggleLabels,
            tooltip: "Toggle Labels",
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context, provider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls Area
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFF252525),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Recording Controls
                Row(
                  children: [
                    _buildControlBtn(
                      context,
                      icon: Icons.fiber_manual_record,
                      color: provider.isRecording ? Colors.red : Colors.grey,
                      label: provider.isRecording ? "REC" : "Record",
                      onTap: () {
                        if (provider.isRecording) {
                          provider.stopRecording();
                        } else {
                          provider.startRecording();
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildControlBtn(
                      context,
                      icon: provider.isPlayingBack ? Icons.stop : Icons.play_arrow,
                      color: provider.isPlayingBack ? Colors.amber : Colors.green,
                      label: provider.isPlayingBack ? "Stop" : "Play",
                      onTap: () {
                        if (provider.isPlayingBack) {
                          provider.stopPlayback();
                        } else {
                          // We need to reconstruct all notes to find them by ID
                          // In a real app, we'd have a better registry
                          List<PianoNote> allNotes = [];
                          for(int i=1; i<=7; i++) {
                             // Re-generate notes logic briefly to pass to player
                             // This is a simplification for the demo
                             final whiteNotes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
                             final blackNotes = ['C#', 'D#', 'F#', 'G#', 'A#'];
                             for (var n in whiteNotes) {
                               allNotes.add(PianoNote(id: "$n$i", name: n, octave: i, type: NoteType.white, soundFile: "", indexInOctave: 0));
                             }
                             for (var n in blackNotes) {
                               allNotes.add(PianoNote(id: "$n$i", name: n, octave: i, type: NoteType.black, soundFile: "", indexInOctave: 0));
                             }
                          }
                          provider.playRecording(allNotes);
                        }
                      },
                    ),
                  ],
                ),
                
                // Metronome Controls
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.timer, color: provider.isMetronomeOn ? Colors.blue : Colors.grey),
                        onPressed: provider.toggleMetronome,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${provider.bpm} BPM",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                            width: 100,
                            child: Slider(
                              value: provider.bpm.toDouble(),
                              min: 30,
                              max: 200,
                              activeColor: Colors.blue,
                              onChanged: (val) => provider.setBpm(val.toInt()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Info / Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            color: Colors.black,
            child: Text(
              provider.isRecording 
                  ? "Recording... ${provider.recordedEvents.length} events" 
                  : (provider.recordedEvents.isNotEmpty ? "Recorded: ${provider.recordedEvents.length} events" : "Ready"),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),

          // Piano Keyboard Area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  )
                ],
              ),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: 7, // 7 Octaves
                itemBuilder: (context, index) {
                  return OctaveSection(
                    octaveNumber: index + 1, // Start from Octave 1
                    whiteKeyWidth: whiteKeyWidth,
                    whiteKeyHeight: whiteKeyHeight,
                    blackKeyWidth: blackKeyWidth,
                    blackKeyHeight: blackKeyHeight,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn(BuildContext context, {
    required IconData icon, 
    required Color color, 
    required String label,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, PianoProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.volume_up),
                const SizedBox(width: 10),
                const Text("Volume"),
                Expanded(
                  child: Slider(
                    value: provider.volume,
                    onChanged: provider.setVolume,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Note: To hear real piano sounds, you must add .mp3 files to assets/sounds/ (e.g., C4.mp3). Currently using placeholders.", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
