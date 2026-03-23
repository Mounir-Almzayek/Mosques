# جاهز عند تفعيل isMinifyEnabled في release (راجع build.gradle.kts).

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

-keepattributes Signature
-keepattributes *Annotation*
-dontwarn org.conscrypt.**
