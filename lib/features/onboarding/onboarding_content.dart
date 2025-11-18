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
    title: 'Selamat datang di ',
    highlight: 'SIBI Quest',
    subtitle: 'Perjalananmu mempelajari bahasa isyarat dimulai di sini.',
    button: 'Lanjutkan',
  ),
  OnboardingPageData(
    title: 'Tempat belajar ',
    highlight: 'SIBI',
    subtitle: 'Berlatih gerakan, selesaikan tantangan, dan pantau progresmu.',
    button: 'Lanjutkan',
  ),
  OnboardingPageData(
    title: 'Siap untuk ',
    highlight: 'Memulai?',
    subtitle: 'Buat akunmu dan mulai petualangan hari ini.',
    button: 'Mulai Sekarang',
  ),
];
