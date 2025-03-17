import 'package:flutter/material.dart';
import 'package:nlp_flutter/Utilities/constants.dart';

class ThreeDotsLoadingIndicator extends StatefulWidget {
  const ThreeDotsLoadingIndicator({super.key});

  @override
  State<ThreeDotsLoadingIndicator> createState() =>
      _ThreeDotsLoadingIndicatorState();
}

class _ThreeDotsLoadingIndicatorState extends State<ThreeDotsLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _dot3Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Staggered animation for each dot
    _dot1Animation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          0.5,
          curve: Curves.easeInOut,
        ), // Starts immediately
      ),
    );

    _dot2Animation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.7, curve: Curves.easeInOut),
      ),
    );

    _dot3Animation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _dot1Animation.value),
              child: const _Dot(),
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _dot2Animation.value),
              child: const _Dot(),
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _dot3Animation.value),
              child: const _Dot(),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.text, // Customize this to match your theme
        shape: BoxShape.circle,
      ),
    );
  }
}
