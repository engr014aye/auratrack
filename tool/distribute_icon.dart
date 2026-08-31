import 'dart:io';

void main() {
  final sourcePath = r'C:\Users\Engr Ammar Official\.gemini\antigravity\brain\ec3e6013-e38c-486b-b8e8-f7c9cb678dc6\auratrack_app_icon_1788031991564.jpg';
  final sourceFile = File(sourcePath);

  if (!sourceFile.existsSync()) {
    print('Source icon file does not exist.');
    return;
  }

  final bytes = sourceFile.readAsBytesSync();

  // 1. Write to assets/icons/app_icon.png
  final assetsIconsDir = Directory('assets/icons');
  if (!assetsIconsDir.existsSync()) assetsIconsDir.createSync(recursive: true);
  File('assets/icons/app_icon.png').writeAsBytesSync(bytes);
  print('Saved assets/icons/app_icon.png');

  // 2. Write to Android launcher mipmap directories
  final mipmaps = [
    'android/app/src/main/res/mipmap-mdpi',
    'android/app/src/main/res/mipmap-hdpi',
    'android/app/src/main/res/mipmap-xhdpi',
    'android/app/src/main/res/mipmap-xxhdpi',
    'android/app/src/main/res/mipmap-xxxhdpi',
  ];

  for (final dirPath in mipmaps) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('$dirPath/ic_launcher.png').writeAsBytesSync(bytes);
    print('Saved $dirPath/ic_launcher.png');
  }

  print('Icon distribution complete.');
}
