import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  // Navigation State
  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  void setPageIndex(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }

  // ─── Authentication & Profile State ───────────────────────────────────────
  UserProfile _user = UserProfile(
    id: 'usr_guest',
    name: 'Pengguna BeMind',
    email: 'user@bemind.ai',
    targetGoal: 'Job Interview Prep',
    profileCompleteness: 85,
  );
  UserProfile get user => _user;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoadingEssays = false;
  bool get isLoadingEssays => _isLoadingEssays;

  void login(String email, String password) {
    _isLoggedIn = true;
    final supaUser = Supabase.instance.client.auth.currentUser;
    final userId = supaUser?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final userName = supaUser?.userMetadata?['name'] ?? email.split('@').first;
    _user = UserProfile(
      id: userId,
      name: userName,
      email: email,
      targetGoal: 'Job Interview Prep',
      profileCompleteness: 85,
    );
    notifyListeners();
    _loadUserEssays(userId);
    _loadUserVocabularies(userId);
  }

  void loginWithProfile({required String id, required String name, required String email, required String targetGoal}) {
    _isLoggedIn = true;
    _user = UserProfile(
      id: id,
      name: name,
      email: email,
      targetGoal: targetGoal,
      profileCompleteness: 85,
    );
    notifyListeners();
    _loadUserEssays(id);
    _loadUserVocabularies(id);
  }

  void logout() {
    _isLoggedIn = false;
    _essays.clear();
    _activeEssay = null;
    _user = UserProfile(
      id: 'usr_guest',
      name: 'Pengguna BeMind',
      email: 'user@bemind.ai',
      targetGoal: 'Job Interview Prep',
      profileCompleteness: 40,
    );
    Supabase.instance.client.auth.signOut();
    notifyListeners();
  }

  void updateTargetGoal(String newGoal) {
    _user = _user.copyWith(targetGoal: newGoal);
    notifyListeners();
  }

  void updateProfileName(String name) {
    _user = _user.copyWith(name: name);
    notifyListeners();
  }

  /// Update user display name in Supabase Auth (user_metadata) + local state
  Future<String?> updateUserNameInDB(String newName) async {
    if (newName.trim().isEmpty) return 'Nama tidak boleh kosong!';
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'name': newName.trim(), 'full_name': newName.trim()}),
      );
      _user = _user.copyWith(name: newName.trim());
      notifyListeners();
      return null; // success
    } catch (e) {
      debugPrint('[AppProvider] Error updating name: $e');
      return 'Gagal menyimpan nama: $e';
    }
  }

  /// Update user password in Supabase Auth
  Future<String?> updateUserPassword(String newPassword) async {
    if (newPassword.length < 6) return 'Password minimal 6 karakter!';
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return null; // success
    } catch (e) {
      debugPrint('[AppProvider] Error updating password: $e');
      return 'Gagal mengubah password: $e';
    }
  }

  // ─── Context Vault State (user-uploaded context docs) ──────────────────────
  final List<ContextItem> _contextItems = [];
  List<ContextItem> get contextItems => List.unmodifiable(_contextItems);

  void addContextItem(SourceType type, String title, String content) {
    _contextItems.insert(
      0,
      ContextItem(
        id: 'ctx_${DateTime.now().millisecondsSinceEpoch}',
        sourceType: type,
        title: title,
        content: content,
        timestamp: DateTime.now(),
      ),
    );
    int newCompleteness = (40 + (_contextItems.length * 15)).clamp(40, 100);
    _user = _user.copyWith(profileCompleteness: newCompleteness);
    notifyListeners();
  }

  // ─── AI Narrative / Project State ──────────────────────────────────────────
  final List<Essay> _essays = [];
  List<Essay> get essays => List.unmodifiable(_essays);

  Essay? _activeEssay;
  Essay? get activeEssay => _activeEssay ?? (_essays.isNotEmpty ? _essays.first : null);

  // Selected Project context when clicking "+ Tambah Narasi"
  String? _selectedProjectCategory;
  String? get selectedProjectCategory => _selectedProjectCategory;

  void startNewNarrativeForProject(String categoryName) {
    _selectedProjectCategory = categoryName;
    _currentPageIndex = 1; // Navigate to Generate Essay Page (index 1)
    notifyListeners();
  }

  void clearSelectedProjectCategory() {
    _selectedProjectCategory = null;
    notifyListeners();
  }

  void selectEssayForTeleprompter(Essay essay) {
    _activeEssay = essay;
    _currentPageIndex = 2; // Navigate to Teleprompter Reader Page (index 2)
    notifyListeners();
  }

  void addGeneratedEssay(Essay essay) {
    _essays.insert(0, essay);
    _activeEssay = essay;
    notifyListeners();
  }

  /// Update / Edit an existing essay narrative
  Future<void> updateEssayNarrative(String id, String newTitle, String newContent, String newCategory) async {
    final idx = _essays.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final old = _essays[idx];
      final updated = Essay(
        id: old.id,
        title: newTitle,
        category: newCategory,
        subTopic: old.subTopic,
        difficulty: old.difficulty,
        tone: old.tone,
        content: newContent,
        createdAt: old.createdAt,
      );
      _essays[idx] = updated;
      if (_activeEssay?.id == id) {
        _activeEssay = updated;
      }
      notifyListeners();

      // Sync edit to Supabase database if logged in
      try {
        await Supabase.instance.client.from('generated_essays').update({
          'title': newTitle,
          'category': newCategory,
          'content': newContent,
        }).eq('id', id);
      } catch (e) {
        debugPrint('[AppProvider] Error updating essay in Supabase: $e');
      }
    }
  }

  /// Delete an essay narrative
  Future<void> deleteEssayNarrative(String id) async {
    _essays.removeWhere((e) => e.id == id);
    if (_activeEssay?.id == id) {
      _activeEssay = _essays.isNotEmpty ? _essays.first : null;
    }
    notifyListeners();

    try {
      await Supabase.instance.client.from('generated_essays').delete().eq('id', id);
    } catch (e) {
      debugPrint('[AppProvider] Error deleting essay from Supabase: $e');
    }
  }

  /// Update a project category name across all its essays
  Future<void> updateProjectCategory(String oldCategory, String newCategory) async {
    if (oldCategory == newCategory) return;
    for (int i = 0; i < _essays.length; i++) {
      if (_essays[i].category == oldCategory) {
        final old = _essays[i];
        _essays[i] = Essay(
          id: old.id,
          title: old.title,
          category: newCategory,
          subTopic: old.subTopic,
          difficulty: old.difficulty,
          tone: old.tone,
          content: old.content,
          createdAt: old.createdAt,
        );
      }
    }
    notifyListeners();

    try {
      await Supabase.instance.client.from('generated_essays').update({
        'category': newCategory,
      }).eq('category', oldCategory).eq('user_id', _user.id);
    } catch (e) {
      debugPrint('[AppProvider] Error updating category in Supabase: $e');
    }
  }

  /// Fetch this user's essays directly from Supabase generated_essays table
  Future<void> _loadUserEssays(String userId) async {
    if (userId.isEmpty || userId.startsWith('local_')) return;
    _isLoadingEssays = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('generated_essays')
          .select('id, title, category, sub_topic, difficulty, tone, content, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50)
          .timeout(const Duration(seconds: 5));

      _essays.clear();
      for (final row in response) {
        _essays.add(Essay(
          id: row['id']?.toString() ?? '',
          title: row['title'] ?? 'Untitled Project',
          category: row['category'] ?? '',
          subTopic: row['sub_topic'] ?? '',
          difficulty: row['difficulty'] ?? '',
          tone: row['tone'] ?? '',
          content: row['content'] ?? '',
          createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
        ));
      }

      int newCompleteness = (40 + (_essays.length * 8) + (_contextItems.length * 10)).clamp(40, 100);
      _user = _user.copyWith(profileCompleteness: newCompleteness);
    } catch (e) {
      debugPrint('[AppProvider] Error loading user essays from Supabase: $e');
    } finally {
      _isLoadingEssays = false;
      notifyListeners();
    }
  }

  /// Called externally to refresh essays from database
  Future<void> refreshEssays() => _loadUserEssays(_user.id);

  // ─── Vocabulary Vault State ─────────────────────────────────────────────────
  final List<VocabItem> _vocabList = [];
  List<VocabItem> get vocabList => List.unmodifiable(_vocabList);

  void addVocabItem(VocabItem item) async {
    final idx = _vocabList.indexWhere((v) => v.word.toLowerCase() == item.word.toLowerCase());
    if (idx != -1) {
      _vocabList[idx] = item;
    } else {
      _vocabList.insert(0, item);
    }
    notifyListeners();

    // Sync to Supabase database for persistent storage across sessions & logins
    try {
      if (_user.id.isNotEmpty && !_user.id.startsWith('local_')) {
        final payload = <String, dynamic>{
          'user_id': _user.id,
          'word': item.word,
          'phonetic': item.phonetic,
          'definition': item.definition,
          'context_sentence': item.contextSentence,
          'indonesian_meaning': item.indonesianMeaning,
          'mastery_status': item.masteryStatus.name,
        };
        
        // If item.id is a valid UUID, include it
        if (RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(item.id)) {
          payload['id'] = item.id;
        }

        final res = await Supabase.instance.client.from('vocabularies').upsert(
          payload,
        ).select().maybeSingle().timeout(const Duration(seconds: 5));

        if (res != null && res['id'] != null) {
          // Update in-memory item with DB generated UUID
          item.id = res['id'].toString();
        }
      }
    } catch (e) {
      debugPrint('[AppProvider] Error saving vocab to Supabase: $e');
    }
  }

  void updateVocabStatus(String id, MasteryStatus status) async {
    final idx = _vocabList.indexWhere((v) => v.id == id);
    if (idx != -1) {
      _vocabList[idx].masteryStatus = status;
      notifyListeners();

      try {
        if (RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(id)) {
          await Supabase.instance.client.from('vocabularies').update({
            'mastery_status': status.name,
          }).eq('id', id);
        } else if (_user.id.isNotEmpty) {
          await Supabase.instance.client.from('vocabularies').update({
            'mastery_status': status.name,
          }).eq('user_id', _user.id).eq('word', _vocabList[idx].word);
        }
      } catch (e) {
        debugPrint('[AppProvider] Error updating vocab status: $e');
      }
    }
  }

  void deleteVocabItem(String id) async {
    final targetItem = _vocabList.firstWhere((v) => v.id == id, orElse: () => VocabItem(id: '', word: '', phonetic: '', definition: '', contextSentence: '', indonesianMeaning: '', addedAt: DateTime.now()));
    _vocabList.removeWhere((v) => v.id == id);
    notifyListeners();

    try {
      if (RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(id)) {
        await Supabase.instance.client.from('vocabularies').delete().eq('id', id);
      } else if (_user.id.isNotEmpty && targetItem.word.isNotEmpty) {
        await Supabase.instance.client.from('vocabularies').delete().eq('user_id', _user.id).eq('word', targetItem.word);
      }
    } catch (e) {
      debugPrint('[AppProvider] Error deleting vocab: $e');
    }
  }

  /// Fetch user's saved vocabularies directly from Supabase database
  Future<void> _loadUserVocabularies(String userId) async {
    if (userId.isEmpty || userId.startsWith('local_')) return;
    try {
      final response = await Supabase.instance.client
          .from('vocabularies')
          .select('id, word, phonetic, definition, context_sentence, indonesian_meaning, mastery_status, added_at')
          .eq('user_id', userId)
          .order('added_at', ascending: false)
          .timeout(const Duration(seconds: 5));

      _vocabList.clear();
      for (final row in response) {
        MasteryStatus status = MasteryStatus.learning;
        if (row['mastery_status'] == 'mastered') status = MasteryStatus.mastered;
        if (row['mastery_status'] == 'review') status = MasteryStatus.review;

        _vocabList.add(VocabItem(
          id: row['id']?.toString() ?? '',
          word: row['word'] ?? '',
          phonetic: row['phonetic'] ?? '',
          definition: row['definition'] ?? '',
          contextSentence: row['context_sentence'] ?? '',
          indonesianMeaning: row['indonesian_meaning'] ?? '',
          masteryStatus: status,
          addedAt: DateTime.tryParse(row['added_at']?.toString() ?? '') ?? DateTime.now(),
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[AppProvider] Error loading user vocabularies from Supabase: $e');
    }
  }

  // ─── Marketplace Prompts State ──────────────────────────────────────────────
  final List<PromptTemplate> _promptTemplates = [
    PromptTemplate(
      id: 'tmpl_1',
      title: 'STAR Method Interview Master',
      creatorName: 'Sarah Jenkins (Ex-Google Recruiter)',
      category: 'Job Interview',
      description: 'Formats your background experience into crisp Situation, Task, Action, and Result bullet points designed for senior tech interviews.',
      templateStructure: 'Using the user\'s background in {USER_CONTEXT}, construct a compelling STAR response for a senior tech role focusing on {TARGET_GOAL}.',
      useCount: 1420,
      rating: 4.9,
      isFeatured: true,
    ),
    PromptTemplate(
      id: 'tmpl_2',
      title: 'IELTS Band 8.0 Fluency Synthesizer',
      creatorName: 'David Miller (IELTS Examiner)',
      category: 'IELTS/TOEFL',
      description: 'Generates speaking cue card responses rich in idiomatic collocations, advanced cohesion connectors, and C1/C2 vocabulary.',
      templateStructure: 'Transform user personal context {USER_CONTEXT} into an IELTS Speaking Part 2 response with advanced vocabulary and cohesive markers.',
      useCount: 980,
      rating: 4.8,
      isFeatured: true,
    ),
    PromptTemplate(
      id: 'tmpl_3',
      title: '3-Minute Elevator Pitching Engine',
      creatorName: 'Marcus Chen (Y Combinator Alumni)',
      category: 'Business Pitching',
      description: 'Crafts a high-impact startup elevator pitch highlighting problem, traction, unique moat, and vision tailored to venture capitalists.',
      templateStructure: 'Distill {USER_CONTEXT} into a 180-second high-energy pitch deck narration.',
      useCount: 750,
      rating: 4.7,
    ),
  ];
  List<PromptTemplate> get promptTemplates => List.unmodifiable(_promptTemplates);

  PromptTemplate? _selectedRemixTemplate;
  PromptTemplate? get selectedRemixTemplate => _selectedRemixTemplate;

  void selectTemplateToRemix(PromptTemplate template) {
    _selectedRemixTemplate = template;
    template.useCount++;
    _currentPageIndex = 1; // Navigate to AI Narrative Generator Page (index 1)
    notifyListeners();
  }

  void publishTemplate(String title, String category, String description, String structure) {
    _promptTemplates.insert(
      0,
      PromptTemplate(
        id: 'tmpl_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        creatorName: _user.name,
        category: category,
        description: description,
        templateStructure: structure,
        useCount: 1,
        rating: 5.0,
      ),
    );
    notifyListeners();
  }

  // ─── Settings & Notification Engine State ──────────────────────────────────
  final NotificationSettings _notificationSettings = NotificationSettings();
  NotificationSettings get notificationSettings => _notificationSettings;

  void toggleNotifications(bool value) {
    _notificationSettings.isEnabled = value;
    notifyListeners();
  }

  void updateNotificationFrequency(String freq) {
    _notificationSettings.frequency = freq;
    notifyListeners();
  }

  void updateNotificationHours(int start, int end) {
    _notificationSettings.startHour = start;
    _notificationSettings.endHour = end;
    notifyListeners();
  }

  void forceSyncData() {
    _notificationSettings.lastSyncTime = DateTime.now();
    notifyListeners();
  }
}
