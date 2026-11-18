# Lunae Pulse

Frontend Flutter em português, baseado no guia de identidade e telas fornecido. Nenhum serviço de backend é inicializado.

## Executar

```sh
flutter pub get
flutter run -d chrome
```

Também pode executar em um emulador Android ou iOS com `flutter run`. A validação desta entrega usa widgets e build web; builds nativos não foram executados.

## Explorar as telas

O aplicativo abre no painel de demonstração. Use as cinco abas: Início, Treinos, Alimentação, Evolução e Perfil. O ícone de grade no topo abre o catálogo T01–T53, incluindo onboarding e as prévias futuras de IA/Lunae Fit. Nas telas secundárias, o menu no topo permite visualizar os estados de carregamento, vazio, erro, offline e sincronização simulada.

- T01–T11: abertura, benefícios, formulários de acesso e configuração de perfil.
- T12–T15: dashboard, notificações, semana e ações rápidas.
- T16–T24: fichas, catálogo, detalhes, criação, registro de séries, descanso e histórico.
- T25–T32: painel alimentar, diário com edição de porção e remoção com desfazer, busca, alimentos personalizados, receita de exemplo e água.
- T33–T38: tendência de peso, medidas, força, calendário e prévia de relatório.
- T39–T43: saúde, cronômetro de atividade simulado, sono manual e explicações de integração.
- T44–T48: perfil, metas, aparência, privacidade e FAQ.
- T49–T53: prévias futuras do assistente e Lunae Fit.

## Limites da prévia

Os dados iniciais são fictícios. Registros, fichas e preferências vivem apenas na memória da sessão. Não há autenticação real, envio de e-mail, banco, persistência em disco, IA, câmera, GPS, notificações, exportação de arquivos ou acesso a dados de saúde. Os fluxos explicam essas limitações e não solicitam permissões do sistema. Splash é uma tela revisável no catálogo; o lançamento abre o painel sem espera artificial.

As fontes nutricionais, instruções de exercício, metas e números iniciais são conteúdo ilustrativo da interface e exigem revisão antes de uso real. Os gráficos de período demonstram apresentação visual; não consultam históricos externos. A biblioteca de exercícios e receitas usa exemplos reduzidos. Termos, política e contato de suporte definitivos precisam ser fornecidos antes da integração.

As três imagens fornecidas permanecem intactas em assets/. A versão limpa sobre branco é utilizada na abertura e onboarding; as versões quadriculada e com brilho são preservadas como referências.

## Organização

- lib/app: shell responsivo, rotas e temas Material 3.
- lib/core: estado compartilhado em memória, componentes e catálogo de telas.
- lib/features: apresentações de acesso, dia, treino, nutrição, evolução, saúde e perfil.
- DESIGN.md e UX-CONTRACT.md: decisões visuais e de comportamento.

## Verificar

```sh
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
```

Os testes verificam as 53 telas em 320/390/1280 dp, tema escuro e texto ampliado, navegação compacta, registro/edição de alimento, hidratação com desfazer, peso com validação, retomada de treino e estado das fichas personalizadas.
