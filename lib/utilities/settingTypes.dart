
// a class that contains various static lists used in the various effects
// and settings that can be applied to the output.
class settingTypes {

  // a static list of available dithering options.
  static const List<String> ditheringTypes = [
    "(None)",
    "Floyd-Steinberg",
    "Ja-Ju-Ni",
    "Stucki",
    "Sierra-3",
    "Sierra-2",
    "Sierra Lite",
  ];

  // a static list of surface type options.
  static const List<String> surfaceTypeChoices = [
    "Square (178x178)",
    "Wide (356x178)",
    "Large 5x3 (178x107)",
    "Large Corner (178x27)",
    "Small Corner (178x47)",
    "Cockpit \"16:9\" (178x127)",
    "(Custom)",
    "(None)",
  ];

  // a list of integers that contains the resolution in
  // int format, corresponding to [surfaceTypeChoices]
  static List<Pair> surfaceTypeResolutions = [
    Pair(178, 178),
    Pair(356, 178),
    Pair(178, 107),
    Pair(178, 27),
    Pair(178, 47),
    Pair(178, 127),
    Pair(-1, -1),
    Pair(0, 0),
  ];

}

// simple class to contain two values
// probably should be moved out to a different file.
class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}