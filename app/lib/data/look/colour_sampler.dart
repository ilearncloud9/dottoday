import 'package:dottoday/data/look/colour_sampler_channel.dart'
    if (dart.library.js_interop) 'package:dottoday/data/look/colour_sampler_web.dart';
import 'package:flutter/painting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'colour_sampler.g.dart';

/// Custom colour…'s eyedropper, the Mac's Show Colours… (ED-156, owner
/// 4c-3) and More colours… (owner, native pass): the Mac's own screen
/// sampler and Colours panel; iOS's system colour picker; the browser's
/// EyeDropper and colour input where it has them; nothing on Android,
/// which has no system colour picker.
abstract interface class ColourSampler {
  /// Whether the eyedropper is offered here.
  bool get canSample;

  /// Whether Show Colours… (the system Colours panel) is offered here.
  bool get hasPanel;

  /// A colour picked from the screen, or null when cancelled.
  Future<Color?> sample();

  /// Opens the system Colours panel at [start]; its picks are [onColour]
  /// until [closePanel].
  Future<void> openPanel(Color start, void Function(Color) onColour);

  Future<void> closePanel();

  /// Whether More colours… (the platform's own colour picker: iOS's, the
  /// browser's) is offered here.
  bool get hasSystemPicker;

  /// The colour picked in it, starting at [start]; null when unchanged or
  /// cancelled.
  Future<Color?> pickSystem(Color start);
}

/// The sampler for this platform (a fake in tests).
@Riverpod(keepAlive: true)
ColourSampler colourSampler(Ref ref) => platformColourSampler();
