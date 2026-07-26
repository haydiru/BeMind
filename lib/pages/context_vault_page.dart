import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/header_bar.dart';

class ContextVaultPage extends StatelessWidget {
  const ContextVaultPage({Key? key}) : super(key: key);

  void _showEditProjectDialog(BuildContext context, AppProvider provider, String oldCategory) {
    final controller = TextEditingController(text: oldCategory);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Nama Project',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nama Kategori / Project',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                provider.updateProjectCategory(oldCategory, newName);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditNarrativeDialog(BuildContext context, AppProvider provider, Essay essay) {
    final titleController = TextEditingController(text: essay.title);
    final categoryController = TextEditingController(text: essay.category);
    final contentController = TextEditingController(text: essay.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Naskah Narasi',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Narasi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Kategori / Project',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Isi Naskah',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = titleController.text.trim();
              final c = categoryController.text.trim();
              final cnt = contentController.text.trim();
              if (t.isNotEmpty && cnt.isNotEmpty) {
                provider.updateEssayNarrative(essay.id, t, cnt, c.isNotEmpty ? c : 'Umum');
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AppProvider provider, Essay essay) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Naskah?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus naskah "${essay.title}" dari project ini?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteEssayNarrative(essay.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user;
    final essays = provider.essays;
    final vocabCount = provider.vocabList.length;
    final isLoading = provider.isLoadingEssays;

    // Group essays by category (Project)
    final Map<String, List<Essay>> groupedProjects = {};
    for (final essay in essays) {
      final categoryKey = essay.category.isNotEmpty ? essay.category : 'Umum';
      groupedProjects.putIfAbsent(categoryKey, () => []).add(essay);
    }

    final int strengthScore = (60 + (essays.length * 10) + (vocabCount * 2)).clamp(60, 98);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Clean Pristine Light Canvas
      appBar: const HeaderBar(title: 'BeMind AI'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── ELEGANT LIGHT WELCOME BANNER & CREATE PROJECT CTA ──────────────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Fokus Utama',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0D9488),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    user.targetGoal,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // CREATE NEW PROJECT MAIN CTA BUTTON
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => provider.setPageIndex(1),
                        icon: const Icon(LucideIcons.plusCircle, size: 20, color: Colors.white),
                        label: Text(
                          'Buat Project Baru',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── DASHBOARD STATISTIK (STRENGTH & FLUENCY PERFORMANCE CARD) ────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                ),
                child: Row(
                  children: [
                    // Left Ring Indicator
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFCCFBF1), width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 86,
                            height: 86,
                            child: CircularProgressIndicator(
                              value: strengthScore / 100.0,
                              strokeWidth: 6,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
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
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(LucideIcons.shieldCheck, size: 15, color: Color(0xFF0D9488)),
                                ],
                              ),
                              Text(
                                'STRENGTH',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Waveform & Stat Overview
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Performa Fluency',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Dynamic Wave Bar Simulation
                          SizedBox(
                            height: 34,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(18, (i) {
                                final heights = [12, 20, 30, 24, 14, 28, 34, 26, 18, 24, 32, 34, 20, 26, 16, 24, 28, 18];
                                return Container(
                                  width: 3.5,
                                  height: heights[i % heights.length].toDouble(),
                                  decoration: BoxDecoration(
                                    color: i % 2 == 0 ? const Color(0xFF0D9488) : const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Quick Stat Items
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: _buildStatItem('Total Project', '${groupedProjects.length}')),
                              Expanded(child: _buildStatItem('Total Narasi', '${essays.length}')),
                              Expanded(child: _buildStatItem('Fluency Rank', strengthScore > 80 ? 'Advanced' : 'Intermediate')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── DAFTAR PROJECT USER ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Daftar Project Kamu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.refreshCw, size: 16, color: Color(0xFF0D9488)),
                        onPressed: () => provider.refreshEssays(),
                        tooltip: 'Refresh dari Database',
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${groupedProjects.length} Project (${essays.length} Narasi)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D9488),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // LIST OF GROUPED PROJECT CARDS
              isLoading
                  ? Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFF0D9488)),
                            SizedBox(height: 12),
                            Text('Memuat project kamu...'),
                          ],
                        ),
                      ),
                    )
                  : groupedProjects.isEmpty
                      ? _buildEmptyProjectCard(context, provider)
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groupedProjects.keys.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final categoryName = groupedProjects.keys.elementAt(index);
                            final categoryEssays = groupedProjects[categoryName]!;
                            return _buildProjectGroupCard(context, provider, categoryName, categoryEssays);
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProjectCard(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFCCFBF1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.folderPlus, size: 36, color: Color(0xFF0D9488)),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum Ada Project Bahasa Inggris',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            'Buat project narasi pertama kamu untuk dilatih di Teleprompter.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => provider.setPageIndex(1),
              icon: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
              label: Text(
                'Buat Project Pertama',
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card representation for a Project Group containing 1 or more narrative essays
  Widget _buildProjectGroupCard(BuildContext context, AppProvider provider, String categoryName, List<Essay> essays) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Group Header with Edit Title Option
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  categoryName == 'Job Interview'
                      ? LucideIcons.briefcase
                      : categoryName == 'IELTS/TOEFL' || categoryName == 'IELTS Part 2'
                          ? LucideIcons.graduationCap
                          : LucideIcons.presentation,
                  size: 22,
                  color: const Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Project: $categoryName',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.pencil, size: 14, color: Color(0xFF64748B)),
                          onPressed: () => _showEditProjectDialog(context, provider, categoryName),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Edit nama project',
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${essays.length} Naskah Narasi Tersimpan',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF6366F1), fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => provider.setPageIndex(1),
                icon: const Icon(LucideIcons.plus, size: 14, color: Color(0xFF0D9488)),
                label: const Text('Tambah Narasi'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  foregroundColor: const Color(0xFF0D9488),
                  side: const BorderSide(color: Color(0xFFCCFBF1), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          // List of Essays / Narratives within this Project
          Column(
            children: essays.map((essay) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            essay.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Level ${essay.difficulty}',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF6366F1), fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  DateFormat('d MMM HH:mm').format(essay.createdAt),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF94A3B8)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action Buttons for Narrative (Edit, Delete, Practice)
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.moreVertical, size: 16, color: Color(0xFF64748B)),
                      onSelected: (val) {
                        if (val == 'edit') {
                          _showEditNarrativeDialog(context, provider, essay);
                        } else if (val == 'delete') {
                          _showDeleteConfirmDialog(context, provider, essay);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.pencil, size: 14, color: Color(0xFF0D9488)),
                              const SizedBox(width: 8),
                              Text('Edit Naskah', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.trash2, size: 14, color: Colors.red),
                              const SizedBox(width: 8),
                              Text('Hapus Naskah', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => provider.selectEssayForTeleprompter(essay),
                        icon: const Icon(LucideIcons.play, size: 12, color: Colors.white),
                        label: const Text('Latih Prompter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          textStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
