# Flutter Wrapper & Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Ignore optional Play Core deferred components warnings
-dontwarn com.google.android.play.core.**

# Sqflite
-keep class com.tekartik.sqflite.** { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# SharePlus
-keep class dev.fluttercommunity.plus.share.** { *; }
