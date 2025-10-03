import 'package:sibi_quest/features/play/domain/models/questions.dart';

class StaticQuestionsService {
  static List<Question> getQuestionsForLevel(String? levelId) {
    // Sample questions for different levels
    switch (levelId) {
      case 'level_1':
        return _getLevel1Questions();
      case 'level_2':
        return _getLevel2Questions();
      case 'level_3':
        return _getLevel3Questions();
      default:
        return _getDefaultQuestions();
    }
  }

  static List<Question> _getLevel1Questions() {
    return [
      // Question 1: Select Alphabet
      Question(
        id: 'q1_alphabet_A',
        levelId: 'level_1',
        type: QuestionType.selectAlphabet,
        content: QuestionContent(
          prompt: 'hand.point.right',
          isPromptImage: true,
          answers: [
            const Answer(value: 'A', isImage: false),
            const Answer(value: 'B', isImage: false),
            const Answer(value: 'C', isImage: false),
            const Answer(value: 'D', isImage: false),
          ],
        ),
        correctAnswerIndex: 0, // A is correct
      ),

      // Question 2: Select Gesture
      Question(
        id: 'q2_gesture_hello',
        levelId: 'level_1',
        type: QuestionType.selectGesture,
        content: QuestionContent(
          prompt: 'Hello',
          isPromptImage: false,
          answers: [
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
          ],
        ),
        correctAnswerIndex: 0, // hello_gesture.png is correct
      ),

      // Question 3: Perform Gesture
      Question(
        id: 'q3_perform_A',
        levelId: 'level_1',
        type: QuestionType.performGesture,
        content: QuestionContent(
          prompt: 'A',
          isPromptImage: false,
          answers: [
            const Answer(
              value: 'A',
              isImage: false,
            ), // Placeholder for gesture recognition
          ],
        ),
        correctAnswerIndex: 0,
      ),

      // Question 4: Select Alphabet
      Question(
        id: 'q4_alphabet_B',
        levelId: 'level_1',
        type: QuestionType.selectAlphabet,
        content: QuestionContent(
          prompt: 'letter_b_gesture.png',
          isPromptImage: true,
          answers: [
            const Answer(value: 'A', isImage: false),
            const Answer(value: 'B', isImage: false),
            const Answer(value: 'I', isImage: false),
            const Answer(value: 'L', isImage: false),
          ],
        ),
        correctAnswerIndex: 1, // B is correct
      ),

      // Question 5: Select Gesture
      Question(
        id: 'q5_gesture_please',
        levelId: 'level_1',
        type: QuestionType.selectGesture,
        content: QuestionContent(
          prompt: 'Please',
          isPromptImage: false,
          answers: [
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
          ],
        ),
        correctAnswerIndex: 2, // please_gesture.png is correct
      ),
    ];
  }

  static List<Question> _getLevel2Questions() {
    return [
      // Question 1: Select Alphabet
      Question(
        id: 'q1_alphabet_E',
        levelId: 'level_2',
        type: QuestionType.selectAlphabet,
        content: QuestionContent(
          prompt: 'letter_e_gesture.png',
          isPromptImage: true,
          answers: [
            const Answer(value: 'E', isImage: false),
            const Answer(value: 'F', isImage: false),
            const Answer(value: 'M', isImage: false),
            const Answer(value: 'N', isImage: false),
          ],
        ),
        correctAnswerIndex: 0, // E is correct
      ),

      // Question 2: Perform Gesture
      Question(
        id: 'q2_perform_hello',
        levelId: 'level_2',
        type: QuestionType.performGesture,
        content: QuestionContent(
          prompt: 'Hello',
          isPromptImage: false,
          answers: [const Answer(value: 'Hello', isImage: false)],
        ),
        correctAnswerIndex: 0,
      ),

      // Question 3: Select Gesture
      Question(
        id: 'q3_gesture_thank_you',
        levelId: 'level_2',
        type: QuestionType.selectGesture,
        content: QuestionContent(
          prompt: 'Thank You',
          isPromptImage: false,
          answers: [
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
          ],
        ),
        correctAnswerIndex: 1, // thank_you_gesture.png is correct
      ),
    ];
  }

  static List<Question> _getLevel3Questions() {
    return [
      // Question 1: Perform Gesture
      Question(
        id: 'q1_perform_I_love_you',
        levelId: 'level_3',
        type: QuestionType.performGesture,
        content: QuestionContent(
          prompt: 'I Love You',
          isPromptImage: false,
          answers: [const Answer(value: 'I Love You', isImage: false)],
        ),
        correctAnswerIndex: 0,
      ),

      // Question 2: Select Alphabet
      Question(
        id: 'q2_alphabet_complex',
        levelId: 'level_3',
        type: QuestionType.selectAlphabet,
        content: QuestionContent(
          prompt: 'letter_y_gesture.png',
          isPromptImage: true,
          answers: [
            const Answer(value: 'Y', isImage: false),
            const Answer(value: 'X', isImage: false),
            const Answer(value: 'V', isImage: false),
            const Answer(value: 'U', isImage: false),
          ],
        ),
        correctAnswerIndex: 0, // Y is correct
      ),

      // Question 3: Select Gesture
      Question(
        id: 'q3_gesture_goodbye',
        levelId: 'level_3',
        type: QuestionType.selectGesture,
        content: QuestionContent(
          prompt: 'Goodbye',
          isPromptImage: false,
          answers: [
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
          ],
        ),
        correctAnswerIndex: 2, // goodbye_gesture.png is correct
      ),
    ];
  }

  static List<Question> _getDefaultQuestions() {
    return [
      // Default mixed questions
      Question(
        id: 'default_q1',
        levelId: 'default',
        type: QuestionType.selectAlphabet,
        content: QuestionContent(
          prompt: 'hand.point.right',
          isPromptImage: true,
          answers: [
            const Answer(value: 'A', isImage: false),
            const Answer(value: 'I', isImage: false),
            const Answer(value: 'J', isImage: false),
            const Answer(value: 'D', isImage: false),
          ],
        ),
        correctAnswerIndex: 3, // D is correct
      ),

      Question(
        id: 'default_q2',
        levelId: 'default',
        type: QuestionType.selectGesture,
        content: QuestionContent(
          prompt: 'Hello',
          isPromptImage: false,
          answers: [
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
            const Answer(value: 'hand.point.right', isImage: true),
          ],
        ),
        correctAnswerIndex: 0, // hello_gesture.png is correct
      ),

      Question(
        id: 'default_q3',
        levelId: 'default',
        type: QuestionType.performGesture,
        content: QuestionContent(
          prompt: 'A',
          isPromptImage: false,
          answers: [const Answer(value: 'A', isImage: false)],
        ),
        correctAnswerIndex: 0,
      ),
    ];
  }
}
