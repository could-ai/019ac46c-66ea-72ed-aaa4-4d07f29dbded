import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/piano_provider.dart';

class PianoKey extends StatefulWidget {
  final PianoNote note;
  final double width;
  final double height;

  const PianoKey({
    super.key,
    required this.note,
    required this.width,
    required this.height,
  });

  @override
  State<PianoKey> createState() => _PianoKeyState();
}

class _PianoKeyState extends State<PianoKey> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PianoProvider>(context);
    final isWhite = widget.note.type == NoteType.white;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        provider.playNote(widget.note);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.symmetric(horizontal: isWhite ? 1.0 : 0),
        decoration: BoxDecoration(
          color: isWhite
              ? (_isPressed ? Colors.grey[300] : Colors.white)
              : (_isPressed ? Colors.grey[800] : Colors.black),
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(4),
            bottomRight: const Radius.circular(4),
            topLeft: isWhite ? Radius.zero : const Radius.circular(0),
            topRight: isWhite ? Radius.zero : const Radius.circular(0),
          ),
          border: isWhite ? Border.all(color: Colors.black12) : null,
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 2,
              ),
          ],
          gradient: isWhite && !_isPressed
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFF0F0F0)],
                )
              : (isWhite ? null : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF333333), Colors.black],
                )),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (provider.showLabels && isWhite)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.note.name,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.width * 0.3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
