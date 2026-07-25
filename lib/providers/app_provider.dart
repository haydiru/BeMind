import 'dart:convert';
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

  // Auth & Profile State
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  bool _isLoadingEssays = false;
  bool get isLoadingEssays => _isLoadingEssays;

  UserProfile _user = UserProfile(
    id: '',
    name: '',
    email: '',
    targetGoal: 'Job Interview Prep',
    profileCompleteness: 10,
  );
  UserProfile get user => _user;

  /// Called after successful Supabase auth — sets user profile from real data
  void loginWithProfile({
    required String id,
    required String name,
    required String email,
    String targetGoal = 'Job Interview Prep',
  }) {
    _isLoggedIn = true;
    _user = UserProfile(
      id: id,
      name: name,
      email: email,
      targetGoal: targetGoal,
      profileCompleteness: 40,
    );
    notifyListeners();
    // Load essays from Supabase
    _loadUserEssays(id);
  }

  /// Legacy method kept for compat — DO NOT use for Supabase login
  void login(String email, String password) {
    _isLoggedIn = true;
    _user = UserProfile(
      id: 'local_${email.hashCode}',
      name: email.split('@').first,
      email: email,
      targetGoal: _user.targetGoal,
      profileCompleteness: 20,
    );
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentPageIndex = 0;
    _essays.clear();
    _contextItems.clear();
    _user = UserProfile(
      id: '',
      name: '',
      email: '',
      targetGoal: 'Job Interview Prep',
      profileCompleteness: 10,
    );
    // Also sign out from Supabase client
    Supabase.instance.client.auth.signOut().catchError((_) {});
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
    // Recalculate completeness
    int newCompleteness = (40 + (_contextItems.length * 15)).clamp(40, 100);
    _user = _user.copyWith(profileCompleteness: newCompleteness);
    notifyListeners();
  }

  // ─── AI Narrative / Project State ──────────────────────────────────────────
  final List<Essay> _essays = [];
  List<Essay> get essays => List.unmodifiable(_essays);

  Essay? _activeEssay;
  Essay? get activeEssay => _activeEssay ?? (_essays.isNotEmpty ? _essays.first : null);

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

  /// Fetch this user's essays directly from Supabase generated_essays table
  Future<void> _loadUserEssays(String userId) async {
    if (userId.isEmpty || userId.startsWith('local_')) return;
    _isLoadingEssays = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('generated_essays')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

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

  void addVocabItem(VocabItem item) {
    if (!_vocabList.any((v) => v.word.toLowerCase() == item.word.toLowerCase())) {
      _vocabList.insert(0, item);
      notifyListeners();
    }
  }

  void updateVocabStatus(String id, MasteryStatus status) {
    final idx = _vocabList.indexWhere((v) => v.id == id);
    if (idx != -1) {
      _vocabList[idx].masteryStatus = status;
      notifyListeners();
    }
  }

  void deleteVocabItem(String id) {
    _vocabList.removeWhere((v) => v.id == id);
    notifyListeners();
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
    _currentPageIndex = 2; // Navigate to AI Narrative Generator Page
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
