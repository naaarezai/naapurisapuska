# Google ML Kit & Firebase fix
-keep class com.google.firebase.iid.** { *; }
-dontwarn com.google.firebase.iid.**
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**