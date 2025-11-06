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

# Keep NNAPI delegate (if used)
-keep class org.tensorflow.lite.nnapi.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
