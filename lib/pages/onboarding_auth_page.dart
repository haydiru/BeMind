import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_provider.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BeMind — Gamified Duolingo-Inspired Onboarding & Auth Page
// High-energy 3D elevated buttons, mascot speech bubble, 3D goal cards & tactile controls
// ──────────────────────────────────────────────────────────────────────────────

class OnboardingAuthPage extends StatefulWidget {
  const OnboardingAuthPage({Key? key}) : super(key: key);

  @override
  State<OnboardingAuthPage> createState() => _OnboardingAuthPageState();
}

class _OnboardingAuthPageState extends State<OnboardingAuthPage>
    with SingleTickerProviderStateMixin {
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

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final List<_SlideData> _slides = [
    _SlideData(
      icon: LucideIcons.sparkles,
      title: '100% Personal Narrative',
      subtitle: 'Ubah CV & suaramu jadi naskah kelancaran bahasa Inggris.',
    ),
    _SlideData(
      icon: LucideIcons.zap,
      title: 'High-Speed Teleprompter',
      subtitle: 'Latih ritme bicara & tingkatkan percaya diri real-time.',
    ),
    _SlideData(
      icon: LucideIcons.bellRing,
      title: 'Passive Flashcards Engine',
      subtitle: 'Kosakata baru otomatis di lockscreen HP kamu.',
    ),
  ];

  final List<_GoalData> _goals = [
    _GoalData(
      id: 'Job Interview Prep',
      title: 'Job Interview',
      desc: 'Naskah wawancara kerja & CV',
      icon: LucideIcons.briefcase,
      badge: 'POPULER',
      color: const Color(0xFF0D9488),
    ),
    _GoalData(
      id: 'IELTS/TOEFL',
      title: 'IELTS / TOEFL',
      desc: 'Speaking test & essay narrative',
      icon: LucideIcons.graduationCap,
      badge: 'TARGET TOP',
      color: const Color(0xFF6366F1),
    ),
    _GoalData(
      id: 'Business Pitching',
      title: 'Business Pitch',
      desc: 'Presentasi & pitching investor',
      icon: LucideIcons.trendingUp,
      badge: 'KARIR',
      color: const Color(0xFFF59E0B),
    ),
    _GoalData(
      id: 'Casual Conversation',
      title: 'Conversation',
      desc: 'Percakapan sehari-hari & sosial',
      icon: LucideIcons.messagesSquare,
      badge: 'KESEHARIAN',
      color: const Color(0xFFEC4899),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─── LOGIN ──────────────────────────────────────────────────────────────────
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
        final targetGoal =
            supaUser.userMetadata?['target_goal'] ?? 'Job Interview Prep';
        provider.loginWithProfile(
          id: supaUser.id,
          name: userName,
          email: email,
          targetGoal: targetGoal,
        );
        _showSnackBar('Selamat Datang Kembali, $userName! 🚀');
      } else {
        _showSnackBar('Login gagal. Periksa email dan password Anda.',
            isError: true);
      }
    } on AuthException catch (e) {
      _showSnackBar('Login gagal: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi. Coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── REGISTER ──────────────────────────────────────────────────────────────
  Future<void> _handleRegister(AppProvider provider) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Harap lengkapi Nama, Email, dan Password!',
          isError: true);
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
        data: {'name': name, 'target_goal': _selectedGoal},
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
        _showSnackBar('Cek email kamu untuk konfirmasi, lalu login!');
      }
    } on AuthException catch (e) {
      _showSnackBar('Pendaftaran gagal: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi. Coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── NATIVE GOOGLE SIGN-IN ────────────────────────────────────────────────
  Future<void> _handleGoogleLogin(AppProvider provider) async {
    setState(() => _isLoading = true);

    try {
      const webClientId =
          '659983765395-3apa3crilf79tk18ip9c443evec5ul7t.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        _showSnackBar('Google Sign-In gagal: tidak mendapat token.',
            isError: true);
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final supaUser = response.user;
      if (supaUser != null) {
        final userName = supaUser.userMetadata?['full_name'] ??
            supaUser.userMetadata?['name'] ??
            googleUser.displayName ??
            googleUser.email.split('@').first;
        final userEmail = supaUser.email ?? googleUser.email;

        provider.loginWithProfile(
          id: supaUser.id,
          name: userName,
          email: userEmail,
          targetGoal:
              supaUser.userMetadata?['target_goal'] ?? 'Job Interview Prep',
        );
        _showSnackBar('Selamat Datang, $userName! 🎉');
      } else {
        _showSnackBar('Login Google gagal. Coba lagi.', isError: true);
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      _showSnackBar(
        'Google Login gagal. Pastikan akun Google aktif.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final bottomInset = mq.viewInsets.bottom;

    final bool isCompact = screenH < 700 || bottomInset > 100;
    final double topGap = isCompact ? 8 : 16;
    final double sectionGap = isCompact ? 10 : 14;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ── Background Ambient Blobs ──
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D9488).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
              ),
            ),
          ),

          // ── Main Scrollable Content ──
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                            20, topGap, 20, 24 + bottomInset * 0.1),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // ── 1. Duolingo Mascot + Speech Bubble Hero ──
                            _buildMascotHeroBanner(isCompact),
                            SizedBox(height: sectionGap),

                            // ── 2. Value Prop Carousel ──
                            _buildCarousel(isCompact ? 74 : 86),
                            const SizedBox(height: 6),
                            _buildDotsIndicator(),
                            SizedBox(height: sectionGap),

                            // ── 3. Google Sign-In 3D Button ──
                            _buildGoogle3DButton(provider),
                            SizedBox(height: sectionGap),

                            // ── 4. Divider ──
                            _buildDivider(),
                            SizedBox(height: sectionGap),

                            // ── 5. Gamified Auth Card (3D Form) ──
                            _buildAuthCard(provider, isCompact),
                            const SizedBox(height: 14),

                            // ── 6. Bottom Switcher ──
                            _buildBottomToggle(),
                            const SizedBox(height: 12),
                          ]),
                        ),
                      ),
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

  // ═══════════════════════════════════════════════════════════════════════════
  //  WIDGET BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// 🦜 Duolingo-Style Mascot + Speech Bubble Header
  Widget _buildMascotHeroBanner(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFCBD5E1),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mascot Icon Badge
          Container(
            width: isCompact ? 54 : 64,
            height: isCompact ? 54 : 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF0F766E), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF0F766E),
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.sparkles,
                  color: const Color(0xFFFEF08A),
                  size: isCompact ? 22 : 26,
                ),
                Text(
                  'BeMind',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Speech Bubble Container
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0), width: 1.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _isRegisterMode
                                ? 'Halo! Siap jadi fasih?'
                                : 'Selamat Datang Kembali!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isCompact ? 12 : 13,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.zap, size: 13, color: Color(0xFFEAB308)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isRegisterMode
                            ? 'Pilih tujuanmu & raih percakapan bahasa Inggris 100% lancar.'
                            : 'Lanjutkan latihan naskah & kelancaran bicaramu hari ini!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF166534),
                          height: 1.3,
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

  Widget _buildCarousel(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE2E8F0),
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentSlide = i),
        itemCount: _slides.length,
        itemBuilder: (context, index) {
          final slide = _slides[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(slide.icon, size: 15, color: const Color(0xFF0D9488)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        slide.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentSlide == i ? 22 : 8,
          height: 6,
          decoration: BoxDecoration(
            color: _currentSlide == i
                ? const Color(0xFF0D9488)
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  /// 🔘 Duolingo 3D Elevated Google Sign-In Card
  Widget _buildGoogle3DButton(AppProvider provider) {
    return _Duolingo3DTactileButton(
      backgroundColor: Colors.white,
      shadowColor: const Color(0xFFCBD5E1),
      borderColor: const Color(0xFFE2E8F0),
      onPressed: _isLoading ? null : () => _handleGoogleLogin(provider),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/google_logo.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Masuk dengan Google',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFCBD5E1), thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ATAU DENGAN EMAIL',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFCBD5E1), thickness: 1.5)),
      ],
    );
  }

  Widget _buildAuthCard(AppProvider provider, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFCBD5E1),
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 3D Segmented Tab Switcher ──
          _build3DTabSwitcher(),
          SizedBox(height: isCompact ? 14 : 18),

          // ── Form Fields ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _isRegisterMode
                ? _buildRegisterFields(isCompact)
                : _buildLoginFields(isCompact),
          ),

          SizedBox(height: isCompact ? 16 : 20),

          // ── 3D Primary Action Button ──
          _build3DActionButton(provider),
        ],
      ),
    );
  }

  /// 🔀 3D Segmented Tab Switcher
  Widget _build3DTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          _3dTabPill('Masuk', !_isRegisterMode,
              () => setState(() => _isRegisterMode = false)),
          _3dTabPill('Daftar Akun', _isRegisterMode,
              () => setState(() => _isRegisterMode = true)),
        ],
      ),
    );
  }

  Widget _3dTabPill(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0D9488) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: const Color(0xFF0F766E), width: 1.8)
                : null,
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0xFF0F766E),
                      offset: Offset(0, 2.5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFields(bool isCompact) {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel('ALAMAT EMAIL'),
        const SizedBox(height: 6),
        _emailField(),
        SizedBox(height: isCompact ? 10 : 12),
        _fieldLabel('KATA SANDI'),
        const SizedBox(height: 6),
        _passwordField(),
      ],
    );
  }

  Widget _buildRegisterFields(bool isCompact) {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel('NAMA LENGKAP'),
        const SizedBox(height: 6),
        _nameField(),
        SizedBox(height: isCompact ? 10 : 12),
        _fieldLabel('ALAMAT EMAIL'),
        const SizedBox(height: 6),
        _emailField(),
        SizedBox(height: isCompact ? 10 : 12),
        _fieldLabel('KATA SANDI'),
        const SizedBox(height: 6),
        _passwordField(),
        SizedBox(height: isCompact ? 12 : 14),
        _fieldLabel('PILIH TARGET FOKUS BELAJAR:'),
        const SizedBox(height: 8),
        _build3DGoalGrid(),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF475569),
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _3dInputDeco(
      {required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 12.5),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF0D9488)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2.2),
      ),
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _nameController,
      style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w600),
      decoration:
          _3dInputDeco(hint: 'Masukkan nama lengkap', icon: LucideIcons.user),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w600),
      decoration:
          _3dInputDeco(hint: 'contoh: nama@email.com', icon: LucideIcons.mail),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w600),
      decoration: _3dInputDeco(
        hint: 'Masukkan kata sandi',
        icon: LucideIcons.lock,
        suffix: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
            size: 18,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  /// 🎯 Gamified 3D Goal Selection Cards Grid
  Widget _build3DGoalGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _goals.length,
      itemBuilder: (context, index) {
        final goal = _goals[index];
        final isSel = _selectedGoal == goal.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedGoal = goal.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                width: isSel ? 2.2 : 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSel ? const Color(0xFF0F766E) : const Color(0xFFCBD5E1),
                  offset: const Offset(0, 3.5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSel
                        ? const Color(0xFF0D9488).withValues(alpha: 0.15)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    goal.icon,
                    size: 16,
                    color: isSel ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        goal.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isSel ? const Color(0xFF0F766E) : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        goal.desc,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: isSel ? const Color(0xFF15803D) : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🚀 Duolingo 3D Elevated Primary Action Button
  Widget _build3DActionButton(AppProvider provider) {
    return _Duolingo3DTactileButton(
      backgroundColor: const Color(0xFF0D9488),
      shadowColor: const Color(0xFF0F766E),
      borderColor: const Color(0xFF0F766E),
      onPressed: _isLoading
          ? null
          : () => _isRegisterMode
              ? _handleRegister(provider)
              : _handleLogin(provider),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isRegisterMode
                      ? 'DAFTAR AKUN BEMIND'
                      : 'MASUK SEKARANG',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.arrowRight, size: 18, color: Colors.white),
              ],
            ),
    );
  }

  Widget _buildBottomToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isRegisterMode
              ? 'Sudah punya akun?'
              : 'Belum punya akun?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () =>
              setState(() => _isRegisterMode = !_isRegisterMode),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _isRegisterMode ? 'Masuk di sini' : 'Daftar sekarang',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D9488),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 🔘 Reusable Duolingo-Style 3D Tactile Elevated Button Component ────────
class _Duolingo3DTactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color shadowColor;
  final Color borderColor;

  const _Duolingo3DTactileButton({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.backgroundColor,
    required this.shadowColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  State<_Duolingo3DTactileButton> createState() =>
      __Duolingo3DTactileButtonState();
}

class __Duolingo3DTactileButtonState extends State<_Duolingo3DTactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double topMargin = _isPressed ? 4.0 : 0.0;
    final double bottomShadow = _isPressed ? 1.0 : 5.0;

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            },
      onTapCancel: widget.onPressed == null
          ? null
          : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: EdgeInsets.only(top: topMargin),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              offset: Offset(0, bottomShadow),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

// ─── Slide & Goal Data Models ────────────────────────────────────────────────
class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _GoalData {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final String badge;
  final Color color;

  const _GoalData({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    required this.badge,
    required this.color,
  });
}
