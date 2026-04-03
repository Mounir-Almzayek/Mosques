import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OffsetStepperField extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final String? suffix;

  const OffsetStepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.suffix,
  });

  @override
  State<OffsetStepperField> createState() => _OffsetStepperFieldState();
}

class _OffsetStepperFieldState extends State<OffsetStepperField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant OffsetStepperField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // Only update if the text is actually different to avoid cursor jumps
      if (_controller.text != widget.value.toString()) {
        _controller.text = widget.value.toString();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    widget.onChanged(widget.value + 1);
  }

  void _decrement() {
    widget.onChanged(widget.value - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                onPressed: _decrement,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: false,
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                    ],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixText: widget.suffix,
                      suffixStyle: theme.textTheme.bodySmall,
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        widget.onChanged(n);
                      } else if (v == '-') {
                        // Allow typing just the minus sign
                      } else if (v.isEmpty) {
                        widget.onChanged(0);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StepperButton(
                icon: Icons.add,
                onPressed: _increment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
