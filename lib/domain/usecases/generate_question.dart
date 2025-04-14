// import 'dart:math';
// import '../entities/enums.dart';
// import '../entities/math_question.dart';

// class GenerateQuestionUseCase {
//   final Random _random = Random();

//   MathQuestion call({required GameDifficulty difficulty}) {
//     switch (difficulty) {
//       case GameDifficulty.easy:
//         return _generateEasyQuestion();
//       case GameDifficulty.medium:
//         return _generateMediumQuestion();
//       case GameDifficulty.hard:
//         return _generateHardQuestion();
//       case GameDifficulty.master:
//         return _generateMasterQuestion();
//       case GameDifficulty.mix:
//         return _generateMixQuestion();
//       case GameDifficulty.timesDivideTable:
//         return _generateTimesTableQuestion();
//     }
//   }

//   MathQuestion _generateEasyQuestion() {
//     final operation = OperationType.values[_random.nextInt(4)];
//     final num1 = _random.nextInt(100) + 1;
//     final num2 = _random.nextInt(100) + 1;

//     return _createMathQuestion(operation, num1, num2);
//   }

//   MathQuestion _generateMediumQuestion() {
//     final operation = OperationType.values[_random.nextInt(4)];
//     final num1 = _random.nextInt(901) + 100;
//     final num2 = _random.nextInt(901) + 100;

//     return _createMathQuestion(operation, num1, num2);
//   }

//   MathQuestion _generateHardQuestion() {
//     final operation = OperationType.values[_random.nextInt(4)];
//     final num1 = _random.nextInt(9001) + 1000;
//     final num2 = _random.nextInt(9001) + 1000;

//     return _createMathQuestion(operation, num1, num2);
//   }

//   MathQuestion _generateMasterQuestion() {
//     // final num1 = _random.nextInt(900) + 100;
//     // final num2 = _random.nextInt(900) + 100;

//     const operation = OperationType.logarithm;
//     final base = _random.nextInt(3) + 2; // 2-4
//     final logNum = pow(base, _random.nextInt(4) + 2).toInt();
//     final correctAnswer = (log(logNum) / log(base)).toInt();

//     return MathQuestion(
//       question: 'log$base($logNum)',
//       correctAnswer: correctAnswer,
//       answerOptions: _generateAnswerOptions(correctAnswer),
//       operation: operation,
//     );
//   }

//   MathQuestion _generateMixQuestion() {
//     final num1 = _random.nextInt(900) + 100;
//     final num2 = _random.nextInt(900) + 100;
//     final num3 = _random.nextInt(900) + 100;

//     final operation = OperationType.values[_random.nextInt(OperationType.values.length)];

//     return _createMixMathQuestion(operation, num1, num2, num3);
//   }

//   MathQuestion _generateTimesTableQuestion() {
//     final operation = [OperationType.division, OperationType.multiplication][_random.nextInt(2)];

//     if (operation == OperationType.multiplication) {
//       final num1 = _random.nextInt(9) + 1;
//       final num2 = _random.nextInt(9) + 1;
//       final correctAnswer = num1 * num2;

//       return MathQuestion(
//         question: '$num1 × $num2',
//         correctAnswer: correctAnswer,
//         answerOptions: _generateAnswerOptions(correctAnswer),
//         operation: operation,
//       );
//     } else {
//       final num2 = _random.nextInt(9) + 1;
//       final num1 = num2 * (_random.nextInt(9) + 1);
//       final correctAnswer = num1 ~/ num2;

//       return MathQuestion(
//         question: '$num1 ÷ $num2',
//         correctAnswer: correctAnswer,
//         answerOptions: _generateAnswerOptions(correctAnswer),
//         operation: operation,
//       );
//     }
//   }

//   MathQuestion _createMathQuestion(OperationType operation, int num1, int num2) {
//     late int correctAnswer;
//     late String question;

//     switch (operation) {
//       case OperationType.addition:
//         correctAnswer = num1 + num2;
//         question = '$num1 + $num2';
//         break;
//       case OperationType.subtraction:
//         correctAnswer = num1 - num2;
//         question = '$num1 - $num2';
//         break;
//       case OperationType.multiplication:
//         correctAnswer = num1 * num2;
//         question = '$num1 × $num2';
//         break;
//       case OperationType.division:
//         int divisor = _random.nextInt(10) + 1;
//         int quotient = _random.nextInt(10) + 1;
//         int dividend = divisor * quotient;
//         correctAnswer = quotient;
//         question = '$dividend ÷ $divisor';
//         break;
//       default:
//         correctAnswer = num1 + num2;
//         question = '$num1 + $num2';
//     }

//     return MathQuestion(
//       question: question,
//       correctAnswer: correctAnswer,
//       answerOptions: _generateAnswerOptions(correctAnswer),
//       operation: operation,
//     );
//   }

//   MathQuestion _createMixMathQuestion(OperationType operation, int num1, int num2, int num3) {
//     late int correctAnswer;
//     late String question;

//     switch (operation) {
//       case OperationType.addition:
//         correctAnswer = num1 + num2 + num3;
//         question = '$num1 + $num2 + $num3';
//         break;
//       case OperationType.multiplication:
//         correctAnswer = num1 * num2 * num3;
//         question = '$num1 × $num2 × $num3';
//         break;
//       case OperationType.modulo:
//         correctAnswer = num1 % num2;
//         question = '$num1 % $num2';
//         break;
//       case OperationType.exponentiation:
//         final base = num1;
//         final exponent = _random.nextInt(4) + 2; // 2-5
//         correctAnswer = pow(base, exponent).toInt();
//         question = '$base^$exponent';
//         break;
//       default:
//         correctAnswer = num1 + num2;
//         question = '$num1 + $num2';
//     }

//     return MathQuestion(
//       question: question,
//       correctAnswer: correctAnswer,
//       answerOptions: _generateAnswerOptions(correctAnswer),
//       operation: operation,
//     );
//   }

//   List<int> _generateAnswerOptions(int correctAnswer) {
//     final answerOptions = [correctAnswer];
//     int maxAttempts = 20;
//     int attempts = 0;

//     while (answerOptions.length < 4 && attempts < maxAttempts) {
//       final errorMargin = ((correctAnswer.abs()) * 0.2).ceil() + 1;
//       int wrongAnswer;

//       switch (attempts % 3) {
//         case 0:
//           // Around ±20% of correct answer
//           wrongAnswer = correctAnswer + (_random.nextBool() ? _random.nextInt(errorMargin) : -_random.nextInt(errorMargin));
//           break;
//         case 1:
//           // Significantly different from correct answer
//           wrongAnswer = correctAnswer + (_random.nextBool() ? errorMargin * 2 : -errorMargin * 2);
//           break;
//         default:
//           // Somewhat random but limited
//           wrongAnswer = correctAnswer + _random.nextInt(errorMargin * 3) - (errorMargin * 1.5).toInt();
//       }

//       // Safety checks
//       if (wrongAnswer != correctAnswer && wrongAnswer > 0 && !answerOptions.contains(wrongAnswer)) {
//         answerOptions.add(wrongAnswer);
//       }

//       attempts++;
//     }

//     // Fallback mechanism to ensure 4 options
//     while (answerOptions.length < 4) {
//       final fallbackWrongAnswer = correctAnswer + _random.nextInt(10) + 1;
//       if (!answerOptions.contains(fallbackWrongAnswer)) {
//         answerOptions.add(fallbackWrongAnswer);
//       }
//     }

//     answerOptions.shuffle();
//     return answerOptions;
//   }
// }
