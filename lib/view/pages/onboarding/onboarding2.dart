import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:fence_ai/view/pages/main/dashboard.dart';
import 'package:fence_ai/view/pages/onboarding/role_selection.dart';
import 'package:flutter/material.dart';

class Onboarding2 extends StatefulWidget {
  const Onboarding2({super.key});

  @override
  Onboarding2State createState() => Onboarding2State();
}

class Onboarding2State extends State<Onboarding2> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding content data
  final List<OnboardingContent> _pages = [
    OnboardingContent(
      title: 'AI-Powered Land\nDevelopment Intelligence',
      description:
          'Discover, analyze, and maximize the potential of any land plot with the power of artificial intelligence.',
    ),
    OnboardingContent(
      title: 'Get instant\nrecommendations',
      description:
          'Our AI evaluates zoning, market trends, and ROI to recommend the best development projects for your selected plot.',
    ),
    OnboardingContent(
      title: 'Compare Plots\nSide-by-Side',
      description:
          'Select multiple plots and compare them instantly. See detailed breakdowns of costs, potential returns, and development feasibility to choose the best option for your project.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to role
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionPage()),
      );
    }
  }

  void _skipOnboarding() {
    // Navigate to to role 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoleSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay for better text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: .95),
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPage(content: _pages[index]);
                    },
                  ),
                ),
                // Page indicators
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => PageIndicator(isActive: index == _currentPage),
                    ),
                  ),
                ),
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _skipOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary2,
                              foregroundColor: AppColors.primary1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: AppTextStyles.regularTextBold(
                                color: AppColors.primary1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary1,
                              foregroundColor: AppColors.secondary2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: AppTextStyles.regularTextBold(
                                color: AppColors.secondary2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Onboarding content model
class OnboardingContent {
  final String title;
  final String description;

  OnboardingContent({required this.title, required this.description});
}

// Onboarding page widget
class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            content.title,
            style: AppTextStyles.titleLarge(color: AppColors.text1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            content.description,
            style: AppTextStyles.regularText(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// Page indicator widget
class PageIndicator extends StatelessWidget {
  final bool isActive;

  const PageIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary1 : AppColors.secondary1,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
