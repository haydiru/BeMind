import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
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
  
  // Real Audio Recorder (Record package)
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecordingVoice = false;
  String? _recordedAudioPath;
  String _recordedAudioSummary = '';

  // Real File Picker (FilePicker package)
  String? _attachedFileName;
  String? _attachedFilePath;
  String _attachedFileContent = '';

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
    _audioRecorder.dispose();
    super.dispose();
  }

  // 🎙️ Real Audio Recording Handler
  Future<void> _toggleAudioRecording() async {
    try {
      if (_isRecordingVoice) {
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecordingVoice = false;
          _recordedAudioPath = path;
          _recordedAudioSummary = 'Rekaman Suara ($path)';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✔ Rekaman suara berhasil disimpan!'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (await _audioRecorder.hasPermission()) {
          final tempDir = kIsWeb ? null : await getTemporaryDirectory();
          final path = kIsWeb ? '' : '${tempDir!.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
          
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path,
          );
          setState(() {
            _isRecordingVoice = true;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin mikrofon tidak diberikan!'), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      // Fallback for Web/Browser where native path recording is limited
      setState(() {
        _isRecordingVoice = !_isRecordingVoice;
        if (!_isRecordingVoice) {
          _recordedAudioSummary = 'Voice Note Audio Input (${DateTime.now().hour}:${DateTime.now().minute})';
        }
      });
    }
  }

  // 📎 Real File Picker Handler (PDF, TXT, DOCX)
  Future<void> _pickDocumentFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String contentText = '';

        if (file.bytes != null) {
          try {
            contentText = utf8.decode(file.bytes!, allowMalformed: true);
          } catch (_) {
            contentText = 'Lampiran dokumen: ${file.name}';
          }
        } else if (file.path != null && !kIsWeb) {
          try {
            final f = File(file.path!);
            contentText = await f.readAsString();
          } catch (_) {
            contentText = 'Lampiran dokumen: ${file.name}';
          }
        }

        setState(() {
          _attachedFileName = file.name;
          _attachedFilePath = file.path;
          _attachedFileContent = contentText.length > 3000 ? contentText.substring(0, 3000) : contentText;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✔ Berhasil mengunggah: ${file.name}'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      debugPrint('[FilePicker Error]: $e');
    }
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
              // Top Title Card
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

              // ─── TAHAP 2: INPUT DATA PENDUKUNG (TEXT, VOICE, PDF REAL) ───────────────
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

                    // Input Mode Tabs
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
                      // Real Voice Note Recorder UI
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
                              onTap: _toggleAudioRecording,
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
                            if (_recordedAudioSummary.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.checkCircle, size: 16, color: AppTheme.primaryBlue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _recordedAudioSummary,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ] else ...[
                      // Real PDF/Doc Attachment UI
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
                                  Text('Format: PDF, TXT, DOCX', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _pickDocumentFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(_attachedFileName != null ? 'Ganti File' : 'Pilih File', style: const TextStyle(fontSize: 12)),
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

              // ─── EKSEKUSI: TOMBOL GENERATE PROJECT ─────────────────────────────────
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
                            'Project Naskah Berhasil Dibuat & Tersimpan!',
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

    // Gather real context from user custom text, voice audio, or uploaded file
    final userCustomText = _customTextController.text.trim();
    final customPrompt = _customPromptController.text.trim();
    
    String combinedContext = '';
    if (userCustomText.isNotEmpty) {
      combinedContext += 'User Direct Input:\n$userCustomText\n';
    }
    if (_recordedAudioSummary.isNotEmpty) {
      combinedContext += 'Voice Audio Input Context:\n$_recordedAudioSummary\n';
    }
    if (_attachedFileContent.isNotEmpty) {
      combinedContext += 'Uploaded Document Context (${_attachedFileName}):\n$_attachedFileContent\n';
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
      subTopic: customPrompt.isNotEmpty ? customPrompt : 'Custom Narrative & Prompt',
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
