############################
## Gson rules
############################
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

############################
## Firebase + Google Play
############################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

############################
## Flutter / Pigeon generated
############################
# Flutter plugin registrant
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Pigeon generated classes (channels)
-keep class dev.flutter.pigeon.** { *; }
-dontwarn dev.flutter.pigeon.**

# Flutter embedding
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# GeneratedPluginRegistrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

############################
## WorkManager (nếu dùng Firebase Messaging / background)
############################
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

############################
## Extra (nếu dùng Kotlin coroutines)
############################
-dontwarn kotlinx.coroutines.**

# FFmpegKit rules
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-dontwarn com.antonkarpenko.ffmpegkit.**

# Keep all FFmpegKit native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep FFmpegKit Config
-keep class com.antonkarpenko.ffmpegkit.FFmpegKitConfig {
    *;
}

# Keep ABI Detection
-keep class com.antonkarpenko.ffmpegkit.AbiDetect {
    *;
}

# Keep all FFmpegKit sessions
-keep class com.antonkarpenko.ffmpegkit.*Session {
    *;
}

# Keep FFmpegKit callbacks
-keep class com.antonkarpenko.ffmpegkit.*Callback {
    *;
}

# Preserve all public classes in ffmpegkit
-keep public class com.antonkarpenko.ffmpegkit.** {
    public *;
}

# Keep reflection-based access
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses