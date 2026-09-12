# Flutter Wrapper & Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Ignore optional Play Core deferred components warnings
-dontwarn com.google.android.play.core.**

# Google Play Core & In-App Update
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.install.** { *; }
-keep class com.google.android.play.core.common.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class de.ffuf.in_app_update.** { *; }

# Sqflite
-keep class com.tekartik.sqflite.** { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# SharePlus
-keep class dev.fluttercommunity.plus.share.** { *; }
