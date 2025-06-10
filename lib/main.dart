// lib/main.dart
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zifromania/app.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/domain/entities/global.dart';
import 'package:zifromania/domain/entities/math_question.dart';
import 'package:zifromania/firebase_options.dart';
import 'package:zifromania/presentation/providers/bloc_providers.dart';
import 'package:zifromania/presentation/providers/repository_providers.dart';
import 'package:zifromania/services/services_init.dart';
import 'package:path/path.dart' as path;

import 'services/sound_service.dart';

import 'dart:convert';
import 'dart:io';

// Tekrarlanan sualları tap
Map<String, dynamic> findDuplicates(List<dynamic> questions) {
  Map<String, List<Map<String, dynamic>>> questionMap = {};

  // Bütün sualları map-ə əlavə et
  for (int i = 0; i < questions.length; i++) {
    String question = questions[i]['question'].toString().trim();

    if (questionMap.containsKey(question)) {
      questionMap[question]!.add({'index': i, 'data': questions[i]});
    } else {
      questionMap[question] = [
        {'index': i, 'data': questions[i]}
      ];
    }
  }

  // Yalnız tekrarlananları qaytər
  Map<String, dynamic> duplicates = {};
  for (var entry in questionMap.entries) {
    if (entry.value.length > 1) {
      duplicates[entry.key] = entry.value;
    }
  }

  return duplicates;
}

// Tekrarlananları konsola çıxar
void printDuplicates(Map<String, dynamic> duplicates) {
  if (duplicates.isEmpty) {
    print('\n🎉 Heç bir tekrarlanan sual tapılmadı!');
    return;
  }

  print('\n=== TEKRARLANAN SUALLAR ===');
  print('Tekrarlanan sual növü sayı: ${duplicates.length}');
  print('');

  int duplicateNumber = 1;
  for (var entry in duplicates.entries) {
    print('$duplicateNumber. Tekrarlanan sual:');
    print('   "${entry.key}"');
    print('   İndekslər: ${entry.value.map((item) => item['index']).toList()}');
    print('   Təkrar sayı: ${entry.value.length}');

    // Cavab variantlarını da göstər
    print('   Cavab variantları:');
    for (var item in entry.value) {
      var options = item['data']['options'];
      var correct = item['data']['correct_option'];
      print('     İndeks ${item['index']}: A:${options['A']}, B:${options['B']}, C:${options['C']}, D:${options['D']} (Doğru: $correct)');
    }
    print('   ---');
    duplicateNumber++;
  }
}

// Tekrarlananları sil (ilk nüsxəni saxla)
List<dynamic> removeDuplicates(List<dynamic> questions) {
  Map<String, dynamic> uniqueMap = {};
  List<String> processedQuestions = [];

  for (var question in questions) {
    String questionText = question['question'].toString().trim();

    // Əgər bu sual əvvəllər əlavə edilməyibsə, əlavə et
    if (!uniqueMap.containsKey(questionText)) {
      uniqueMap[questionText] = question;
    } else {
      processedQuestions.add(questionText);
    }
  }

  return uniqueMap.values.toList();
}

// Daha dəqiq müqayisə üçün
String normalizeQuestion(String question) {
  return question.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'[^\w\s]'), '');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load();
  await initializeServices();

  // await generateAndSaveQuickThinkingQuestions(batchCount: 10);

  try {
    // Flutter asset-dən JSON faylını oxu
    final jsonString = await rootBundle.loadString('assets/questions/quick_thinking.json');
    final data = jsonDecode(jsonString);

    List<dynamic> questions = data['questions'];

    print('Toplam sual sayı: ${questions.length}');

    // Tekrarlananları tap və logla
    final duplicateInfo = findDuplicates(questions);

    // Konsola çıxar
    printDuplicates(duplicateInfo);

    // Tekrarlananları sil
    // final uniqueQuestions = removeDuplicates(questions);

    print('\n=== NƏTİCƏ ===');
    print('Toplam sual sayı: ${questions.length}');
    // print('Təmiz sual sayı: ${uniqueQuestions.length}');
    // print('Silinən sual sayı: ${questions.length - uniqueQuestions.length}');

  } catch (e) {
    print('Xəta baş verdi: $e');
    print('\nYoxlayın:');
    print('1. pubspec.yaml-da assets qovluğu əlavə edilib?');
    print('2. Fayl yolu düzgündür: assets/questions/quick_thinking.json');
    print('3. Fayl mövcuddur və adı doğrudur?');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiRepositoryProvider(
        providers: repositoryProviders,
        child: MultiBlocProvider(
          providers: blocProviders,
          child: ZifroMania(soundService: locator.get<SoundService>()),
        ),
      ),
    ),
  );
}

Future<List<MathQuestion>> _generateFromAPI(
  GameCategory gameCategory,
  int questionCount, {
  required String aiModel,
}) async {
  try {
    final prompt = _getSystemPrompt(questionCount);

    final response = await Dio().post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer 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',
        },
      ),
      data: {
        "model": aiModel,
        // "response_format": {"type": "json_object"},
        "messages": [
          {"role": "system", "content": prompt},
          {
            "role": "user",
            "content":
                "Generate $questionCount mathematically accurate questions for the `quick_thinking` category. Ensure proper answer distribution and double-check all calculations."
          }
        ]
      },
    );

    final rawContent = response.data['choices'][0]['message']['content'];
    final cleanContent = rawContent.trim();
    final decoded = json.decode(cleanContent);

    List<dynamic> questionList;

    if (decoded is Map<String, dynamic> && decoded.containsKey('questions')) {
      questionList = decoded['questions'];
    } else if (decoded is List) {
      questionList = decoded;
    } else {
      throw const FormatException("Unexpected JSON format from OpenAI");
    }

    return questionList.map<MathQuestion>((q) => MathQuestion.fromJson(q)).toList();
  } catch (e) {
    if (e is DioException && CancelToken.isCancel(e)) {
      throw Exception('Request was cancelled');
    }
    log.e('Error in _generateFromAPI: $e');
    rethrow;
  }
}

// Yeni funksiya - sualları JSON faylına yazmaq üçün
Future<void> saveQuestionsToFile(
  List<MathQuestion> questions,
  GameCategory category,
) async {
  try {
    // Project root directory-ni tapın
    final projectRoot = Directory.current;
    final assetsDir = Directory(path.join(projectRoot.path, 'assets', 'questions'));

    // assets/questions direktoriyasını yaradın (əgər yoxdursa)
    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }

    final filePath = path.join(assetsDir.path, 'quick_thinking.json');
    final file = File(filePath);

    // Mövcud sualları oxuyun (əgər fayl varsa)
    List<Map<String, dynamic>> existingQuestions = [];
    if (await file.exists()) {
      final existingContent = await file.readAsString();
      final existingData = json.decode(existingContent);

      if (existingData is Map<String, dynamic> && existingData.containsKey('questions')) {
        existingQuestions = List<Map<String, dynamic>>.from(existingData['questions']);
      }
    }

    // Yeni sualları əlavə edin
    final newQuestions = questions
        .map((question) => {
              'question': question.question,
              'options': question.answerOptions,
              'correct_option': question.correctAnswer,
              'created_at': DateTime.now().toIso8601String(),
            })
        .toList();

    existingQuestions.addAll(newQuestions);

    // JSON strukturunu hazırlayın
    final jsonData = {
      'category': category.name,
      'total_questions': existingQuestions.length,
      'last_updated': DateTime.now().toIso8601String(),
      'questions': existingQuestions,
    };

    // Faylı yazın (pretty formatting ilə)
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJsonString = encoder.convert(jsonData);

    await file.writeAsString(prettyJsonString);

    log.i("Saved ${questions.length} questions to file: $filePath");
    log.i("Total questions in file: ${existingQuestions.length}");
  } catch (e) {
    log.e("Error saving questions to file: $e");
    rethrow;
  }
}

// Yenilənmiş əsas funksiya
Future<void> generateAndSaveQuickThinkingQuestions({
  required int batchCount,
  int questionPerBatch = 100,
  String aiModel = "o3-mini",
}) async {
  List<MathQuestion> allQuestions = [];

  // Bütün batch-ları toplayın
  for (int i = 0; i < batchCount; i++) {
    try {
      final List<MathQuestion> questions = await _generateFromAPI(
        GameCategory.quickThinking,
        questionPerBatch,
        aiModel: aiModel,
      );

      allQuestions.addAll(questions);
      log.i("Batch ${i + 1}/$batchCount generated successfully (${questions.length} questions)");
    } catch (e) {
      log.e("Batch ${i + 1} failed: $e");
    }
  }

  // Bütün sualları faylə yazın
  if (allQuestions.isNotEmpty) {
    await saveQuestionsToFile(allQuestions, GameCategory.quickThinking);
    log.i("All ${allQuestions.length} questions saved to file successfully!");
  }
}

// Sualları fayldan oxumaq üçün yardımçı funksiya
Future<List<MathQuestion>> loadQuestionsFromFile() async {
  try {
    final projectRoot = Directory.current;
    final filePath = path.join(projectRoot.path, 'assets', 'questions', 'quick_thinking.json');
    final file = File(filePath);

    if (!await file.exists()) {
      log.w("Questions file not found: $filePath");
      return [];
    }

    final content = await file.readAsString();
    final data = json.decode(content);

    if (data is Map<String, dynamic> && data.containsKey('questions')) {
      final questionList = List<Map<String, dynamic>>.from(data['questions']);
      return questionList.map<MathQuestion>((q) => MathQuestion.fromJson(q)).toList();
    }

    return [];
  } catch (e) {
    log.e("Error loading questions from file: $e");
    return [];
  }
}

String _getSystemPrompt(int questionCount) {
  return """You are a system that creates simple but mathematically correct questions for the "quick_thinking" category. Your task is to generate exactly $questionCount math questions and return them in a strict JSON array format.

**QUESTION RULES:**
Include a balanced mix of the following types of questions:
1. Addition and subtraction between numbers from 1 to 100. Example: `57 - 19 = ?`
2. Power expressions where the result does not exceed 100. Example: `3^4 = ?` or `2^6 = ?`
3. Multiplication and division between numbers from 1 to 10. For division, ensure the dividend is at most 100. Example: `81 ÷ 9 = ?`
4. Three-step mixed expressions using numbers from 1 to 50. Use only `+`, `-`, `×`, `÷`. Example: `5 + 7 - 2 = ?` or `10 × 2 - 5 = ?`

**IMPORTANT RULES FOR ANSWER OPTIONS:**
- Each question must have exactly 4 answer options: A, B, C, D.
- The **correct answer must be placed in a different option each time** (randomized and evenly distributed).
- For example, if you're generating 40 questions, approximately 10 questions should have the correct answer in A, 10 in B, 10 in C, and 10 in D.
- The positions must be **randomized** so the correct answers are not always in order (e.g., A, B, C, D...). Use a **shuffled, non-repeating pattern**.

**ADDITIONAL GUIDELINES:**
- Do not repeat any question.
- Ensure the correct answers are calculated with 100% mathematical accuracy.
- Wrong options should be plausible but clearly incorrect.
- Avoid repeating the same correct answer value multiple times.

**FINAL OUTPUT FORMAT (STRICT):**
Return a **JSON object** with a single key `"questions"` that maps to the array of question objects. 

Example:
{
  "questions": [
    {
      "question": "6 × 2 = ?",
      "options": {
        "A": "15",
        "B": "10", 
        "C": "14",
        "D": "12"
      },
      "correct_option": "D"
    },
    {
      "question": "3^4 = ?",
      "options": {
        "A": "64",
        "B": "81",
        "C": "27",
        "D": "36"
      },
      "correct_option": "B"
    }
    ...
  ]
}

Do NOT return a plain array. Wrap the array inside a "questions" key.
Generate exactly $questionCount questions following all rules and output only the JSON array.
""";
}

// Future<void> uploadTitles() async {
//   final firestore = FirebaseFirestore.instance;
//   final titlesCollection = firestore.collection('titles');
//   const image =
//       'https://img-cdn.inc.com/image/upload/f_webp,c_fit,w_1920,q_auto/images/panoramic/shutterstock_781606792_360874.jpg';

//   final List<Map<String, dynamic>> titles = [
//     {
//       "name": "Speedster",
//       "description": "60 saniyədə 50+ doğru cavab ver.",
//       "iconUrl": image,
//       "requirements": {"category": "speedCalculation", "score": 50}
//     },
//     {
//       "name": "Multiplier Master",
//       "description": "Multiplication Table kategorisində 50+ düzgün cavab ver.",
//       "iconUrl": image,
//       "requirements": {"category": "multiplyDivideBattle", "score": 50}
//     },
//     {
//       "name": "Truth Seeker",
//       "description": "True or False modunda 45 və ya daha çox düzgün cavab ver.",
//       "iconUrl": image,
//       "requirements": {"category": "trueFalse", "score": 45}
//     },
//     {
//       "name": "Expert Challenger",
//       "description": "Expert mode-da 60 və ya daha çox düzgün cavab ver.",
//       "iconUrl": image,
//       "requirements": {"category": "expert", "score": 60}
//     },
//     {
//       "name": "XP Seeker",
//       "description": "25-ci səviyyəyə çat.",
//       "iconUrl": image,
//       "requirements": {"level": 25}
//     },
//     {
//       "name": "Legendary",
//       "description": "Ən yüksək səviyyə olan 50-ə çat!",
//       "iconUrl": image,
//       "requirements": {"levelExact": 50}
//     },
//     {
//       "name": "Quick Thinker",
//       "description": "Ortalama 2 saniyədən az vaxtla 30+ düzgün cavab ver.",
//       "iconUrl": image,
//       "requirements": {"averageTimePerQuestion": 2, "score": 30}
//     },
//     {
//       "name": "No Mistake",
//       "description": "30 sualı ardıcıl və səhvsiz cavabla.",
//       "iconUrl": image,
//       "requirements": {"score": 30, "incorrectAnswers": 0}
//     },
//     {
//       "name": "Zifro Premium",
//       "description": "Premium istifadəçisən!",
//       "iconUrl": image,
//       "requirements": {"isPremium": true}
//     },
//     {
//       "name": "Persistent Player",
//       "description": "7 gün ardıcıl oyun oyna.",
//       "iconUrl": image,
//       "requirements": {"dailyStreak": 7}
//     },
//     {
//       "name": "Marathon Mind",
//       "description": "Endless modda 100+ suala cavab ver.",
//       "iconUrl": image,
//       "requirements": {"category": "endless", "questionsAnswered": 100}
//     }
//   ];

//   for (final title in titles) {
//     final doc = await titlesCollection.add(title);
//     print('Added title: ${title["name"]} with ID: ${doc.id}');
//   }
// }

// Future<void> createUserProfile() async {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   const String usersCollection = 'users';
//   try {
//     // First check if the user already exists
//     final docRef = firestore.collection(usersCollection).doc('JDEHpUuNlwuzDoMWBEYD');

//     await docRef.set({
//       'displayName': '꧁༒☬𝓘 𝓛𝓸𝓿𝓮 𝓨𝓸𝓾☬༒꧂',
//       'email': 'iloveyou@gmail.com',
//       'photoURL': null,
//       'coins': 1123,
//       'level': 37,
//       'xp': 11232,
//       'xpForNextLevel': 22345,
//       'hasActiveSubscription': false,
//       'subscription': {
//         'active': false,
//         'autoRenew': false,
//         'tier': 'none',
//         'platform': null,
//         'expiry': null,
//         'purchaseDate': null,
//       },
//       'achievements': const <String>[],
//       'uid': 'JDEHpUuNlwuzDoMWBEYD'
//     });
//   } catch (e) {
//     print('Error creating/updating user profile: $e');
//     throw Exception('Failed to create or update user profile: $e');
//   }
// }
