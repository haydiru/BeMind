import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'supabase_config.dart';

class ApiService {
  static final String baseUrl = SupabaseConfig.backendBaseUrl;

  /// High-accuracy Speech-to-Text Transcribe via Backend AI (Whisper/STT API)
  static Future<String> transcribeAudio({
    required String audioPath,
    List<int>? bytes,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ai/transcribe'));
      if (bytes != null && bytes.isNotEmpty) {
        request.files.add(http.MultipartFile.fromBytes('audio', bytes, filename: 'voice_note.m4a'));
      } else if (audioPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
      } else {
        return '';
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['transcript'] != null) {
          return data['transcript'].toString();
        }
      }
    } catch (e) {
      print('[ApiService] STT Backend error or offline fallback: $e');
    }
    return '';
  }

  /// Synthesizes personalized narrative essay via Express backend & AI Proxy
  static Future<Essay> generateEssay({
    required String userId,
    required String category,
    required String subTopic,
    required String difficulty,
    required String tone,
    required String userContext,
    String? templateId,
    String? promptTemplate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/generate-essay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'category': category,
          'subTopic': subTopic,
          'difficulty': difficulty,
          'tone': tone,
          'userContext': userContext,
          'templateId': templateId,
          'promptTemplate': promptTemplate,
        }),
      ).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['essay'] != null) {
          final essayData = data['essay'];
          return Essay(
            id: essayData['id'] ?? 'ess_${DateTime.now().millisecondsSinceEpoch}',
            title: essayData['title'] ?? 'STAR Method Narrative',
            category: essayData['category'] ?? category,
            subTopic: essayData['subTopic'] ?? subTopic,
            difficulty: essayData['difficulty'] ?? difficulty,
            tone: essayData['tone'] ?? tone,
            content: essayData['content'] ?? '',
            createdAt: DateTime.tryParse(essayData['createdAt'] ?? '') ?? DateTime.now(),
          );
        }
      }
      throw Exception('Backend API returned status ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('[ApiService] Backend call error or offline fallback: $e');
      // Fallback synthesis if offline
      return Essay(
        id: 'ess_${DateTime.now().millisecondsSinceEpoch}',
        title: 'STAR Method: $category',
        category: category,
        subTopic: subTopic,
        difficulty: difficulty,
        tone: tone,
        content: '''In my software engineering career, I spearheaded the architectural redesign of our financial transactions API. Initially, our microservices experienced severe latency bottlenecks. I instituted a comprehensive audit, implemented a high-performance Redis caching layer, and reduced endpoint response latency by 45%. This initiative boosted transaction throughput while maintaining zero downtime during peak user traffic.''',
        createdAt: DateTime.now(),
      );
    }
  }

  /// Admin: Fetch active AI model
  static Future<Map<String, dynamic>> fetchAdminModelInfo() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/model'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('[ApiService] Fetch admin model error: $e');
    }
    return {'activeModel': 'Qwen3.6-35B-A3B', 'availableModels': ['Qwen3.6-35B-A3B', 'gpt-4o', 'gemini-1.5-flash']};
  }

  /// Admin: Change active AI model on the fly
  static Future<bool> updateAdminActiveModel(String modelName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/model'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'model': modelName}),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('[ApiService] Update admin model error: $e');
    }
    return false;
  }
}
