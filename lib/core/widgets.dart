import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';

void feedback(BuildContext context, String message, {VoidCallback? undo}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: undo == null
            ? null
            : SnackBarAction(label: 'Desfazer', onPressed: undo),
      ),
    );
}

class PulseCard extends StatelessWidget {
  const PulseCard({super.key, required this.child, this.hero = false});
  final Widget child;
  final bool hero;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: hero ? PulseColors.gradient : null,
      color: hero ? null : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(hero ? 24 : 20),
      border: hero
          ? null
          : Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: hero
        ? Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme
                  .apply(bodyColor: Colors.white, displayColor: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            child: child,
          )
        : child,
  );
}

class PulseButton extends StatelessWidget {
  const PulseButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.secondary = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool secondary;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: secondary
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label),
          ),
  );
}

class Section extends StatelessWidget {
  const Section(this.title, {super.key, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
      ],
    ),
  );
}

class PulseTile extends StatelessWidget {
  const PulseTile(
    this.title,
    this.subtitle, {
    super.key,
    this.icon = Icons.chevron_right_rounded,
    this.onTap,
    this.trailing,
  });
  final String title, subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing:
          trailing ??
          (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
      onTap: onTap,
    ),
  );
}

class Metric extends StatelessWidget {
  const Metric(
    this.value,
    this.label, {
    super.key,
    this.icon = Icons.insights_rounded,
  });
  final String value, label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => PulseCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cols = constraints.maxWidth > 650
          ? 3
          : constraints.maxWidth < 340 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.4
          ? 1
          : 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children
            .map(
              (child) => SizedBox(
                width: (constraints.maxWidth - 12 * (cols - 1)) / cols,
                child: child,
              ),
            )
            .toList(),
      );
    },
  );
}

class PulseRing extends StatelessWidget {
  const PulseRing({
    super.key,
    required this.progress,
    required this.value,
    required this.label,
    this.light = false,
  });
  final double progress;
  final String value, label;
  final bool light;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    child: SizedBox(
      width: 160 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.5),
      height: 160 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width:
                150 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.5),
            height:
                150 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.5),
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 9,
              strokeCap: StrokeCap.round,
              backgroundColor: light
                  ? Colors.white.withValues(alpha: .15)
                  : Theme.of(context).colorScheme.outlineVariant,
              color: light
                  ? PulseColors.aqua
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    ),
  );
}

class PulseChart extends StatelessWidget {
  const PulseChart({super.key, required this.values, required this.label});
  final List<double> values;
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label. Valores: ${values.join(', ')}',
    child: SizedBox(
      height: 160,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(
          values,
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    ),
  );
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.values, this.color, this.grid);
  final List<double> values;
  final Color color, grid;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = 12 + (size.height - 24) * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    if (values.length < 2) return;
    final low = values.reduce(math.min) - .3,
        high = values.reduce(math.max) + .3;
    final points = List.generate(
      values.length,
      (i) => Offset(
        8 + (size.width - 16) * i / (values.length - 1),
        size.height -
            16 -
            (values[i] - low) / (high - low) * (size.height - 32),
      ),
    );
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final mid = (points[i - 1].dx + points[i].dx) / 2;
      line.cubicTo(
        mid,
        points[i - 1].dy,
        mid,
        points[i].dy,
        points[i].dx,
        points[i].dy,
      );
    }
    final area = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: .18), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.values != values || old.color != color;
}

class Brand extends StatelessWidget {
  const Brand({super.key, this.large = false});
  final bool large;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.nightlight_round,
        color: Theme.of(context).colorScheme.primary,
        size: large ? 38 : 26,
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Lunae',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: ' Pulse',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          style: TextStyle(fontSize: large ? 28 : 20, letterSpacing: -.8),
        ),
      ),
    ],
  );
}

class InfoNote extends StatelessWidget {
  const InfoNote(
    this.text, {
    super.key,
    this.icon = Icons.info_outline_rounded,
  });
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    ],
  );
}

class PulseSearch extends StatefulWidget {
  const PulseSearch({super.key, required this.label, required this.onChanged});
  final String label;
  final ValueChanged<String> onChanged;
  @override
  State<PulseSearch> createState() => _PulseSearchState();
}

class _PulseSearchState extends State<PulseSearch> {
  final controller = TextEditingController();
  final focus = FocusNode();
  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focus,
    onChanged: (v) {
      setState(() {});
      widget.onChanged(v);
    },
    decoration: InputDecoration(
      labelText: widget.label,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Limpar busca',
              onPressed: () {
                controller.clear();
                setState(() {});
                widget.onChanged('');
                focus.requestFocus();
              },
              icon: const Icon(Icons.close_rounded),
            ),
    ),
  );
}

enum ViewStatus { content, loading, empty, error, offline, syncing }

class StatePreview extends StatelessWidget {
  const StatePreview({
    super.key,
    required this.status,
    required this.retry,
    required this.child,
  });
  final ViewStatus status;
  final VoidCallback retry;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (status == ViewStatus.loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando demonstração…'),
          ],
        ),
      );
    }
    if (status == ViewStatus.empty || status == ViewStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status == ViewStatus.empty
                    ? Icons.spa_outlined
                    : Icons.cloud_off_rounded,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                status == ViewStatus.empty
                    ? 'Seu próximo passo começa aqui'
                    : 'Não foi possível carregar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                status == ViewStatus.empty
                    ? 'Adicione seu primeiro registro para acompanhar sua rotina.'
                    : 'Seus registros desta sessão continuam disponíveis.',
              ),
              const SizedBox(height: 24),
              PulseButton(
                status == ViewStatus.empty
                    ? 'Explorar demonstração'
                    : 'Tentar novamente',
                onPressed: retry,
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        if (status == ViewStatus.offline || status == ViewStatus.syncing)
          MaterialBanner(
            content: Text(
              status == ViewStatus.offline
                  ? 'Modo offline · dados de demonstração'
                  : 'Simulando sincronização · sem conexão real',
            ),
            leading: Icon(
              status == ViewStatus.offline ? Icons.cloud_off : Icons.sync,
            ),
            actions: [
              TextButton(onPressed: retry, child: const Text('Voltar')),
            ],
          ),
        Expanded(child: child),
      ],
    );
  }
}
