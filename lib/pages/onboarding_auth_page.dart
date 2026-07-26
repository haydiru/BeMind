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
      'subtitle': 'Ubah CV, rekaman suara, dan catatan karirmu menjadi naskah kelancaran bahasa Inggris personal.',
    },
    {
      'title': 'High-Speed Teleprompter Reader',
      'subtitle': 'Latih kelancaran, ritme bicara, dan percaya diri dengan kontrol kecepatan baca dinamis.',
    },
    {
      'title': 'On-Device Passive Learning',
      'subtitle': 'Simpan kosakata asing instan dan dapatkan notifikasi pengingat otomatis di lockscreen.',
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
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // PRISTINE AIRY LIGHT CANVAS
      body: Stack(
        children: [
          // Subtle Soft Gradient Orbs Background
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D9488).withValues(alpha: 0.08), // Soft Teal Orb
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.07), // Soft Indigo Orb
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),

                      // ─── ELEGANT BRAND LOGO HEADER (COMPACT) ───────────────────────
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1), // Soft Emerald Tint
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.brainCircuit,
                                size: 26,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'BeMind',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'AI-NATIVE',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0D9488),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'English Fluency Builder',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ─── PRISTINE CAROUSEL CARD (VALUE PROP - COMPACT 96px) ────────
                      Container(
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentSlide = index),
                          itemCount: _onboardingSlides.length,
                          itemBuilder: (context, index) {
                            final slide = _onboardingSlides[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                        size: 15,
                                        color: const Color(0xFF0D9488),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        slide['title']!,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    slide['subtitle']!,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFF64748B),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Dots Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingSlides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentSlide == index ? 18 : 6,
                            height: 5,
                            decoration: BoxDecoration(
                              color: _currentSlide == index ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ─── GOOGLE LOGIN BUTTON ──────────────────────────────────────
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleGoogleLogin(provider),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: CustomPaint(
                                size: const Size(16, 16),
                                painter: GoogleLogoPainter(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Masuk dengan Google',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: const Color(0xFFE2E8F0))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'atau dengan email',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                          Expanded(child: Divider(color: const Color(0xFFE2E8F0))),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ─── FLOATING WHITE AUTH CARD ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Dual Pill Tab Switcher
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isRegisterMode = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        decoration: BoxDecoration(
                                          color: !_isRegisterMode ? const Color(0xFF0D9488) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(999),
                                          boxShadow: !_isRegisterMode
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
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
                                            color: !_isRegisterMode ? Colors.white : const Color(0xFF64748B),
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
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        decoration: BoxDecoration(
                                          color: _isRegisterMode ? const Color(0xFF0D9488) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(999),
                                          boxShadow: _isRegisterMode
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
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
                                            color: _isRegisterMode ? Colors.white : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Full Name Field (Register Mode Only)
                            if (_isRegisterMode) ...[
                              Text(
                                'Nama Lengkap',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _nameController,
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nama lengkap kamu',
                                  hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13),
                                  prefixIcon: const Icon(LucideIcons.user, size: 18, color: Color(0xFF0D9488)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Email Field
                            Text(
                              'Alamat Email',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _emailController,
                              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'contoh: nama@email.com',
                                hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13),
                                prefixIcon: const Icon(LucideIcons.mail, size: 18, color: Color(0xFF0D9488)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Password Field
                            Text(
                              'Kata Sandi (Password)',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Masukkan kata sandi',
                                hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13),
                                prefixIcon: const Icon(LucideIcons.lock, size: 18, color: Color(0xFF0D9488)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                    size: 18,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                                ),
                              ),
                            ),

                            // Target Goal Selector (Register Mode Only)
                            if (_isRegisterMode) ...[
                              const SizedBox(height: 14),
                              Text(
                                'Fokus Utama Belajar:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
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
                                    selectedColor: const Color(0xFF0D9488),
                                    backgroundColor: const Color(0xFFF8FAFC),
                                    labelStyle: GoogleFonts.plusJakartaSans(
                                      color: isSelected ? Colors.white : const Color(0xFF475569),
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                      side: BorderSide(
                                        color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            const SizedBox(height: 22),

                            // Primary Action Button (Gradient Soft Emerald to Royal Indigo)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0D9488), Color(0xFF6366F1)], // Emerald to Indigo
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0D9488).withValues(alpha: 0.35),
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
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(
                                        _isRegisterMode ? 'Daftar & Buat Akun BeMind' : 'Masuk ke Aplikasi',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Bottom Toggle Prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRegisterMode ? 'Sudah memiliki akun BeMind?' : 'Belum memiliki akun?',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
                            child: Text(
                              _isRegisterMode ? 'Masuk di sini' : 'Daftar sekarang',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0D9488),
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

/// CustomPainter for rendering authentic 4-color Google G Logo
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;

    // Paints for 4 Google brand colors
    final Paint bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final Paint greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final Paint redPaint = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;

    // Outer & Inner Radius for G Ring
    final double outerR = r;
    final double innerR = r * 0.52;

    final Rect outerRect = Rect.fromCircle(center: Offset(cx, cy), radius: outerR);
    final Rect innerRect = Rect.fromCircle(center: Offset(cx, cy), radius: innerR);

    // Helper to draw ring segment arc
    Path createSegment(double startAngleRad, double sweepAngleRad) {
      final Path path = Path();
      path.arcTo(outerRect, startAngleRad, sweepAngleRad, false);
      path.arcTo(innerRect, startAngleRad + sweepAngleRad, -sweepAngleRad, false);
      path.close();
      return path;
    }

    // 1. Red Top Arc (-0.75 rad to ~2.2 rad)
    canvas.drawPath(createSegment(-0.75, 2.15), redPaint);

    // 2. Yellow Left Arc (~1.4 rad to ~1.2 rad)
    canvas.drawPath(createSegment(1.4, 1.2), yellowPaint);

    // 3. Green Bottom Arc (~2.6 rad to ~1.2 rad)
    canvas.drawPath(createSegment(2.6, 1.25), greenPaint);

    // 4. Blue Right Arc & Horizontal Bar
    final Path blueSegment = createSegment(-0.75, 0.95);
    canvas.drawPath(blueSegment, bluePaint);

    // Blue Center Horizontal Bar
    final Path barPath = Path()
      ..moveTo(cx, cy - r * 0.24)
      ..lineTo(cx + outerR, cy - r * 0.24)
      ..lineTo(cx + outerR, cy + r * 0.24)
      ..lineTo(cx, cy + r * 0.24)
      ..close();
    canvas.drawPath(barPath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
