import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BeMind — Duolingo-Inspired Gamified Header Bar
// Features Mascot Badge, Streak Flame Counter 🔥 & XP Gems Badge ⚡
// ──────────────────────────────────────────────────────────────────────────────

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const HeaderBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          // Mascot Logo Badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF0F766E), width: 1.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF0F766E),
                  offset: Offset(0, 2.5),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.sparkles,
              size: 18,
              color: Color(0xFFFEF08A),
            ),
          ),
          const SizedBox(width: 10),

          // App Title
          Text(
            'BeMind',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 4),

          // Subtitle / Page Title Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
            ),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF15803D),
              ),
            ),
          ),

          const Spacer(),

          // 🔥 Duolingo-Style Streak Flame Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFFED7AA),
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  '7 Hari',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFC2410C),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // ⚡ Duolingo-Style XP Gems Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFEF08A), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFFDE047),
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.zap, size: 13, color: Color(0xFFA16207)),
                const SizedBox(width: 4),
                Text(
                  '1.2k',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFA16207),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
