# Poster Pro - ناشر برو - بناء APK

## المتطلبات

قبل بناء APK، تأكد من تثبيت المتطلبات التالية:

### 1. Flutter SDK
- قم بتحميل Flutter من: https://flutter.dev/docs/get-started/install
- أضف Flutter إلى متغير PATH

### 2. Android SDK
- قم بتثبيت Android Studio من: https://developer.android.com/studio
- أو قم بتحميل Android SDK Command-line Tools من: https://developer.android.com/studio#downloads
- تأكد من تعيين متغير `ANDROID_HOME`

### 3. Java Development Kit (JDK)
- تثبيت Java 17 أو أحدث
- تأكد من تعيين متغير `JAVA_HOME`

## خطوات البناء

### الخطوة 1: تثبيت الحزم
```bash
cd poster_pro_flutter
flutter pub get
```

### الخطوة 2: بناء APK (Debug)
للاختبار السريع:
```bash
flutter build apk --debug
```

الملف الناتج سيكون في:
```
build/app/outputs/flutter-apk/app-debug.apk
```

### الخطوة 3: بناء APK (Release)
للإصدار النهائي:
```bash
flutter build apk --release
```

الملف الناتج سيكون في:
```
build/app/outputs/flutter-apk/app-release.apk
```

### الخطوة 4: بناء AAB (Android App Bundle)
للنشر على Google Play Store:
```bash
flutter build appbundle --release
```

الملف الناتج سيكون في:
```
build/app/outputs/bundle/release/app-release.aab
```

## استكشاف الأخطاء

### خطأ: "Android SDK not found"
```bash
flutter config --android-sdk=/path/to/android/sdk
```

### خطأ: "Java version mismatch"
تأكد من استخدام Java 17 أو أحدث:
```bash
java -version
export JAVA_HOME=/path/to/java/17
```

### خطأ: "Gradle build failed"
جرب تنظيف المشروع:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## تثبيت APK على جهاز

### 1. تفعيل وضع المطور على الجهاز
- انتقل إلى الإعدادات > حول الهاتف
- اضغط على رقم البناء 7 مرات
- عد إلى الإعدادات > خيارات المطور
- فعّل "تصحيح USB"

### 2. توصيل الجهاز
```bash
adb devices
```

### 3. تثبيت APK
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

أو استخدم Flutter مباشرة:
```bash
flutter install
```

## متطلبات الأذونات

تم تكوين المشروع مع الأذونات التالية في `AndroidManifest.xml`:

- `android.permission.INTERNET` - للوصول إلى الإنترنت
- `android.permission.READ_EXTERNAL_STORAGE` - لقراءة الملفات
- `android.permission.WRITE_EXTERNAL_STORAGE` - لكتابة الملفات
- `android.permission.READ_MEDIA_IMAGES` - لقراءة الصور

## معلومات التطبيق

- **اسم التطبيق**: Poster Pro - ناشر برو
- **معرّف الحزمة**: com.posterpro.nasher
- **الإصدار**: 1.0.0
- **الحد الأدنى لـ Android**: Android 5.0 (API 21)
- **الهدف**: Android 14 (API 34)

## ملاحظات مهمة

1. **WebView**: يستخدم التطبيق WebView لتسجيل الدخول إلى Facebook. تأكد من تحديث WebView على الجهاز.

2. **الأداء**: قد يستغرق البناء الأول 10-15 دقيقة. الإصدارات اللاحقة ستكون أسرع.

3. **حجم APK**: حجم APK النهائي حوالي 100-150 MB.

4. **التوقيع**: APK في وضع Debug موقع بمفتاح توقيع تصحيح. للإصدار النهائي، تحتاج إلى توقيع APK بمفتاح خاص بك.

## توقيع APK للإصدار

### إنشاء مفتاح توقيع
```bash
keytool -genkey -v -keystore ~/poster_pro.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias poster_pro
```

### تكوين ملف التوقيع
أنشئ ملف `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=poster_pro
storeFile=/path/to/poster_pro.keystore
```

### بناء APK موقع
```bash
flutter build apk --release
```

## الدعم والمساعدة

للمزيد من المعلومات، راجع:
- https://flutter.dev/docs/deployment/android
- https://developer.android.com/studio/build
