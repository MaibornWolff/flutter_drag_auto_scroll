import 'package:flutter/material.dart';

class ScrollerSettings {
  ScrollerSettings({
    this.edgeThreshold = 80.0,
    this.maxScrollSpeed = 20.0,
    this.showEdgeZones = true,
  });

  double edgeThreshold;
  double maxScrollSpeed;
  bool showEdgeZones;
}

class ScrollerControls extends StatelessWidget {
  const ScrollerControls({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final ScrollerSettings settings;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SliderRow(
            label: 'Edge threshold',
            value: settings.edgeThreshold,
            min: 20,
            max: 200,
            unit: 'px',
            onChanged: (v) {
              settings.edgeThreshold = v;
              onChanged();
            },
          ),
          _SliderRow(
            label: 'Max scroll speed',
            value: settings.maxScrollSpeed,
            min: 1,
            max: 60,
            unit: 'px/frame',
            onChanged: (v) {
              settings.maxScrollSpeed = v;
              onChanged();
            },
          ),
          Row(
            children: [
              Text('Show edge zones', style: theme.textTheme.bodySmall),
              const Spacer(),
              Switch(
                value: settings.showEdgeZones,
                onChanged: (v) {
                  settings.showEdgeZones = v;
                  onChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            '${value.round()} $unit',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
