import 'package:flutter/material.dart';

class R {
  static late MediaQueryData _mq;
  static late double width;
  static late double height;
  static late double _base;

  static void init(BuildContext context) {
    _mq   = MediaQuery.of(context);
    width  = _mq.size.width;
    height = _mq.size.height;
    _base  = width / 375; // baseline: iPhone 14 width
  }

  // Scale a size relative to screen width
  static double w(double v)  => v * _base;

  // Scale font sizes
  static double sp(double v) => (v * _base).clamp(v * 0.85, v * 1.15);

  // Vertical spacing relative to height
  static double h(double v)  => v * (height / 812);

  // Padding shortcut
  static EdgeInsets pad({double h = 16, double v = 16}) =>
      EdgeInsets.symmetric(horizontal: w(h), vertical: R.h(v));

  // Device type helpers
  static bool get isSmall  => width < 360;
  static bool get isMedium => width >= 360 && width < 414;
  static bool get isLarge  => width >= 414;

  // Safe area
  static double get topPad    => _mq.padding.top;
  static double get bottomPad => _mq.padding.bottom;
}
