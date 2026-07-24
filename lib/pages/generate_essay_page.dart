import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class GenerateEssayPage extends StatefulWidget {
  const GenerateEssayPage({Key? key}) : super(key: key);

  @override
  State<GenerateEssayPage> createState() => _GenerateEssayPageState();
}

class _GenerateEssayPageState extends State<GenerateEssayPage> {
  String _selectedCategory = 'Job Interview';
  String _selectedSubTopic = 'Technical Leadership & STAR';
  double _difficultyValue = 3.0; // C1
  String _selectedTone = 'Professional';

  bool _isGenerating = false;
  Essay? _newGeneratedEssay;

  final List<String> _categories = ['Job Interview', 'IELTS Part 2', 'Elevator Pitch', 'Conversation'];
  final List<String> _difficulties = ['A2', 'B1', 'B2', 'C1', 'C2'];
  final List<String> _tones = ['Professional', 'Conversational', 'Academic'];

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
              // Top Title Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.sparkles, color: AppTheme.primaryBlue, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Narrative Generator',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                              ),
                              Text(
                                'Powered by Gemini 1.5 Flash API & Context Vault',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category Selector Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Select Speech Category',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: AppTheme.primaryCyan,
                          backgroundColor: const Color(0xFFF8FAFC),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            color: isSel ? const Color(0xFF0F172A) : AppTheme.textSecondary,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategory = cat);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Difficulty Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Target Level:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                        Text(
                          _difficulties[_difficultyValue.round()],
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryPurple),
                        ),
                      ],
                    ),
                    Slider(
                      value: _difficultyValue,
                      min: 0,
                      max: 4,
                      divisions: 4,
                      activeColor: AppTheme.primaryCyan,
                      inactiveColor: const Color(0xFFE2E8F0),
                      onChanged: (val) => setState(() => _difficultyValue = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Fused Payload Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fused Prompt Context:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryPurple),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fintech Engineering Resume + STAR Method Template (Level ${_difficulties[_difficultyValue.round()]})',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Generate Action Button
              InkWell(
                onTap: _isGenerating ? null : () => _generateNarrative(provider),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: AppTheme.gradientButtonDecoration(borderRadius: 24),
                  child: Center(
                    child: _isGenerating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(
                            'Synthesize & Launch Prompter',
                            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                  ),
                ),
              ),

              if (_newGeneratedEssay != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(borderColor: AppTheme.accentEmerald),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.checkCircle2, color: AppTheme.accentEmerald, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Script Synthesized Successfully!',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.accentEmerald),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _newGeneratedEssay!.title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _newGeneratedEssay!.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () => provider.selectEssayForTeleprompter(_newGeneratedEssay!),
                        icon: const Icon(LucideIcons.playCircle, size: 18),
                        label: const Text('Open Teleprompter Reader'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _generateNarrative(AppProvider provider) async {
    setState(() {
      _isGenerating = true;
      _newGeneratedEssay = null;
    });

    await Future.delayed(const Duration(milliseconds: 1400));

    final essay = Essay(
      id: 'ess_${DateTime.now().millisecondsSinceEpoch}',
      title: 'STAR Method: $_selectedCategory',
      category: _selectedCategory,
      subTopic: _selectedSubTopic,
      difficulty: _difficulties[_difficultyValue.round()],
      tone: _selectedTone,
      content: 'In my software engineering career, I spearheaded the architectural redesign of our financial transactions API. Initially, our microservices experienced severe latency bottlenecks. I instituted a audit, implemented a Redis cache layer, and reduced endpoint response latency by 45%.',
      createdAt: DateTime.now(),
    );

    provider.addGeneratedEssay(essay);

    setState(() {
      _isGenerating = false;
      _newGeneratedEssay = essay;
    });
  }
}
