import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class OnboardingAuthPage extends StatefulWidget {
  const OnboardingAuthPage({Key? key}) : super(key: key);

  @override
  State<OnboardingAuthPage> createState() => _OnboardingAuthPageState();
}

class _OnboardingAuthPageState extends State<OnboardingAuthPage> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  final TextEditingController _emailController = TextEditingController(text: 'alex.supriyanto@bemind.ai');
  final TextEditingController _passwordController = TextEditingController(text: 'secret123');
  bool _obscurePassword = true;
  String _selectedGoal = 'Job Interview Prep';

  final List<Map<String, String>> _onboardingSlides = [
    {
      'title': '100% Personal Narrative Engine',
      'subtitle': 'AI converts your actual CV, voice notes, and background documents into custom fluency scripts.',
      'icon': 'brain',
    },
    {
      'title': '60-120 FPS High-Speed Teleprompter',
      'subtitle': 'Train reading pace, speech rhythm, and confidence with real-time WPM speed control.',
      'icon': 'speedometer',
    },
    {
      'title': 'On-Device Passive Learning',
      'subtitle': 'Extract unknown words instantly and get periodic lockscreen vocabulary notifications offline.',
      'icon': 'bell',
    },
  ];

  final List<String> _goals = [
    'Job Interview Prep',
    'IELTS/TOEFL',
    'Business Pitching',
    'Casual Conversation',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: AppTheme.neonDecoration(
                      gradientColors: [AppTheme.primaryCyan, AppTheme.primaryBlue],
                      borderRadius: 16,
                    ),
                    child: const Icon(
                      LucideIcons.brainCircuit,
                      size: 32,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BeMind',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'AI-Native Fluency Builder',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryCyan.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Carousel
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentSlide = index;
                    });
                  },
                  itemCount: _onboardingSlides.length,
                  itemBuilder: (context, index) {
                    final slide = _onboardingSlides[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.glassDecoration(
                        borderColor: AppTheme.primaryCyan.withOpacity(0.3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            index == 0
                                ? LucideIcons.sparkles
                                : index == 1
                                    ? LucideIcons.zap
                                    : LucideIcons.bellRing,
                            size: 36,
                            color: AppTheme.primaryCyan,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['subtitle']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingSlides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentSlide == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentSlide == index
                          ? AppTheme.primaryCyan
                          : AppTheme.surfaceBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Goal Selector Section
              const Text(
                'Select Your Primary Learning Focus',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _goals.map((goal) {
                  final isSelected = _selectedGoal == goal;
                  return ChoiceChip(
                    label: Text(goal),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedGoal = goal;
                        });
                        provider.updateTargetGoal(goal);
                      }
                    },
                    selectedColor: AppTheme.primaryCyan,
                    backgroundColor: AppTheme.surfaceLight,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryCyan
                            : AppTheme.surfaceBorder,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Auth Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign In to BeMind',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(LucideIcons.mail, size: 18, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.surfaceBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(LucideIcons.lock, size: 18, color: AppTheme.textMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.surfaceBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Button
                    ElevatedButton(
                      onPressed: () {
                        provider.login(_emailController.text, _passwordController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged in successfully! Welcome to BeMind.'),
                            backgroundColor: AppTheme.accentEmerald,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.primaryCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Continue to Dashboard',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Social Auth Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.login('google.user@bemind.ai', 'google123');
                      },
                      icon: const Icon(LucideIcons.globe, size: 18, color: AppTheme.textPrimary),
                      label: const Text('Google', style: TextStyle(color: AppTheme.textPrimary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.surfaceBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.login('apple.user@bemind.ai', 'apple123');
                      },
                      icon: const Icon(LucideIcons.apple, size: 18, color: AppTheme.textPrimary),
                      label: const Text('Apple', style: TextStyle(color: AppTheme.textPrimary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.surfaceBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
