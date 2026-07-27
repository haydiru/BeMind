import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/notification_service.dart';
import '../widgets/header_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isEditingProfile = false;
  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final List<String> _goals = [
    'Job Interview Prep',
    'IELTS/TOEFL Practice',
    'Business Pitching',
    'Casual Conversation',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveProfileChanges(AppProvider provider) async {
    final user = provider.user;
    setState(() => _isSaving = true);

    // 1. Save name if changed
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != user.name) {
      final err = await provider.updateUserNameInDB(newName);
      if (err != null) {
        _showSnackBar(err, isError: true);
        setState(() => _isSaving = false);
        return;
      }
    }

    // 2. Save password if filled
    final newPass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;
    if (newPass.isNotEmpty) {
      if (newPass != confirmPass) {
        _showSnackBar('Password dan konfirmasi tidak cocok!', isError: true);
        setState(() => _isSaving = false);
        return;
      }
      final err = await provider.updateUserPassword(newPass);
      if (err != null) {
        _showSnackBar(err, isError: true);
        setState(() => _isSaving = false);
        return;
      }
    }

    _passwordController.clear();
    _confirmPasswordController.clear();

    setState(() {
      _isSaving = false;
      _isEditingProfile = false;
    });

    _showSnackBar('✔ Profil berhasil diperbarui!');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user;
    final notif = provider.notificationSettings;
    final vocabList = provider.vocabList;

    final sampleVocab = vocabList.isNotEmpty
        ? vocabList.first
        : VocabItem(
            id: 'sample',
            word: 'Spearheaded',
            phonetic: '/ˈspɪər.hed.ɪd/',
            definition: 'To lead an attack or course of action.',
            contextSentence: 'I spearheaded a comprehensive system audit.',
            indonesianMeaning: 'Memimpin / Pelopor akselerasi',
            addedAt: DateTime.now(),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const HeaderBar(title: 'BeMind AI'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ─── 1. USER PROFILE CARD ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── User Avatar + Info + Edit Toggle ──
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                              ),
                              Text(
                                user.email,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        // Edit/Cancel toggle
                        IconButton(
                          icon: Icon(
                            _isEditingProfile ? LucideIcons.x : LucideIcons.pencil,
                            size: 18,
                            color: _isEditingProfile ? const Color(0xFFEF4444) : const Color(0xFF0D9488),
                          ),
                          onPressed: () {
                            if (_isEditingProfile) {
                              // Cancel editing — reset fields
                              _nameController.text = user.name;
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                            }
                            setState(() => _isEditingProfile = !_isEditingProfile);
                          },
                        ),
                      ],
                    ),

                    // ── Editable Profile Fields ──
                    if (_isEditingProfile) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // Name Field
                      Text(
                        'Nama Lengkap',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama baru',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF94A3B8)),
                          prefixIcon: const Icon(LucideIcons.user, size: 17, color: Color(0xFF0D9488)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // New Password Field
                      Text(
                        'Password Baru (opsional)',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Masukkan password baru',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF94A3B8)),
                          prefixIcon: const Icon(LucideIcons.lock, size: 17, color: Color(0xFF0D9488)),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                            child: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, size: 17, color: const Color(0xFF94A3B8)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Confirm Password Field
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Konfirmasi password baru',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF94A3B8)),
                          prefixIcon: const Icon(LucideIcons.shieldCheck, size: 17, color: Color(0xFF0D9488)),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            child: Icon(_obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye, size: 17, color: const Color(0xFF94A3B8)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Save Button (Full Width, Overflow Safe)
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : () => _saveProfileChanges(provider),
                            icon: _isSaving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(LucideIcons.save, size: 16),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),

                    // Target Goal Selection
                    Text(
                      'Target Karir & Belajar:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _goals.map((g) {
                          final isSel = user.targetGoal == g;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                provider.loginWithProfile(
                                  id: user.id,
                                  name: user.name,
                                  email: user.email,
                                  targetGoal: g,
                                );
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: isSel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  g,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: isSel ? Colors.white : const Color(0xFF64748B),
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── 2. ON-DEVICE PASSIVE LEARNING & NOTIFICATIONS ────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCFBF1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(LucideIcons.bellRing, size: 20, color: Color(0xFF0D9488)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Passive Learning Engine',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      'Notifikasi lockscreen HP otomatis',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: notif.isEnabled,
                          activeColor: const Color(0xFF0D9488),
                          onChanged: (val) async {
                            provider.toggleNotifications(val);
                            if (val) {
                              // Trigger notification permission request & test notification
                              await NotificationService.showPassiveVocabNotification(vocabList);
                            }
                          },
                        ),
                      ],
                    ),

                    if (notif.isEnabled) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Frekuensi Pengiriman Notifikasi:',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                          ),
                          InkWell(
                            onTap: () async {
                              await NotificationService.showPassiveVocabNotification(vocabList);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🔔 Notifikasi tes telah dikirim ke status bar HP!'),
                                    backgroundColor: Color(0xFF0D9488),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(LucideIcons.send, size: 12, color: Color(0xFF0D9488)),
                                const SizedBox(width: 4),
                                Text(
                                  'Tes Sekarang',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0D9488)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Every 2 hours', 'Every 4 hours', 'Once a day'].map((freq) {
                          final isSel = notif.frequency == freq;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () => provider.updateNotificationFrequency(freq),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isSel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    freq == 'Every 2 hours'
                                        ? '2 Jam'
                                        : freq == 'Every 4 hours'
                                            ? '4 Jam'
                                            : '1x Sehari',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isSel ? Colors.white : const Color(0xFF64748B),
                                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── 3. LOCKSCREEN PREVIEW CARD ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PREVIEW LOCKSCREEN HP', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488))),
                        const Icon(LucideIcons.smartphone, size: 16, color: Colors.white54),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('22:15', style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w200, color: Colors.white)),
                    Text('Minggu, 26 Juli', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.sparkles, size: 12, color: Color(0xFF0D9488)),
                              const SizedBox(width: 6),
                              Text('BeMind Passive Flashcard', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${sampleVocab.word} ${sampleVocab.phonetic}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('Arti: ${sampleVocab.indonesianMeaning}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF4ADE80), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── 4. APP SYSTEM INFO & LOGOUT ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Versi Aplikasi', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                        Text('v2.4.0 (Build 2026)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Backend API Cloud', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                        Text('be-mind.vercel.app', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0D9488))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () => provider.logout(),
                icon: const Icon(LucideIcons.logOut, size: 18),
                label: Text('Keluar / Log Out', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
