import 'package:flutter/material.dart';

import 'package:pdf_toolkit/providers/app_state.dart';
import 'package:pdf_toolkit/utils/tool_meta.dart';

/// Big page-marker badge shown above a tool screen title.
///
/// Uses the same icon and colour as the corresponding home card
/// ([ToolMeta]), so every tool page keeps the visual identity of the tile
/// that opened it: Cupertino (SF-Symbol-like) icons and pastel/accent colours
/// on iOS, Material icons and pastel fills elsewhere.
class ToolPageBadge extends StatelessWidget {
  final ToolType tool;

  const ToolPageBadge({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    final meta = ToolMeta.of(tool);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color fill = isDark
        ? meta.color.withValues(alpha: 0.16)
        : Color.alphaBlend(meta.color.withValues(alpha: 0.18), Colors.white);
    final Color border = isDark
        ? meta.color.withValues(alpha: 0.85)
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.16), fill);
    final Color iconColor = isDark
        ? meta.color
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.32), meta.color);

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: isDark ? 1.4 : 1.2),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(4, 4),
                ),
              ],
      ),
      child: Icon(meta.icon, size: 44, color: iconColor),
    );
  }
}
