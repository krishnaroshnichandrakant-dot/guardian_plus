# ══════════════════════════════════════════════════════════════════════════
# Guardian Plus — ProGuard / R8 Obfuscation Rules
# Layer 4: Anti-Tampering — Aggressive code obfuscation
# Applied in: android/app/build.gradle (release buildType)
# ══════════════════════════════════════════════════════════════════════════

# ── Flutter core ──────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.**

# ── Firebase ──────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── Security layer: AGGRESSIVELY obfuscate all Guardian security classes ──
# These class names must be unrecognizable to reverse engineers
-obfuscationdictionary proguard-dictionary.txt
-classobfuscationdictionary proguard-dictionary.txt
-packageobfuscationdictionary proguard-dictionary.txt

# ── Cryptography ──────────────────────────────────────────────────────────
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# ── Background service ────────────────────────────────────────────────────
-keep class id.flutter.flutter_background_service.** { *; }

# ── Hive ──────────────────────────────────────────────────────────────────
-keep class com.hive.** { *; }
-keep @com.hive.HiveType class * { *; }
-keep @com.hive.HiveField class * { *; }

# ── TFLite ────────────────────────────────────────────────────────────────
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# ── Frida detection: Keep native method names that check /proc/maps ───────
-keep class com.guardianplus.security.** { *; }

# ── Remove all logging in release builds ─────────────────────────────────
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# ── Stack traces: Keep crash reporting readable but not reversible ─────────
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ── Serialization (Hive adapters, FCM payloads) ───────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# ── Reflection protection ─────────────────────────────────────────────────
-keepattributes InnerClasses

# ── Remove debug symbols ──────────────────────────────────────────────────
-optimizationpasses 5
-allowaccessmodification
-dontpreverify
-repackageclasses ''
