class OnboardingPageData {
  final String title;
  final String highlight;
  final String subtitle;
  final String button;

  const OnboardingPageData({
    required this.title,
    required this.highlight,
    required this.subtitle,
    required this.button,
  });
}

const onboardingPages = [
  OnboardingPageData(
    title: 'Welcome to ',
    highlight: 'SIBI Quest',
    subtitle: 'Your journey into sign language starts here.',
    button: 'Continue',
  ),
  OnboardingPageData(
    title: 'A Place to Learn ',
    highlight: 'SIBI',
    subtitle: 'Practice signs, complete challenges, and track your progress.',
    button: 'Continue',
  ),
  OnboardingPageData(
    title: 'Ready to ',
    highlight: 'Start?',
    subtitle: 'Create your account and begin your quest today.',
    button: 'Get Started',
  ),
  // ...other pages
];
