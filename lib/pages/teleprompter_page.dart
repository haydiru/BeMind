import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class TeleprompterPage extends StatefulWidget {
  const TeleprompterPage({Key? key}) : super(key: key);

  @override
  State<TeleprompterPage> createState() => _TeleprompterPageState();
}

class _TeleprompterPageState extends State<TeleprompterPage> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _wpm = 164.0;
  late ScrollController _scrollController;

  final List<String> _scriptParagraphs = [
    "In my software engineering career, I",
    "spearheaded the architectural redesign",
    "of our financial transactions API.",
    "Initially, our microservices experienced",
    "severe latency bottlenecks.",
    "I instituted a comprehensive system audit,",
    "implemented a high-performance Redis cache layer,",
    "and reduced endpoint response latency by 45%.",
    "This initiative significantly boosted transaction throughput,",
    "ensuring uninterrupted service during peak user traffic."
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        if (!_scrollController.hasClients) return;
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final remainingDist = maxScroll - currentScroll;
        final durationSec = (remainingDist / (_wpm * 2)).clamp(5.0, 120.0);

        _scrollController.animateTo(
          maxScroll,
          duration: Duration(seconds: durationSec.toInt()),
          curve: Curves.linear, // BUTTER-SMOOTH CONTINUOUS 60-120 FPS SCROLL
        );
      } else {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.offset);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(title: 'BeMind AI'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header Row (FULL AT TOP)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STAR Method Teleprompter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '60-120 FPS',
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

              // 2. Full Height Container Box Text (EXPANDED TO FILL ALL VERTICAL SPACE)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.05),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Top Mask Fade Overlay
                      Positioned(
                        top: 0, left: 0, right: 0,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom Mask Fade Overlay
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Continuous Smooth Scroll Physics Track
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 20),
                        itemCount: _scriptParagraphs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              _scriptParagraphs[index],
                              textAlign: TextAlign.center, // CENTER ALIGN
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                height: 1.55,
                                letterSpacing: -0.4,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 3. Bottom Controls Group (FULL AT BOTTOM)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Large Cyan Play Button
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
                            color: const Color(0xFF00E5FF).withOpacity(0.4),
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

                  // WPM Control Bar Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.05),
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
                          child: const Icon(LucideIcons.star, size: 18, color: Color(0xFFFF3366)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_wpm.toInt()} WPM',
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
                                  min: 60,
                                  max: 300,
                                  onChanged: (val) {
                                    setState(() => _wpm = val);
                                    if (_isPlaying) {
                                      _togglePlay();
                                      _togglePlay();
                                    }
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
