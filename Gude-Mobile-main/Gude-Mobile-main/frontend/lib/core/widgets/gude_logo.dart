// lib/core/widgets/gude_logo.dart
//
// Shared Gude branding widgets.
// The logo mark uses the current brand asset at assets/images/gude_logo.png.
// Wherever that asset is unavailable (e.g. tests) it gracefully falls back
// to the text-based "G" mark.

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// GUDE LOGO MARK  — square icon (asset-first, text fallback)
// ─────────────────────────────────────────────────────────────
class GudeLogoMark extends StatelessWidget {
  final double size;
  const GudeLogoMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/gude_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _FallbackMark(size: size),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GUDE LOCKUP  — horizontal logo mark + "GUDE" wordmark
// ─────────────────────────────────────────────────────────────
class GudeLockup extends StatelessWidget {
  final double logoSize;
  final Color textColor;

  const GudeLockup({
    super.key,
    this.logoSize = 28,
    this.textColor = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GudeLogoMark(size: logoSize),
        const SizedBox(width: 7),
        Text(
          'GUDE',
          style: TextStyle(
            fontSize: logoSize * 0.65,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FALLBACK MARK  — shown when asset can't load
// ─────────────────────────────────────────────────────────────
class _FallbackMark extends StatelessWidget {
  final double size;
  const _FallbackMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE30613),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.55,
          ),
        ),
      ),
    );
  }
}
