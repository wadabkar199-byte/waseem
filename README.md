# منصة وسيم | WASEEM
> **إطلالتك تبدأ من هنا - منصة حجز الحلاقة والعناية بالرجال الذكية**

---

## 📌 نبذة عن المشروع
منصة "وسيم" هي حل تقني متكامل يربط العملاء بأفضل صالونات ومحترفي الحلاقة، مما يتيح استكشاف الصالونات، حجز المواعيد المؤكدة لحظياً، الاستفادة من العروض الحصرية، وإدارة عمليات الصالون بكل احترافية وسلاسة.

---

## 📂 هيكل المستودع (Monorepo)
- `assets/brand/`: الشعار الرسمي الأصلي لمنصة وسيم (`waseem_logo.png`).
- `docs/`: التوثيق المعماري، المتطلبات، ومخطط قاعدة البيانات والاختبارات (`TESTING.md`, `DATABASE.md`).
- `mobile/`: تطبيق الهاتف الذكي (Flutter - Android) للعملاء والحلاقين.
- `admin/`: لوحة التحكم الإدارية المركزية (React + TypeScript).
- `supabase/`: ترحيلات قاعدة البيانات PostgreSQL وسياسات RLS والدوال السحابية واختبارات الأمان.

---

## 🚀 متطلبات التشغيل
1. **Flutter SDK** (إصدار 3.0 فما فوق) مع بيئة Android SDK و Java 17+.
2. **Node.js** (إصدار 18 فما فوق) للوحة الإدارة.
3. **حساب Supabase السحابي**.
4. **مشروع Firebase Console** لتفعيل إشعارات FCM.

---

## ⚙️ خطوات التثبيت والتشغيل المحلي

### 1. إعداد قاعدة البيانات (Supabase)
1. سجل الدخول إلى [supabase.com](https://supabase.com) وأنشئ مشروعاً جديداً.
2. افتح **SQL Editor** ونفّذ ملفات الترحيل بالترتيب التالي:
   - `supabase/migrations/20261010000000_initial_schema.sql` (الجداول والفهارس وقيد منع التعارض).
   - `supabase/migrations/20261010000001_rls_policies.sql` (تفعيل RLS والصلاحيات).
   - `supabase/seed.sql` (بيانات تجريبية للمناطق والتصنيفات).
3. في قسم **Storage**، أنشئ وعاءين عامين (Public Buckets): `shop-logos` و `shop-covers`.

### 2. إعداد تطبيق الهاتف المحمول (`mobile/`)
```bash
cd mobile

# 1. تجهيز المتغيرات البيئية
cp .env.example .env
# قم بفتح .env وضع SUPABASE_URL و SUPABASE_ANON_KEY الخاصة بمشروعك

# 2. تنزيل الحزم والمكتبات
flutter pub get

# 3. تشغيل التطبيق في وضع التطوير
flutter run
```

---

## 📱 بناء نسخة APK للاختبار (Android APK Build)

### أ. بناء نسخة تجريبية سريعة (Debug APK):
```bash
cd mobile
flutter build apk --debug
```
المسار الناتج للملف:
`mobile/build/app/outputs/flutter-apk/app-debug.apk`

### ب. بناء نسخة اختبار مجمعة ومحسنة (Release APK):
```bash
cd mobile
flutter build apk --release
```
المسار الناتج للملف:
`mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## 📲 كيفية تثبيت ملف APK على هاتف Android:
1. **عبر وصلة USB وأداة ADB:**
   ```bash
   adb install -r mobile/build/app/outputs/flutter-apk/app-release.apk
   ```
2. **عبر النقل المباشر للهاتف:**
   - انسخ ملف `app-release.apk` إلى هاتفك عبر البلوتوث، Google Drive، أو كابل USB.
   - افتح تطبيق "ملفاتي" (Files) على الهاتف واضغط على ملف الـ APK.
   - إذا ظهر تنبيه "تثبيت تطبيقات غير معروفة"، اضغط "السماح من هذا المصدر".
   - اضغط "تثبيت" (Install) ثم افتح التطبيق واستمتع بتجربة وسيم.

---

## 💻 تشغيل لوحة الإدارة (`admin/`)
```bash
cd admin
cp .env.example .env
# ضع VITE_SUPABASE_URL و VITE_SUPABASE_ANON_KEY في ملف .env
npm install
npm run dev
```
افتح المتصفح على الرابط: `http://localhost:3000`

---

## 🔐 إرشادات الأمان والحماية
- حظر رفع أي ملفات `.env` أو مفاتيح `service_role` إلى Git نهائياً.
- سياسات RLS وقيد منع تضارب الحجوزات مفروضة تلقائياً على مستوى قاعدة البيانات.
