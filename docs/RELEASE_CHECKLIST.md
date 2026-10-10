# قائمة التحقق وإجراءات ما قبل الإطلاق والنسخ الاحتياطي | منصة وسيم (WASEEM)
> **تاريخ التحديث:** 2026-10-10  
> **الإصدار:** 1.0 (Release Checklist & Backup Guide)

---

## 1. قائمة التحقق قبل النشر والإنتاج (Pre-Launch Checklist)

- [x] **فحص الأسرار والمفاتيح:** لا يوجد أي مفتاح `service_role` أو توكن سري في كود Flutter أو Git.
- [x] **سياسات الأمان RLS:** مفعلة بنسبة 100% على كافة الجداول، والمدير فقط يصل لسجل التدقيق.
- [x] **منع التزامن:** قيد الاستبعاد `prevent_overlapping_barber_bookings` يمنع الحجز المزدوج.
- [x] **منع التلاعب بالأسعار:** الأسعار والخصومات تحسب ذرياً من جهة الخادم.
- [x] **التحقق من رفع الصور:** فحص الامتدادات وحظر ما يتجاوز 5MB.
- [x] **الهوية البصرية:** اعتماد شعار وسيم الرسمي، وتطبيق الألوان (`#123D32` و `#F0D49A`) واللغة العربية RTL.
- [x] **سياسة الخصوصية وحذف الحساب:** متوفرة وموثقة للمتجر والمستخدمين.

---

## 2. دليل توقيع تطبيق أندرويد للإنتاج (Android App Signing)

لرفع التطبيق على متجر Google Play:
1. **توليد مفتاح التوقيع (Keystore):**
   ```bash
   keytool -genkey -v -keystore waseem-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias waseem
   ```
2. **إنشاء ملف `android/key.properties` (مستثنى في .gitignore):**
   ```properties
   storePassword=your-store-password
   keyPassword=your-key-password
   keyAlias=waseem
   storeFile=/path/to/waseem-release.jks
   ```
3. **بناء حزمة أندرويد للمتجر (App Bundle):**
   ```bash
   cd mobile
   flutter build appbundle --release
   ```
   المسار: `mobile/build/app/outputs/bundle/release/app-release.aab`

---

## 3. آلية النسخ الاحتياطي واختبار الاستعادة (Database Backup & Restore)

لحماية بيانات صالونات وحجوزات وسيم:
1. **النسخ الاحتياطي اليومي الآلي:**
   - Supabase يوفر نسخاً احتياطياً يومياً تلقائياً (Automated Daily Backups) مع دعم Point-in-Time Recovery (PITR) في خطط Pro.
2. **النسخ الاحتياطي اليدوي الدوري عبر pg_dump:**
   ```bash
   # أخذ نسخة احتياطية كاملة للمخطط والبيانات
   pg_dump "postgres://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres" -F c -b -v -f "waseem_backup_$(date +%Y%m%d).dump"
   ```
3. **اختبار الاستعادة (Restore Test):**
   - يُنصح دورياً (كل شهر) باستعادة النسخة الاحتياطية على قاعدة بيانات تجريبية للتأكد من سلامة ملف النسخ:
   ```bash
   pg_restore -v -d "postgres://...target_test_db" "waseem_backup_20261010.dump"
   ```
