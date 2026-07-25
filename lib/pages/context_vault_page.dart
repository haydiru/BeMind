import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class ContextVaultPage extends StatelessWidget {
  const ContextVaultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user;
    final essays = provider.essays;
    final vocabCount = provider.vocabList.length;

    // Calculate dynamic strength score (clamped between 60 and 98)
    final int strengthScore = (60 + (essays.length * 10) + (vocabCount * 2)).clamp(60, 98);

    return Scaffold(
      appBar: const HeaderBar(title: 'BeMind AI'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ─── WELCOME HEADER & CREATE PROJECT BUTTON ────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, ${user.name} 👋',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fokus Utama: ${user.targetGoal}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.primaryCyan,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryCyan,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // CREATE NEW PROJECT MAIN CTA BUTTON
                    ElevatedButton.icon(
                      onPressed: () => provider.setPageIndex(1), // Navigate to Generate Essay / Project page
                      icon: const Icon(LucideIcons.plusCircle, size: 20, color: Colors.black),
                      label: Text(
                        'Buat Project Baru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── DASHBOARD STATISTIK (STRENGTH & ACTIVITY OVERVIEW) ─────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Left Ring Widget (Dynamic Strength Index)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F172A),
                            border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.4), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 90,
                                height: 90,
                                child: CircularProgressIndicator(
                                  value: strengthScore / 100.0,
                                  strokeWidth: 6,
                                  backgroundColor: const Color(0xFF1E293B),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$strengthScore',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(LucideIcons.shieldCheck, size: 16, color: AppTheme.primaryCyan),
                                    ],
                                  ),
                                  Text(
                                    'STRENGTH',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Waveform & Quick Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Performa Fluency',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Dynamic Wave Graphic Simulation
                              SizedBox(
                                height: 38,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(18, (i) {
                                    final heights = [12, 22, 34, 26, 16, 32, 38, 30, 20, 28, 36, 38, 22, 30, 18, 26, 32, 20];
                                    return Container(
                                      width: 3.5,
                                      height: heights[i % heights.length].toDouble(),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.buttonGradient,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    );
                                  }),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Stat Numbers
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatItem('Total Project', '${essays.length}'),
                                  _buildStatItem('Kosakata Vault', '$vocabCount'),
                                  _buildStatItem('Fluency Rank', strengthScore > 80 ? 'Advanced' : 'Intermediate'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── DAFTAR PROJECT USER (USER'S REAL PROJECTS LIST) ───────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Project Kamu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.chipTextBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${essays.length} Project',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // LIST OF USER PROJECTS (NO DUMMY DATA)
              essays.isEmpty
                  ? _buildEmptyProjectCard(context, provider)
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: essays.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final essay = essays[index];
                        return _buildProjectCard(context, provider, essay);
                      },
                    ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProjectCard(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Icon(LucideIcons.folderPlus, size: 42, color: AppTheme.primaryCyan),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Project Bahasa Inggris',
            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Buat project narasi pertama kamu untuk dilatih di Teleprompter.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.setPageIndex(1),
            icon: const Icon(LucideIcons.sparkles, size: 16),
            label: const Text('Buat Project Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryCyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, AppProvider provider, Essay essay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  essay.category == 'Job Interview'
                      ? LucideIcons.briefcase
                      : essay.category == 'IELTS/TOEFL'
                          ? LucideIcons.graduationCap
                          : LucideIcons.presentation,
                  size: 20,
                  color: AppTheme.primaryCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      essay.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            essay.category,
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${essay.difficulty}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.black.withValues(alpha: 0.06)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('d MMM yyyy').format(essay.createdAt),
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
              ),

              ElevatedButton.icon(
                onPressed: () => provider.selectEssayForTeleprompter(essay),
                icon: const Icon(LucideIcons.play, size: 14),
                label: const Text('Latihan Teleprompter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
