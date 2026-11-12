# ArteNaRua

App Flutter para descobrir obras de arte urbana de São Paulo. A lista vem da **Google Places API (New)**, cada obra tem ficha com **audiodescrição em voz alta**, favoritos, **reconhecimento por foto** com o Gemini e obras **perto de você** num mapa do Google.

Projeto da **Global Solution 2026.2**, disciplina Cross Platform (Flutter), 3SI FIAP.

## Desenvolvedores

| Nome completo | RM |
|---|---|
| Caio Vinicius Magalhães Leria | RM: 557833 |
| Cesar Alves Brasil | RM: 556236 |

## Tema da Global Solution

**CitizenTech**: O ArteNaRua aproxima as pessoas da arte urbana da cidade e inclui quem tem baixa visão com a audiodescrição de cada obra.

## Descrição da solução

O usuário escolhe uma região de São Paulo (Vila Madalena, Pinheiros, Cambuci, Centro ou Avenida Paulista), vê as obras de arte urbana da região, busca pelo nome e abre a ficha de cada uma, com foto, endereço e botão **Ouvir descrição**. Pode favoritar obras, ver as mais próximas pelo GPS, alternar entre lista e mapa e tirar uma foto de um mural para o app tentar reconhecê-lo.

## Funcionalidades

- **Splash** que decide, com `SharedPreferences`, se mostra o onboarding ou vai direto para a tela principal.
- **Onboarding** de 3 páginas, com botões Avançar e Voltar e a opção "Não mostrar novamente".
- **Obras**: lista por região (chips) vinda da Places API, busca pelo título, estados de carregamento, erro (com "Tentar novamente") e lista vazia.
- **Detalhe da obra**: foto com crédito do autor, endereço, audiodescrição com **Ouvir descrição** (voz do aparelho em português) e botão de favoritar.
- **Favoritos**: guarda só o identificador (`place_id`) da obra no aparelho, e busca os dados de novo ao abrir.
- **Reconhecer por foto**: tira ou escolhe uma foto, e o Gemini tenta casar com as obras conhecidas e escreve uma descrição curta. O resultado sempre vem com o aviso de que a IA pode errar.
- **Perto de mim**: usa o GPS, ordena as obras por distância e mostra a distância em cada card.
- **Mapa**: obras em um mapa do Google, com resumo ao tocar no marcador.
- **Acessibilidade** e **Sobre**: informações de uso, termos de uso, política de privacidade e créditos.

## Fluxo de telas

```
Splash ── já viu o onboarding ──▶ Início
   └─ senão ─▶ Onboarding ─▶ Início

Início (abas): Obras | Favoritos | Acessibilidade | Sobre

Obras ─ toca numa obra ─▶ Detalhe ─ voltar ─▶ Obras
Obras ─ Reconhecer por foto ─▶ Captura ─▶ Resultado ─▶ (Sugestões) ─▶ Detalhe
Obras ─ Perto de mim / Mapa ─▶ marcador ─▶ resumo ─▶ Detalhe
Favoritos ─ toca numa obra ─▶ Detalhe
```

## Prints das telas


(docs/prints/about_page.jpeg) 
(docs/prints/detail_page.jpeg) 
(docs/prints/fav_page.jpeg) 
(docs/prints/gemini_response.jpeg) 
(docs/prints/list_page.jpeg) 
(docs/prints/splash_1.jpeg) 
(docs/prints/splash_2.jpeg) 
(docs/prints/splash_3.jpeg)


## API utilizada

- **Google Places API (New)**: busca de obras por texto e região (`places:searchText`), detalhe do lugar e fotos. Os dados são convertidos em objetos Dart (`Artwork.fromPlaceJson`).
- **Gemini API**: reconhecimento da foto e descrição da obra.

Todas as chamadas HTTP usam o pacote `http`.

## Arquitetura

```
Screen (StatefulWidget + setState) → Service (http / SharedPreferences / GPS / TTS) → API ou disco
                                      Model (fromJson)
```

| Pasta | Responsabilidade |
|---|---|
| `lib/models` | `Artwork`, `Curation`, `RecognitionResult`, `UserPosition`, `ArtworkDistance` |
| `lib/services` | `PlacesService`, `GeminiRecognitionService`, `LocationService`, `CurationService`, `FavoritesService`, `PreferencesService`, `TtsService` |
| `lib/screens` | Uma `StatefulWidget` por tela, com estado só em `setState` |
| `lib/widgets` | Widgets reutilizáveis (`ArtworkCard`, `RegionChips`, `SearchField`, `ErrorView`, `EmptyView`, `ListenButton`, `ArtworkMap` e outros) |
| `lib/utils` | `LoadState`, regiões, cálculo de distância |

O estado de carregamento de cada tela usa o enum `LoadState` (inicial, carregando, sucesso e erro). Não há Provider, Bloc nem Riverpod, e cada tela cria o seu service. Navegação com `Navigator.push`, `pop` e `pushReplacement`, passando a obra para o detalhe pelo construtor.

## Termos de uso e privacidade

- O app **não pede cadastro** e não envia dados pessoais para servidor próprio.
- **Favoritos** ficam apenas no aparelho e guardam só o identificador do lugar.
- A **localização** é lida uma vez para ordenar as obras por distância e não é guardada.
- A **foto** do reconhecimento é enviada ao Gemini só para identificar a obra e não é guardada.
- Os dados de lugares e fotos vêm da Google Places API e seguem as regras da Google Maps Platform, com atribuição ao Google e ao autor das fotos. A tela **Sobre** do app traz os termos completos.
- A descrição escrita pela IA pode conter erros.

## Como rodar
testado em: **Flutter 3.47.9**  com `sdk: ^3.13.7`.

Pré-requisito: **Flutter 3.50.0** (ou compatível com `sdk: ^3.13.7`).

1. Crie o arquivo `env.json` na raiz do projeto (ele **não** deve ir para o Git):

```json
{
  "PLACES_API_KEY": "sua-chave-da-places",
  "GEMINI_API_KEY": "sua-chave-do-gemini"
}
```

2. Chave do mapa no Android: em `android/local.properties`, adicione:

```
MAPS_API_KEY=sua-chave-do-maps
```

3. Rode:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
```

As chaves **não estão no repositório**. Elas acompanham o `.zip` entregue ao professor.

## Vídeo pitch

Será disponibilizado na área de entregas pelo professor Parducci
