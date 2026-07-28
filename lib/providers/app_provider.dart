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

  void logout() async {
    if (!_isLoggedIn) return; // Prevents recursive auth state change loop
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
    notifyListeners();
    try {
      if (Supabase.instance.client.auth.currentUser != null) {
        await Supabase.instance.client.auth.signOut();
      }
    } catch (e) {
      debugPrint('[AppProvider] SignOut exception: $e');
    }
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
  final List<Essay> _essays = [
    Essay(
      id: 'demo_1',
      title: 'Senior AI Engineer Tech Interview Narration',
      category: 'Job Interview',
      subTopic: 'System Architecture & Microservices',
      difficulty: 'Advanced (C1)',
      tone: 'Professional & Confident',
      content: 'Good morning. Over the past five years as a Senior Software Engineer, I have specialized in building high-throughput distributed microservices. In my most recent role, I led the architectural redesign of our core payment gateway, reducing P99 latency by 42% while scaling to handle over two million daily transactions.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Essay(
      id: 'demo_2',
      title: 'IELTS Speaking Part 2 — Memorable Journey',
      category: 'IELTS/TOEFL',
      subTopic: 'Travel & Cultural Adaptation',
      difficulty: 'Upper-Intermediate (B2)',
      tone: 'Conversational',
      content: 'I would like to talk about an unforgettable trip I took to Kyoto two years ago. What struck me most was the seamless juxtaposition of ancient Buddhist temples right beside cutting-edge technological infrastructure.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
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
      _essays[idx] = Essay(
        id: _essays[idx].id,
        title: newTitle,
        category: newCategory.isNotEmpty ? newCategory : _essays[idx].category,
        subTopic: _essays[idx].subTopic,
        difficulty: _essays[idx].difficulty,
        tone: _essays[idx].tone,
        content: newContent,
        createdAt: _essays[idx].createdAt,
      );
      notifyListeners();

      try {
        if (RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(id)) {
          await Supabase.instance.client.from('generated_essays').update({
            'title': newTitle,
            'content': newContent,
            'category': newCategory,
          }).eq('id', id);
        } else if (_user.id.isNotEmpty) {
          await Supabase.instance.client.from('generated_essays').update({
            'title': newTitle,
            'content': newContent,
            'category': newCategory,
          }).eq('user_id', _user.id).eq('title', _essays[idx].title);
        }
      } catch (e) {
        debugPrint('[AppProvider] Error updating essay in Supabase: $e');
      }
    }
  }

  /// Delete an essay narrative
  Future<void> deleteEssayNarrative(String id) async {
    final targetEssay = _essays.firstWhere((e) => e.id == id, orElse: () => Essay(id: '', title: '', category: '', subTopic: '', difficulty: '', tone: '', content: '', createdAt: DateTime.now()));
    _essays.removeWhere((e) => e.id == id);
    if (_activeEssay?.id == id) {
      _activeEssay = _essays.isNotEmpty ? _essays.first : null;
    }
    notifyListeners();

    try {
      if (RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(id)) {
        await Supabase.instance.client.from('generated_essays').delete().eq('id', id);
      } else if (_user.id.isNotEmpty && targetEssay.title.isNotEmpty) {
        await Supabase.instance.client.from('generated_essays').delete().eq('user_id', _user.id).eq('title', targetEssay.title);
      }
    } catch (e) {
      debugPrint('[AppProvider] Error deleting essay in Supabase: $e');
    }
  }

  /// Update Project Category name across all belonging essays
  Future<void> updateProjectCategoryName(String oldCategory, String newCategory) async {
    if (oldCategory == newCategory || newCategory.trim().isEmpty) return;
    for (int i = 0; i < _essays.length; i++) {
      if (_essays[i].category == oldCategory) {
        _essays[i] = Essay(
          id: _essays[i].id,
          title: _essays[i].title,
          category: newCategory.trim(),
          subTopic: _essays[i].subTopic,
          difficulty: _essays[i].difficulty,
          tone: _essays[i].tone,
          content: _essays[i].content,
          createdAt: _essays[i].createdAt,
        );
      }
    }
    notifyListeners();

    try {
      await Supabase.instance.client.from('generated_essays').update({
        'category': newCategory.trim(),
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
          .timeout(const Duration(seconds: 8));

      if (response.isNotEmpty) {
        final fetched = <Essay>[];
        for (final row in response) {
          fetched.add(Essay(
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
        // Merge Supabase essays efficiently without losing unsaved local items
        for (var item in fetched) {
          if (!_essays.any((e) => e.id == item.id || (e.title == item.title && e.category == item.category))) {
            _essays.insert(0, item);
          }
        }
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
  final List<VocabItem> _vocabList = [
    VocabItem(
      id: 'v1',
      word: 'Articulation',
      phonetic: '/ɑːrˌtɪk.jəˈleɪ.ʃən/',
      definition: 'The clear and precise pronunciation of words and sounds.',
      contextSentence: 'Clear articulation is crucial during high-stakes job interviews.',
      indonesianMeaning: 'Pelafalan / pengucapan kata yang jelas dan presisi.',
      masteryStatus: MasteryStatus.mastered,
      addedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    VocabItem(
      id: 'v2',
      word: 'Eloquent',
      phonetic: '/ˈel.ə.kwənt/',
      definition: 'Fluent or persuasive in speaking or writing.',
      contextSentence: 'She gave an eloquent presentation to the board of directors.',
      indonesianMeaning: 'Fasih, anggun, dan meyakinkan dalam berbicara.',
      masteryStatus: MasteryStatus.learning,
      addedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    VocabItem(
      id: 'v3',
      word: 'Cohesion',
      phonetic: '/koʊˈhiː.ʒən/',
      definition: 'The action or fact of forming a united whole in speech structure.',
      contextSentence: 'Using transitional discourse markers improves essay cohesion.',
      indonesianMeaning: 'Keterpaduan dan kesinambungan alur kalimat.',
      masteryStatus: MasteryStatus.review,
      addedAt: DateTime.now(),
    ),
  ];
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
          .timeout(const Duration(seconds: 8));

      if (response.isNotEmpty) {
        final fetched = <VocabItem>[];
        for (final row in response) {
          MasteryStatus status = MasteryStatus.learning;
          if (row['mastery_status'] == 'mastered') status = MasteryStatus.mastered;
          if (row['mastery_status'] == 'review') status = MasteryStatus.review;

          fetched.add(VocabItem(
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

        for (var item in fetched) {
          if (!_vocabList.any((v) => v.id == item.id || v.word.toLowerCase() == item.word.toLowerCase())) {
            _vocabList.insert(0, item);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[AppProvider] Error loading user vocabularies from Supabase: $e');
    }
  }

  /// Called externally to refresh vocabularies from database
  Future<void> refreshVocabularies() => _loadUserVocabularies(_user.id);

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

  void clearSelectedRemixTemplate() {
    _selectedRemixTemplate = null;
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
