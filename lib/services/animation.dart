import 'package:flutter/material.dart';

class HandwrittenText extends StatefulWidget {
  final String text;
  final Duration duration;

  const HandwrittenText({
    Key? key,
    required this.text,
    this.duration = const Duration(milliseconds: 3000),
  }) : super(key: key);

  @override
  _HandwrittenTextState createState() => _HandwrittenTextState();
}

class _HandwrittenTextState extends State<HandwrittenText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Create an animation that goes from 0 to 1
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Set a fixed width for the text
      height: 100, // Set a fixed height for the text
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Color(0xffb25dcc), // Soft teal (primary color)
            Color(0xfff08486), // Soft blue (secondary color)
          ],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          tileMode: TileMode.clamp,
        ).createShader(bounds),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(400, 100), // Match the size of the SizedBox
              painter: TextDrawingPainter(
                text: widget.text,
                progress: _animation.value,
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'Hello Valentina',
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Use white for better contrast with the gradient
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TextDrawingPainter extends CustomPainter {
  final String text;
  final double progress;
  final TextStyle style;

  TextDrawingPainter({
    required this.text,
    required this.progress,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a text painter for measuring and painting text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Measure the full width of the text
    textPainter.text = TextSpan(text: text, style: style);
    textPainter.layout();

    // Calculate the width of the text drawn up to the progress point
    final fullTextWidth = textPainter.width;
    final drawWidth = fullTextWidth * progress;

    // Draw text progressively
    String visibleText = '';
    double currentWidth = 0.0;

    for (int i = 0; i < text.length; i++) {
      // Measure the width of each character
      textPainter.text = TextSpan(text: text[i], style: style);
      textPainter.layout();

      final charWidth = textPainter.width;

      if (currentWidth + charWidth > drawWidth) break;

      visibleText += text[i];
      currentWidth += charWidth;
    }

    // Paint only the visible part of the text
    textPainter.text = TextSpan(text: visibleText, style: style);
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(covariant TextDrawingPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.progress != progress ||
        oldDelegate.style != style;
  }
}
