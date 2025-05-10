import 'package:notte_chat/features/chat/presentation/provider/chat_provider.dart';
import 'package:flutter/material.dart';

import 'package:notte_chat/shared/style/color.dart';
import 'package:notte_chat/features/settings/presentation/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  _ThemeToggleButtonState createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SettingsProvider>();
    return IconButton(
      icon: AnimatedBuilder(
        animation: _animation,
        builder:
            (context, child) => Icon(
              provider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              // color: Colors.white.withOpacity(0.5 + 0.5 * _animation.value),
            ),
      ),
      onPressed: () {
        if (_controller.isAnimating) return;
        provider.toggleTheme();
        if (provider.isDarkMode) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      tooltip: 'Toggle Theme',
    );
  }
}
