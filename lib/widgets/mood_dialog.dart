import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class MoodDialog extends StatelessWidget {
  final VoidCallback onCompleted;

  const MoodDialog({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double dialogWidth = MediaQuery.of(context).size.width * 0.8;
        final double dialogPadding = MediaQuery.of(context).size.width * 0.05;

        return Container(
          width: dialogWidth,
          padding: EdgeInsets.all(dialogPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'How do you feel now?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCompleted();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildMoodButton(context, '😊', 'Happy'),
                    _buildMoodButton(context, '😌', 'Relaxed'),
                    _buildMoodButton(context, '😐', 'Neutral'),
                    _buildMoodButton(context, '😓', 'Tired'),
                    _buildMoodButton(context, '😡', 'Angry'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  // Close dialog but stay on the breathing screen
                  Navigator.of(context).pop();
                  onCompleted();
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodButton(BuildContext context, String emoji, String mood) {
    return GestureDetector(
      onTap: () async {
        // Save mood to database
        await DatabaseHelper.instance.saveMood(mood);
        // Close dialog but stay on the breathing screen
        if (context.mounted) {
          Navigator.of(context).pop();
          onCompleted();
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mood,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
