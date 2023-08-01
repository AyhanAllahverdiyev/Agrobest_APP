import 'dart:async';
import 'package:flutter/material.dart';

void showMessageNegative(
    BuildContext context, List<String> errorMessages, String type) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            for (var message in errorMessages)
              Text(
                message,
                style: TextStyle(fontSize: 17),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

void showMessagePositive(
    BuildContext context, List<String> errorMessages, String type) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check,
              size: 60,
              color: Colors.indigo,
            ),
            const SizedBox(height: 30),
            for (var message in errorMessages)
              Text(message, style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    },
  );
}

void showFadeawayMessage(BuildContext context, String message) {
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: FadeawayMessage(message: message),
    ),
  );

  Overlay.of(context)?.insert(overlayEntry);
}

class FadeawayMessage extends StatefulWidget {
  final String message;

  const FadeawayMessage({required this.message});

  @override
  _FadeawayMessageState createState() => _FadeawayMessageState();
}

class _FadeawayMessageState extends State<FadeawayMessage> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _startFadeOutTimer();
  }

  void _startFadeOutTimer() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          widget.message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
