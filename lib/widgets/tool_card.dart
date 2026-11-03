import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;
  final double? width;
  final double? height;

  const ToolCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.color,
    required this.onTap,
    this.disabled = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<SettingsProvider>(context).primaryColor;
    final double cardWidth = width ?? 150.0;
    final double cardHeight = height ?? 160.0;
    // Scale icon and font proportionally to card size
    final double iconSize = (cardWidth * 0.30).clamp(32.0, 56.0);
    final double titleFontSize = (cardWidth * 0.096).clamp(11.0, 16.0);
    final double descFontSize = (cardWidth * 0.068).clamp(9.0, 12.0);
    // Use the same colored pastel card fill in both light and dark mode
    final Color cardFill = disabled ? Colors.grey[700]! : color;
    final Color borderColor = disabled ? Colors.grey.shade500 : themeColor;
    final bool useDarkText = color.computeLuminance() > 0.6;

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: cardFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1.6,
          ),
          boxShadow: [
            // subtle highlight (top-left)
            BoxShadow(
              color: (disabled
                  ? Colors.black26
                  : themeColor.withAlpha((0.08 * 255).round())),
              offset: const Offset(-6, -6),
              blurRadius: 12,
            ),
            // main drop shadow (bottom-right)
            BoxShadow(
              color: Colors.black.withAlpha((0.18 * 255).round()),
              blurRadius: 18,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all((cardWidth * 0.10).clamp(10.0, 18.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: disabled
                    ? Colors.white54
                    : (useDarkText ? Colors.black87 : Colors.white),
              ),
              SizedBox(height: (cardHeight * 0.07).clamp(6.0, 14.0)),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: disabled
                      ? Colors.white
                      : (useDarkText ? Colors.black87 : Colors.white),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (description != null) ...[
                SizedBox(height: (cardHeight * 0.025).clamp(3.0, 6.0)),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: descFontSize,
                    color: disabled
                        ? Colors.grey[400]
                        : (useDarkText ? Colors.black54 : Colors.white70),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
