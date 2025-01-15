import 'package:flutter/material.dart';

class RotatingIconWidget extends StatefulWidget {
  final VoidCallback onTap;
  final IconData? icon;

  const RotatingIconWidget(
      {Key? key, required this.onTap, this.icon = Icons.loop})
      : super(key: key);

  @override
  _RotatingIconWidgetState createState() => _RotatingIconWidgetState();
}

class _RotatingIconWidgetState extends State<RotatingIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.forward(from: 0.0).whenComplete(() {
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: width * 0.13,
        height: width * 0.13,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.5),
        ),
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * -2.0 * 3.141592653589793,
              child: child,
            );
          },
          child: Icon(
            widget.icon ?? Icons.loop,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
