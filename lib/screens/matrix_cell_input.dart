import 'package:flutter/material.dart';

class MatrixCellInput extends StatefulWidget {
  final double value;
  final Function(double) onChanged;

  const MatrixCellInput({required this.value, required this.onChanged});

  @override
  State<MatrixCellInput> createState() => _MatrixCellInputState();
}

class _MatrixCellInputState extends State<MatrixCellInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // If value is 0.0, show empty
    String text = widget.value == 0.0 ? "" : widget.value.toString();
    _controller = TextEditingController(text: text);
  }

  @override
  void didUpdateWidget(covariant MatrixCellInput oldWidget) {
     super.didUpdateWidget(oldWidget);
     // Only update from model if logic requires sync, but here local edit is priority.
     // However, if we reset, we need to clear. Use a focus check? 
     // For simplicity: if model value is 0.0 and text is not empty and not focused... 
     // Actually, if model changes independently (e.g. resize), we might need to update.
     // But typically user updates it.
     if (widget.value != oldWidget.value) {
        if (widget.value == 0.0 && _controller.text.isNotEmpty && double.tryParse(_controller.text) != 0.0) {
             // Reset scenario
             _controller.text = "";
        }
     }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(12),
        fillColor: isDark ? const Color(0xFF11161B) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      onChanged: (value) {
        final val = double.tryParse(value) ?? 0.0;
        widget.onChanged(val);
      },
    );
  }
}
