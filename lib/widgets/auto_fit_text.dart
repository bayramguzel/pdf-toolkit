import 'package:flutter/material.dart';

/// Text that shrinks its font size just enough to fit the available width and
/// [maxLines]. This keeps card titles inside their cards for every language
/// (German labels are noticeably longer than the English ones) without
/// clipping or awkward mid-word ellipses.
class AutoFitText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final TextAlign textAlign;
  final double minFontSize;
  final TextOverflow overflow;

  const AutoFitText(
    this.text, {
    super.key,
    required this.style,
    this.maxLines = 2,
    this.textAlign = TextAlign.start,
    this.minFontSize = 9,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    final double maxFontSize = style.fontSize ?? 14;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        double fontSize = maxFontSize;

        if (maxWidth.isFinite && maxWidth > 0 && text.isNotEmpty) {
          while (fontSize > minFontSize) {
            final painter = TextPainter(
              text: TextSpan(
                text: text,
                style: style.copyWith(fontSize: fontSize),
              ),
              maxLines: maxLines,
              textAlign: textAlign,
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout(maxWidth: maxWidth);
            final bool fits = !painter.didExceedMaxLines;
            painter.dispose();
            if (fits) break;
            fontSize -= 0.5;
          }
        }

        return Text(
          text,
          style: style.copyWith(fontSize: fontSize),
          maxLines: maxLines,
          textAlign: textAlign,
          overflow: overflow,
        );
      },
    );
  }
}
