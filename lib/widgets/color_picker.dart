import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerField extends StatelessWidget {
  final String label;
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerField({
    super.key,
    required this.label,
    required this.selectedColor,
    required this.onColorChanged,
  });

  void _openColorPicker(BuildContext context) {
    Color tempColor = selectedColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) => tempColor = color,
            enableAlpha: false,
            labelTypes: const [ColorLabelType.hex, ColorLabelType.rgb],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onColorChanged(tempColor);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openColorPicker(context),
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
            ),
            suffixIcon: const Icon(Icons.colorize),
          ),
          controller: TextEditingController(
            text: '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
          ),
        ),
      ),
    );
  }
}