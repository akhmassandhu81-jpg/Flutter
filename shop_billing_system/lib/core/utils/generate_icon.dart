import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final image = img.Image(width: 256, height: 256);
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  // Background square (Deep Navy #0F172A)
  img.fillRect(image, x1: 16, y1: 16, x2: 240, y2: 240, color: img.ColorRgba8(15, 23, 42, 255));

  // Inner glowing border (Cyan #06B6D4)
  img.drawRect(image, x1: 16, y1: 16, x2: 240, y2: 240, color: img.ColorRgba8(6, 182, 212, 255), thickness: 6);

  // Shopping bag body (White #FFFFFF)
  img.fillRect(image, x1: 64, y1: 88, x2: 192, y2: 208, color: img.ColorRgba8(255, 255, 255, 255));

  // Bag handles (Cyan #06B6D4)
  img.drawRect(image, x1: 96, y1: 60, x2: 160, y2: 96, color: img.ColorRgba8(6, 182, 212, 255), thickness: 8);

  // Ledger lines on bag (Navy #0F172A)
  img.drawLine(image, x1: 88, y1: 120, x2: 168, y2: 120, color: img.ColorRgba8(15, 23, 42, 255), thickness: 6);
  img.drawLine(image, x1: 88, y1: 144, x2: 168, y2: 144, color: img.ColorRgba8(15, 23, 42, 255), thickness: 6);
  img.drawLine(image, x1: 88, y1: 168, x2: 140, y2: 168, color: img.ColorRgba8(15, 23, 42, 255), thickness: 6);

  final pngBytes = img.encodePng(image);

  final icoHeader = <int>[0x00, 0x00, 0x01, 0x00, 0x01, 0x00];
  final pngSize = pngBytes.length;
  final icoDirEntry = <int>[
    0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x20, 0x00,
    pngSize & 0xFF, (pngSize >> 8) & 0xFF, (pngSize >> 16) & 0xFF, (pngSize >> 24) & 0xFF,
    0x16, 0x00, 0x00, 0x00
  ];

  final icoFileBytes = [...icoHeader, ...icoDirEntry, ...pngBytes];
  final file = File('windows/runner/resources/app_icon.ico');
  file.writeAsBytesSync(icoFileBytes);
  print('Successfully generated custom professional app_icon.ico (${icoFileBytes.length} bytes)');
}
