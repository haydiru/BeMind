import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Job Interview', 'IELTS/TOEFL', 'Business Pitching'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final templates = provider.promptTemplates;

    final filteredTemplates = templates.where((t) {
      if (_selectedCategory == 'All') return true;
      return t.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: const HeaderBar(title: 'BeMind AI'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.primaryCyan,
        foregroundColor: const Color(0xFF0F172A),
        icon: const Icon(LucideIcons.plus),
        label: Text('Publish Prompt', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'CANVA FOR PROMPTS',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'STAR Method Interview Script',
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By Sarah Jenkins (Ex-Google Recruiter)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        provider.selectTemplateToRemix(templates.first);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('Remix With My Context', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: AppTheme.primaryCyan,
                        backgroundColor: const Color(0xFFF8FAFC),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isSel ? const Color(0xFF0F172A) : AppTheme.textSecondary,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Prompt Feed Items
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTemplates.length,
                itemBuilder: (context, index) {
                  final item = filteredTemplates[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'By ${item.creatorName}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.accentEmerald, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => provider.selectTemplateToRemix(item),
                          icon: const Icon(LucideIcons.sparkles, size: 16),
                          label: const Text('Remix Template'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
