class MathQuestion {
  final String question;
  final int correctAnswer;
  final Map<String, String> answerOptions;

  const MathQuestion({
    required this.question,
    required this.correctAnswer,
    required this.answerOptions,
  });

  factory MathQuestion.fromJson(Map<String, dynamic> json) {
    return MathQuestion(
      question: json['question'] as String,
      correctAnswer: json['correct_option'] as int,
      answerOptions: Map<String, String>.from(json['options']),
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'correct_option': correctAnswer,
        'options': answerOptions,
      };
}
