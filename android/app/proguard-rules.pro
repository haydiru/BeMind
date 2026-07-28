# ProGuard Rules for BeMind Production Release on Google Play Store

# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.binder.** { *; }
-keep class io.flutter.build.** { *; }

# Ignore optional Play Store Split / Deferred Component classes
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Preserve Supabase & Auth models
-keep class com.supabase.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Preserve Native Audio & Speech plugins
-keep class com.example.bemind.** { *; }
-keep class cs.min.speech.** { *; }
-keep class com.bluefire.audioplayers.** { *; }
