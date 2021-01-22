
class BitmapDitheringKernels {

/*
    Dithering kernels found from:
    https://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering
    http://www.tannerhelland.com/4660/dithering-eleven-algorithms-source-code/
    http://www.efg2.com/Lab/Library/ImageProcessing/DHALF.TXT

    Links to said kernels found in:
    https://github.com/Whiplash141/Whips-Image-Converter/blob/develop/WhipsImageConverter/MainForm.cs
    (lines 23-26)
  */

  static const List<List<int>> floydSteinbergKernel =
  [
    [16],
    [-1, 0, 7],
    [ 3, 5, 1],
  ];

  static const List<List<int>> jaJuNiKernel =
    [
      [48],
      [-1, -1,  0,  7,  5],
      [ 3,  5,  7,  5,  3],
      [ 1,  3,  5,  3,  1],
    ];

  static const List<List<int>> stuckiKernel =
    [
      [42],
      [-1, -1,  0,  8,  4],
      [ 2,  4,  8,  4,  2],
      [ 1,  2,  4,  2,  1],
    ];

  static const List<List<int>> sierraThreeKernel =
    [
      [32],
      [-1, -1,  0,  5,  3],
      [ 2,  4,  5,  4,  2],
      [-1,  2,  3,  2, -1],
    ];

  static const List<List<int>> sierraTwoKernel =
    [
      [16],
      [-1, -1,  0,  4,  3],
      [ 1,  2,  3,  2,  1],
    ];


  static const List<List<int>> sierraLiteKernel =
    [
      [4],
      [-1,  0,  2],
      [ 1,  1, -1],
    ];
}
