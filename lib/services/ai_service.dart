import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI 人生助手服务
/// 提供智能对话、内容整理、成长总结等功能
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // AI API 配置
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  String _apiKey = '';

  /// 设置 API Key
  void setApiKey(String key) {
    _apiKey = key;
  }

  /// 与 AI 对话
  Future<String> askAI(String message, {List<Map<String, String>>? context}) async {
    if (_apiKey.isEmpty) {
      return '请先配置 AI API Key';
    }

    try {
      final messages = <Map<String, String>>[
        {
          'role': 'system',
          'content': '''你是"人生管家"，一个专业的个人生活管理AI助手。
你的职责包括：
- 帮助用户整理人生记录（家人册、学习册、生活册、工作册、人生三鉴）
- 生成成长总结和个人传记
- 整理导游资料和旅行攻略
- 生成自媒体文案和短视频脚本
- 整理读书笔记和知识库
- 提供人生感悟和思考引导

请用温暖、专业的语气回复用户，像一个智慧的老朋友。''',
        },
      ];

      if (context != null) {
        messages.addAll(context);
      }

      messages.add({'role': 'user', 'content': message});

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': messages,
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return 'AI 服务暂时不可用，请稍后重试';
      }
    } catch (e) {
      return 'AI 请求出错：$e';
    }
  }

  /// 自动整理日记
  Future<String> organizeDiary(String rawContent) async {
    return askAI(
      '请帮我整理以下日记内容，使其更有条理和文学性：\n\n$rawContent',
    );
  }

  /// 生成成长总结
  Future<String> generateGrowthSummary(
    String period,
    List<String> records,
  ) async {
    return askAI(
      '请根据以下${period}的记录，生成一份成长总结：\n\n${records.join('\n---\n')}',
    );
  }

  /// 整理导游资料
  Future<String> organizeTourGuideInfo(String rawInfo) async {
    return askAI(
      '请帮我整理以下导游资料，包括线路规划、景点介绍和注意事项：\n\n$rawInfo',
    );
  }

  /// 生成短视频脚本
  Future<String> generateVideoScript(String topic, String platform) async {
    return askAI(
      '请为$platform平台生成一个关于"$topic"的短视频脚本，包含开场、正文、结尾和推荐标签',
    );
  }

  /// 生成自媒体文案
  Future<String> generateSocialMediaContent(
    String topic,
    String platform,
    String style,
  ) async {
    return askAI(
      '请为$platform平台生成一篇关于"$topic"的内容，风格：$style',
    );
  }

  /// 整理读书笔记
  Future<String> organizeBookNotes(String bookName, String rawNotes) async {
    return askAI(
      '请帮我整理《$bookName》的读书笔记，提取核心观点、金句和个人感悟：\n\n$rawNotes',
    );
  }

  /// 人生三鉴引导
  Future<String> guideReflection(String view, String userThought) async {
    String prompt;
    switch (view) {
      case '见天地':
        prompt = '用户分享了关于自然和世界的感悟，请给予深度回应和引导：';
        break;
      case '见众生':
        prompt = '用户分享了对他人的理解和共情，请给予温暖回应和思考引导：';
        break;
      case '见自己':
        prompt = '用户正在进行自我反思，请给予专业的人生指导：';
        break;
      default:
        prompt = '请回应用户的思考：';
    }
    return askAI('$prompt\n\n$userThought');
  }
}
