import 'package:flutter/material.dart';

class ScrollButton extends StatefulWidget {
  const ScrollButton({super.key, required this.icon, this.onPressed});

  final Icon icon;
  final void Function()? onPressed;

  @override
  State<ScrollButton> createState() => _ScrollButtonState();
}

class _ScrollButtonState extends State<ScrollButton> {
  static const Color _buttonColor = Colors.black12;
  static const Color _buttonColorHover = Colors.black38;

  Color _currentButtonColor = _buttonColor;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _currentButtonColor = _buttonColorHover;
      }),
      onExit: (_) => setState(() {
        _currentButtonColor = _buttonColor;
      }),
      child: Container(
        color: _currentButtonColor,
        child: IconButton(
          onPressed: widget.onPressed,
          icon: widget.icon,
        ),
      ),
    );
  }
}
