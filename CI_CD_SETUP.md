# CI/CD Setup Guide - Poster Pro

هذا الدليل يشرح كيفية بناء APK أونلاين مجاناً باستخدام GitHub Actions أو Codemagic.

## الخيار 1: GitHub Actions (مجاني تماماً)

### المتطلبات
- حساب GitHub
- مشروع على GitHub

### الخطوات

#### 1. رفع المشروع إلى GitHub

```bash
# إنشاء مستودع جديد على GitHub
# ثم:

git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/poster_pro_flutter.git
git push -u origin main
```

#### 2. ملف GitHub Actions موجود بالفعل

الملف `.github/workflows/build-apk.yml` موجود بالفعل في المشروع.

#### 3. تفعيل GitHub Actions

1. اذهب إلى مستودعك على GitHub
2. اضغط على **Actions** tab
3. اضغط **Enable GitHub Actions**

#### 4. تشغيل البناء

**الطريقة الأولى: تلقائياً عند الـ Push**
```bash
git push origin main
```

**الطريقة الثانية: يدوياً**
1. اذهب إلى **Actions** tab
2. اختر **Build APK** workflow
3. اضغط **Run workflow**

#### 5. تحميل الملفات الناتجة

1. انتظر انتهاء البناء (عادة 10-15 دقيقة)
2. اضغط على البناء المكتمل
3. اضغط **Artifacts**
4. حمّل `app-release.apk` أو `app-debug.apk`

### مميزات GitHub Actions

✅ مجاني تماماً
✅ 2000 دقيقة بناء شهرياً (للحسابات المجانية)
✅ بناء تلقائي عند الـ Push
✅ دعم الـ Tags للإصدارات
✅ تكامل كامل مع GitHub

### حدود GitHub Actions

⚠️ 2000 دقيقة شهرياً فقط (للحسابات المجانية)
⚠️ وقت البناء الواحد: 6 ساعات كحد أقصى
⚠️ لا يوجد دعم مباشر للنشر على Play Store

---

## الخيار 2: Codemagic (مجاني مع حدود)

### المتطلبات
- حساب GitHub أو GitLab أو Bitbucket
- حساب Codemagic (مجاني)

### الخطوات

#### 1. إنشاء حساب Codemagic

1. اذهب إلى https://codemagic.io
2. اضغط **Sign up**
3. اختر **Sign up with GitHub** (أو خدمة أخرى)
4. وافق على الأذونات

#### 2. ربط المستودع

1. اضغط **Add repository**
2. اختر `poster_pro_flutter`
3. اضغط **Connect**

#### 3. ملف Codemagic موجود بالفعل

الملف `codemagic.yaml` موجود بالفعل في المشروع.

#### 4. تشغيل البناء

1. اذهب إلى مشروعك في Codemagic
2. اضغط **Start new build**
3. اختر **android-release**
4. اضغط **Build**

#### 5. تحميل الملفات الناتجة

1. انتظر انتهاء البناء
2. اضغط على البناء المكتمل
3. حمّل APK من **Artifacts**

### مميزات Codemagic

✅ مجاني (مع حدود)
✅ 500 دقيقة بناء شهرياً (مجاني)
✅ واجهة سهلة الاستخدام
✅ دعم الإشعارات البريدية
✅ دعم النشر على Play Store (مدفوع)

### حدود Codemagic

⚠️ 500 دقيقة شهرياً فقط (مجاني)
⚠️ بناء واحد فقط في نفس الوقت
⚠️ وقت البناء الواحد: 120 دقيقة كحد أقصى

---

## الخيار 3: EAS Build (Expo Application Services)

### ملاحظة
هذا الخيار أفضل للمشاريع التي تستخدم Expo، لكن يمكن استخدامه مع Flutter أيضاً.

### الخطوات

```bash
# تثبيت EAS CLI
npm install -g eas-cli

# تسجيل الدخول
eas login

# بناء APK
eas build --platform android --local
```

---

## المقارنة بين الخيارات

| الميزة | GitHub Actions | Codemagic | EAS Build |
|-------|---|---|---|
| السعر | مجاني | مجاني | مجاني |
| دقائق البناء الشهرية | 2000 | 500 | 30 |
| سهولة الاستخدام | متوسطة | سهلة | سهلة |
| سرعة البناء | سريعة | سريعة | متوسطة |
| دعم النشر | محدود | جيد | ممتاز |
| التكامل مع GitHub | ممتاز | جيد | جيد |

---

## نصائح مهمة

### 1. تحسين سرعة البناء

```yaml
# في codemagic.yaml أو GitHub Actions
cache: true  # تفعيل الـ Cache
```

### 2. الإشعارات

**GitHub Actions:**
```yaml
- name: Send notification
  if: failure()
  run: |
    echo "Build failed!"
```

**Codemagic:**
```yaml
publishing:
  email:
    recipients:
      - your-email@example.com
```

### 3. الإصدارات التلقائية

**GitHub Actions:**
```yaml
- name: Create Release
  if: startsWith(github.ref, 'refs/tags/')
  uses: softprops/action-gh-release@v1
```

---

## استكشاف الأخطاء الشائعة

### مشكلة: "Build failed: Android SDK not found"

**الحل**: الملفات موجودة بالفعل في البيئة، تأكد من:
- صحة `pubspec.yaml`
- صحة `android/build.gradle`

### مشكلة: "Gradle build daemon disappeared"

**الحل**: قلل حجم الذاكرة:
```yaml
script: |
  export GRADLE_OPTS="-Xmx2g"
  flutter build apk --release
```

### مشكلة: "Out of memory"

**الحل**: استخدم instance أكبر:
- GitHub Actions: `ubuntu-latest` كافية
- Codemagic: استخدم `linux_x2` بدلاً من `linux`

---

## الخطوات التالية

### 1. إضافة توقيع للـ APK

للنشر على Play Store، تحتاج إلى توقيع APK:

```bash
# إنشاء keystore
keytool -genkey -v -keystore ~/poster_pro.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias poster_pro

# إضافة إلى GitHub Secrets أو Codemagic
```

### 2. النشر على Play Store

```yaml
# في codemagic.yaml
publishing:
  google_play:
    credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
    track: internal
```

### 3. الإشعارات المتقدمة

```yaml
# Slack notifications
- name: Notify Slack
  if: always()
  run: |
    curl -X POST $SLACK_WEBHOOK \
      -d '{"text":"Build completed"}'
```

---

## الموارد الإضافية

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Codemagic Documentation](https://docs.codemagic.io)
- [Flutter CI/CD Guide](https://flutter.dev/docs/deployment/cd)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)

---

## الخلاصة

**للبدء السريع**: استخدم **GitHub Actions**
- مجاني تماماً
- 2000 دقيقة شهرياً
- سهل التكامل

**للمشاريع الكبيرة**: استخدم **Codemagic**
- واجهة أفضل
- دعم أفضل للنشر
- إشعارات متقدمة

اختر ما يناسب احتياجاتك!
