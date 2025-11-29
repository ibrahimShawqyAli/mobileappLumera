import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomThreeStepSlider extends StatefulWidget {
  final ValueChanged<int>? onChanged; // 👈 New callback

  const CustomThreeStepSlider({super.key, this.onChanged});

  @override
  _CustomThreeStepSliderState createState() => _CustomThreeStepSliderState();
}

class _CustomThreeStepSliderState extends State<CustomThreeStepSlider> {
  double _currentValue = 1;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        activeTrackColor: Colors.transparent,
        inactiveTrackColor: Colors.grey.shade300,
        thumbShape: _CustomThumbWithImage(),
        overlayShape: SliderComponentShape.noOverlay,
        trackShape: _GradientTrackShape(),
      ),
      child: Slider(
        min: 0,
        max: 2,
        divisions: 2, // 🧠 3 values: 0, 1, 2
        value: _currentValue,
        onChanged: (value) {
          setState(() {
            _currentValue = value;
            widget.onChanged?.call(value.toInt()); // 👈 trigger callback
          });
        },
      ),
    );
  }
}

// 👇 Custom thumb shape (e.g. lightbulb)
class _CustomThumbWithImage extends SliderComponentShape {
  late ui.Image? _image;
  bool _imageLoaded = false;

  _CustomThumbWithImage() {
    _loadImage('assets/images/lighting.png');
  }

  void _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    _image = frame.image;
    _imageLoaded = true;
  }

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(36, 36);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Gradient circle background
    final Paint paint =
        Paint()
          ..shader = LinearGradient(
            colors: [Color(0xFFDA22FF), Color(0xFFFF8A00)],
          ).createShader(Rect.fromCircle(center: center, radius: 18));

    canvas.drawCircle(center, 18, paint);

    // Draw the image (if loaded)
    if (_imageLoaded && _image != null) {
      final double imageSize = 20;
      final Offset imageOffset = center - Offset(imageSize / 2, imageSize / 2);
      paintImage(
        canvas: canvas,
        image: _image!,
        rect: Rect.fromLTWH(
          imageOffset.dx,
          imageOffset.dy,
          imageSize,
          imageSize,
        ),
        fit: BoxFit.contain,
      );
    }
  }
}

class _GradientTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft =
        offset.dx +
        sliderTheme.overlayShape!.getPreferredSize(true, true).width / 2;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth =
        parentBox.size.width -
        sliderTheme.overlayShape!.getPreferredSize(true, true).width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    required RenderBox parentBox,
    Offset? secondaryOffset,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required Offset thumbCenter,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint activePaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Color(0xFFFF8A00), Color(0xFFDA22FF)],
          ).createShader(
            Rect.fromLTRB(
              trackRect.left,
              trackRect.top,
              thumbCenter.dx,
              trackRect.bottom,
            ),
          );

    final Paint inactivePaint = Paint()..color = Colors.grey.shade300;

    // Draw active track (left of thumb)
    context.canvas.drawRRect(
      RRect.fromLTRBR(
        trackRect.left,
        trackRect.top,
        thumbCenter.dx,
        trackRect.bottom,
        Radius.circular(2),
      ),
      activePaint,
    );

    // Draw inactive track (right of thumb)
    context.canvas.drawRRect(
      RRect.fromLTRBR(
        thumbCenter.dx,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
        Radius.circular(2),
      ),
      inactivePaint,
    );
  }
}
