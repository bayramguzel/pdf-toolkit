# Flutter ProGuard Rules
-keep class com.software41.pdftoolkit.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.**
-dontwarn com.software41.pdftoolkit.**

# Keep syncfusion pdf viewer / pdf classes
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**

# Unity Ads
-keep class com.unity3d.services.** { *; }
-dontwarn com.unity3d.services.**
-keep class com.unity3d.ads.** { *; }
-dontwarn com.unity3d.ads.**

# Video Player / ExoPlayer
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# Kotlin
-keep class kotlin.Metadata { *; }
-keep class kotlin.coroutines.Continuation { *; }
-dontwarn kotlin.**

# SharedPreferences
-keep class androidx.preference.** { *; }
-dontwarn androidx.preference.**

# AndroidX Edge-to-Edge
-keep class androidx.activity.** { *; }
-dontwarn androidx.activity.**
