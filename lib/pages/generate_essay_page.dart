import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../widgets/header_bar.dart';

class GenerateEssayPage extends StatefulWidget {
  const GenerateEssayPage({Key? key}) : super(key: key);

  @override
  State<GenerateEssayPage> createState() => _GenerateEssayPageState();
}

class _GenerateEssayPageState extends State<GenerateEssayPage> {
  // Step 1: Project Name, Category & Level
  final TextEditingController _projectTitleController = TextEditingController();
  String _selectedCategory = 'Job Interview';
  double _difficultyValue = 3.0; // C1
  String _selectedTone = 'Professional';

  // Step 2: Context Input (Text, Voice, File)
  int _inputModeTab = 0; // 0 = Ketik Teks, 1 = Voice Note, 2 = Import File
  final TextEditingController _customTextController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();

  // 🎙️ Real Audio Recorder & Player State
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isRecordingVoice = false;
  bool _isPlayingVoice = false;
  String? _recordedAudioPath;
  final TextEditingController _transcriptTextController = TextEditingController();
  bool _isTranscribing = false;
  bool _sttInitialized = false;

  // Language Locale for Speech-To-Text ('en_US' for English, 'id_ID' for Bahasa Indonesia)
  String _sttLocaleId = 'en_US';

  // 📎 Real File Picker
  String? _attachedFileName;
  String _attachedFileContent = '';

  // Execution State
  bool _isGenerating = false;
  Essay? _newGeneratedEssay;

  final List<String> _categories = ['Job Interview', 'IELTS Part 2', 'Elevator Pitch', 'Conversation'];
  final List<String> _difficulties = ['A2', 'B1', 'B2', 'C1', 'C2'];
  final List<String> _tones = ['Professional', 'Conversational', 'Academic'];

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlayingVoice = false);
    });
  }

  Future<void> _initSpeechToText() async {
    try {
      _sttInitialized = await _speechToText.initialize(
        onError: (val) => debugPrint('[STT Error]: $val'),
        onStatus: (val) => debugPrint('[STT Status]: $val'),
      );
    } catch (e) {
      debugPrint('[STT Init Exception]: $e');
    }
  }

  @override
  void dispose() {
    _projectTitleController.dispose();
    _customTextController.dispose();
    _customPromptController.dispose();
    _transcriptTextController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _speechToText.stop();
    super.dispose();
  }

  // 🎙️ Audio Recording Handler
  Future<void> _toggleAudioRecording() async {
    try {
      if (_isRecordingVoice) {
        // Stop recording
        final path = await _audioRecorder.stop();
        if (_speechToText.isListening) {
          await _speechToText.stop();
        }

        setState(() {
          _isRecordingVoice = false;
          _recordedAudioPath = path;
          _isTranscribing = true;
        });

        // Verify audio file size (kIsWeb bypasses file length check)
        int audioSize = 0;
        if (path != null && path.isNotEmpty && !kIsWeb) {
          final file = File(path);
          if (await file.exists()) {
            audioSize = await file.length();
          }
        }

        // Warn ONLY if audio file is truly empty AND no text was recognized by STT
        if ((path == null || path.isEmpty || (audioSize < 100 && !kIsWeb)) && _transcriptTextController.text.trim().isEmpty) {
          setState(() {
            _recordedAudioPath = null;
            _isTranscribing = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Suara tidak terdeteksi! Harap periksa mikrofon kamu dan rekam ulang.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✔ Rekaman berhasil disimpan! Transkripsi siap.'),
              backgroundColor: Color(0xFF0D9488),
            ),
          );
        }

        // Attempt Backend STT Transcription
        String transcript = await ApiService.transcribeAudio(audioPath: path ?? '');

        // If backend returns empty, preserve user's captured live speech
        if (transcript.isEmpty && _transcriptTextController.text.trim().isNotEmpty) {
          transcript = _transcriptTextController.text.trim();
        }

        if (mounted) {
          setState(() {
            if (transcript.isNotEmpty) {
              _transcriptTextController.text = transcript;
            }
            _isTranscribing = false;
          });
        }
      } else {
        // Start recording
        if (await _audioRecorder.hasPermission()) {
          final tempDir = kIsWeb ? null : await getTemporaryDirectory();
          final path = kIsWeb ? '' : '${tempDir!.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

          // Reset previous state
          setState(() {
            _isRecordingVoice = true;
            _transcriptTextController.text = '';
            _recordedAudioPath = null;
          });

          // Start On-device Speech Recognition in selected language
          if (_sttInitialized) {
            _startContinuousListening();
          }

          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin mikrofon belum diberikan!'), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[AudioRecord Error]: $e');
      setState(() {
        _isRecordingVoice = false;
        _isTranscribing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal merekam suara: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 🔄 Continuous Speech Recognition without early timeout pause
  void _startContinuousListening() {
    if (!_isRecordingVoice) return;

    _speechToText.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _transcriptTextController.text = result.recognizedWords;
          });
        }
      },
      localeId: _sttLocaleId, // Uses user-selected language (en_US or id_ID)
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 10),
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onSoundLevelChange: null,
      cancelOnError: false,
    );
  }

  // 🔊 Audio Playback Handler
  Future<void> _toggleAudioPlayback() async {
    if (_recordedAudioPath == null || _recordedAudioPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada file rekaman suara!'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      if (_isPlayingVoice) {
        await _audioPlayer.stop();
        setState(() => _isPlayingVoice = false);
      } else {
        setState(() => _isPlayingVoice = true);
        await _audioPlayer.stop();

        if (kIsWeb) {
          await _audioPlayer.play(UrlSource(_recordedAudioPath!));
        } else {
          final file = File(_recordedAudioPath!);
          if (await file.exists() && (await file.length()) > 0) {
            await _audioPlayer.play(DeviceFileSource(_recordedAudioPath!));
          } else {
            setState(() => _isPlayingVoice = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File rekaman kosong atau tidak ditemukan.'), backgroundColor: Colors.red),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[AudioPlayer Exception]: $e');
      setState(() => _isPlayingVoice = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memutar audio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 📎 Real File Picker Handler
  Future<void> _pickDocumentFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
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
          _attachedFileContent = contentText.length > 3000 ? contentText.substring(0, 3000) : contentText;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✔ Berhasil mengunggah: ${file.name}'), backgroundColor: const Color(0xFF0D9488)),
          );
        }
      }
    } catch (e) {
      debugPrint('[FilePicker Error]: $e');
    }
  }

  void _showEditGeneratedDialog(BuildContext context, AppProvider provider) {
    if (_newGeneratedEssay == null) return;
    final titleCtrl = TextEditingController(text: _newGeneratedEssay!.title);
    final categoryCtrl = TextEditingController(text: _newGeneratedEssay!.category);
    final contentCtrl = TextEditingController(text: _newGeneratedEssay!.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Hasil Narasi',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Judul Project / Narasi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: InputDecoration(
                  labelText: 'Kategori / Project',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Naskah Narasi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              final c = categoryCtrl.text.trim();
              final cnt = contentCtrl.text.trim();
              if (t.isNotEmpty && cnt.isNotEmpty) {
                provider.updateEssayNarrative(_newGeneratedEssay!.id, t, cnt, c.isNotEmpty ? c : 'Umum');
                setState(() {
                  _newGeneratedEssay = Essay(
                    id: _newGeneratedEssay!.id,
                    title: t,
                    category: c,
                    subTopic: _newGeneratedEssay!.subTopic,
                    difficulty: _newGeneratedEssay!.difficulty,
                    tone: _newGeneratedEssay!.tone,
                    content: cnt,
                    createdAt: _newGeneratedEssay!.createdAt,
                  );
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Pristine Light Canvas
      appBar: const HeaderBar(title: 'BeMind AI'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── ELEGANT HEADER CARD ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.sparkles, color: Color(0xFF0D9488), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buat Project & Narasi AI',
                            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sintesis naskah narasi presisi berdasarkan latar belakang & kustomisasi kamu.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ─── STEP 1: NAMA PROJECT, KATEGORI & TARGET LEVEL ──────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _buildStepBadge('1'),
                        const SizedBox(width: 10),
                        Text(
                          'Pilih Project & Level Fluency',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Input Nama/Judul Project
                    Text(
                      'Nama Project / Judul Narasi:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _projectTitleController,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Persiapan Wawancara Senior AI Engineer',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Kategori Project Chips
                    Text(
                      'Kategori Project:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: const Color(0xFF0D9488),
                          backgroundColor: const Color(0xFFF8FAFC),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            color: isSel ? Colors.white : const Color(0xFF64748B),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                            side: BorderSide(color: isSel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategory = cat);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Slider Target English Level
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Target English Level:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _difficulties[_difficultyValue.round()],
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF6366F1)),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _difficultyValue,
                      min: 0,
                      max: 4,
                      divisions: 4,
                      activeColor: const Color(0xFF0D9488),
                      inactiveColor: const Color(0xFFE2E8F0),
                      onChanged: (val) => setState(() => _difficultyValue = val),
                    ),

                    const SizedBox(height: 10),

                    // Gaya Bahasa / Tone Selection Chips
                    Row(
                      children: [
                        Text('Gaya Bahasa:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            children: _tones.map((t) {
                              final isSel = _selectedTone == t;
                              return ChoiceChip(
                                label: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                                selected: isSel,
                                selectedColor: const Color(0xFFCCFBF1),
                                labelStyle: TextStyle(color: isSel ? const Color(0xFF0D9488) : const Color(0xFF64748B), fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  side: BorderSide(color: isSel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
                                ),
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

              const SizedBox(height: 18),

              // ─── STEP 2: INPUT DATA PENDUKUNG (TEXT, VOICE, PDF REAL) ───────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _buildStepBadge('2'),
                        const SizedBox(width: 10),
                        Text(
                          'Input Data Konteks (Context)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masukkan informasi pengalaman, poin penting, atau latar belakang kamu.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 14),

                    // 📱 Full-Width 100% Symmetric Tab Switcher Bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildTabButton(0, LucideIcons.fileText, 'Ketik Teks')),
                          Expanded(child: _buildTabButton(1, LucideIcons.mic, 'Voice Note')),
                          Expanded(child: _buildTabButton(2, LucideIcons.paperclip, 'Import File')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tab Body 0: Ketik Teks
                    if (_inputModeTab == 0) ...[
                      TextField(
                        controller: _customTextController,
                        maxLines: 4,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Saya berpengalaman 5 tahun sebagai AI Engineer di Fintech. Berhasil membangun microservice Golang dan optimasi latency database 45%...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
                        ),
                      ),
                    ]
                    // Tab Body 1: 🎙️ VOICE NOTE RECORDER & PLAYER (WITH LANGUAGE SELECTOR)
                    else if (_inputModeTab == 1) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 🌐 Language Mode Switcher (English vs Bahasa Indonesia)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Bahasa Bicara:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('English 🇺🇸'),
                                  selected: _sttLocaleId == 'en_US',
                                  selectedColor: const Color(0xFF0D9488),
                                  labelStyle: TextStyle(color: _sttLocaleId == 'en_US' ? Colors.white : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
                                  onSelected: (sel) {
                                    if (sel) setState(() => _sttLocaleId = 'en_US');
                                  },
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('Bahasa Indonesia 🇮🇩'),
                                  selected: _sttLocaleId == 'id_ID',
                                  selectedColor: const Color(0xFF0D9488),
                                  labelStyle: TextStyle(color: _sttLocaleId == 'id_ID' ? Colors.white : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
                                  onSelected: (sel) {
                                    if (sel) setState(() => _sttLocaleId = 'id_ID');
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 🟢 Recording Button centered perfectly
                            GestureDetector(
                              onTap: _toggleAudioRecording,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRecordingVoice ? Colors.red : const Color(0xFF0D9488),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isRecordingVoice ? Colors.red : const Color(0xFF0D9488)).withValues(alpha: 0.35),
                                      blurRadius: 20,
                                      spreadRadius: _isRecordingVoice ? 6 : 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isRecordingVoice ? LucideIcons.square : LucideIcons.mic,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _isRecordingVoice
                                  ? '🔴 Sedang Merekam Tanpa Henti... (Ketuk untuk Selesai)'
                                  : (_recordedAudioPath != null ? '✔ Rekaman Tersimpan & Siap Diputar' : 'Ketuk Tombol Mikrofon untuk Merekam Suara'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isRecordingVoice ? Colors.red : const Color(0xFF0F172A),
                              ),
                            ),

                            // 🔊 Audio Playback Controls (Dengarkan Ulang Audio)
                            if (_recordedAudioPath != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFCCFBF1), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: _toggleAudioPlayback,
                                      icon: Icon(
                                        _isPlayingVoice ? LucideIcons.pauseCircle : LucideIcons.playCircle,
                                        size: 32,
                                        color: const Color(0xFF0D9488),
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dengarkan Ulang Voice Note',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _isPlayingVoice ? 'Memutar audio rekaman...' : 'Ketuk play untuk memeriksa kejelasan suara',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _recordedAudioPath = null;
                                          _transcriptTextController.clear();
                                        });
                                      },
                                      icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                                      tooltip: 'Hapus & Rekam Ulang',
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // 📝 High-Accuracy STT Transcribed Text Box (Editable Live)
                            if (_isTranscribing) ...[
                              const SizedBox(height: 16),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D9488))),
                                  SizedBox(width: 8),
                                  Text('Mengonversi Suara menjadi Teks Presisi AI...', style: TextStyle(fontSize: 11, color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ] else ...[
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Hasil Transkripsi Teks (Dapat Diedit / Disesuaikan):',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0D9488)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _transcriptTextController,
                                maxLines: 4,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF0F172A)),
                                decoration: InputDecoration(
                                  hintText: 'Teks hasil rekaman suara kamu akan otomatis muncul di sini...',
                                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCCFBF1))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCCFBF1))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ]
                    // Tab Body 2: Import Document
                    else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.fileCode2, size: 32, color: Color(0xFF6366F1)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _attachedFileName ?? 'Upload File CV / Resume (PDF)',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                  ),
                                  Text('Format: PDF, TXT, DOCX', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _pickDocumentFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
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

              const SizedBox(height: 18),

              // ─── STEP 3: KUSTOMISASI PROMPT (TUNE PROMPT) ─────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _buildStepBadge('3'),
                        const SizedBox(width: 10),
                        Text(
                          'Kustomisasi Prompt & Instruksi AI',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Atur instruksi khusus untuk AI (misal: Gunakan STAR Method, tekankan leadership).',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _customPromptController,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Gunakan STAR Method (Situation, Task, Action, Result) dan tekankan arsitektur cloud & efisiensi database...',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ─── EKSEKUSI: TOMBOL GENERATE PROJECT ─────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : () => _generateNarrative(provider),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
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

              // ─── HASIL GENERATE & AKSI (EDIT / DELETE / TELEPROMPTER) ────────────────
              if (_newGeneratedEssay != null) ...[
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.checkCircle2, color: Color(0xFF0D9488), size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Project Naskah Berhasil Dibuat!',
                                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.pencil, size: 16, color: Color(0xFF0D9488)),
                                onPressed: () => _showEditGeneratedDialog(context, provider),
                                tooltip: 'Edit Hasil Narasi',
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                                onPressed: () {
                                  provider.deleteEssayNarrative(_newGeneratedEssay!.id);
                                  setState(() => _newGeneratedEssay = null);
                                },
                                tooltip: 'Hapus Naskah Ini',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _newGeneratedEssay!.title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Project: ${_newGeneratedEssay!.category}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF0D9488), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Level ${_newGeneratedEssay!.difficulty}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6366F1), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _newGeneratedEssay!.content,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => provider.selectEssayForTeleprompter(_newGeneratedEssay!),
                          icon: const Icon(LucideIcons.playCircle, size: 20, color: Colors.white),
                          label: const Text('Buka di Teleprompter Reader'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
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
        color: const Color(0xFFCCFBF1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Langkah $number',
        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488)),
      ),
    );
  }

  // 📱 Symmetric Full-Width Tab Button Widget
  Widget _buildTabButton(int index, IconData icon, String label) {
    final isSel = _inputModeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _inputModeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF0D9488) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSel ? [BoxShadow(color: const Color(0xFF0D9488).withValues(alpha: 0.3), blurRadius: 6)] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isSel ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  void _generateNarrative(AppProvider provider) async {
    final customTitle = _projectTitleController.text.trim();

    setState(() {
      _isGenerating = true;
      _newGeneratedEssay = null;
    });

    final userCustomText = _customTextController.text.trim();
    final customPrompt = _customPromptController.text.trim();
    final voiceText = _transcriptTextController.text.trim();

    String combinedContext = '';
    if (userCustomText.isNotEmpty) {
      combinedContext += 'User Direct Input:\n$userCustomText\n';
    }
    if (voiceText.isNotEmpty) {
      combinedContext += 'Voice Audio Transcript:\n$voiceText\n';
    }
    if (_attachedFileContent.isNotEmpty) {
      combinedContext += 'Uploaded Document Context (${_attachedFileName}):\n$_attachedFileContent\n';
    }

    final providerContexts = provider.contextItems.map((c) => c.content).join('\n');
    if (providerContexts.isNotEmpty) {
      combinedContext += 'Context Vault Items:\n$providerContexts\n';
    }

    final essay = await ApiService.generateEssay(
      userId: provider.user.id,
      category: _selectedCategory,
      subTopic: customTitle.isNotEmpty ? customTitle : (customPrompt.isNotEmpty ? customPrompt : 'Custom Narrative & Prompt'),
      difficulty: _difficulties[_difficultyValue.round()],
      tone: _selectedTone,
      userContext: combinedContext,
      templateId: provider.selectedRemixTemplate?.id,
      promptTemplate: customPrompt.isNotEmpty ? customPrompt : provider.selectedRemixTemplate?.templateStructure,
    );

    // Override title with user custom project title if provided
    Essay finalEssay = essay;
    if (customTitle.isNotEmpty) {
      finalEssay = Essay(
        id: essay.id,
        title: customTitle,
        category: essay.category,
        subTopic: essay.subTopic,
        difficulty: essay.difficulty,
        tone: essay.tone,
        content: essay.content,
        createdAt: essay.createdAt,
      );
    }

    provider.addGeneratedEssay(finalEssay);

    setState(() {
      _isGenerating = false;
      _newGeneratedEssay = finalEssay;
    });
  }
}
