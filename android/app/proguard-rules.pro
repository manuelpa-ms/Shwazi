# Proguard rules for Shwazi
# Keep Flutter and Kotlin reflection essentials
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class androidx.core.app.CoreComponentFactory { *; }

# Keep application class if generated
-keep class com.manuelpa.shwazi.Application { *; }

# Suppress warnings on missing classes sometimes referenced by Flutter
-dontwarn org.jetbrains.annotations.**
-dontwarn javax.annotation.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.tasks.**

# General optimizations
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
