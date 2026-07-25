import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class GenerateEssayPage extends StatefulWidget {
  const GenerateEssayPage({Key? key}) : super(key: key);

  @override
  State<GenerateEssayPage> createState() => _GenerateEssayPageState();
}

class _GenerateEssayPageState extends State<GenerateEssayPage> {
  // Step 1: Category & Level
  String _selectedCategory = 'Job Interview';
  double _difficultyValue = 3.0; // C1
  String _selectedTone = 'Professional';

  // Step 2: Context Input (Text, Voice, File)
  int _inputModeTab = 0; // 0 = Text Direct, 1 = Voice Note, 2 = Document/PDF
  final TextEditingController _customTextController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();
  
  // Voice Recording Simulator
  bool _isRecordingVoice = false;
  String _simulatedVoiceText = '';

  // File Upload Simulator
  String? _attachedFileName;

  // Execution State
  bool _isGenerating = false;
  Essay? _newGeneratedEssay;

  final List<String> _categories = ['Job Interview', 'IELTS Part 2', 'Elevator Pitch', 'Conversation'];
  final List<String> _difficulties = ['A2', 'B1', 'B2', 'C1', 'C2'];
  final List<String> _tones = ['Professional', 'Conversational', 'Academic'];

  @override
  void dispose() {
    _customTextController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

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
              // Top Title Card (Removed "Powered by Gemini" subtitle as requested)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Row(
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
                            'Buat Project Narasi AI',
                            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sintesis naskah narasi presisi berdasarkan latar belakang & kustomisasi kamu.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── TAHAP 1: KATEGORI & TARGET FLUENCY LEVEL ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStepBadge('1'),
                        const SizedBox(width: 10),
                        Text(
                          'Pilih Kategori & Level Target',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Kategori Chips
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

                    const SizedBox(height: 18),

                    // Slider Level English
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Target English Level:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _difficulties[_difficultyValue.round()],
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryPurple),
                          ),
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

                    const SizedBox(height: 10),

                    // Tone Selection Chips
                    Row(
                      children: [
                        Text('Gaya Bahasa / Tone:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            children: _tones.map((t) {
                              final isSel = _selectedTone == t;
                              return ChoiceChip(
                                label: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                                selected: isSel,
                                selectedColor: const Color(0xFFE0F2FE),
                                labelStyle: TextStyle(color: isSel ? AppTheme.primaryBlue : AppTheme.textSecondary, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                                onSelected: (sel) {
                                  if (sel) setState(() => _selectedTone = t);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── TAHAP 2: INPUT DATA PENDUKUNG (TEXT, VOICE, PDF) ─────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStepBadge('2'),
                        const SizedBox(width: 10),
                        Text(
                          'Input Data Pendukung (Context)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masukkan informasi pengalaman, poin penting, atau latar belakang kamu.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 14),

                    // Input Mode Tabs (Text Direct | Voice Note | Upload Doc)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _buildTabItem(0, LucideIcons.fileText, 'Ketik Teks'),
                          _buildTabItem(1, LucideIcons.mic, 'Voice Note'),
                          _buildTabItem(2, LucideIcons.paperclip, 'Import PDF/Doc'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tab Body
                    if (_inputModeTab == 0) ...[
                      // Text Direct Field
                      TextField(
                        controller: _customTextController,
                        maxLines: 4,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Saya punya pengalaman 5 tahun sebagai AI Engineer di Fintech. Berhasil membangun microservice Golang dan optimasi database latency 45%...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.black38),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                    ] else if (_inputModeTab == 1) ...[
                      // Voice Note Recorder UI
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isRecordingVoice = !_isRecordingVoice;
                                  if (!_isRecordingVoice) {
                                    _simulatedVoiceText = 'Voice Transkrip: Membahas pengalaman memimpin tim 10 orang engineer dalam migrasi arsitektur ke Kubernetes.';
                                  }
                                });
                              },
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: _isRecordingVoice ? Colors.red : AppTheme.primaryCyan,
                                child: Icon(_isRecordingVoice ? LucideIcons.square : LucideIcons.mic, color: Colors.white, size: 24),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isRecordingVoice ? 'Sedang Merekam Suara... (Ketuk untuk Berhenti)' : 'Ketuk Mikrofon untuk Merekam Suara',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: _isRecordingVoice ? Colors.red : AppTheme.textPrimary),
                            ),
                            if (_simulatedVoiceText.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                                child: Text(_simulatedVoiceText, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary)),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ] else ...[
                      // PDF/Doc Attachment UI
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.fileCode2, size: 32, color: AppTheme.primaryPurple),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _attachedFileName ?? 'Upload File CV / Resume (PDF)',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                  ),
                                  Text('Format yang didukung: PDF, TXT, DOCX (Maks 10MB)', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _attachedFileName = 'CV_AI_Engineer_2026.pdf';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(_attachedFileName != null ? 'Ganti' : 'Pilih File', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── TAHAP 3: KUSTOMISASI PROMPT & ROLES (TUNE PROMPT) ───────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStepBadge('3'),
                        const SizedBox(width: 10),
                        Text(
                          'Kustomisasi Prompt & Spesifikasi',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Misal: Buat khusus untuk wawancara AI Engineer dengan pengalaman 10 tahun.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _customPromptController,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Gunakan STAR Method (Situation, Task, Action, Result). Tekankan kepemimpinan teknis dan efisiensi cloud...',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.black38),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── EKS EKUSI: TOMBOL GENERATE PROJECT ─────────────────────────────────
              InkWell(
                onTap: _isGenerating ? null : () => _generateNarrative(provider),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: AppTheme.gradientButtonDecoration(borderRadius: 24),
                  child: Center(
                    child: _isGenerating
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                              SizedBox(width: 12),
                              Text('Sedang Menyusun Naskah AI...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Generate & Sintesis Narasi',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // ─── HASIL HASIL GENERATE & LAUNCH PROMPTER ─────────────────────────────
              if (_newGeneratedEssay != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration(borderColor: AppTheme.accentEmerald),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.checkCircle2, color: AppTheme.accentEmerald, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Project Naskah Berhasil Dibuat!',
                            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.accentEmerald),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _newGeneratedEssay!.title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _newGeneratedEssay!.content,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => provider.selectEssayForTeleprompter(_newGeneratedEssay!),
                        icon: const Icon(LucideIcons.playCircle, size: 20),
                        label: const Text('Buka di Teleprompter Reader'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          minimumSize: const Size(double.infinity, 48),
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

  Widget _buildStepBadge(String number) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryCyan,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Langkah $number',
        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSel = _inputModeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _inputModeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSel ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSel ? AppTheme.primaryPurple : AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? AppTheme.primaryPurple : AppTheme.textSecondary),
              ),
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

    // Gather context from custom inputs + existing provider context
    final userCustomText = _customTextController.text.trim();
    final customPrompt = _customPromptController.text.trim();
    
    String combinedContext = '';
    if (userCustomText.isNotEmpty) {
      combinedContext += 'User Custom Background:\n$userCustomText\n';
    }
    if (_simulatedVoiceText.isNotEmpty) {
      combinedContext += 'Voice Input:\n$_simulatedVoiceText\n';
    }
    if (_attachedFileName != null) {
      combinedContext += 'Attached Document: $_attachedFileName (Senior Software Engineer resume context)\n';
    }

    final providerContexts = provider.contextItems.map((c) => c.content).join('\n');
    if (providerContexts.isNotEmpty) {
      combinedContext += 'Context Vault Items:\n$providerContexts\n';
    }

    if (combinedContext.isEmpty) {
      combinedContext = 'Role: Senior AI Engineer with 10 years experience building scalable machine learning microservices and LLM infrastructure.';
    }

    final essay = await ApiService.generateEssay(
      userId: provider.user.id,
      category: _selectedCategory,
      subTopic: 'Custom Narrative & Prompt',
      difficulty: _difficulties[_difficultyValue.round()],
      tone: _selectedTone,
      userContext: combinedContext,
      templateId: provider.selectedRemixTemplate?.id,
      promptTemplate: customPrompt.isNotEmpty ? customPrompt : provider.selectedRemixTemplate?.templateStructure,
    );

    provider.addGeneratedEssay(essay);

    setState(() {
      _isGenerating = false;
      _newGeneratedEssay = essay;
    });
  }
}
