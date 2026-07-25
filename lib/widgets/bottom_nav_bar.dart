import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currentIndex = provider.currentPageIndex;

    final navItems = [
      {'icon': LucideIcons.layoutGrid, 'label': 'Dashboard'},
      {'icon': LucideIcons.sparkles, 'label': 'Generate'},
      {'icon': LucideIcons.playCircle, 'label': 'Prompter'},
      {'icon': LucideIcons.bookOpen, 'label': 'Vocab'},
      {'icon': LucideIcons.shoppingBag, 'label': 'Market'},
      {'icon': LucideIcons.settings, 'label': 'Settings'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.surfaceBorder.withOpacity(0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = currentIndex == index;

              return InkWell(
                onTap: () => provider.setPageIndex(index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.chipTextBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
                        ),
                      ),
                    ],
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
