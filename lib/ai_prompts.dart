const quickThinkingPrompt =
    """You are a system that creates simple but mathematically correct questions for the "quick_thinking" category. Your task is to generate exactly 100 math questions and return them in a strict JSON array format.

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
Generate exactly 100 questions following all rules and output only the JSON array.
""";

const multiplyDividePrompt =
    """You are a system that creates simple but mathematically correct questions for the "multiply_divide" category. Your task is to generate exactly 100 math questions and return them in a strict JSON array format.

**QUESTION RULES:**
- All questions must be either:
  1. Multiplication questions using numbers from 1 to 10 (i.e., complete multiplication table: 1×1 up to 10×10).
  2. Division questions derived from the multiplication table (i.e., reversed: 81 ÷ 9 = 9).

Examples: 
- `7 × 3 = ?`
- `36 ÷ 4 = ?`

**IMPORTANT RULES FOR ANSWER OPTIONS:**
- Each question must have exactly 4 answer options: A, B, C, D.
- The **correct answer must be placed in a different option each time** (randomized and evenly distributed).
- For example, if you're generating 40 questions, approximately 10 questions should have the correct answer in A, 10 in B, 10 in C, and 10 in D.
- The positions must be **randomized** so the correct answers are not always in the same sequence (e.g., A, B, C, D...).

**ADDITIONAL GUIDELINES:**
- Ensure the questions cover a wide variety of combinations from the full multiplication table (1×1 to 10×10) and their division counterparts.
- Do not repeat any question.
- Ensure the correct answers are calculated with 100% mathematical accuracy.
- Wrong options should be plausible (e.g., common multiplication/division mistakes) but clearly incorrect.
- Avoid using the same correct answer too many times across questions.

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
      "question": "81 ÷ 9 = ?",
      "options": {
        "A": "6",
        "B": "8",
        "C": "9",
        "D": "7"
      },
      "correct_option": "C"
    }
    ...
  ]
}
Generate exactly 100 unique questions following all rules and output only the JSON object.
""";

const trueOrFalsePrompt =
    """You are a system that creates simple but mathematically correct questions for the "true_false" category. Your task is to generate exactly 100 math questions and return them in a strict JSON array format.

**QUESTION RULES:**
Include a balanced mix of the following types of questions:
1. Addition and subtraction between numbers from 1 to 100.
   - Example: `57 - 19 = 38 ?`
2. Power expressions where the result does not exceed 100.
   - Example: `3^4 = 81 ?` or `2^6 = 64 ?`
3. Multiplication and division between numbers from 1 to 10. For division, ensure the dividend is at most 100.
   - Example: `81 ÷ 9 = 9 ?`
4. Three-step mixed expressions using numbers from 1 to 50. Use only `+`, `-`, `×`, `÷`.
   - Example: `5 + 7 - 2 = 10 ?` or `10 × 2 - 5 = 15 ?`

Some statements must be mathematically **correct (True)** and others **incorrect (False)**. Ensure there is a balanced distribution between true and false statements (approximately 50 of each).

**ANSWER OPTIONS RULES:**
- Each question must have exactly 2 answer options: `"True"` and `"False"`.
- The `correct_option` field must indicate which of the two options is correct.
- Randomize which of the two options (`True` or `False`) is placed under `"A"` or `"B"` for each question.
- Ensure that the correct answer is not always in the same position (i.e., not always A or always B).

**ADDITIONAL GUIDELINES:**
- All questions must follow the structure `expression = value ?`
- Do not repeat any question.
- Ensure all correct and incorrect values are mathematically accurate.
- Make incorrect values close enough to be plausible (e.g., common miscalculations).
- Avoid using the same numerical value too often.

**FINAL OUTPUT FORMAT (STRICT):**
Return a **JSON object** with a single key `"questions"` that maps to the array of question objects.

Example:
{
  "questions": [
    {
      "question": "6 × 2 = 12 ?",
      "options": {
        "A": "True",
        "B": "False"
      },
      "correct_option": "A"
    },
    {
      "question": "3^3 = 10 ?",
      "options": {
        "A": "False",
        "B": "True"
      },
      "correct_option": "A"
    }
    ...
  ]
}

Generate exactly 100 unique true/false questions following all rules and output only the JSON object.
""";

const expertPrompt =
    """You are a system that creates simple but mathematically correct questions for the "expert" category. Your task is to generate exactly 100 math questions and return them in a strict JSON array format.

**QUESTION RULES:**
Include a balanced mix of the following types of questions:
1. Addition and subtraction between numbers from 100 to 1000.
   - Example: `198 + 530 = ?`
2. Power expressions where the result does not exceed 5000.
   - Example: `6^4 = ?` or `13^3 = ?`
3. Multiplication and division between numbers from 50 to 5000. For division, ensure the dividend is at most 5000.
   - Example: `2640 ÷ 80 = ?`
4. Three-step mixed expressions using numbers from 50 to 500. Use only `+`, `-`, `×`, `÷`.
   - Example: `55 + 77 - 22 = ?` or `100 × 2 - 5 = ?`


**IMPORTANT RULES FOR ANSWER OPTIONS:**
- Each question must have exactly 4 answer options: A, B, C, D.
- The correct_option should be provided in order as A, B, C, D.
- But double-check carefully whether the correct_option is correct, so there’s no mathematical mistake.

**ADDITIONAL GUIDELINES:**
- Ensure the questions cover a wide variety of combinations from the full multiplication table (1×1 to 10×10) and their division counterparts.
- Do not repeat any question.
- Ensure the correct answers are calculated with 100% mathematical accuracy.
- Wrong options should be plausible (e.g., common multiplication/division mistakes) but clearly incorrect.
- Avoid using the same correct answer too many times across questions.

**FINAL OUTPUT FORMAT (STRICT):**
Return a **JSON object** with a single key `"questions"` that maps to the array of question objects. 

Example:
{
  "questions": [
    {
      "question": "648  - 352 = ?",
      "options": {
        "A": "278",
        "B": "286", 
        "C": "274",
        "D": "296"
      },
      "correct_option": "D"
    },
    {
      "question": "5^5 = ?",
      "options": {
        "A": "3325",
        "B": "3235",
        "C": "3115",
        "D": "3125"
      },
      "correct_option": "D"
    }
    ...
  ]
}

Do NOT return a plain array. Wrap the array inside a "questions" key.
Generate exactly 100 questions following all rules and output only the JSON array.
""";
