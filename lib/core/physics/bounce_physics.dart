import 'package:flutter/material.dart';

/// Global scroll physics adhering to iOS Human Interface Guidelines bounce mechanics.
class AuraBounceScrollPhysics extends BouncingScrollPhysics {
  const AuraBounceScrollPhysics({super.parent = const AlwaysScrollableScrollPhysics()});

  @override
  AuraBounceScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return AuraBounceScrollPhysics(parent: buildParent(ancestor));
  }
}

/// Spring simulation constants for tactile bounce widgets.
class AuraSpring {
  AuraSpring._();

  static const Duration tapDuration = Duration(milliseconds: 100);
  static const Duration releaseDuration = Duration(milliseconds: 250);
  static const Curve pressCurve = Curves.easeOutCubic;
  static const Curve releaseCurve = Curves.elasticOut;
  static const double cardScalePressed = 0.96;
  static const double buttonScalePressed = 0.93;
}
