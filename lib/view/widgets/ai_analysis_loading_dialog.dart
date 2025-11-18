import 'package:flutter/material.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'dart:math' as math;

class AIAnalysisLoadingDialog extends StatefulWidget {
  const AIAnalysisLoadingDialog({super.key});

  @override
  State<AIAnalysisLoadingDialog> createState() => _AIAnalysisLoadingDialogState();
}

class _AIAnalysisLoadingDialogState extends State<AIAnalysisLoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _textController;
  int _currentMessageIndex = 0;

  final List<String> _loadingMessages = [
    'Analyzing location data...',
    'Gathering insights from surroundings...',
    'Pulling nearby infrastructure data...',
    'Researching land topological structure...',
    'Evaluating development potential...',
    'Consulting AI knowledge base...',
    'Processing environmental factors...',
    'Calculating optimal recommendations...',
    'Finalizing comprehensive analysis...',
  ];

  @override
  void initState() {
    super.initState();

    // Pulse animation for the glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Rotation animation for the outer ring
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Text fade animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Cycle through messages
    _cycleMessages();
  }

  void _cycleMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
        _textController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary1.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated glowing hub
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulsing glow
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 150 + (_pulseController.value * 30),
                        height: 150 + (_pulseController.value * 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary1.withOpacity(0.3 * (1 - _pulseController.value)),
                              AppColors.primary1.withOpacity(0.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Rotating outer ring
                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateController.value * 2 * math.pi,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary1.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CustomPaint(
                            painter: _ArcPainter(
                              color: AppColors.primary1,
                              progress: _rotateController.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Center glowing core
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary1.withOpacity(0.9),
                              AppColors.primary1.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary1.withOpacity(0.6 * _pulseController.value),
                              blurRadius: 20 + (10 * _pulseController.value),
                              spreadRadius: 5 * _pulseController.value,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                  ),
                  
                  // Inner particles
                  ...List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        final angle = (_rotateController.value * 2 * math.pi) + 
                                     (index * 2 * math.pi / 3);
                        return Transform.translate(
                          offset: Offset(
                            math.cos(angle) * 45,
                            math.sin(angle) * 45,
                          ),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary1.withOpacity(0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary1.withOpacity(0.5),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // AI Analysis text
            Text(
              'AI Analysis',
              style: AppTextStyles.titleMedium().copyWith(
                fontSize: 22,
                color: AppColors.primary1,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Animated status message
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: Curves.easeIn.transform(_textController.value),
                  child: Text(
                    _loadingMessages[_currentMessageIndex],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.regularText().copyWith(
                      color: AppColors.text2,
                      height: 1.5,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 8),
            
            // Progress indicator
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.bg,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary1.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double progress;

  _ArcPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 0.6; // 108 degrees arc

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
