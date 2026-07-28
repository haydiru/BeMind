import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppProvider>(context, listen: false).refreshVocabularies();
      }
    });
  }

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
      if (_selectedFilter == 'Review') return v.masteryStatus == MasteryStatus.review;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const HeaderBar(title: 'BeMind AI'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVocabDialog(context, provider),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: Text(
          'Tambah Kosa Kata',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Controls & Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  // Title & Counter Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(LucideIcons.bookMarked, size: 20, color: Color(0xFF0D9488)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vocab Vault',
                                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                              ),
                              Text(
                                '${allVocab.length} kosa kata tersimpan',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Flashcard / List Mode Toggle Button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isFlashcardMode = !_isFlashcardMode;
                            _flashcardIndex = 0;
                            _isCardFlipped = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isFlashcardMode ? const Color(0xFF6366F1) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _isFlashcardMode ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isFlashcardMode ? LucideIcons.list : LucideIcons.layers,
                                size: 15,
                                color: _isFlashcardMode ? Colors.white : const Color(0xFF0F172A),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isFlashcardMode ? 'Mode List' : 'Mode Kartu',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _isFlashcardMode ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Search Field
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari kosa kata, arti, atau contoh...',
                      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 12),
                      prefixIcon: const Icon(LucideIcons.search, size: 18, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Mastery Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Learning', 'Mastered', 'Review'].map((filter) {
                        final isSel = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedFilter = filter),
                            borderRadius: BorderRadius.circular(999),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF0D9488) : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: isSel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                filter == 'All'
                                    ? 'Semua (${allVocab.length})'
                                    : filter == 'Learning'
                                        ? 'Sedang Pelajari'
                                        : filter == 'Mastered'
                                            ? 'Sudah Paham'
                                            : 'Perlu Review',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: isSel ? Colors.white : const Color(0xFF64748B),
                                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFFF1F5F9), height: 1),

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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.bookOpenCheck, size: 48, color: Color(0xFFCBD5E1)),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Kosa Kata',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Text(
                'Klik kata di halaman Teleprompter saat latihan untuk menyimpan kosa kata baru secara otomatis!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isMastered = item.masteryStatus == MasteryStatus.mastered;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word Title, Phonetic & Mastery Status Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.word,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.phonetic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0D9488)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Mastery Toggle Button
                      InkWell(
                        onTap: () {
                          final newStatus = isMastered ? MasteryStatus.learning : MasteryStatus.mastered;
                          provider.updateVocabStatus(item.id, newStatus);
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isMastered ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: isMastered ? const Color(0xFF16A34A).withValues(alpha: 0.3) : const Color(0xFFD97706).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isMastered ? LucideIcons.checkCircle2 : LucideIcons.clock,
                                size: 12,
                                color: isMastered ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isMastered ? 'Paham' : 'Pelajari',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isMastered ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Delete Icon
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFF94A3B8)),
                        onPressed: () => provider.deleteVocabItem(item.id),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Indonesian Meaning & Sentence Context Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.indonesianMeaning,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0D9488), height: 1.4),
                    ),
                    if (item.contextSentence.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '📝 Contoh: "${item.contextSentence}"',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF475569), fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlashcardView(List<VocabItem> items, AppProvider provider) {
    if (items.isEmpty) return const Center(child: Text('Tidak ada kartu kosa kata.'));
    final item = items[_flashcardIndex % items.length];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kartu ${_flashcardIndex + 1} dari ${items.length}',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488)),
              ),
              Text(
                'Ketuk kartu untuk balik',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCardFlipped = !_isCardFlipped),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isCardFlipped ? _buildCardBack(item) : _buildCardFront(item),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.updateVocabStatus(item.id, MasteryStatus.learning);
                    setState(() {
                      _flashcardIndex = (_flashcardIndex + 1) % items.length;
                      _isCardFlipped = false;
                    });
                  },
                  icon: const Icon(LucideIcons.rotateCcw, size: 16, color: Color(0xFFD97706)),
                  label: const Text('Perlu Latihan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF3C7),
                    foregroundColor: const Color(0xFFD97706),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.updateVocabStatus(item.id, MasteryStatus.mastered);
                    setState(() {
                      _flashcardIndex = (_flashcardIndex + 1) % items.length;
                      _isCardFlipped = false;
                    });
                  },
                  icon: const Icon(LucideIcons.checkCircle2, size: 16, color: Colors.white),
                  label: const Text('Sudah Paham'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCardFront(VocabItem item) {
    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.word,
            style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          Text(
            item.phonetic,
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0D9488)),
          ),
          const SizedBox(height: 20),
          Text(
            '🔄 Ketuk untuk melihat arti & konteks',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(VocabItem item) {
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFCCFBF1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF0D9488), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.indonesianMeaning,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488), height: 1.4),
          ),
          if (item.contextSentence.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              '"${item.contextSentence}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF334155), fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddVocabDialog(BuildContext context, AppProvider provider) {
    final wordCtrl = TextEditingController();
    final meaningCtrl = TextEditingController();
    final exampleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Tambah Kosa Kata Manual', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordCtrl,
              decoration: InputDecoration(
                labelText: 'Kosa Kata (Bahasa Inggris)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: meaningCtrl,
              decoration: InputDecoration(
                labelText: 'Arti (Bahasa Indonesia)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: exampleCtrl,
              decoration: InputDecoration(
                labelText: 'Contoh Kalimat (Opsional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final w = wordCtrl.text.trim();
              final m = meaningCtrl.text.trim();
              if (w.isNotEmpty && m.isNotEmpty) {
                provider.addVocabItem(VocabItem(
                  id: 'vcb_${DateTime.now().millisecondsSinceEpoch}',
                  word: w,
                  phonetic: '/${w.toLowerCase()}/',
                  definition: 'Manual entry',
                  contextSentence: exampleCtrl.text.trim(),
                  indonesianMeaning: m,
                  masteryStatus: MasteryStatus.learning,
                  addedAt: DateTime.now(),
                ));
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
}
