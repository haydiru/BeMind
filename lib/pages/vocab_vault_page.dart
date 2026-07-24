import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/header_bar.dart';

class VocabVaultPage extends StatefulWidget {
  const VocabVaultPage({Key? key}) : super(key: key);

  @override
  State<VocabVaultPage> createState() => _VocabVaultPageState();
}

class _VocabVaultPageState extends State<VocabVaultPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isFlashcardMode = false;
  int _flashcardIndex = 0;
  bool _isCardFlipped = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allVocab = provider.vocabList;

    final filteredVocab = allVocab.where((v) {
      final matchesSearch = v.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.definition.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.indonesianMeaning.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;
      if (_selectedFilter == 'Learning') return v.masteryStatus == MasteryStatus.learning;
      if (_selectedFilter == 'Mastered') return v.masteryStatus == MasteryStatus.mastered;
      if (_selectedFilter == 'Need Review') return v.masteryStatus == MasteryStatus.review;
      return true;
    }).toList();

    return Scaffold(
      appBar: const HeaderBar(title: 'BeMind AI'),
      body: SafeArea(
        child: Column(
          children: [
            // Top Controls Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: GoogleFonts.plusJakartaSans(color: AppTheme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search words, definitions...',
                            hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted),
                            prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppTheme.textMuted),
                            filled: true,
                            fillColor: const Color(0FFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0FFE2E8F0)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isFlashcardMode = !_isFlashcardMode;
                            _flashcardIndex = 0;
                            _isCardFlipped = false;
                          });
                        },
                        icon: Icon(_isFlashcardMode ? LucideIcons.list : LucideIcons.layers, size: 16),
                        label: Text(_isFlashcardMode ? 'List' : 'Flashcard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFlashcardMode ? AppTheme.primaryPurple : AppTheme.primaryCyan,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Learning', 'Mastered', 'Need Review'].map((filter) {
                        final isSel = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSel,
                            selectedColor: AppTheme.primaryCyan,
                            backgroundColor: const Color(0FFF8FAFC),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isSel ? const Color(0FFF0F172A) : AppTheme.textSecondary,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0FFE2E8F0), height: 1),

            Expanded(
              child: _isFlashcardMode
                  ? _buildFlashcardView(filteredVocab, provider)
                  : _buildListView(filteredVocab, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<VocabItem> items, AppProvider provider) {
    if (items.isEmpty) {
      return Center(
        child: Text('No vocabulary items found', style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.word,
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.chipPdfBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.masteryStatus.name.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.chipPdfColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Arti: ${item.indonesianMeaning}',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accentEmerald),
              ),
              const SizedBox(height: 4),
              Text(
                item.definition,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textPrimary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlashcardView(List<VocabItem> items, AppProvider provider) {
    if (items.isEmpty) return const Center(child: Text('No cards available.'));
    final item = items[_flashcardIndex % items.length];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Card ${_flashcardIndex + 1} of ${items.length}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
              Text('Tap to flip card', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCardFlipped = !_isCardFlipped),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isCardFlipped ? _buildCardBack(item) : _buildCardFront(item),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _flashcardIndex = (_flashcardIndex + 1) % items.length;
                _isCardFlipped = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Next Card', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCardFront(VocabItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.word, style: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
          const SizedBox(height: 8),
          Text(item.phonetic, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCardBack(VocabItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.cardDecoration(borderColor: AppTheme.accentEmerald),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.indonesianMeaning, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.accentEmerald)),
          const SizedBox(height: 12),
          Text(item.definition, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
