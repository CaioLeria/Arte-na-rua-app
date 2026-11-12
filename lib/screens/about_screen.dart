import 'package:flutter/material.dart';

import '../widgets/google_attribution.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Sobre o ArteNaRua', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
            'App do cidadão para descobrir obras de arte urbana de São Paulo, '
            'ouvir a audiodescrição de cada uma e guardar as favoritas.'),
        const SizedBox(height: 16),
        Text('Termos de uso', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
            'O app usa as APIs do Google Maps Platform. Ao usá-lo, você '
            'também está sujeito aos Termos de Serviço do Google Maps '
            'Platform. As informações das obras vêm do Google e podem estar '
            'incompletas ou desatualizadas.'),
        const SizedBox(height: 16),
        Text('Política de privacidade', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
            'Guardamos no aparelho apenas os códigos das suas obras '
            'favoritas e as suas preferências de acessibilidade. Não há '
            'conta de usuário e não coletamos dados pessoais. As consultas '
            'ao Google seguem a Política de Privacidade do Google.'),
        const SizedBox(height: 8),
        const Text(
            'Localização: usada apenas enquanto o app está aberto, e só quando '
            'você toca em "Perto de mim" ou abre o mapa. A posição não é '
            'salva nem enviada a ninguém além do Google, para a busca.'),
        const SizedBox(height: 8),
        const Text(
            'Reconhecimento por foto: a foto que você tira é enviada ao '
            'Gemini, do Google, apenas para a comparação. Ela não é guardada '
            'no aparelho e o resultado é gerado por IA, podendo conter erros.'),
        const SizedBox(height: 16),
        Text('Créditos', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
            'Global Solution 2026.2 (CitizenTech), Cross Platform, 3SI FIAP. '
            'Desenvolvido pela equipe ArteNaRua.'),
        const GoogleAttribution(),
      ],
    );
  }
}
