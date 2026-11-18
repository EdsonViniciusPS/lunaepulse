import 'package:flutter/material.dart';

import '../app/app.dart';
import '../core/store.dart';
import '../core/widgets.dart';

class AccessPage extends StatefulWidget {
  const AccessPage({super.key, required this.id});
  final int id;
  @override
  State<AccessPage> createState() => _AccessPageState();
}

class _AccessPageState extends State<AccessPage> {
  int page = 0;
  final Map<String, TextEditingController> controllers = {};
  final form = GlobalKey<FormState>();
  bool showPassword = false, accepted = false, busy = false;
  TextEditingController control(String label) => controllers.putIfAbsent(
    label,
    () => TextEditingController(
      text: PulseScope.of(context).drafts[widget.id]?[label] ?? '',
    ),
  );
  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget field(
    String label, {
    bool password = false,
    bool number = false,
    bool email = false,
    bool optional = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: control(label),
      obscureText: password && !showPassword,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : email
          ? TextInputType.emailAddress
          : TextInputType.text,
      autofillHints: password
          ? [AutofillHints.password]
          : email
          ? [AutofillHints.email]
          : null,
      onChanged: password || email
          ? null
          : (v) {
              PulseScope.of(context).drafts
                      .putIfAbsent(widget.id, () => {})[label] =
                  v;
            },
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: password
            ? IconButton(
                tooltip: showPassword ? 'Ocultar senha' : 'Exibir senha',
                onPressed: () => setState(() => showPassword = !showPassword),
                icon: Icon(
                  showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : null,
      ),
      validator: (v) {
        if (optional && (v ?? '').isEmpty) return null;
        if ((v ?? '').trim().isEmpty) return 'Preencha este campo.';
        if (email && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v!)) {
          return 'Digite um e-mail válido.';
        }
        if (password && v!.length < 8) return 'Use pelo menos 8 caracteres.';
        if (number && (double.tryParse(v!.replaceAll(',', '.')) ?? -1) <= 0) {
          return 'Informe um valor maior que zero.';
        }
        return null;
      },
    ),
  );
  void go(int id) => openScreen(context, id);
  Future<void> save() async {
    if (!(form.currentState?.validate() ?? true)) return;
    if (widget.id == 5 && !accepted) {
      feedback(
        context,
        'Leia e aceite os documentos da demonstração para continuar.',
      );
      return;
    }
    setState(() => busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final store = PulseScope.of(context);
    if (controllers.containsKey('Como quer ser chamado?')) {
      store.update(
        () => store.name = controllers['Como quer ser chamado?']!.text.trim(),
      );
    }
    // Passwords and e-mail are intentionally never copied to the demo store.
    if (widget.id == 6) {
      setState(() => busy = false);
      feedback(context, 'Demonstração: nenhum e-mail foi enviado.');
      return;
    }
    setState(() => busy = false);
    go(
      widget.id == 4
          ? 7
          : widget.id == 5
          ? 7
          : widget.id == 7
          ? 8
          : widget.id == 9
          ? 10
          : 11,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context), id = widget.id;
    if (id == 1) {
      return Column(
        children: [
          const SizedBox(height: 40),
          const Brand(large: true),
          const SizedBox(height: 32),
          Image.asset(
            'assets/Logo Lunae Pulse_ Lua Crescente e Pulso.png',
            height: 240,
            fit: BoxFit.contain,
            semanticLabel: 'Logo Lunae Pulse, lua crescente com pulso',
          ),
          const SizedBox(height: 24),
          const Text('Movimento, saúde e evolução.'),
          const SizedBox(height: 32),
          PulseButton('Abrir boas-vindas', onPressed: () => go(2)),
          const SizedBox(height: 12),
          const InfoNote(
            'Prévia da abertura. O aplicativo inicia no painel para facilitar a revisão.',
          ),
        ],
      );
    }
    if (id == 2 || id == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Brand(large: true),
          const SizedBox(height: 24),
          Center(
            child: Image.asset(
              'assets/Logo Lunae Pulse_ Lua Crescente e Pulso.png',
              height: 240,
              fit: BoxFit.contain,
              semanticLabel: 'Lunae Pulse',
            ),
          ),
          const SizedBox(height: 24),
          Text(
            id == 2
                ? 'Seu bem-estar.\nNo seu ritmo.'
                : [
                    'Treine com\nconsistência.',
                    'Alimente sua\nmelhor rotina.',
                    'Veja sua\nevolução.',
                  ][page],
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            id == 2
                ? 'Treinos, alimentação e pequenas conquistas. Tudo junto para acompanhar a jornada que é sua.'
                : [
                    'Organize seus treinos e registre cada série com tranquilidade.',
                    'Acompanhe refeições e hidratação, sem culpa e com informação.',
                    'Reconheça sua constância e acompanhe tendências ao longo do tempo.',
                  ][page],
          ),
          const SizedBox(height: 28),
          if (id == 3) ...[
            Row(
              children: List.generate(
                3,
                (i) => Container(
                  width: i == page ? 28 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: i == page
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          PulseButton(
            id == 2
                ? 'Começar'
                : page < 2
                ? 'Continuar'
                : 'Criar minha conta',
            onPressed: () {
              if (id == 3 && page < 2) {
                setState(() => page++);
              } else {
                go(id == 2 ? 3 : 5);
              }
            },
          ),
          const SizedBox(height: 12),
          PulseButton(
            id == 2 ? 'Já tenho conta' : 'Pular apresentação',
            secondary: true,
            onPressed: () => go(4),
          ),
        ],
      );
    }
    if (id == 8) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O que move você?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          const Text('Escolha até três objetivos. Você pode mudar depois.'),
          const SizedBox(height: 24),
          for (final goal in [
            'Melhorar condicionamento',
            'Ganhar força',
            'Desenvolver massa muscular',
            'Gerenciar peso',
            'Criar rotina',
            'Bem-estar geral',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: store.goals.contains(goal),
                title: Text(goal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tileColor: Theme.of(context).colorScheme.surface,
                onChanged: (v) => store.update(() {
                  if (v == true && store.goals.length < 3) {
                    store.goals.add(goal);
                  } else if (v == false) {
                    store.goals.remove(goal);
                  }
                }),
              ),
            ),
          const SizedBox(height: 24),
          PulseButton('Continuar', onPressed: () => go(9)),
        ],
      );
    }
    if (id == 11) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Você escolhe\no que conectar.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          const Text(
            'Permissões são opcionais. Use seus registros manuais a qualquer momento.',
          ),
          const SizedBox(height: 24),
          PulseTile(
            'Notificações',
            'Lembretes que respeitam sua rotina · não ativados',
            icon: Icons.notifications_none,
            onTap: () => feedback(
              context,
              'Prévia: nenhum acesso ao sistema foi solicitado.',
            ),
          ),
          const SizedBox(height: 12),
          PulseTile(
            'Saúde do dispositivo',
            'Passos, sono e atividade · não conectado',
            icon: Icons.favorite_border,
            onTap: () => go(42),
          ),
          const SizedBox(height: 32),
          PulseButton(
            'Fazer depois e explorar',
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      );
    }
    final headings = {
      4: 'Bom ter você de volta.',
      5: 'Sua jornada começa aqui.',
      6: 'Vamos recuperar seu acesso.',
      7: 'Vamos conhecer você.',
      9: 'Um treino que cabe no seu dia.',
      10: 'Alimentação do seu jeito.',
    };
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Brand(),
          const SizedBox(height: 32),
          Text(headings[id]!, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text(
            id <= 6
                ? 'Acesso de demonstração · nenhum dado será enviado.'
                : 'Etapa ${id - 6} de 5 · configure agora ou ajuste depois.',
          ),
          const SizedBox(height: 28),
          if (id == 5 || id == 7) field('Como quer ser chamado?'),
          if (id <= 6) field('E-mail', email: true),
          if (id == 4 || id == 5) field('Senha', password: true),
          if (id == 7) ...[
            field('Altura (cm) · opcional', number: true, optional: true),
            field('Peso (kg) · opcional', number: true, optional: true),
            const InfoNote(
              'Esses dados ajudam a contextualizar seus registros. Você pode deixar para depois.',
            ),
          ],
          if (id == 9) ...[
            const Section('Experiência'),
            _choices(['Iniciante', 'Intermediário', 'Avançado'], 'level'),
            const Section('Dias disponíveis'),
            _choices(
              ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
              'days',
              multi: true,
            ),
            const Section('Onde você treina?'),
            _choices(['Academia', 'Em casa', 'Ao ar livre'], 'place'),
            const SizedBox(height: 20),
            field('Duração por sessão (min)', number: true),
          ],
          if (id == 10) ...[
            const Section('Como quer acompanhar?'),
            _choices(['Apenas registrar', 'Definir minha meta'], 'nutrition'),
            const SizedBox(height: 20),
            field(
              'Meta pessoal (kcal) · opcional',
              number: true,
              optional: true,
            ),
            field('Preferências ou restrições · opcional', optional: true),
            const InfoNote(
              'Nenhuma meta calórica é calculada automaticamente nesta prévia.',
            ),
          ],
          if (id == 5)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              onChanged: (v) => setState(() => accepted = v ?? false),
              title: const Text('Li os avisos desta demonstração'),
              subtitle: const Text(
                'Termos e política definitivos serão adicionados ao produto.',
              ),
            ),
          const SizedBox(height: 24),
          PulseButton(
            busy
                ? 'Continuando…'
                : id == 4
                ? 'Entrar na demonstração'
                : id == 5
                ? 'Criar perfil de demonstração'
                : id == 6
                ? 'Simular envio de e-mail'
                : 'Salvar e continuar',
            onPressed: busy ? null : save,
          ),
          if (id == 4) ...[
            TextButton(
              onPressed: () => go(6),
              child: const Text('Esqueci minha senha'),
            ),
            TextButton(
              onPressed: () => go(5),
              child: const Text('Ainda não tenho conta'),
            ),
          ],
          if (id >= 7)
            TextButton(
              onPressed: () => go(
                id == 7
                    ? 8
                    : id == 9
                    ? 10
                    : 11,
              ),
              child: const Text('Configurar depois'),
            ),
        ],
      ),
    );
  }

  Widget _choices(List<String> values, String key, {bool multi = false}) =>
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values.map((v) {
          final s = PulseScope.of(context);
          final k = '$key:$v';
          return FilterChip(
            label: Text(v),
            selected: s.preferences[k] ?? false,
            onSelected: (selected) => s.update(() {
              if (!multi) {
                s.preferences.removeWhere((k, _) => k.startsWith('$key:'));
              }
              s.preferences[k] = selected;
            }),
          );
        }).toList(),
      );
}
