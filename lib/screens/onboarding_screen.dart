import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<({IconData icon, String title, String text})> pages = [
    (
      icon: Icons.location_city,
      title: 'Arte na rua',
      text: 'Descubra murais e grafites de São Paulo, bairro por bairro.',
    ),
    (
      icon: Icons.volume_up,
      title: 'Audiodescrição',
      text: 'Ouça a descrição de cada obra em voz alta.',
    ),
    (
      icon: Icons.favorite,
      title: 'Suas favoritas',
      text: 'Guarde as obras que você mais gostou para ver depois.',
    ),
  ];

  final PageController controller = PageController();
  final PreferencesService preferences = PreferencesService();

  int currentPage = 0;
  bool dontShowAgain = false;

  bool get isLast => currentPage == pages.length - 1;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void goTo(int page) {
    controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> finish() async {
    await preferences.setHideOnboarding(dontShowAgain);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (page) => setState(() => currentPage = page),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon,
                            size: 96,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(page.title,
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Text(page.text, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  Container(
                    margin: const EdgeInsets.all(4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == currentPage
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
              ],
            ),
            CheckboxListTile(
              value: dontShowAgain,
              onChanged: (value) =>
                  setState(() => dontShowAgain = value ?? false),
              title: const Text('Não mostrar novamente'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  currentPage == 0
                      ? const SizedBox(width: 48)
                      : TextButton(
                          onPressed: () => goTo(currentPage - 1),
                          child: const Text('Voltar'),
                        ),
                  ElevatedButton(
                    onPressed: isLast ? finish : () => goTo(currentPage + 1),
                    child: Text(isLast ? 'Começar' : 'Avançar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
