import 'dart:math' as math;
import 'package:flutter/material.dart';

Future<Color?> showCustomColorPickerDialog({
  required BuildContext context,
  required Color initialColor,
}) {
  return showDialog<Color>(
    context: context,
    builder: (_) => _CustomColorPickerDialog(initialColor: initialColor),
  );
}

class _CustomColorPickerDialog extends StatefulWidget {
  const _CustomColorPickerDialog({
    required this.initialColor,
  });

  final Color initialColor;

  @override
  State<_CustomColorPickerDialog> createState() =>
      _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<_CustomColorPickerDialog> {
  late HSVColor _hsvColor;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
    _hexController = TextEditingController(
      text: _toHex(widget.initialColor),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor => _hsvColor.toColor();

  void _syncHex() {
    _hexController.text = _toHex(_currentColor);
  }

  String _toHex(Color color) {
    return color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
  }

  Color? _parseHex(String input) {
    final clean = input.replaceAll('#', '').trim();
    if (clean.length != 6) return null;
    final value = int.tryParse(clean, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Color'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: _currentColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _hexController,
                decoration: const InputDecoration(
                  labelText: 'HEX (#RRGGBB)',
                  hintText: '#7C3AED',
                ),
                onChanged: (value) {
                  final parsed = _parseHex(value);
                  if (parsed == null) return;
                  setState(() {
                    _hsvColor = HSVColor.fromColor(parsed);
                  });
                },
              ),
              const SizedBox(height: 16),
              _SliderBlock(
                label: 'Hue',
                value: _hsvColor.hue,
                max: 360,
                onChanged: (value) {
                  setState(() {
                    _hsvColor = _hsvColor.withHue(value);
                    _syncHex();
                  });
                },
              ),
              _SliderBlock(
                label: 'Saturation',
                value: _hsvColor.saturation,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    _hsvColor = _hsvColor.withSaturation(value);
                    _syncHex();
                  });
                },
              ),
              _SliderBlock(
                label: 'Value',
                value: _hsvColor.value,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    _hsvColor = _hsvColor.withValue(value);
                    _syncHex();
                  });
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final color in [
                    const Color(0xFFEF4444),
                    const Color(0xFFF97316),
                    const Color(0xFFF59E0B),
                    const Color(0xFFEAB308),
                    const Color(0xFF22C55E),
                    const Color(0xFF10B981),
                    const Color(0xFF06B6D4),
                    const Color(0xFF3B82F6),
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                    const Color(0xFFEC4899),
                    const Color(0xFF14B8A6),
                  ])
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _hsvColor = HSVColor.fromColor(color);
                          _syncHex();
                        });
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _currentColor),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _SliderBlock extends StatelessWidget {
  const _SliderBlock({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayValue = max == 1 ? (value * 100).round() : value.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label  $displayValue'),
        Slider(
          value: value.clamp(0, max),
          min: 0,
          max: math.max(max, 0.0001),
          onChanged: onChanged,
        ),
      ],
    );
  }
}