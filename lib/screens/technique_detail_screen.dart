import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import 'breathing_screen.dart'; // For navigation

class TechniqueDetailScreen extends StatefulWidget {
  final BreathingTechnique technique;

  const TechniqueDetailScreen({super.key, required this.technique});

  @override
  State<TechniqueDetailScreen> createState() => _TechniqueDetailScreenState();
}

class _TechniqueDetailScreenState extends State<TechniqueDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to go behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2F4F4F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.technique.name,
          style: GoogleFonts.lato(
              fontSize: 20, // Slightly smaller for AppBar
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F4F4F)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Colors.white],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 60, 20,
                    120), // Padding top for appbar, bottom for button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Description'),
                    const SizedBox(height: 8),
                    Text(
                      widget.technique.description,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: const Color(0xFF333333),
                        height: 1.4, // Line height
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Benefits'),
                    const SizedBox(height: 8),
                    ...widget.technique.benefits.map((benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      color: Color(0xFF333333), fontSize: 16)),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: const Color(0xFF333333),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Instructions'),
                    const SizedBox(height: 8),
                    ...widget.technique.instructions
                        .map((instruction) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${widget.technique.instructions.indexOf(instruction) + 1}. ',
                                      style: TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      instruction,
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        color: const Color(0xFF333333),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                  ],
                ),
              ),
            ),
            // Start Button aligned at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pass the specific technique to the BreathingScreen
                      Navigator.pushReplacement(
                        // Use replace to avoid back to details
                        context,
                        MaterialPageRoute(
                          builder: (context) => BreathingScreen(
                            technique:
                                widget.technique, // Pass the selected technique
                          ),
                        ),
                      );
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('Breathing screen navigation TBD')),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4682B4),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(25),
                      elevation: 5,
                    ),
                    child: Text(
                      'Start',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lato(
        fontSize: 20, // Slightly smaller than main title
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2F4F4F),
      ),
    );
  }
}
