import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../auth/login_screen.dart';
import '../../utils/page_transitions.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// 3-Slide interactive onboarding screen with responsive sizing.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Discover Your Plants 🌿',
      description: 'Snap a photo or upload an image to instantly identify any plant with smart care insights.',
      icon: Icons.center_focus_strong_rounded,
    ),
    OnboardingPage(
      title: 'Keep Your Garden Thriving 🌱',
      description: 'Access tailored watering, light, soil, and temperature guides designed specifically for your plants.',
      icon: Icons.spa_rounded,
    ),
    OnboardingPage(
      title: 'Never Forget Plant Care 💧',
      description: 'Set custom reminders for watering, fertilizing, and misting so your greenery stays fresh year-round.',
      icon: Icons.alarm_on_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      AppPageRoute.slideUp(const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: _currentPage < _pages.length - 1
                    ? TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'Skip',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isShort = constraints.maxHeight < 500;
                      final circleSize = isShort ? 120.0 : 160.0;
                      final iconSize = isShort ? 60.0 : 80.0;
                      final topSpace = isShort ? 16.0 : 36.0;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: isShort ? 10 : 20),
                            // Central Visual Icon Circle
                            Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(128),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.secondary.withAlpha(76),
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                item.icon,
                                size: iconSize,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: topSpace),

                            // Title
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.displayMedium.copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Navigation Indicators & Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  // Smooth Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dynamic Button (Next or Get Started)
                  AppButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started 🌿' : 'Continue',
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
