import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user.name);
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
              // Profile Section Card
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

              // Passive Learning Engine Settings
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

              // Smartphone Lockscreen Preview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text('22:15', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w200, color: Colors.white)),
                    Text('Friday, July 24', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
