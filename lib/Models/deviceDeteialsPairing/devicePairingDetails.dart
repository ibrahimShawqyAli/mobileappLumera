class ParsedUnit {
  final bool hasIR;
  final bool hasRGB;
  final List<int> pins;
  const ParsedUnit({
    required this.hasIR,
    required this.hasRGB,
    required this.pins,
  });
}

ParsedUnit parseUnitId(String unitId) {
  // Expect: PREFIX:BODY/SHORTID  e.g. LM:I-R-21-19/3FDLG
  final colon = unitId.indexOf(':');
  final slash = unitId.lastIndexOf('/');
  final body =
      (colon >= 0 && slash > colon)
          ? unitId.substring(colon + 1, slash)
          : (colon >= 0 ? unitId.substring(colon + 1) : unitId);

  final tokens = body.split('-').where((t) => t.isNotEmpty).toList();

  bool hasIR = false, hasRGB = false;
  final pins = <int>[];

  for (final t in tokens) {
    final up = t.toUpperCase();
    if (up == 'I')
      hasIR = true;
    else if (up == 'R')
      hasRGB = true;
    else {
      final n = int.tryParse(t);
      if (n != null) pins.add(n);
    }
  }
  return ParsedUnit(hasIR: hasIR, hasRGB: hasRGB, pins: pins);
}
