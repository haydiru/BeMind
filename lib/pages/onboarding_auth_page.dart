import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isRegisterMode = false;
  bool _isLoading = false;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedGoal = 'Job Interview Prep';

  final List<Map<String, String>> _onboardingSlides = [
    {
      'title': '100% Personal Narrative Engine',
      'subtitle': 'AI converts your actual CV, voice notes, and background documents into custom fluency scripts.',
    },
    {
      'title': '60-120 FPS High-Speed Teleprompter',
      'subtitle': 'Train reading pace, speech rhythm, and confidence with real-time WPM speed control.',
    },
    {
      'title': 'On-Device Passive Learning',
      'subtitle': 'Extract unknown words instantly and get periodic lockscreen vocabulary notifications offline.',
    },
  ];

  final List<String> _goals = [
    'Job Interview Prep',
    'IELTS/TOEFL',
    'Business Pitching',
    'Casual Conversation',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─── LOGIN HANDLER ──────────────────────────────────────────────────────────
  Future<void> _handleLogin(AppProvider provider) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Harap isi Email dan Password!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final supaUser = response.user;
      if (supaUser != null) {
        final userName = supaUser.userMetadata?['name'] ??
            supaUser.userMetadata?['full_name'] ??
            email.split('@').first;
        final targetGoal = supaUser.userMetadata?['target_goal'] ?? 'Job Interview Prep';
        provider.loginWithProfile(
          id: supaUser.id,
          name: userName,
          email: email,
          targetGoal: targetGoal,
        );
        _showSnackBar('Selamat Datang Kembali, $userName!');
      } else {
        _showSnackBar('Login gagal. Periksa email dan password Anda.', isError: true);
      }
    } on AuthException catch (e) {
      _showSnackBar('Login gagal: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi. Coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── REGISTER HANDLER ───────────────────────────────────────────────────────
  Future<void> _handleRegister(AppProvider provider) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Harap lengkapi Nama, Email, dan Password!', isError: true);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password minimal 6 karakter!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'target_goal': _selectedGoal,
        },
      );

      final supaUser = response.user;
      if (supaUser != null) {
        provider.loginWithProfile(
          id: supaUser.id,
          name: name,
          email: email,
          targetGoal: _selectedGoal,
        );
        _showSnackBar('Akun Berhasil Dibuat! Selamat Datang, $name 🎉');
      } else {
        _showSnackBar(
          'Cek email kamu untuk konfirmasi, lalu login!',
          isError: false,
        );
      }
    } on AuthException catch (e) {
      _showSnackBar('Pendaftaran gagal: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi. Coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── GOOGLE GMAIL LOGIN ──────────────────────────────────────────────────────
  Future<void> _handleGoogleLogin(AppProvider provider) async {
    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.bemind://login-callback/',
      );
    } on AuthException {
      _showSnackBar(
        'Google Login belum diaktifkan di Supabase Dashboard.\nAktifkan di: Authentication → Providers → Google',
        isError: true,
      );
    } catch (_) {
      _showSnackBar('Gagal memulai Google Login. Coba login dengan email.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: isError ? AppTheme.accentRose : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Midnight Obsidian Base
      body: Stack(
        children: [
          // ─── ATMOSPHERIC BACKGROUND SHADERS & GLOWS ───────────────────────
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.18),
                    blurRadius: 140,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // ─── BRAND LOGO HEADER ─────────────────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.brainCircuit,
                                size: 36,
                                color: Color(0xFF06B6D4),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'BeMind',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    'AI-NATIVE',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF06B6D4),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'English Fluency Builder',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ─── GLASSMORPHIC ONBOARDING CAROUSEL ─────────────────────────
                      Container(
                        height: 135,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentSlide = index),
                          itemCount: _onboardingSlides.length,
                          itemBuilder: (context, index) {
                            final slide = _onboardingSlides[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        index == 0
                                            ? LucideIcons.sparkles
                                            : index == 1
                                                ? LucideIcons.zap
                                                : LucideIcons.bellRing,
                                        size: 20,
                                        color: const Color(0xFF06B6D4),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        slide['title']!,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    slide['subtitle']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: const Color(0xFF94A3B8),
                                      height: 1.4,
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
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentSlide == index ? const Color(0xFF06B6D4) : const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: _currentSlide == index
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF06B6D4).withValues(alpha: 0.5),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ─── GOOGLE LOGIN BUTTON ──────────────────────────────────────
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _handleGoogleLogin(provider),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.globe, size: 16, color: Color(0xFFEA4335)),
                        ),
                        label: Text(
                          'Masuk dengan Gmail / Google',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.6),
                          side: BorderSide(
                            color: const Color(0xFF334155).withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999), // Pill radius
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: const Color(0xFF334155).withValues(alpha: 0.6))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'atau gunakan email',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                          ),
                          Expanded(child: Divider(color: const Color(0xFF334155).withValues(alpha: 0.6))),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ─── GLASSMORPHIC AUTH FORM CONTAINER ──────────────────────────
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Dual Pill Tab Switcher
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B0F19),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isRegisterMode = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: !_isRegisterMode ? const Color(0xFF06B6D4) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(999),
                                          boxShadow: !_isRegisterMode
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                                                    blurRadius: 10,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          'Masuk',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: !_isRegisterMode ? const Color(0xFF0B0F19) : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isRegisterMode = true),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _isRegisterMode ? const Color(0xFF06B6D4) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(999),
                                          boxShadow: _isRegisterMode
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                                                    blurRadius: 10,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          'Daftar Akun',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _isRegisterMode ? const Color(0xFF0B0F19) : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // Full Name Field (Register Mode Only)
                            if (_isRegisterMode) ...[
                              Text(
                                'Nama Lengkap',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _nameController,
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nama lengkap kamu',
                                  hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF475569), fontSize: 13),
                                  prefixIcon: const Icon(LucideIcons.user, size: 18, color: Color(0xFF06B6D4)),
                                  filled: true,
                                  fillColor: const Color(0xFF0B0F19),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFF1E293B)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFF1E293B)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Email Field
                            Text(
                              'Alamat Email',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _emailController,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'contoh: nama@email.com',
                                hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF475569), fontSize: 13),
                                prefixIcon: const Icon(LucideIcons.mail, size: 18, color: Color(0xFF06B6D4)),
                                filled: true,
                                fillColor: const Color(0xFF0B0F19),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Password Field
                            Text(
                              'Kata Sandi (Password)',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Masukkan kata sandi',
                                hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF475569), fontSize: 13),
                                prefixIcon: const Icon(LucideIcons.lock, size: 18, color: Color(0xFF06B6D4)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                    size: 18,
                                    color: const Color(0xFF64748B),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: const Color(0xFF0B0F19),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
                                ),
                              ),
                            ),

                            // Target Goal Selector (Register Mode Only)
                            if (_isRegisterMode) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Fokus Utama Belajar:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _goals.map((goal) {
                                  final isSelected = _selectedGoal == goal;
                                  return ChoiceChip(
                                    label: Text(goal, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) setState(() => _selectedGoal = goal);
                                    },
                                    selectedColor: const Color(0xFF06B6D4),
                                    backgroundColor: const Color(0xFF0B0F19),
                                    labelStyle: GoogleFonts.plusJakartaSans(
                                      color: isSelected ? const Color(0xFF0B0F19) : const Color(0xFF94A3B8),
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                      side: BorderSide(
                                        color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Primary Action Button (Gradient Cyan to Sapphire)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF06B6D4), Color(0xFF0566D9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => _isRegisterMode ? _handleRegister(provider) : _handleLogin(provider),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: const Color(0xFF0B0F19),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B0F19)),
                                      )
                                    : Text(
                                        _isRegisterMode ? 'Daftar & Buat Akun BeMind' : 'Masuk ke Aplikasi',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0B0F19),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Bottom Toggle Prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRegisterMode ? 'Sudah memiliki akun BeMind?' : 'Belum memiliki akun?',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
                            child: Text(
                              _isRegisterMode ? 'Masuk di sini' : 'Daftar sekarang',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF06B6D4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
