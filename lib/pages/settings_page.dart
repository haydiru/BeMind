import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;

  // Admin Model Switcher state
  String _activeModel = 'Qwen3.6-35B-A3B';
  List<String> _availableModels = ['Qwen3.6-35B-A3B', 'gpt-4o', 'gpt-4o-mini', 'gemini-1.5-flash', 'deepseek-coder'];
  bool _isLoadingModel = false;
  bool _isAdminExpanded = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user.name);
    _loadAdminModelInfo();
  }

  Future<void> _loadAdminModelInfo() async {
    final info = await ApiService.fetchAdminModelInfo();
    if (mounted) {
      setState(() {
        _activeModel = info['activeModel'] ?? 'Qwen3.6-35B-A3B';
        _availableModels = List<String>.from(info['availableModels'] ?? _availableModels);
      });
    }
  }

  Future<void> _switchModel(String model) async {
    setState(() => _isLoadingModel = true);
    final success = await ApiService.updateAdminActiveModel(model);
    if (mounted) {
      setState(() {
        _isLoadingModel = false;
        if (success) _activeModel = model;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          success ? '✔ Model switched to $model' : '✖ Failed to switch model — backend may be offline',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        backgroundColor: success ? const Color(0xFF16A34A) : AppTheme.accentRose,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user;
    final notif = provider.notificationSettings;
    final vocabList = provider.vocabList;

    final sampleVocab = vocabList.isNotEmpty
        ? vocabList.first
        : VocabItem(
            id: 'sample',
            word: 'Spearheaded',
            phonetic: '/ˈspɪər.hed.ɪd/',
            definition: 'To lead an attack or course of action.',
            contextSentence: 'I spearheaded a comprehensive system audit.',
            indonesianMeaning: 'Memimpin / Pelopor akselerasi',
            addedAt: DateTime.now(),
          );

    return Scaffold(
      appBar: const HeaderBar(title: 'BeMind AI'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ─── Profile Section ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.primaryCyan,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              Text(user.email, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.plusJakartaSans(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Passive Learning Settings ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'On-Device Passive Learning',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                        Switch(
                          value: notif.isEnabled,
                          activeColor: AppTheme.primaryCyan,
                          onChanged: (val) => provider.toggleNotifications(val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pushes random vocabulary cards to smartphone lockscreen.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Admin AI Model Switcher ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1E1B4B), const Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    // Header — tap to expand/collapse
                    GestureDetector(
                      onTap: () => setState(() => _isAdminExpanded = !_isAdminExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(LucideIcons.cpu, size: 18, color: AppTheme.primaryPurple),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⚡ Admin: AI Model Control',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                  Text(
                                    'Active: $_activeModel',
                                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.primaryPurple),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedRotation(
                              turns: _isAdminExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: Icon(LucideIcons.chevronDown, size: 18, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expanded Model Selection Panel
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isAdminExpanded
                          ? Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(color: Colors.white.withValues(alpha: 0.08)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Switch Active LLM Model',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white54),
                                  ),
                                  const SizedBox(height: 10),
                                  _isLoadingModel
                                      ? const Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _availableModels.map((model) {
                                            final isActive = model == _activeModel;
                                            return GestureDetector(
                                              onTap: isActive ? null : () => _switchModel(model),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? AppTheme.primaryPurple.withValues(alpha: 0.2)
                                                      : const Color(0xFF1E293B),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isActive ? AppTheme.primaryPurple : Colors.white12,
                                                    width: isActive ? 1.5 : 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (isActive)
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 6),
                                                        child: Icon(LucideIcons.check, size: 12, color: AppTheme.primaryPurple),
                                                      ),
                                                    Text(
                                                      model,
                                                      style: GoogleFonts.jetBrainsMono(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: isActive ? AppTheme.primaryPurple : Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: _loadAdminModelInfo,
                                    icon: Icon(LucideIcons.refreshCw, size: 13, color: Colors.white38),
                                    label: Text('Refresh from backend', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white38)),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Lockscreen Preview ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text('22:15', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w200, color: Colors.white)),
                    Text('Friday, July 25', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BeMind Passive Flashcard', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryCyan)),
                          const SizedBox(height: 4),
                          Text('${sampleVocab.word} (${sampleVocab.phonetic})', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Arti: ${sampleVocab.indonesianMeaning}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF4ADE80))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () => provider.logout(),
                icon: const Icon(LucideIcons.logOut, size: 18),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.chipTextBg,
                  foregroundColor: AppTheme.accentRose,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
