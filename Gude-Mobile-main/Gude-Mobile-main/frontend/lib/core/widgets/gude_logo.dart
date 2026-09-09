// lib/core/widgets/gude_logo.dart
//
// Shared Gude branding widgets.

import 'package:flutter/material.dart';

const _gudeLogoAsset = 'assets/images/gude_logo.jpg';

class GudeLogoMark extends StatelessWidget {
  final double size;

  const GudeLogoMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.12),
      child: Image.asset(
        _gudeLogoAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _FallbackMark(size: size),
      ),
    );
  }
}

class GudeLockup extends StatelessWidget {
  final double logoSize;
  final Color textColor;

  const GudeLockup({
    super.key,
    this.logoSize = 28,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(logoSize * 0.14),
      child: Image.asset(
        _gudeLogoAsset,
        width: logoSize * 2.25,
        height: logoSize,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _FallbackMark(
          size: logoSize,
          foregroundColor: textColor,
        ),
      ),
    );
  }
}

class _FallbackMark extends StatelessWidget {
  final double size;
  final Color foregroundColor;

  const _FallbackMark({
    required this.size,
    this.foregroundColor = Colors.white,
  });

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
            color: foregroundColor,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.55,
          ),
        ),
      ),
    );
  }
}
