import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class TeleprompterPage extends StatefulWidget {
  const TeleprompterPage({Key? key}) : super(key: key);

  @override
  State<TeleprompterPage> createState() => _TeleprompterPageState();
}

class _TeleprompterPageState extends State<TeleprompterPage> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _wpm = 25.0; // Comfortable reading pace default
  late ScrollController _scrollController;
  Timer? _scrollTimer;

  /// Splits essay content into ~6-8 word chunks for smooth teleprompter reading
  List<String> _buildScriptChunks(String content) {
    if (content.isEmpty) return [];
    final words = content.split(RegExp(r'\s+'));
    final chunks = <String>[];
    const chunkSize = 7;
    for (int i = 0; i < words.length; i += chunkSize) {
      chunks.add(words.sublist(i, (i + chunkSize).clamp(0, words.length)).join(' '));
    }
    return chunks;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startSmoothScrolling();
      } else {
        _stopSmoothScrolling();
      }
    });
  }

  void _startSmoothScrolling() {
    _scrollTimer?.cancel();
    // 60 FPS Smooth ticker (16ms per step)
    const interval = Duration(milliseconds: 16);
    
    _scrollTimer = Timer.periodic(interval, (timer) {
      if (!_scrollController.hasClients || !_isPlaying) {
        timer.cancel();
        return;
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        setState(() => _isPlaying = false);
        timer.cancel();
        return;
      }

      // Calculate smooth pixel step based on WPM (Words Per Minute)
      // Low speed: 5 - 100 WPM for comfortable reading pace
      final pixelsPerSec = (_wpm * 0.45).clamp(2.0, 150.0);
      final step = pixelsPerSec * (16 / 1000.0);

      _scrollController.jumpTo((currentScroll + step).clamp(0.0, maxScroll));
    });
  }

  void _stopSmoothScrolling() {
    _scrollTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final activeEssay = provider.activeEssay;
    final scriptParagraphs = activeEssay != null
        ? _buildScriptChunks(activeEssay.content)
        : <String>[];
    final essayTitle = activeEssay?.title ?? 'Teleprompter';

    return Scaffold(
      appBar: const HeaderBar(title: 'BeMind AI'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      essayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '60 FPS Smooth',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. Full Height Teleprompter Box with Smooth Gradual Fade-out Mask
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Empty state when no essay is selected
                      if (scriptParagraphs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.scrollText, size: 48, color: AppTheme.primaryCyan.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum Ada Project Dipilih',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Buat project narasi dari halaman Dashboard, lalu pilih "Latihan Teleprompter" untuk memulai.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Continuous 60 FPS Teleprompter ListView
                      if (scriptParagraphs.isNotEmpty)
                        ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 140, horizontal: 24),
                          itemCount: scriptParagraphs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              child: Text(
                                scriptParagraphs[index],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  height: 1.6,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            );
                          },
                        ),

                      // TOP GRADUAL FADE-OUT MASK (Teks Hilang Perlahan Saat Ke Atas)
                      if (scriptParagraphs.isNotEmpty)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 130,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.4, 0.75, 1.0],
                                  colors: [
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.95),
                                    Colors.white.withValues(alpha: 0.5),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // BOTTOM GRADUAL FADE-OUT MASK (Teks Muncul Perlahan Dari Bawah)
                      if (scriptParagraphs.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 130,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  stops: const [0.0, 0.4, 0.75, 1.0],
                                  colors: [
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.95),
                                    Colors.white.withValues(alpha: 0.5),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 3. Bottom Controls Group (Pristine Proportional Design System)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play / Pause & Quick Reset Control Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset to Top Button
                      InkWell(
                        onTap: () {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                          }
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.rotateCcw, size: 20, color: Color(0xFF64748B)),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Main Play/Pause Floating Action Circle
                      GestureDetector(
                        onTap: _togglePlay,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying ? LucideIcons.pause : LucideIcons.play,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Font Size Adjustment Quick Button
                      InkWell(
                        onTap: () {
                          // Quick feedback toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kecepatan teleprompter diatur secara otomatis ke 60 FPS'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Color(0xFF0D9488),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.slidersHorizontal, size: 20, color: Color(0xFF0D9488)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // WPM Speed Control Container with Intuitive Icons (Turtle, Gauge, Zap) & Presets
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Speed Header with WPM Count & Intuitive Pace Label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCFBF1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _wpm < 20
                                        ? LucideIcons.turtle
                                        : _wpm < 50
                                            ? LucideIcons.gauge
                                            : LucideIcons.zap,
                                    size: 18,
                                    color: const Color(0xFF0D9488),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kecepatan Baca (WPM)',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      _wpm < 20
                                          ? 'Mode Santai & Pelan'
                                          : _wpm < 50
                                              ? 'Tempo Bicara Ideal (Standar)'
                                              : 'Mode Cepat & Fluency Tinggi',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_wpm.toInt()} WPM',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Interactive WPM Slider Bar
                        Row(
                          children: [
                            const Icon(LucideIcons.turtle, size: 16, color: Color(0xFF94A3B8)),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 6,
                                  thumbColor: const Color(0xFF0D9488),
                                  activeTrackColor: const Color(0xFF0D9488),
                                  inactiveTrackColor: const Color(0xFFF1F5F9),
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                                  overlayColor: const Color(0xFF0D9488).withValues(alpha: 0.2),
                                ),
                                child: Slider(
                                  value: _wpm,
                                  min: 5,
                                  max: 80,
                                  divisions: 75,
                                  onChanged: (val) {
                                    setState(() => _wpm = val);
                                  },
                                ),
                              ),
                            ),
                            const Icon(LucideIcons.zap, size: 16, color: Color(0xFF6366F1)),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Quick Speed Preset Chips (15 WPM, 25 WPM, 40 WPM, 60 WPM)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [15.0, 25.0, 40.0, 60.0].map((preset) {
                            final isSel = (_wpm - preset).abs() < 2.5;
                            return InkWell(
                              onTap: () => setState(() => _wpm = preset),
                              borderRadius: BorderRadius.circular(999),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: isSel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  '${preset.toInt()} WPM',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                    color: isSel ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
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
