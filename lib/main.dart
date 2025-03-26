import 'dart:async';
import 'dart:math';
// import 'package:flame/components.dart' hide Timer;
// import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const MathGameApp());
}

class MathGameApp extends StatelessWidget {
  const MathGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Master',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Montserrat',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameIntroScreen(),
    );
  }
}

class GameIntroScreen extends StatefulWidget {
  const GameIntroScreen({super.key});

  @override
  State<GameIntroScreen> createState() => _GameIntroScreenState();
}

class _GameIntroScreenState extends State<GameIntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade300, Colors.purple.shade300],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Math Master',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              DifficultyButton(title: 'Easy Mode', color: Colors.green.shade400, difficulty: GameDifficulty.easy),
              const SizedBox(height: 20),
              DifficultyButton(title: 'Medium Mode', color: Colors.orange.shade400, difficulty: GameDifficulty.medium),
              const SizedBox(height: 20),
              DifficultyButton(title: 'Hard Mode', color: Colors.red.shade400, difficulty: GameDifficulty.hard),
              const SizedBox(height: 20),
              DifficultyButton(title: 'Master Mode', color: Colors.deepPurple.shade400, difficulty: GameDifficulty.veryDifficult),
              const SizedBox(height: 20),
              DifficultyButton(
                  title: 'Times&Divide Table', color: Colors.deepPurple.shade400, difficulty: GameDifficulty.timesDivideTable),
            ],
          ),
        ),
      ),
    );
  }
}

class DifficultyButton extends StatefulWidget {
  final String title;
  final Color color;
  final GameDifficulty difficulty;

  const DifficultyButton({
    super.key,
    required this.title,
    required this.color,
    required this.difficulty,
  });

  @override
  State<DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<DifficultyButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Color _buttonColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.8, // Kiçilmə dərəcəsi
      upperBound: 1.0, // Normal ölçü
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _buttonColor = widget.color; // Əsas rəng
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _animationController.reverse(); // Basanda kiçilir
        setState(() {
          _buttonColor = widget.color.withValues(alpha: 0.7); // Tündləşdirilmiş rəng
        });
      },
      onTapUp: (_) {
        _animationController.forward(); // Buraxanda böyüyür
        setState(() {
          _buttonColor = widget.color; // Normal rəngə qayıdır
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return GameScreen(difficulty: widget.difficulty);
            },
          ),
        );
      },
      onTapCancel: () {
        _animationController.animateTo(1.0); // Əgər toxunub çıxarsa, normal ölçüyə qayıdır
        setState(() {
          _buttonColor = widget.color; // Normal rəngə qayıdır
        });
      },
      child: ScaleTransition(
        scale: _animation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Ink(
            color: Colors.black,
            child: ColoredBox(
              color: _buttonColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Enum for Game Difficulty Levels
enum GameDifficulty { easy, medium, hard, veryDifficult, mix, timesDivideTable }

// Enum for Operation Types with Extended Operations
enum OperationType { addition, subtraction, multiplication, division, squareRoot, modulo, exponentiation, logarithm }

class GameScreen extends StatefulWidget {
  final GameDifficulty difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late int score = 0;
  late int secondsRemaining = 60;
  Timer? timer;
  late String currentQuestion;
  late int correctAnswer;
  late List<int> answerOptions;
  bool isGameActive = true;
  int incorrectAnswersCount = 0;
  static const int MAX_INCORRECT_ANSWERS = 4;

  int? _lastSelectedAnswer;

  // Sound and animation controllers
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
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
      case GameDifficulty.timesDivideTable:
        operation = [OperationType.division, OperationType.multiplication][random.nextInt(2)];
        num1 = random.nextInt(10) + 1; // 1-100
        num2 = random.nextInt(10) + 1; // 1-100
        switch (operation) {
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
        }
    }

    // Cavab seçimlərini strategik şəkildə yaradılması
    answerOptions = [correctAnswer];

    int maxAttempts = 20;
    int attempts = 0;

    while (answerOptions.length < 4 && attempts < maxAttempts) {
      int errorMargin = ((correctAnswer.abs()) * 0.2).ceil() + 1;

      // Farklı stratejilerle yanlış cevap üretme
      int wrongAnswer;

      switch (attempts % 3) {
        case 0:
          // Doğru cevabın etrafında ±20% aralığında
          wrongAnswer = correctAnswer + (random.nextBool() ? random.nextInt(errorMargin) : -random.nextInt(errorMargin));
          break;
        case 1:
          // Doğru cevaptan belirgin şekilde farklı
          wrongAnswer = correctAnswer + (random.nextBool() ? errorMargin * 2 : -errorMargin * 2);
          break;
        default:
          // Tamamen rastgele ama sınırlı
          wrongAnswer = (correctAnswer + random.nextInt(errorMargin * 3) - (errorMargin * 1.5).toInt());
      }

      // Güvenlik kontrolleri
      if (wrongAnswer != correctAnswer && wrongAnswer > 0 && !answerOptions.contains(wrongAnswer)) {
        answerOptions.add(wrongAnswer);
      }

      attempts++;
    }

    while (answerOptions.length < 4) {
      int fallbackWrongAnswer = correctAnswer + random.nextInt(10) + 1;
      if (!answerOptions.contains(fallbackWrongAnswer)) {
        answerOptions.add(fallbackWrongAnswer);
      }
    }
    answerOptions.shuffle();
  }

  void checkAnswer(int selectedAnswer) {
    if (!isGameActive) return;

    // Store the selected answer
    setState(() => _lastSelectedAnswer = selectedAnswer);

    bool isCorrect = selectedAnswer == correctAnswer;
    if (isCorrect) {
      setState(() => score++);
    } else {
      setState(() {
        incorrectAnswersCount++;
        // 4 səhv cavabda 1 xal çıxılır
        if (incorrectAnswersCount >= MAX_INCORRECT_ANSWERS) {
          score = max(0, score - 1);
          incorrectAnswersCount = 0;
        }
      });
    }

    showAnswerResult(isCorrect, selectedAnswer);

    // Reset the selected answer after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && isGameActive) {
        setState(() {
          _lastSelectedAnswer = null;
          generateNewQuestion();
        });
      }
    });
  }

  void playSoundEffect(bool isCorrect) async {
    if (isCorrect) {
      await _audioPlayer.play(AssetSource('sounds/correct_sound.mp3'));
    } else {
      await _audioPlayer.play(AssetSource('sounds/wrong_sound.mp3'));
    }
  }

  void showAnswerResult(bool isCorrect, int selectedAnswer) {
    playSoundEffect(isCorrect);

    if (isCorrect) {
      _confettiController.play();
    } else {
      _shakeController.forward(from: 0.0);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && isGameActive) {
        setState(() {
          generateNewQuestion();
        });
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
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const GameIntroScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  Color _getButtonColor(int answer) {
    if (_lastSelectedAnswer == null) {
      return Colors.transparent; // Default state
    }

    if (answer == correctAnswer) {
      return Colors.green; // Correct answer always green
    }

    if (answer == _lastSelectedAnswer) {
      return Colors.red; // Selected wrong answer in red
    }

    return Colors.transparent; // Other buttons remain transparent
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
      case GameDifficulty.timesDivideTable:
        difficultyTitle = 'Səviyyə 6: Vurma & Bolme Cədvəli';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(difficultyTitle),
        centerTitle: true,
      ),
      body: Stack(children: [
        Center(
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
                            backgroundColor: _getButtonColor(answer),
                          ),
                          onPressed: () => checkAnswer(answer),
                          child: Text(answer.toString()),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ],
          ),
        ),
      ]),
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
    _audioPlayer.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}
