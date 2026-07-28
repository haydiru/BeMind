import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BeMind — Duolingo-Style 3D Elevated Bottom Navigation Bar
// Tactile 3D active pills with elevated bottom shadows & high-energy feedback
// ──────────────────────────────────────────────────────────────────────────────

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currentIndex = provider.currentPageIndex;

    final navItems = [
      {'icon': LucideIcons.layoutGrid, 'label': 'Naskah'},
      {'icon': LucideIcons.sparkles, 'label': 'Buat AI'},
      {'icon': LucideIcons.playCircle, 'label': 'Prompter'},
      {'icon': LucideIcons.bookOpen, 'label': 'Vocab'},
      {'icon': LucideIcons.shoppingBag, 'label': 'Market'},
      {'icon': LucideIcons.settings, 'label': 'Setting'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 2.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFCBD5E1),
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => provider.setPageIndex(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: const Color(0xFF0F766E), width: 1.8)
                          : null,
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0xFF0F766E),
                                offset: Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: isSelected ? 19 : 18,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item['label'] as String,
                            maxLines: 1,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
