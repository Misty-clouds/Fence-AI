import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:fence_ai/view/pages/onboarding/onboarding2.dart';
import 'package:flutter/material.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Title animations - starts first
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Subtitle animations - starts after title with delay
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    // Button animation - starts last
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary1,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboarding1.png',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: SlideTransition(
                    position: _titleSlideAnimation,
                    child: Text(
                      'Welcome to Fense',
                      style: AppTextStyles.labelLarge(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _subtitleFadeAnimation,
                  child: SlideTransition(
                    position: _subtitleSlideAnimation,
                    child: Text(
                      'Discover, analyze, and maximize the potential of any land plot with the power of artificial intelligence.',
                      style: AppTextStyles.labelSubtitle(color: AppColors.secondary2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Spacer(),
                FadeTransition(
                  opacity: _buttonFadeAnimation,
                  child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder:(context) => Onboarding2(),));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary2,
                    foregroundColor: AppColors.primary1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTextStyles.regularTextBold(color: AppColors.primary1),
                  ),
                ),
                  ),
                ),
                const SizedBox(height: 15)
              ],
          ),
        ),
        ],
      ),
    );
  }
}
