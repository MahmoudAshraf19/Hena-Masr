import 'package:flutter/material.dart';

import 'package:hena_masr/core/theme/theme_context.dart';
import 'package:hena_masr/core/widgets/ankh_loader.dart';

/// Full-area centered loading state with Egyptian Ankh.
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
    this.size = 72,
    this.color,
  });

  final String? message;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnkhLoader(
            size: size,
            color: color,
            semanticLabel: message,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: context.text.bodyMedium
                  ?.copyWith(color: context.colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
