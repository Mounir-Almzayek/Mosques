import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'offset_stepper_button.dart';

/// A numeric counter for durations: minus / value / plus, with manual entry.
///
/// Unlike a bounded slider, the value can grow without an upper cap; it is only
/// clamped to [min]. Stepping moves by [step]. Used for publish durations
/// (album image, urgent alert) so the user has fine, unbounded control.
class DurationCounterField extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int step;
  final int min;
  final String? suffix;

  const DurationCounterField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 10,
    this.min = 5,
    this.suffix,
  });

  @override
  State<DurationCounterField> createState() => _DurationCounterFieldState();
}

class _DurationCounterFieldState extends State<DurationCounterField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant DurationCounterField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value.toString()) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _clamp(int v) => v < widget.min ? widget.min : v;

  void _increment() => widget.onChanged(_clamp(widget.value + widget.step));

  void _decrement() => widget.onChanged(_clamp(widget.value - widget.step));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            OffsetStepperButton(icon: Icons.remove, onPressed: _decrement),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixText: widget.suffix,
                    suffixStyle: theme.textTheme.bodySmall,
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) widget.onChanged(n);
                  },
                  onEditingComplete: () {
                    final n = int.tryParse(_controller.text) ?? widget.min;
                    final clamped = _clamp(n);
                    _controller.text = clamped.toString();
                    widget.onChanged(clamped);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            OffsetStepperButton(icon: Icons.add, onPressed: _increment),
          ],
        ),
      ],
    );
  }
}
