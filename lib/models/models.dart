class UserProfile {
  final String id;
  final String name;
  final String email;
  final String targetGoal;
  final int profileCompleteness;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.targetGoal,
    required this.profileCompleteness,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? targetGoal,
    int? profileCompleteness,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      targetGoal: targetGoal ?? this.targetGoal,
      profileCompleteness: profileCompleteness ?? this.profileCompleteness,
    );
  }
}

enum SourceType { text, voice, pdf, ocr }

class ContextItem {
  final String id;
  final SourceType sourceType;
  final String title;
  final String content;
  final DateTime timestamp;

  ContextItem({
    required this.id,
    required this.sourceType,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  int get wordCount => content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}

/// Project Group Model (Container containing multiple Essay narratives)
class ProjectGroup {
  final String id; // Category e.g., 'Job Interview'
  final String title; // Category Name
  final List<Essay> essays;

  ProjectGroup({
    required this.id,
    required this.title,
    required this.essays,
  });
}

class Essay {
  final String id;
  final String title;
  final String category;
  final String subTopic;
  final String difficulty; // A2, B1, B2, C1, C2
  final String tone; // Formal, Conversational, Academic
  final String content;
  final DateTime createdAt;

  Essay({
    required this.id,
    required this.title,
    required this.category,
    required this.subTopic,
    required this.difficulty,
    required this.tone,
    required this.content,
    required this.createdAt,
  });
}

enum MasteryStatus { learning, mastered, review }

class VocabItem {
  final String id;
  final String word;
  final String phonetic;
  final String definition;
  final String contextSentence;
  final String indonesianMeaning;
  MasteryStatus masteryStatus;
  final DateTime addedAt;

  VocabItem({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.contextSentence,
    required this.indonesianMeaning,
    this.masteryStatus = MasteryStatus.learning,
    required this.addedAt,
  });
}

class PromptTemplate {
  final String id;
  final String title;
  final String creatorName;
  final String category;
  final String description;
  final String templateStructure;
  int useCount;
  final double rating;
  final bool isFeatured;

  PromptTemplate({
    required this.id,
    required this.title,
    required this.creatorName,
    required this.category,
    required this.description,
    required this.templateStructure,
    required this.useCount,
    required this.rating,
    this.isFeatured = false,
  });
}

class NotificationSettings {
  bool isEnabled;
  String frequency;
  int startHour;
  int endHour;
  DateTime? lastSyncTime;

  NotificationSettings({
    this.isEnabled = true,
    this.frequency = '5x a day',
    this.startHour = 8,
    this.endHour = 21,
    this.lastSyncTime,
  });
}
