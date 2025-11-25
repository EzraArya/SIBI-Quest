# TensorFlow Lite ProGuard Rules
# Prevents R8 from stripping TFLite classes used via JNI/reflection

# Keep all TensorFlow Lite core classes
-keep class org.tensorflow.lite.** { *; }
-keepclassmembers class org.tensorflow.lite.** { *; }

# Keep GPU Delegate classes (CRITICAL for GPU acceleration)
-keep class org.tensorflow.lite.gpu.** { *; }
-keepclassmembers class org.tensorflow.lite.gpu.** { *; }

# Keep GpuDelegate factory and options (fixes missing inner class error)
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate$Options$* { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.CompatibilityList { *; }

# Keep GPU Delegate V2 classes (used in your code)
-keep class org.tensorflow.lite.gpu.GpuDelegateV2 { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateV2$Options { *; }

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep TFLite model interpreter classes
-keep class org.tensorflow.lite.Interpreter { *; }
-keep class org.tensorflow.lite.Interpreter$Options { *; }
-keep class org.tensorflow.lite.InterpreterApi { *; }
-keep class org.tensorflow.lite.InterpreterApi$Options$TfLiteRuntime { *; }

# Keep Tensor and DataType classes
-keep class org.tensorflow.lite.Tensor { *; }
-keep class org.tensorflow.lite.DataType { *; }

# Keep delegate classes
-keep interface org.tensorflow.lite.Delegate { *; }
-keep class * implements org.tensorflow.lite.Delegate { *; }

# Suppress warnings for optional dependencies
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Keep NNAPI delegate (if used)
-keep class org.tensorflow.lite.nnapi.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ========================================
# Flutter TFLite Plugin Rules (CRITICAL)
# ========================================

# Keep all Flutter plugin classes
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep tflite_flutter plugin classes
-keep class sq.flutter.tflite.** { *; }
-keepclassmembers class sq.flutter.tflite.** { *; }

# Keep Flutter method channel handlers
-keep class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
-keep class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }

# Keep Flutter binary messenger
-keep class io.flutter.plugin.common.** { *; }

# Keep Flutter engine classes (critical for native interop)
-keep class io.flutter.view.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.util.** { *; }

# Prevent reflection-related stripping
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# Keep all classes that might be accessed via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Aggressive TFLite protection - prevent ANY optimizations
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# ========================================
# Native Library Loading (CRITICAL)
# ========================================

# Keep JNI exported functions
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# ========================================
# Image Processing Libraries
# ========================================

# Keep image package classes (used in preprocessing)
-keep class com.github.bumptech.glide.** { *; }
-dontwarn com.github.bumptech.glide.**

# ========================================
# Additional Safety Rules
# ========================================

# Keep all Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep all Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep exception classes
-keep public class * extends java.lang.Exception

# Preserve line numbers for debugging stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
