import 'package:flutter/material.dart';

class InputItem extends StatefulWidget {

  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool readOnly;

  const InputItem({super.key, required this.label, this.hint, required this.controller, this.readOnly=false});

  @override
  State<InputItem> createState() => _InputItemState();
}

class _InputItemState extends State<InputItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(widget.label)
        ),
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: OutlineInputBorder(),
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 5
              ),
            ),
            readOnly: widget.readOnly,
          )
        )
      ],
    );
  }
}