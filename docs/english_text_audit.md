# English Text Usage Audit

This document catalogs all English text strings currently displayed in the SIBI Quest app for potential internationalization or localization.

## Play Feature

### Question Type Pages

#### PlayTypeOnePage (`lib/features/play/presentation/pages/type/play_type_one_page.dart`)
- **Line 26-27**: "Select the correct"
- **Line 32-33**: "Alphabet"

#### PlayTypeTwoPage (`lib/features/play/presentation/pages/type/play_type_two_page.dart`)
- **Line 26-27**: "Select the correct"
- **Line 32-33**: "Gesture"

#### PlayTypeThreePage (`lib/features/play/presentation/pages/type/play_type_three_page.dart`)
- **Line 32-33**: "Perform this"
- **Line 38-39**: "Gesture"
- **Line 119**: "Select an image" (placeholder)
- **Line 145**: "Analysing your gesture..." (processing indicator)

### Play Page (`lib/features/play/presentation/pages/play_page.dart`)

#### Button Text
- **Line 340**: "Submit Answer"
- **Line 342-343**: "Next Question"
- **Line 345**: "Finish Game"
- **Line 349**: "Try Again"
- **Line 351-352**: "Continue"

#### Helper Text
- **Line 372**: "[X] attempt(s) remaining"
- **Line 374**: "No attempts remaining."

#### Settings Menu
- **Line 433**: "Game Settings"
- **Line 441**: "Return to Home"
- **Line 452**: "Restart Level"

#### Error Messages
- **Line 506**: "We'll retry syncing your progress later."

### Score Page (`lib/features/play/presentation/pages/score_page.dart`)

#### Score Messages
- **Line 20**: "Excellent!"
- **Line 22**: "Good Job!"
- **Line 24**: "Keep Practicing!"
- **Line 26**: "Try Again!"

#### UI Labels
- **Line 85**: "Your Score"
- **Line 104**: "Play Again" (button)

### Loading Page (`lib/features/play/presentation/pages/loading_page.dart`)
- **Line 59**: "Loading Game!"

### Camera Page (`lib/features/play/presentation/pages/camera/camera_page.dart`)
- **Line 158**: "Capture failed: [error]"

### Static Questions (`lib/features/play/data/static_questions_service.dart`)

#### Gesture Prompts (English Words)
- **Line 44**: "Hello"
- **Line 98**: "Please"
- **Line 138**: "Hello"
- **Line 151**: "Thank You"
- **Line 173**: "I Love You"
- **Line 204**: "Goodbye"
- **Line 243**: "Hello"

#### Alphabet Letters
- All alphabet letters A-Z used as prompts and answers throughout the file

## Onboarding & Welcome

### Onboarding Content (`lib/features/onboarding/onboarding_content.dart`)
- **Line 16-18**: "Welcome to SIBI Quest"
  - Title: "Welcome to "
  - Highlight: "SIBI Quest"
  - Subtitle: "Your journey into sign language starts here."
  - Button: "Continue"

- **Line 20-22**: "A Place to Learn SIBI"
  - Title: "A Place to Learn "
  - Highlight: "SIBI"
  - Subtitle: "Practice signs, complete challenges, and track your progress."
  - Button: "Continue"

- **Line 24-26**: "Ready to Start?"
  - Title: "Ready to "
  - Highlight: "Start?"
  - Subtitle: "Create your account and begin your quest today."
  - Button: "Get Started"

### Welcome Page (`lib/features/onboarding/presentation/pages/welcome_page.dart`)
- **Line 25**: "Already have an account?"
- **Line 32**: "Log In" (button)
- **Line 47**: "New to SIBI Quest?"
- **Line 54**: "Get Started" (button)

## Home Feature

### Home Page (`lib/features/home/presentation/pages/home_page.dart`)
- **Line 86**: "Welcome, "
- **Line 92**: "Explorer" (fallback display name)

## Leaderboard Feature

### Leaderboard Page (`lib/features/leaderboard/presentation/pages/leaderboard_page.dart`)

#### Empty State
- **Line 237**: "Leaderboard is empty"
- **Line 244**: "Play a few levels to start competing with friends!"

## Shared Widgets

### Level Button (`lib/shared/widgets/level_button.dart`)

#### Popup Subtitles
- **Line 36**: "Complete this level to earn rewards"
- **Line 38**: "You have completed this level"
- **Line 40**: "This level is locked"

## Assets

### Model Labels (`assets/models/labels.txt`)
- Contains all 26 English alphabet letters (A-Z) used for classification

---

## Recommendations for Internationalization

1. **Implement i18n**: Consider adding the `flutter_localizations` package and creating translation files
2. **Extract Constants**: Move all hardcoded strings to a centralized constants file or localization system
3. **Question Content**: Move static questions to Firestore with language support
4. **Model Labels**: Keep labels in English as they represent standardized gesture classifications, but translate UI display text

## Priority Areas for Localization

1. **High Priority** (User-facing UI):
   - Question type headers
   - Button labels
   - Score messages
   - Onboarding flow

2. **Medium Priority**:
   - Settings menu
   - Error messages
   - Empty states

3. **Low Priority** (Technical):
   - Model labels (standardized identifiers)
   - Debug messages
