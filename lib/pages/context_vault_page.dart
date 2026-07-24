import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class ContextVaultPage extends StatefulWidget {
  const ContextVaultPage({Key? key}) : super(key: key);

  @override
  State<ContextVaultPage> createState() => _ContextVaultPageState();
}

class _ContextVaultPageState extends State<ContextVaultPage> {
  int _activeChipIndex = 0;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: const HeaderBar(title: 'BeMind AI'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ultra-Premium 3D Glass Strength Overview Card (Dynamic & No % Symbol)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.06),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left 3D Glass Dial Ring Widget (No % symbol!)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.9), width: 3),
                        gradient: const RadialGradient(
                          center: Alignment(-0.4, -0.4),
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFD2E6FF),
                            Color(0xFFB4D2FF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0FF007AFF).withOpacity(0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Dynamic Progress Arc
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: CircularProgressIndicator(
                              value: 0.95,
                              strokeWidth: 6.5,
                              backgroundColor: const Color(0xFFEBF2FA),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                            ),
                          ),
                          // Dial Content (Clean Index 95 + Shield)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '95',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: -1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.shieldCheck, size: 20, color: AppTheme.primaryPurple),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'CONTEXT STRENGTH',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF475569),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Dynamic Ribbon Waveform Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Strength Overview',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Dynamic Wave Graphic Simulation
                          SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(20, (i) {
                                final heights = [14, 22, 34, 26, 16, 32, 44, 38, 20, 30, 42, 44, 24, 36, 18, 28, 34, 22, 14, 10];
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
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('WEEK 1', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                              Text('WEEK 2', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                              Text('WEEK 3', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                              Text('WEEK 4', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Source Integration Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Source Integration',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(0, LucideIcons.fileText, 'Add Text', AppTheme.chipTextBg, AppTheme.chipTextColor),
                        _buildChip(1, LucideIcons.mic, 'Add Voice', AppTheme.chipVoiceBg, AppTheme.chipVoiceColor),
                        _buildChip(2, LucideIcons.fileUp, 'Upload CV/PDF', AppTheme.chipPdfBg, AppTheme.chipPdfColor),
                        _buildChip(3, LucideIcons.camera, 'Add Image/OCR', AppTheme.chipOcrBg, AppTheme.chipOcrColor),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Direct Text Input',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0FF334155),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Paste career summary...',
                        hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () {
                        if (_textController.text.isNotEmpty) {
                          provider.addContextItem(SourceType.text, 'Career Background', _textController.text);
                          _textController.clear();
                        }
                        provider.setPageIndex(1);
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: AppTheme.gradientButtonDecoration(borderRadius: 24),
                        child: Center(
                          child: Text(
                            'Enhance My Context',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Active Projects Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Projects',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Icon(LucideIcons.moreHorizontal, color: AppTheme.textMuted, size: 20),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Interview Prep (STAR)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Level C1 • Input types: Text, CV',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => provider.setPageIndex(2),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPurple,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            child: Text(
                              'Start Teleprompter',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(int index, IconData icon, String label, Color bg, Color text) {
    final isSelected = _activeChipIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeChipIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? text : text.withOpacity(0.3), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: text),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
