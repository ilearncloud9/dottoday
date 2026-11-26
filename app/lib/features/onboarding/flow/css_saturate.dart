/// CSS `saturate(s)` as a colour matrix, for the prototype's blurs (the
/// card's backdrop, the nudge's glass).
List<double> cssSaturate(double s) {
  const r = 0.213, g = 0.715, b = 0.072;
  return [
    r + (1 - r) * s, g - g * s, b - b * s, 0, 0, //
    r - r * s, g + (1 - g) * s, b - b * s, 0, 0, //
    r - r * s, g - g * s, b + (1 - b) * s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}
