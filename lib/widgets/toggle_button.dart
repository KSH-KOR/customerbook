import 'package:flutter/material.dart';

class MyToggleButton extends StatefulWidget {
  const MyToggleButton({super.key, required this.buttonOptions});

  final List<Widget> buttonOptions;

  @override
  State<MyToggleButton> createState() => _MyToggleButtonState();
}

class _MyToggleButtonState extends State<MyToggleButton> {
  @override
  Widget build(BuildContext context) {
    final List<bool> selectedOptions = widget.buttonOptions.map((e) => false,).toList();
    return ToggleButtons(
                direction: Axis.horizontal,
                onPressed: (int index) {
                  for (int i = 0; i < selectedOptions.length; i++) {
                      selectedOptions[i] = i == index;
                    }
                    
                  setState(() {
                    
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.red[700],
                selectedColor: Colors.white,
                fillColor: Colors.red[200],
                color: Colors.red[400],
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: selectedOptions,
                children: widget.buttonOptions,
              );
  }
}