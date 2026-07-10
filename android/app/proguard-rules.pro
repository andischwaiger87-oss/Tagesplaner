# flutter_local_notifications speichert geplante Meldungen über Gson.
# R8 darf die dafür nötigen Typinformationen nicht entfernen,
# sonst schlägt zonedSchedule mit "Missing type parameter" fehl.
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
