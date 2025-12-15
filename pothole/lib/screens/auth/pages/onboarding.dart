import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/config/utils/assets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Spot it. Report it. Fix it.',
      'subtitle':
          'Empowering citizens to report potholes instantly and make roads safer for everyone.',
      'image': Assets.firstOnboarding, // Replace with your image assets
    },
    {
      'title': 'Your Click Can Fix a Road.',
      'subtitle':
          'Just take a photo and let our AI-powered system handle the rest.',
      'image': Assets.secondOnboarding,
    },
    {
      'title': 'Drive Change. One Pothole at a Time',
      'subtitle':
          'Play your part in transforming road safety — it starts with one report.',
      'image': Assets.thirdOnboarding,
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go("/enableLocation");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go("/enableLocation"),
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final data = onboardingData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Image section
                      SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Image.asset(data['image']!, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 40),
                      // Title
                      Text(
                        data['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Subtitle
                      Text(
                        data['subtitle']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Custom illustration
                    ],
                  ),
                );
              },
            ),
          ),
          // Bottom section with indicators and navigation
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? Colors.teal
                                : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Navigation button with progress indicator
                GestureDetector(
                  onTap: _nextPage,
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: (_currentPage + 1) / onboardingData.length,
                            strokeWidth: 7,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppPallet.buttonColor,
                            ),
                          ),
                        ),
                        // Inner button
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
