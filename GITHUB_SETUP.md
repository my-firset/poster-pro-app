# إعداد GitHub و بناء APK - دليل سريع

## الخطوة 1: إنشاء مستودع GitHub

### أ. إنشاء مستودع جديد

1. اذهب إلى https://github.com/new
2. أدخل اسم المستودع: `poster_pro_flutter`
3. اختر **Public** (اختياري)
4. اضغط **Create repository**

### ب. رفع المشروع

```bash
# من مجلد المشروع
git init
git add .
git commit -m "Initial commit: Poster Pro Flutter App"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/poster_pro_flutter.git
git push -u origin main
```

**استبدل `YOUR_USERNAME` باسم مستخدمك على GitHub**

## الخطوة 2: تفعيل GitHub Actions

1. اذهب إلى مستودعك على GitHub
2. اضغط على **Actions** tab (في الأعلى)
3. ستجد **Build APK** workflow
4. اضغط **Enable GitHub Actions** إذا لزم الأمر

## الخطوة 3: بناء APK

### الطريقة الأولى: تلقائياً

```bash
# ما عليك سوى الـ Push
git push origin main
```

البناء سيبدأ تلقائياً!

### الطريقة الثانية: يدوياً

1. اذهب إلى **Actions** tab
2. اختر **Build APK** من اليسار
3. اضغط **Run workflow** (الزر الأزرق)
4. اختر الفرع (main)
5. اضغط **Run workflow**

## الخطوة 4: تحميل APK

1. انتظر البناء (عادة 10-15 دقيقة)
2. اضغط على البناء المكتمل
3. اضغط **Artifacts** (في الأسفل)
4. حمّل الملفات:
   - `app-debug.apk` - للاختبار
   - `app-release.apk` - للإصدار النهائي

## الخطوة 5: تثبيت APK على جهازك

### على جهاز Android:

```bash
# بعد تحميل APK
adb install app-release.apk
```

### أو يدوياً:
1. انسخ الملف إلى جهازك
2. افتح الملف على جهازك
3. اضغط **Install**

## مثال عملي

```bash
# 1. استنساخ المشروع
git clone https://github.com/YOUR_USERNAME/poster_pro_flutter.git
cd poster_pro_flutter

# 2. إجراء تغييرات
# ... عدّل الملفات ...

# 3. رفع التغييرات
git add .
git commit -m "Add new features"
git push origin main

# 4. البناء يبدأ تلقائياً!
# اذهب إلى Actions tab لمراقبة البناء
```

## ملاحظات مهمة

✅ **مجاني تماماً** - 2000 دقيقة بناء شهرياً
✅ **تلقائي** - يبدأ عند كل Push
✅ **آمن** - لا تحتاج لتثبيت أي شيء محلياً
✅ **سريع** - عادة 10-15 دقيقة

⚠️ **الحد الأقصى للبناء الواحد**: 6 ساعات
⚠️ **الحد الأقصى الشهري**: 2000 دقيقة

## استكشاف الأخطاء

### البناء فشل

1. اضغط على البناء الفاشل
2. اضغط **Build APK** job
3. ابحث عن رسالة الخطأ
4. عدّل الملفات وأعد المحاولة

### البناء بطيء جداً

- هذا طبيعي في المرة الأولى
- الإصدارات اللاحقة ستكون أسرع

### لا أرى Artifacts

- تأكد من انتهاء البناء بنجاح (✓)
- قد يستغرق دقيقة إضافية لظهور الملفات

## الخطوات التالية

### 1. إضافة Badges

أضف هذا إلى `README.md`:

```markdown
[![Build APK](https://github.com/YOUR_USERNAME/poster_pro_flutter/actions/workflows/build-apk.yml/badge.svg)](https://github.com/YOUR_USERNAME/poster_pro_flutter/actions)
```

### 2. إصدارات تلقائية

```bash
# إنشاء tag
git tag v1.0.0
git push origin v1.0.0

# سيتم إنشاء Release تلقائياً مع APK!
```

### 3. إشعارات

أضف هذا إلى `.github/workflows/build-apk.yml`:

```yaml
- name: Notify on failure
  if: failure()
  run: echo "Build failed! Check the logs."
```

## الدعم

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter CI/CD Guide](https://flutter.dev/docs/deployment/cd)
- [GitHub Community](https://github.community)

---

**تم! الآن يمكنك بناء APK مجاناً أونلاين! 🚀**
