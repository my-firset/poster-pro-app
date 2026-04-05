# إعداد Codemagic و بناء APK - دليل سريع

## ما هو Codemagic؟

Codemagic هي منصة بناء سحابية مجانية متخصصة في تطبيقات Flutter و React Native.

**المميزات:**
- ✅ مجاني (500 دقيقة بناء شهرياً)
- ✅ سهل الاستخدام
- ✅ واجهة رسومية جميلة
- ✅ دعم النشر على Play Store
- ✅ إشعارات بريدية

## الخطوة 1: إنشاء حساب Codemagic

1. اذهب إلى https://codemagic.io
2. اضغط **Sign up**
3. اختر **Sign up with GitHub** (أو GitLab/Bitbucket)
4. وافق على الأذونات
5. أكمل الإعدادات الأساسية

## الخطوة 2: ربط المستودع

### الطريقة الأولى: من Codemagic

1. بعد تسجيل الدخول، اضغط **Add repository**
2. اختر GitHub (أو الخدمة التي تستخدمها)
3. اختر `poster_pro_flutter`
4. اضغط **Connect**

### الطريقة الثانية: من GitHub

1. اذهب إلى مستودعك على GitHub
2. اذهب إلى **Settings** → **Applications**
3. اختر **Codemagic**
4. اضغط **Authorize**

## الخطوة 3: تشغيل البناء الأول

1. اضغط على مشروعك في Codemagic
2. اضغط **Start new build**
3. اختر **android-release** من القائمة
4. اضغط **Build**

## الخطوة 4: تحميل APK

1. انتظر البناء (عادة 10-15 دقيقة)
2. عندما ينتهي، اضغط على البناء
3. اضغط **Artifacts** (في الأسفل)
4. حمّل:
   - `app-debug.apk` - للاختبار
   - `app-release.apk` - للإصدار النهائي
   - `app-release.aab` - لـ Google Play Store

## الخطوة 5: إعدادات متقدمة (اختياري)

### تفعيل الإشعارات البريدية

1. اضغط على المشروع
2. اضغط **Settings** (الترس)
3. اضغط **Notifications**
4. أدخل بريدك الإلكتروني
5. فعّل **Email on success** و **Email on failure**

### تفعيل البناء التلقائي

1. اضغط **Settings**
2. اضغط **Build triggers**
3. فعّل **Build on push**
4. اختر الفروع (main, develop)

### إضافة متغيرات البيئة

إذا كنت تحتاج متغيرات خاصة:

1. اضغط **Settings**
2. اضغط **Environment variables**
3. أضف المتغيرات:
   - `DEVELOPER_EMAIL` - بريدك الإلكتروني
   - `BUILD_VERSION` - رقم الإصدار

## مثال عملي

```bash
# 1. استنساخ المشروع
git clone https://github.com/YOUR_USERNAME/poster_pro_flutter.git

# 2. إجراء تغييرات
cd poster_pro_flutter
# ... عدّل الملفات ...

# 3. رفع التغييرات
git add .
git commit -m "Add new features"
git push origin main

# 4. البناء يبدأ تلقائياً!
# اذهب إلى Codemagic لمراقبة البناء
```

## المقارنة: GitHub Actions vs Codemagic

| الميزة | GitHub Actions | Codemagic |
|-------|---|---|
| السعر | مجاني | مجاني |
| دقائق البناء | 2000/شهر | 500/شهر |
| الواجهة | بسيطة | جميلة |
| سهولة الاستخدام | متوسطة | سهلة |
| دعم النشر | محدود | ممتاز |
| الإشعارات | GitHub | بريد إلكتروني |

**الخلاصة:**
- **GitHub Actions**: أفضل للمشاريع الصغيرة والبناء السريع
- **Codemagic**: أفضل للمشاريع الكبيرة والنشر على Play Store

## الخطوات التالية

### 1. النشر على Google Play Store

```yaml
# في codemagic.yaml
publishing:
  google_play:
    credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
    track: internal
```

### 2. إضافة اختبارات

```yaml
scripts:
  - name: Run tests
    script: flutter test
```

### 3. إضافة تحليل الكود

```yaml
scripts:
  - name: Analyze
    script: flutter analyze
```

## استكشاف الأخطاء

### مشكلة: "Build failed"

1. اضغط على البناء الفاشل
2. اضغط **View logs**
3. ابحث عن رسالة الخطأ
4. عدّل الملفات وأعد المحاولة

### مشكلة: "Out of memory"

الحل في `codemagic.yaml`:
```yaml
environment:
  java: 17
  flutter: 3.41.6
instance_type: linux_x2  # استخدم instance أكبر
```

### مشكلة: "Gradle timeout"

الحل:
```bash
export GRADLE_OPTS="-Xmx2g"
```

## الموارد الإضافية

- [Codemagic Documentation](https://docs.codemagic.io)
- [Flutter CI/CD Guide](https://flutter.dev/docs/deployment/cd)
- [Google Play Store Guide](https://developer.android.com/studio/publish)

## الخلاصة

**خطوات سريعة:**
1. أنشئ حساب Codemagic
2. ربط مستودعك
3. اضغط **Build**
4. حمّل APK

**الآن يمكنك بناء APK مجاناً أونلاين! 🚀**

---

**ملاحظة**: إذا واجهت مشاكل، تأكد من:
- ✅ صحة `pubspec.yaml`
- ✅ صحة `android/build.gradle`
- ✅ وجود `codemagic.yaml` في جذر المشروع
