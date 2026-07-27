import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_provider.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BeMind — Premium Onboarding & Authentication Page
// Responsive, pixel-perfect, with native Google Sign-In
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
      subtitle:
          'Ubah CV & rekaman suaramu menjadi naskah kelancaran bahasa Inggris.',
    ),
    _SlideData(
      icon: LucideIcons.zap,
      title: 'High-Speed Teleprompter',
      subtitle:
          'Latih ritme bicara & percaya diri dengan kecepatan baca dinamis.',
    ),
    _SlideData(
      icon: LucideIcons.bellRing,
      title: 'Passive Learning Engine',
      subtitle:
          'Kosakata asing instan & pengingat otomatis di lockscreen HP-mu.',
    ),
  ];

  final List<String> _goals = [
    'Job Interview Prep',
    'IELTS/TOEFL',
    'Business Pitching',
    'Casual Conversation',
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
        _showSnackBar('Selamat Datang Kembali, $userName!');
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
      // Web Client ID from Google Cloud Console
      const webClientId =
          '659983765395-3apa3crilf79tk18ip9c443evec5ul7t.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled
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

      // Authenticate with Supabase using the Google ID token
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
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final bottomInset = mq.viewInsets.bottom; // keyboard height

    // Adaptive spacing — shrinks when keyboard is open or screen is small
    final bool isCompact = screenH < 700 || bottomInset > 100;
    final double topGap = isCompact ? 8 : 20;
    final double sectionGap = isCompact ? 10 : 16;
    final double carouselH = isCompact ? 72 : 88;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ── Background Gradient Orbs ──
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0D9488).withValues(alpha: 0.10),
                    const Color(0xFF0D9488).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.08),
                    const Color(0xFF6366F1).withValues(alpha: 0.0),
                  ],
                ),
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
                            24, topGap, 24, 24 + bottomInset * 0.1),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // ── Brand Header ──
                            _buildBrandHeader(isCompact),
                            SizedBox(height: sectionGap),

                            // ── Value Prop Carousel ──
                            _buildCarousel(carouselH),
                            const SizedBox(height: 6),
                            _buildDotsIndicator(),
                            SizedBox(height: sectionGap),

                            // ── Google Login ──
                            _buildGoogleButton(provider),
                            SizedBox(height: sectionGap),

                            // ── Divider ──
                            _buildDivider(),
                            SizedBox(height: sectionGap),

                            // ── Auth Card ──
                            _buildAuthCard(provider, isCompact),
                            const SizedBox(height: 14),

                            // ── Bottom Toggle ──
                            _buildBottomToggle(),
                            const SizedBox(height: 8),
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

  Widget _buildBrandHeader(bool isCompact) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brain Icon
          Container(
            padding: EdgeInsets.all(isCompact ? 8 : 10),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.brainCircuit,
              size: isCompact ? 22 : 26,
              color: const Color(0xFF0D9488),
            ),
          ),
          SizedBox(height: isCompact ? 6 : 8),

          // App Name + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BeMind',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isCompact ? 22 : 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'AI-NATIVE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0D9488),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'English Fluency Builder',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
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
                    Icon(slide.icon,
                        size: 14, color: const Color(0xFF0D9488)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        slide.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
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
          width: _currentSlide == i ? 18 : 6,
          height: 4,
          decoration: BoxDecoration(
            color: _currentSlide == i
                ? const Color(0xFF0D9488)
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(AppProvider provider) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      elevation: 0,
      child: InkWell(
        onTap: _isLoading ? null : () => _handleGoogleLogin(provider),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau dengan email',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: const Color(0xFF94A3B8)),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }

  Widget _buildAuthCard(AppProvider provider, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Tab Switcher ──
          _buildTabSwitcher(),
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

          // ── Primary Action Button ──
          _buildActionButton(provider),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _tabPill('Masuk', !_isRegisterMode,
              () => setState(() => _isRegisterMode = false)),
          _tabPill('Daftar Akun', _isRegisterMode,
              () => setState(() => _isRegisterMode = true)),
        ],
      ),
    );
  }

  Widget _tabPill(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0D9488) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
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
        _fieldLabel('Alamat Email'),
        const SizedBox(height: 5),
        _emailField(),
        SizedBox(height: isCompact ? 10 : 12),
        _fieldLabel('Kata Sandi'),
        const SizedBox(height: 5),
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
        _fieldLabel('Nama Lengkap'),
        const SizedBox(height: 5),
        _nameField(),
        SizedBox(height: isCompact ? 10 : 12),
        _fieldLabel('Alamat Email'),
        const SizedBox(height: 5),
        _emailField(),
        SizedBox(height: isCompact ? 10 : 12),
        _fieldLabel('Kata Sandi'),
        const SizedBox(height: 5),
        _passwordField(),
        SizedBox(height: isCompact ? 10 : 12),
        _fieldLabel('Fokus Utama Belajar:'),
        const SizedBox(height: 6),
        _buildGoalChips(),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF475569),
      ),
    );
  }

  InputDecoration _inputDeco(
      {required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 12.5),
      prefixIcon: Icon(icon, size: 17, color: const Color(0xFF0D9488)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
      ),
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _nameController,
      style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F172A), fontSize: 13),
      decoration:
          _inputDeco(hint: 'Masukkan nama lengkap', icon: LucideIcons.user),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F172A), fontSize: 13),
      decoration:
          _inputDeco(hint: 'contoh: nama@email.com', icon: LucideIcons.mail),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F172A), fontSize: 13),
      decoration: _inputDeco(
        hint: 'Masukkan kata sandi',
        icon: LucideIcons.lock,
        suffix: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
            size: 17,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _goals.map((goal) {
        final isSelected = _selectedGoal == goal;
        return ChoiceChip(
          label: Text(goal),
          selected: isSelected,
          onSelected: (s) {
            if (s) setState(() => _selectedGoal = goal);
          },
          selectedColor: const Color(0xFF0D9488),
          backgroundColor: const Color(0xFFF8FAFC),
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF0D9488)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () => _isRegisterMode
                ? _handleRegister(provider)
                : _handleLogin(provider),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                _isRegisterMode
                    ? 'Daftar & Buat Akun BeMind'
                    : 'Masuk ke Aplikasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildBottomToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isRegisterMode
              ? 'Sudah memiliki akun?'
              : 'Belum memiliki akun?',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: const Color(0xFF64748B)),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D9488),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Slide Data Model ────────────────────────────────────────────────────────
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
