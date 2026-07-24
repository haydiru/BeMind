import 'package:flutter/material.dart';
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
  bool _isLoggedIn = true;
  bool get isLoggedIn => _isLoggedIn;

  UserProfile _user = UserProfile(
    id: 'usr_001',
    name: 'Alex Supriyanto',
    email: 'alex.supriyanto@bemind.ai',
    targetGoal: 'Job Interview Prep',
    profileCompleteness: 85,
  );
  UserProfile get user => _user;

  void login(String email, String password) {
    _isLoggedIn = true;
    _user = UserProfile(
      id: 'usr_001',
      name: email.split('@').first,
      email: email,
      targetGoal: _user.targetGoal,
      profileCompleteness: 85,
    );
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentPageIndex = 0;
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

  // Context Vault State
  final List<ContextItem> _contextItems = [
    ContextItem(
      id: 'ctx_1',
      sourceType: SourceType.text,
      title: 'Senior Software Engineer Resume & Background',
      content: 'I have 5 years of experience building distributed systems in Fintech. My core strengths are Golang, Microservices, System Architecture, and Leading Agile Teams.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ContextItem(
      id: 'ctx_2',
      sourceType: SourceType.voice,
      title: 'Voice Note: Career Ambition & IELTS Target',
      content: 'My goal is to obtain an 8.0 band score in IELTS Speaking. I want to articulate complex engineering decisions confidently without hesitation or vocal fillers.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ContextItem(
      id: 'ctx_3',
      sourceType: SourceType.pdf,
      title: 'Tech Lead CV - 2026.pdf',
      content: 'Extracted PDF: Managed a team of 8 engineers, reduced API latency by 45%, migrated legacy monolithic architecture to Kubernetes infrastructure.',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
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
    int newCompleteness = (_contextItems.length * 25).clamp(25, 100);
    _user = _user.copyWith(profileCompleteness: newCompleteness);
    notifyListeners();
  }

  // AI Narrative Generator State
  final List<Essay> _essays = [
    Essay(
      id: 'ess_1',
      title: 'STAR Method: Overcoming Architectural Bottlenecks',
      category: 'Job Interview',
      subTopic: 'Technical Challenge & Leadership',
      difficulty: 'C1 (Advanced)',
      tone: 'Formal & Professional',
      content: '''In my previous role as a Senior Software Engineer, our microservices architecture experienced severe latency issues during peak financial traffic hours. 

To address this challenge, I spearheaded a comprehensive system audit. I identified that our primary database connection pool was saturated due to unindexed queries and redundant network calls. 

I restructured our query execution pipeline and implemented a high-performance Redis caching layer. As a result, we reduced overall API response latency by 45% and improved our system throughput significantly. 

This experience reinforced my belief that proactive performance monitoring and decoupled architecture design are essential for building reliable, scalable software solutions.''',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Essay(
      id: 'ess_2',
      title: 'IELTS Speaking Part 2: Describing a Technological Innovation',
      category: 'IELTS/TOEFL',
      subTopic: 'Part 2 Cue Card',
      difficulty: 'B2 (Upper Intermediate)',
      tone: 'Conversational',
      content: '''I would like to talk about cloud-native infrastructure, which has fundamentally transformed how modern applications are deployed and maintained worldwide. 

Before cloud migration became widespread, companies had to purchase and manage physical servers, which was both prohibitively expensive and time-consuming. Today, cloud platforms allow software teams to scale resources dynamically within seconds. 

In my own work, leveraging cloud technologies has enabled us to deploy code faster, reduce operational overhead, and maintain continuous service availability for millions of active users.''',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
  List<Essay> get essays => List.unmodifiable(_essays);

  Essay? _activeEssay;
  Essay get activeEssay => _activeEssay ?? _essays.first;

  void selectEssayForTeleprompter(Essay essay) {
    _activeEssay = essay;
    _currentPageIndex = 3; // Navigate to Teleprompter Page
    notifyListeners();
  }

  void addGeneratedEssay(Essay essay) {
    _essays.insert(0, essay);
    _activeEssay = essay;
    notifyListeners();
  }

  // Vocabulary Vault State
  final List<VocabItem> _vocabList = [
    VocabItem(
      id: 'v_1',
      word: 'Spearhead',
      phonetic: '/ˈspɪər.hed/',
      definition: 'To lead an attack or a course of action; initiate and direct.',
      contextSentence: 'I spearheaded a comprehensive system audit to resolve latency.',
      indonesianMeaning: 'Memimpin / Mendorong akselerasi',
      masteryStatus: MasteryStatus.learning,
      addedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    VocabItem(
      id: 'v_2',
      word: 'Prohibitively',
      phonetic: '/prəˈhɪb.ə.tɪv.li/',
      definition: 'In a way that is so expensive or difficult that it prevents something.',
      contextSentence: 'Managing physical servers was prohibitively expensive.',
      indonesianMeaning: 'Sangat mahal / Menghalangi',
      masteryStatus: MasteryStatus.review,
      addedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    VocabItem(
      id: 'v_3',
      word: 'Saturated',
      phonetic: '/ˈsætʃ.ər.eɪ.tɪd/',
      definition: 'Holding as much moisture or content as can be absorbed; completely full.',
      contextSentence: 'The database connection pool was saturated during peak hours.',
      indonesianMeaning: 'Jenuh / Sangat penuh',
      masteryStatus: MasteryStatus.mastered,
      addedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    VocabItem(
      id: 'v_4',
      word: 'Throughput',
      phonetic: '/ˈθruː.pʊt/',
      definition: 'The amount of material or items passing through a system or process.',
      contextSentence: 'We improved overall system throughput significantly.',
      indonesianMeaning: 'Kapasitas pemrosesan data',
      masteryStatus: MasteryStatus.learning,
      addedAt: DateTime.now(),
    ),
  ];
  List<VocabItem> get vocabList => List.unmodifiable(_vocabList);

  void addVocabItem(VocabItem item) {
    // Check if duplicate
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

  // Marketplace Prompts State
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

  // Settings & Notification Engine State
  NotificationSettings _notificationSettings = NotificationSettings();
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
