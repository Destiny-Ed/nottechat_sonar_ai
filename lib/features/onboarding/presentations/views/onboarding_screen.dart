import 'package:flutter/material.dart';
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:notte_chat/features/chat/presentation/views/chat_screen.dart';
import 'package:notte_chat/features/subscription/presentation/provider/subscription_provider.dart';
import 'package:notte_chat/features/subscription/presentation/views/free_trial_paywall_screen.dart';
import 'package:notte_chat/shared/style/color.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Chat with any Documents',
      'description': 'Upload PDFs or Word docs and ask questions. Get answers instanly!',
      'image': 'assets/document_chat.jpeg', // Placeholder: Add image to assets
    },
    {
      'title': 'Save Time, Study Smart',
      'description': 'Summarize long papers or reports in seconds. Perfect for students and pros!',
      'image': 'assets/study_smart.png',
    },
    {
      'title': 'Offline Power',
      'description': 'Use NotteChat offline on all platform. Your documents, anywhere!',
      'image': 'assets/offline_mode.png',
    },
    {
      'title': '3-Day Free Trial',
      'description': 'Unlock unlimited chats with NotteChat Pro. Try it free for 3 days!',
      'image': 'assets/free_trial.jpeg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Log onboarding view
    AnalysisLogger.logEvent("onboarding_viewed", EventDataModel(value: "Onboarding Screen"));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToNextScreen(bool isSkip) async {
    if (!isSkip) {
      if (_currentPage + 1 != _onboardingData.length) {
        _pageController.nextPage(duration: Duration(seconds: 1), curve: Curves.ease);
        return;
      }
    }

    final proProvider = context.read<ProProvider>();
    AnalysisLogger.logEvent("onboarding_completed", EventDataModel(value: "Get Started - Page ${_currentPage + 1}"));

    if (proProvider.isProSubscribed) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatListScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FreeTrialPaywallScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor[900]!, primaryColor[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo and Skip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/nottechat_logo.png', // Add NotteChat logo to assets
                      width: 50,
                    ),
                    TextButton(
                      onPressed: () {
                        _navigateToNextScreen(true);
                      },
                      child: const Text('Skip', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    ),
                  ],
                ),
              ),
              // PageView for Onboarding Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(
                      _onboardingData[index]['title']!,
                      _onboardingData[index]['description']!,
                      _onboardingData[index]['image']!,
                    );
                  },
                ),
              ),
              // Dots Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_onboardingData.length, (index) => _buildDot(index)),
                ),
              ),
              // Get Started Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder:
                      (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: ElevatedButton(
                          onPressed: () {
                            _navigateToNextScreen(false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 5,
                            shadowColor: Colors.black45,
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1 ? 'Try Now' : 'Next',
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(String title, String description, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image with Fade Animation
          AnimatedBuilder(
            animation: _animationController,
            builder:
                (context, child) => Opacity(
                  opacity: 0.7 + 0.3 * _animationController.value,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      image: DecorationImage(image: AssetImage(imagePath)),
                    ),
                  ),
                ),
          ),
          const SizedBox(height: 20),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          // Description
          Text(description, style: const TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: _currentPage == index ? 12.0 : 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? secondaryColor : Colors.white70,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
