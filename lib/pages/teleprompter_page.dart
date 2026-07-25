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
  double _wpm = 110.0; // Comfortably readable speed: 60 - 220 WPM
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
      // 1 WPM ~ 3.5 pixels/sec at 20px font
      final pixelsPerSec = (_wpm * 2.8).clamp(30.0, 450.0);
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

              // 3. Bottom Controls Group
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play / Pause Button
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00E5FF),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? LucideIcons.pause : LucideIcons.play,
                        color: const Color(0xFF0F172A),
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // WPM Speed Control Bar Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFF1F2),
                          ),
                          child: const Icon(LucideIcons.gauge, size: 18, color: Color(0xFFFF3366)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_wpm.toInt()} WPM (Reading Pace)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbColor: const Color(0xFF00E5FF),
                                  activeTrackColor: const Color(0xFF00E5FF),
                                  inactiveTrackColor: const Color(0xFFE2E8F0),
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                ),
                                child: Slider(
                                  value: _wpm,
                                  min: 50,
                                  max: 250,
                                  onChanged: (val) {
                                    setState(() => _wpm = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(LucideIcons.settings, size: 20, color: AppTheme.primaryPurple),
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
