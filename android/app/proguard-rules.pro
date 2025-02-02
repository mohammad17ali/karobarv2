# Razorpay-specific rules
-keep class proguard.annotation.** { *; }
-keep class com.razorpay.** { *; }
-keepattributes *Annotation*

# Preserve all classes and methods used by Razorpay
-keep class com.razorpay.AnalyticsEvent { *; }
-keep class com.razorpay.Checkout { *; }
-keep class com.razorpay.** { *; }
