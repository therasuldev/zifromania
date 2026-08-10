// Enum for Game Categories
enum GameCategory {
  quickThinking,
  multiplyDivide,
  trueOrFalse,
  expert,
  training;

   String toText() {
    return switch (this) {
      GameCategory.quickThinking => 'Quick Thinking',
      GameCategory.multiplyDivide => 'Multiply/Divide',
      GameCategory.trueOrFalse => 'True/False',
      GameCategory.expert => 'Expert',
      GameCategory.training => 'Training',
    };
  }

   String toTextWithUnderscores() {
    return switch (this) {
      GameCategory.quickThinking => 'quick_thinking',
      GameCategory.multiplyDivide => 'multiply_divide',
      GameCategory.trueOrFalse => 'true_or_false',
      GameCategory.expert => 'expert',
      GameCategory.training => 'training',
    };
  }
}
