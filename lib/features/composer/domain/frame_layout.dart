/// Shared layout constants for on-screen preview and exported JPEG.
class FrameLayout {
  FrameLayout._();

  static const double portraitAspect = 2 / 3;

  static const int exportWidth = 1200;
  static const int exportHeight = 1800;

  /// White mat padding inside each cell (fraction of cell size).
  static const double cellPaddingRatio = 0.14;

  /// Outer white border around the whole frame (fraction of canvas).
  static const double outerPaddingRatio = 0.05;
}
