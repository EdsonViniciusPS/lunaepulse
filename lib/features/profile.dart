import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app.dart';
import '../core/store.dart';
import '../core/widgets.dart';
import 'workouts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.id});
  final int id;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, TextEditingController> fields = {};
  final form = GlobalKey<FormState>();
  String query = '';
  bool recording = false, paused = false, preview = false;
  int seconds = 0;
  Timer? timer;
  final List<String> messages = [];
  TextEditingController field(String key, {String initial = ''}) =>
      fields.putIfAbsent(key, () => TextEditingController(text: initial));
  @override
  void dispose() {
    timer?.cancel();
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  void go(int id) => openScreen(context, id);
  Widget tile(int id, String title, String sub, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: PulseTile(title, sub, icon: icon, onTap: () => go(id)),
  );
  Widget toggle(String title, String subtitle) {
    final store = PulseScope.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: store.preferences[title] ?? false,
      onChanged: (v) => store.update(() => store.preferences[title] = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context), id = widget.id;
    if (id == 44) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulseCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  child: Text(
                    store.name.isEmpty ? 'A' : store.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  store.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(store.goals.join(' · '), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => go(7),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar perfil'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Section('Sua jornada, suas escolhas'),
          tile(
            45,
            'Metas e preferências',
            'Objetivos, treino e alimentação',
            Icons.flag_outlined,
          ),
          tile(
            39,
            'Saúde e atividade',
            'Sono, passos e movimento',
            Icons.favorite_border,
          ),
          tile(
            42,
            'Integrações',
            'Escolha suas fontes de dados',
            Icons.link_rounded,
          ),
          tile(
            46,
            'Configurações',
            'Tema, idioma e acessibilidade',
            Icons.tune,
          ),
          tile(
            47,
            'Privacidade e dados',
            'Controle seus registros',
            Icons.shield_outlined,
          ),
          tile(
            48,
            'Ajuda e suporte',
            'Encontre o próximo passo',
            Icons.help_outline,
          ),
          tile(
            2,
            'Conhecer a experiência inicial',
            'Boas-vindas e criação de perfil',
            Icons.waving_hand_outlined,
          ),
          const SizedBox(height: 8),
          const InfoNote(
            'Perfil local de demonstração · nenhum login real ativo.',
          ),
        ],
      );
    }
    if (id == 45) {
      return Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tile(
              8,
              'Seus objetivos',
              store.goals.join(' · '),
              Icons.flag_outlined,
            ),
            tile(
              9,
              'Preferências de treino',
              'Dias, duração e equipamentos',
              Icons.fitness_center,
            ),
            tile(
              10,
              'Preferências alimentares',
              'Acompanhamento e restrições',
              Icons.restaurant_outlined,
            ),
            const Section('Hidratação'),
            TextFormField(
              controller: field('water', initial: '${store.waterGoal}'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Meta pessoal de água (mL / dia)',
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return n == null || n <= 0 || n > 10000
                    ? 'Informe de 1 a 10.000 mL.'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            const InfoNote(
              'Meta definida por você. Alterações afetam o painel atual e não modificam registros históricos.',
            ),
            const SizedBox(height: 24),
            PulseButton(
              'Salvar preferências',
              icon: Icons.check,
              onPressed: () {
                if (form.currentState!.validate()) {
                  store.update(
                    () => store.waterGoal = int.parse(field('water').text),
                  );
                  feedback(context, 'Preferências salvas nesta sessão');
                }
              },
            ),
          ],
        ),
      );
    }
    if (id == 46) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Section('A aparência que combina com você'),
          DropdownButtonFormField<ThemeMode>(
            isExpanded: true,
            initialValue: store.themeMode,
            decoration: const InputDecoration(labelText: 'Tema do aplicativo'),
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('Acompanhar o sistema'),
              ),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Escuro')),
            ],
            onChanged: (v) => store.update(() => store.themeMode = v!),
          ),
          const SizedBox(height: 24),
          const PulseTile(
            'Idioma',
            'Português (Brasil)',
            icon: Icons.translate_rounded,
          ),
          const SizedBox(height: 12),
          const PulseTile(
            'Unidades',
            'kg · cm · mL · km',
            icon: Icons.straighten,
          ),
          const Section('Conforto e atenção'),
          toggle(
            'Lembretes de treino',
            'Preferência local; não agenda notificações.',
          ),
          toggle(
            'Reduzir animações',
            'As telas respeitam também a configuração do sistema.',
          ),
          const SizedBox(height: 24),
          PulseButton(
            'Restaurar aparência',
            secondary: true,
            icon: Icons.restart_alt,
            onPressed: () {
              store.update(() => store.themeMode = ThemeMode.system);
              feedback(context, 'Aparência restaurada');
            },
          ),
        ],
      );
    }
    if (id == 47) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seus dados.\nSuas escolhas.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          const PulseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 40),
                SizedBox(height: 16),
                Text('Esta versão é uma demonstração de frontend.'),
                SizedBox(height: 12),
                Text(
                  'Os registros são mantidos em memória durante a sessão. Nenhuma informação é enviada para uma conta, servidor ou serviço de saúde.',
                ),
                SizedBox(height: 12),
                Text(
                  'Termos, política e regras de retenção da versão integrada ainda precisam ser definidos.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          tile(
            38,
            'Pré-visualizar meus dados',
            'Escolha quais módulos incluir',
            Icons.description_outlined,
          ),
          tile(
            42,
            'Gerenciar integrações',
            'Nenhuma permissão ativa nesta versão',
            Icons.link_off,
          ),
          PulseButton(
            'Limpar registros desta sessão',
            secondary: true,
            icon: Icons.delete_outline,
            onPressed: () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Limpar os registros locais?'),
                  content: const Text(
                    'Alimentos, água, treinos e pesos desta demonstração serão removidos da sessão atual. Esta ação não exclui contas externas.',
                  ),
                  actions: [
                    TextButton(
                      autofocus: true,
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Manter registros'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Limpar registros'),
                    ),
                  ],
                ),
              );
              if (yes == true && context.mounted) {
                store.update(() {
                  store.foods.clear();
                  store.weights.clear();
                  store.weights.add(store.weight);
                  store.sessions.clear();
                  store.water = 0;
                  store.completedSets = 0;
                  store.activeWorkout = false;
                  store.workoutStarted = null;
                });
                feedback(context, 'Registros desta sessão limpos');
              }
            },
          ),
        ],
      );
    }
    if (id == 48) {
      final faq = [
        (
          'Como registrar um treino?',
          'Abra Treinos, escolha uma ficha e toque em Iniciar treino. Durante a sessão, registre carga e repetições e conclua cada série.',
        ),
        (
          'Como os nutrientes são calculados?',
          'A prévia multiplica o valor por 100 g pela quantidade informada. Os dados do catálogo são demonstrativos e os totais são estimativas.',
        ),
        (
          'Meus dados ficam salvos?',
          'Os registros são mantidos somente em memória nesta versão. Ao encerrar o aplicativo, a sessão é descartada.',
        ),
        (
          'Como conectar um dispositivo?',
          'O fluxo visual está disponível em Integrações. Esta prévia não solicita permissões nem acessa sensores.',
        ),
        (
          'Como recuperar meu acesso?',
          'A recuperação de conta é apenas uma simulação, sem envio de e-mail. O serviço de autenticação será conectado em outra etapa.',
        ),
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estamos por aqui.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          PulseSearch(
            label: 'Buscar ajuda',
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 24),
          for (final f in faq.where(
            (f) =>
                '${f.$1} ${f.$2}'.toLowerCase().contains(query.toLowerCase()),
          ))
            Card(
              child: ExpansionTile(
                title: Text(f.$1),
                children: [
                  Padding(padding: const EdgeInsets.all(20), child: Text(f.$2)),
                ],
              ),
            ),
          const SizedBox(height: 24),
          const InfoNote(
            'O canal de suporte humano será configurado pelo responsável pelo aplicativo.',
          ),
        ],
      );
    }
    if (id == 39) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olhe para\no seu bem-estar.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          const Text('Conecte uma fonte ou faça um registro manual.'),
          const SizedBox(height: 24),
          const AdaptiveGrid(
            children: [
              Metric(
                'Sem dados',
                'Passos · dispositivo não conectado',
                icon: Icons.directions_walk,
              ),
              Metric(
                'Sem dados',
                'Frequência cardíaca · sem fonte',
                icon: Icons.favorite_border,
              ),
            ],
          ),
          const SizedBox(height: 24),
          tile(
            40,
            'Caminhada e corrida',
            'Acompanhe uma atividade de exemplo',
            Icons.directions_run,
          ),
          tile(
            41,
            'Sono e recuperação',
            'Registros manuais e tendências',
            Icons.bedtime_outlined,
          ),
          tile(
            42,
            'Conectar fonte de saúde',
            'Escolha quais dados compartilhar',
            Icons.link_rounded,
          ),
          const InfoNote(
            'Ausência de dados não significa zero. Nenhum sensor está conectado.',
          ),
        ],
      );
    }
    if (id == 40) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulseCard(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 180),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.route_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text('Prévia do percurso'),
                  const Text(
                    'Localização não conectada',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AdaptiveGrid(
            children: [
              Metric(
                '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                'Duração da simulação',
                icon: Icons.timer_outlined,
              ),
              const Metric(
                'Sem dados',
                'Distância · GPS não conectado',
                icon: Icons.route,
              ),
            ],
          ),
          const SizedBox(height: 24),
          PulseButton(
            !recording
                ? 'Iniciar simulação'
                : paused
                ? 'Retomar atividade'
                : 'Pausar atividade',
            icon: recording && !paused ? Icons.pause : Icons.play_arrow,
            onPressed: () {
              setState(() {
                if (!recording) {
                  recording = true;
                  timer = Timer.periodic(const Duration(seconds: 1), (_) {
                    if (mounted && !paused) setState(() => seconds++);
                  });
                } else {
                  paused = !paused;
                }
              });
            },
          ),
          const SizedBox(height: 12),
          if (recording)
            PulseButton(
              'Encerrar e revisar',
              secondary: true,
              icon: Icons.stop,
              onPressed: () {
                timer?.cancel();
                setState(() {
                  recording = false;
                  preview = true;
                });
              },
            ),
          if (preview) ...[
            const SizedBox(height: 20),
            InfoNote(
              'Atividade simulada concluída: $seconds segundos. Nenhum trajeto ou distância foi registrado.',
            ),
          ],
          const SizedBox(height: 24),
          const InfoNote(
            'Nenhum acesso à localização foi solicitado. A duração é apenas uma simulação de interface.',
          ),
        ],
      );
    }
    if (id == 41) {
      return Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PulseTile(
              'Seu sono merece atenção',
              'Sem dados de dispositivo · registro manual disponível',
              icon: Icons.bedtime_outlined,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: field('sleep'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Duração do sono (horas)',
              ),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                return n == null || n <= 0 || n > 24
                    ? 'Informe uma duração entre 0 e 24 horas.'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: field('sleepNotes'),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Como você se sente? (opcional)',
              ),
            ),
            const SizedBox(height: 24),
            PulseButton(
              'Salvar registro manual',
              icon: Icons.check,
              onPressed: () {
                if (form.currentState!.validate()) {
                  store.update(
                    () => store.drafts[41] = {'hours': field('sleep').text},
                  );
                  feedback(context, 'Sono registrado nesta sessão');
                }
              },
            ),
            if (store.drafts[41] != null) ...[
              const SizedBox(height: 24),
              PulseTile(
                '${store.drafts[41]!['hours']} h de sono',
                'Informado por você · nesta sessão',
                icon: Icons.bedtime_outlined,
              ),
            ],
            const SizedBox(height: 24),
            const InfoNote(
              'A duração por si só não determina a qualidade do sono. Esta tela não oferece diagnóstico.',
            ),
          ],
        ),
      );
    }
    if (id == 42 || id == 11) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conexões com\na sua permissão.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          const Text('Você mantém o controle sobre o que compartilhar.'),
          const SizedBox(height: 24),
          for (final service in [
            'Health Connect · Android',
            'Apple Health · iOS',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PulseCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Não conectado · integração futura'),
                    const SizedBox(height: 12),
                    const Text(
                      'Escopos previstos: passos, exercícios e sono. Você poderá escolher cada categoria.',
                    ),
                    const SizedBox(height: 20),
                    PulseButton(
                      'Ver como conectar',
                      secondary: true,
                      icon: Icons.link,
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(service),
                          content: const Text(
                            'Na versão integrada, este passo abrirá a permissão do sistema. Esta prévia não acessa nem transmite seus dados de saúde.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('Entendi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          tile(
            43,
            'Histórico de sincronização',
            'Veja status e fontes dos registros',
            Icons.sync,
          ),
          const InfoNote(
            'Nenhuma permissão foi concedida ou solicitada nesta demonstração.',
          ),
        ],
      );
    }
    if (id == 43) {
      return Column(
        children: [
          const PulseCard(
            child: Column(
              children: [
                Icon(Icons.cloud_off_rounded, size: 48),
                SizedBox(height: 16),
                Text('Nenhuma fonte conectada'),
                SizedBox(height: 12),
                Text(
                  'Ao conectar um serviço de saúde, a origem e o horário de sincronização aparecerão aqui.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PulseButton('Ver integrações', onPressed: () => go(42)),
          const SizedBox(height: 20),
          const InfoNote(
            'Última sincronização: não realizada. Não há conflitos de dados nesta prévia.',
          ),
        ],
      );
    }
    if (id == 49) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Chip(label: Text('Laboratório · recurso futuro')),
          const SizedBox(height: 16),
          Text(
            'Uma conversa sobre\na sua rotina.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          const PulseCard(
            child: Text(
              'Olá! Nesta prévia você pode conhecer o formato das conversas. Nenhum modelo de IA está conectado.',
            ),
          ),
          for (final message in messages) ...[
            const SizedBox(height: 12),
            PulseCard(child: Text(message)),
          ],
          const SizedBox(height: 24),
          TextField(
            controller: field('chat'),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Escreva uma pergunta de exemplo',
            ),
          ),
          const SizedBox(height: 16),
          PulseButton(
            'Pré-visualizar resposta',
            icon: Icons.send_outlined,
            onPressed: () {
              if (field('chat').text.trim().isEmpty) return;
              setState(() {
                messages.add('Você: ${field('chat').text.trim()}');
                messages.add(
                  'Pulse · exemplo: posso ajudar a organizar seus registros. Qualquer alteração nas suas metas exigirá sua revisão e confirmação.',
                );
                field('chat').clear();
              });
            },
          ),
          const SizedBox(height: 16),
          const InfoNote(
            'Conversa simulada. Nenhuma sugestão altera seus registros ou substitui orientação profissional.',
          ),
        ],
      );
    }
    if (id == 52) return const WorkoutPage(id: 52);
    if (id == 50) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Chip(label: Text('Lunae Fit · prévia futura')),
          const SizedBox(height: 16),
          Text(
            'Seu acompanhamento,\nmais próximo.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          const PulseTile(
            'Professor responsável',
            'Não vinculado · exemplo visual',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 12),
          tile(
            20,
            'Ficha atribuída',
            'Superior A · demonstração',
            Icons.fitness_center,
          ),
          tile(
            33,
            'Minha evolução',
            'Acompanhe suas próprias referências',
            Icons.insights,
          ),
          const SizedBox(height: 16),
          const InfoNote(
            'Vínculos profissionais e mensagens não estão conectados nesta versão.',
          ),
        ],
      );
    }
    if (id == 51) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Chip(label: Text('Lunae Fit · perfil profissional futuro')),
          const SizedBox(height: 16),
          Text(
            'Acompanhe cada jornada.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          PulseSearch(
            label: 'Buscar aluno de exemplo',
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 20),
          for (final student in [
            'Aluno de exemplo A',
            'Aluno de exemplo B',
            'Aluno de exemplo C',
          ].where((s) => s.toLowerCase().contains(query.toLowerCase())))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PulseTile(
                student,
                'Dados fictícios · vínculo demonstrativo',
                icon: Icons.person_outline,
                onTap: () => go(50),
              ),
            ),
          const SizedBox(height: 16),
          PulseButton(
            'Montar ficha de exemplo',
            icon: Icons.add,
            onPressed: () => go(52),
          ),
          const SizedBox(height: 24),
          const InfoNote(
            'Prévia sem dados reais. A versão integrada exigirá vínculo autorizado para cada aluno.',
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Chip(label: Text('Lunae Fit · gestão futura')),
        const SizedBox(height: 16),
        Text(
          'Mais presença.\nMelhor acompanhamento.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 16),
        const Text('Novembro de 2026 · indicadores fictícios'),
        const SizedBox(height: 24),
        const AdaptiveGrid(
          children: [
            Metric('32', 'Alunos de exemplo', icon: Icons.people_outline),
            Metric(
              '4',
              'Fichas pendentes fictícias',
              icon: Icons.assignment_outlined,
            ),
            Metric('76%', 'Adesão ilustrativa · semana', icon: Icons.insights),
          ],
        ),
        const SizedBox(height: 24),
        tile(
          51,
          'Acompanhar alunos',
          'Lista de demonstração da equipe',
          Icons.people_outline,
        ),
        tile(
          52,
          'Criar ficha',
          'Planejamento visual do personal',
          Icons.fitness_center,
        ),
        const InfoNote(
          'Não há organização real, permissões ou indicadores operacionais conectados.',
        ),
      ],
    );
  }
}
