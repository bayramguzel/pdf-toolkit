import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'auto_fit_text.dart';

/// Pastel tool card used on Android and the web home screen.
///
/// Light mode: filled with the pastel colour supplied by the caller.
/// Dark mode: nearly black surface with the same pastel colour as its border,
/// so the grid stays readable without glowing card fills.
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double cardWidth = width ?? 150.0;
    final double cardHeight = height ?? 160.0;
    // Scale icon and font proportionally to card size
    final double iconSize = (cardWidth * 0.26).clamp(28.0, 48.0);
    final double titleFontSize = (cardWidth * 0.098).clamp(12.0, 16.0);
    final double descFontSize = (cardWidth * 0.074).clamp(9.5, 12.0);

    // Dark mode: black card with a pastel border. Light mode: pastel card.
    final Color cardFill = disabled
        ? (isDark ? const Color(0xFF17181C) : Colors.grey[300]!)
        : (isDark ? const Color(0xFF111318) : color);
    final Color effectiveBorder = disabled
        ? Colors.grey.shade500
        : (isDark
            ? color.withValues(alpha: 0.85)
            : Color.alphaBlend(Colors.black.withValues(alpha: 0.20), color));
    final Color titleColor = disabled
        ? (isDark ? Colors.white54 : Colors.black45)
        : (isDark ? Colors.white : Colors.black87);
    final Color descColor = disabled
        ? (isDark ? Colors.white38 : Colors.black38)
        : (isDark ? Colors.white70 : Colors.black54);
    final Color iconColor = disabled
        ? Colors.grey
        : (isDark
            ? color
            : Color.alphaBlend(Colors.black.withValues(alpha: 0.35), color));

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
            color: effectiveBorder,
            width: isDark ? 1.4 : 1.6,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: (disabled
                        ? Colors.black26
                        : themeColor.withValues(alpha: 0.08)),
                    offset: const Offset(-6, -6),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
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
              Container(
                padding: EdgeInsets.all(iconSize * 0.22),
                decoration: BoxDecoration(
                  color: isDark
                      ? color.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
              SizedBox(height: (cardHeight * 0.06).clamp(5.0, 12.0)),
              Flexible(
                flex: 3,
                child: AutoFitText(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: titleColor,
                  ),
                  maxLines: 2,
                  minFontSize: 9.5,
                  textAlign: TextAlign.center,
                ),
              ),
              if (description != null) ...[
                SizedBox(height: (cardHeight * 0.02).clamp(2.0, 6.0)),
                Flexible(
                  flex: 2,
                  child: AutoFitText(
                    description!,
                    style: TextStyle(
                      fontSize: descFontSize,
                      height: 1.15,
                      color: descColor,
                    ),
                    maxLines: 2,
                    minFontSize: 8.5,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
