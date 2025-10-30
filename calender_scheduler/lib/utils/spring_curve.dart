import 'dart:math';
import 'package:flutter/animation.dart';

/// Apple의 스프링 애니메이션과 유사한 커스텀 커브
/// 자연스러운 유기적인 움직임을 제공합니다
class SpringCurve extends Curve {
  /// 스프링 강성 (stiffness) - 값이 클수록 빠르게 반응
  final double stiffness;

  /// 감쇠 (damping) - 값이 클수록 빠르게 안정화
  final double damping;

  /// 질량 (mass) - 값이 클수록 느리게 움직임
  final double mass;

  const SpringCurve({
    this.stiffness = 300.0,
    this.damping = 30.0,
    this.mass = 1.0,
  });

  @override
  double transform(double t) {
    // 스프링 물리 시뮬레이션
    final double w = sqrt(stiffness / mass);
    final double zeta = damping / (2 * sqrt(stiffness * mass));

    if (zeta < 1) {
      // Under-damped (약간의 오버슈트 있음)
      final double wd = w * sqrt(1 - zeta * zeta);
      final double A = 1.0;
      final double B = (zeta * w) / wd;
      return 1 - (exp(-zeta * w * t) * (A * cos(wd * t) + B * sin(wd * t)));
    } else {
      // Over-damped 또는 critically damped (오버슈트 없음)
      return 1 - exp(-w * t) * (1 + w * t);
    }
  }
}

/// Apple의 기본 스프링 애니메이션과 유사한 프리셋
class AppleSpringCurves {
  /// 부드러운 기본 스프링 (오버슈트 없음)
  static const Curve smooth = SpringCurve(
    stiffness: 300.0,
    damping: 30.0,
    mass: 1.0,
  );

  /// 약간 튀는 스프링 (미세한 오버슈트)
  static const Curve bouncy = SpringCurve(
    stiffness: 400.0,
    damping: 25.0,
    mass: 1.0,
  );

  /// 빠른 반응 스프링
  static const Curve snappy = SpringCurve(
    stiffness: 500.0,
    damping: 35.0,
    mass: 0.8,
  );

  /// 느리고 부드러운 스프링
  static const Curve gentle = SpringCurve(
    stiffness: 200.0,
    damping: 28.0,
    mass: 1.2,
  );
}
