import 'dart:io';

import 'package:flutter/material.dart';

class AnimatedListTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onDelete;

  const AnimatedListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onDelete,
  }) : super(key: key);

  @override
  _AnimatedListTileState createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<AnimatedListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Define the fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListTile(
        title: Text(widget.title),
        subtitle: Text(widget.subtitle),
        leading: CircleAvatar(
          backgroundImage: FileImage(File(widget.imagePath)),
        ),
        trailing: IconButton(
          onPressed: widget.onDelete,
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
