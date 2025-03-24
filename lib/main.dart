// ignore_for_file: constant_identifier_names
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MathGameApp());
}

// Enum for Game Difficulty Levels
enum GameDifficulty { easy, medium, hard, veryDifficult, mix }

// Enum for Operation Types with Extended Operations
enum OperationType { addition, subtraction, multiplication, division, squareRoot, modulo, exponentiation, logarithm }

class MathGameApp extends StatelessWidget {
  const MathGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riyazi Oyun',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const CategorySelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Category Selection Screen
class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riyazi Oyun - Kateqoriyalar'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryButton(
                context,
                'Səviyyə 1: Sadə',
                'Əsas riyazi əməllər (1-100)',
                GameDifficulty.easy,
              ),
              const SizedBox(height: 20),
              _buildCategoryButton(
                context,
                'Səviyyə 2: Orta',
                'Mürəkkəb riyazi əməllər (100-1000)',
                GameDifficulty.medium,
              ),
              const SizedBox(height: 20),
              _buildCategoryButton(
                context,
                'Səviyyə 3: Çətin',
                'Mürəkkəb hesablamalar (1000-10000)',
                GameDifficulty.hard,
              ),
              const SizedBox(height: 20),
              _buildCategoryButton(
                context,
                'Səviyyə 4: Çox Çətin',
                'Yüksək səviyyəli riyazi problemlər',
                GameDifficulty.veryDifficult,
              ),
              const SizedBox(height: 20),
              _buildCategoryButton(
                context,
                'Səviyyə 5: Qarışıq',
                'Çoxəməlli kompleks məsələlər',
                GameDifficulty.mix,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title, String subtitle, GameDifficulty difficulty) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(difficulty: difficulty),
            ),
          );
        },
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Main Game Screen
class GameScreen extends StatefulWidget {
  final GameDifficulty difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int score = 0;
  late int secondsRemaining = 60;
  Timer? timer;
  late String currentQuestion;
  late int correctAnswer;
  late List<int> answerOptions;
  bool isCorrect = false;
  bool isGameActive = true;
  int incorrectAnswersCount = 0;
  static const int MAX_INCORRECT_ANSWERS = 4;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    score = 0;
    secondsRemaining = 60;
    isGameActive = true;
    incorrectAnswersCount = 0;
    generateNewQuestion();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          endGame();
        }
      });
    });
  }

  void endGame() {
    timer?.cancel();
    setState(() => isGameActive = false);
    showResultDialog();
  }

  void generateNewQuestion() {
    Random random = Random();
    OperationType operation;
    late int num1, num2, num3;

    // Əməliyyat seçimi və rəqəmlərin diapazonu çətinliyə görə
    switch (widget.difficulty) {
      case GameDifficulty.easy:
        // Easy: n1 və n2 1-100 arası
        operation = OperationType.values[random.nextInt(4)];
        num1 = random.nextInt(100) + 1; // 1-100
        num2 = random.nextInt(100) + 1; // 1-100

        switch (operation) {
          case OperationType.addition:
            correctAnswer = num1 + num2;
            currentQuestion = '$num1 + $num2 = ?';
            break;
          case OperationType.subtraction:
            correctAnswer = num1 - num2;
            currentQuestion = '$num1 - $num2 = ?';
            break;
          case OperationType.multiplication:
            correctAnswer = num1 * num2;
            currentQuestion = '$num1 × $num2 = ?';
            break;
          case OperationType.division:
            // Bölmə əməliyyatında sıfırdan qaçınmaq üçün
            num2 = num2 == 0 ? 1 : num2;
            correctAnswer = num1 ~/ num2;
            currentQuestion = '$num1 ÷ $num2 = ?';
            break;
          default:
            correctAnswer = num1 + num2;
            currentQuestion = '$num1 + $num2 = ?';
        }
        break;

      case GameDifficulty.medium:
        // Medium: n1 və n2 100-1000 arası (1000 də daxil)
        operation = OperationType.values[random.nextInt(4)];
        num1 = random.nextInt(901) + 100; // 100-1000
        num2 = random.nextInt(901) + 100; // 100-1000

        switch (operation) {
          case OperationType.addition:
            correctAnswer = num1 + num2;
            currentQuestion = '$num1 + $num2 = ?';
            break;
          case OperationType.subtraction:
            correctAnswer = num1 - num2;
            currentQuestion = '$num1 - $num2 = ?';
            break;
          case OperationType.multiplication:
            correctAnswer = num1 * num2;
            currentQuestion = '$num1 × $num2 = ?';
            break;
          case OperationType.division:
            num2 = num2 == 0 ? 1 : num2;
            correctAnswer = num1 ~/ num2;
            currentQuestion = '$num1 ÷ $num2 = ?';
            break;
          default:
            correctAnswer = num1 + num2;
            currentQuestion = '$num1 + $num2 = ?';
        }
        break;

      case GameDifficulty.hard:
        // Hard: n1 və n2 1000-10,000 arası (10,000 də daxil)
        operation = OperationType.values[random.nextInt(4)];
        num1 = random.nextInt(9001) + 1000; // 1000-10,000
        num2 = random.nextInt(9001) + 1000; // 1000-10,000

        switch (operation) {
          case OperationType.addition:
            correctAnswer = num1 + num2;
            currentQuestion = '$num1 + $num2 = ?';
            break;
          case OperationType.subtraction:
            correctAnswer = num1 - num2;
            currentQuestion = '$num1 - $num2 = ?';
            break;
          case OperationType.multiplication:
            correctAnswer = num1 * num2;
            currentQuestion = '$num1 × $num2 = ?';
            break;
          case OperationType.division:
            num2 = num2 == 0 ? 1 : num2;
            correctAnswer = num1 ~/ num2;
            currentQuestion = '$num1 ÷ $num2 = ?';
            break;
          default:
            correctAnswer = num1 + num2;
            currentQuestion = '$num1 + $num2 = ?';
        }
        break;

      case GameDifficulty.veryDifficult:
      case GameDifficulty.mix:
        // Daha mürəkkəb rəqəm generasiyası
        num1 = random.nextInt(900) + 100; // 100-999 arası
        num2 = random.nextInt(900) + 100; // 100-999 arası

        if (widget.difficulty == GameDifficulty.mix) {
          // Çox əməliyyatlı problemlər
          operation = OperationType.values[random.nextInt(OperationType.values.length)];
          // Daha mürəkkəbliyi artırmaq üçün üçüncü rəqəm
          num3 = random.nextInt(900) + 100; // 100-999 arası

          switch (operation) {
            case OperationType.addition:
              correctAnswer = num1 + num2 + num3;
              currentQuestion = '$num1 + $num2 + $num3 = ?';
              break;
            case OperationType.multiplication:
              correctAnswer = num1 * num2 * num3;
              currentQuestion = '$num1 × $num2 × $num3 = ?';
              break;
            case OperationType.modulo:
              correctAnswer = num1 % num2;
              currentQuestion = '$num1 % $num2 = ?';
              break;
            case OperationType.exponentiation:
              // Çox böyük nəticələrin qarşısını almaq üçün
              num2 = random.nextInt(4) + 2; // 2-5 arası
              correctAnswer = pow(num1, num2).toInt();
              currentQuestion = '$num1^$num2 = ?';
              break;
            default:
              correctAnswer = num1 + num2;
              currentQuestion = '$num1 + $num2 = ?';
          }
        } else {
          // Very Difficult üçün tək əməliyyatlı problemlər
          operation = OperationType.values[random.nextInt(OperationType.values.length)];

          switch (operation) {
            case OperationType.logarithm:
              // Tam ədəd nəticəsi almaq üçün ideal güc generasiyası
              num2 = random.nextInt(3) + 2; // baza: 2-4
              num1 = pow(num2, random.nextInt(4) + 2).toInt(); // num1: num2^n, n: 2-5
              correctAnswer = (log(num1) / log(num2)).toInt();
              currentQuestion = 'log$num2($num1) = ?';
              break;
            default:
              correctAnswer = num1 + num2;
              currentQuestion = '$num1 + $num2 = ?';
          }
        }
        break;
    }

    // Cavab seçimlərini strategik şəkildə yaradılması
    answerOptions = [correctAnswer];

    while (answerOptions.length < 3) {
      print('Answer Options Length: ${answerOptions.length}');
      int wrongAnswer;

      // Doğru cavabın ±20%-lik səhv marginindən istifadə olunur
      int errorMargin = ((correctAnswer.abs()) * 0.2).ceil() + 1;
      wrongAnswer = correctAnswer + (random.nextBool() ? random.nextInt(errorMargin) : -random.nextInt(errorMargin));

      // Mənalı yanlış cavabların seçilməsi üçün əlavə yoxlamalar
      if (wrongAnswer > 0 &&
          wrongAnswer != correctAnswer &&
          !answerOptions.contains(wrongAnswer) &&
          !_hasMultipleEndingDigit(answerOptions, wrongAnswer % 10)) {
        answerOptions.add(wrongAnswer);
      }
    }

    answerOptions.shuffle();
  }

// Eyni son rəqəmli cavabların çoxluğunu önləyən funksiya
  bool _hasMultipleEndingDigit(List<int> currentOptions, int endDigit) {
    return currentOptions.where((option) => option % 10 == endDigit).length >= 2;
  }

  void checkAnswer(int selectedAnswer) {
    if (!isGameActive) return;

    isCorrect = selectedAnswer == correctAnswer;

    if (isCorrect) {
      setState(() => score++);
    } else {
      setState(() {
        incorrectAnswersCount++;

        // 4 ardıcıl səhv cavabda 1 xal çıxılır
        if (incorrectAnswersCount >= MAX_INCORRECT_ANSWERS) {
          score = max(0, score - 1);
          incorrectAnswersCount = 0;
        }
      });
    }

    showAnswerResult(isCorrect, selectedAnswer);
  }

  void showAnswerResult(bool isCorrect, int selectedAnswer) {
    // Generate new question immediately
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && isGameActive) {
        setState(() => generateNewQuestion());
      }
    });
  }

  void showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyun Bitdi!'),
          content: Text('Sizin nəticəniz: $score doğru cavab!'),
          actions: [
            TextButton(
              child: const Text('Yenidən Oyna'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
            TextButton(
              child: const Text('Ana Səhifəyə Qayıt'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const CategorySelectionScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String difficultyTitle;
    switch (widget.difficulty) {
      case GameDifficulty.easy:
        difficultyTitle = 'Səviyyə 1: Sadə';
        break;
      case GameDifficulty.medium:
        difficultyTitle = 'Səviyyə 2: Orta';
        break;
      case GameDifficulty.hard:
        difficultyTitle = 'Səviyyə 3: Çətin';
        break;
      case GameDifficulty.veryDifficult:
        difficultyTitle = 'Səviyyə 4: Çox Çətin';
        break;
      case GameDifficulty.mix:
        difficultyTitle = 'Səviyyə 5: Qarışıq';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(difficultyTitle),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoCard('Vaxt', '$secondsRemaining saniyə'),
                _buildInfoCard('Xal', score.toString()),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentQuestion,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: answerOptions.map((answer) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          textStyle: const TextStyle(fontSize: 20),
                          backgroundColor: isCorrect && answer == correctAnswer ? Colors.green : Colors.transparent,
                        ),
                        onPressed: () => checkAnswer(answer),
                        child: Text(answer.toString()),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: label == 'Vaxt' ? (secondsRemaining < 10 ? Colors.red.shade100 : Colors.green.shade100) : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: label == 'Vaxt' && secondsRemaining < 10 ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
