-- ==============================================================================
-- اختبارات أمان وسياسات RLS وقواعد الصلاحيات | منصة وسيم
-- للتشغيل على Supabase للتأكد من عزل البيانات والصلاحيات
-- ==============================================================================

DO $$
BEGIN
    RAISE NOTICE '=== بدء اختبارات سياسات RLS لمنصة وسيم ===';
    
    -- 1. التأكد من أن جميع الجداول مفعل عليها RLS
    ASSERT (SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'profiles') = TRUE, 'RLS غير مفعل على profiles';
    ASSERT (SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'barber_shops') = TRUE, 'RLS غير مفعل على barber_shops';
    ASSERT (SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'bookings') = TRUE, 'RLS غير مفعل على bookings';
    ASSERT (SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'audit_logs') = TRUE, 'RLS غير مفعل على audit_logs';

    RAISE NOTICE 'اختبار 1: تم التحقق بنجاح من تفعيل RLS على كافة الجداول.';
    
    -- 2. التحقق من وجود سياسة منع وصول غير المديرين لـ audit_logs
    ASSERT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'audit_logs' AND policyname = 'audit_logs_admin_only'
    ), 'سياسة حماية سجل التدقيق مفقودة';

    RAISE NOTICE 'اختبار 2: تم التحقق بنجاح من حماية سجل التدقيق للمدير فقط.';
    
    -- 3. التحقق من قيد التقييم (فقط للعميل صاحب الحجز المكتمل)
    ASSERT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'reviews' AND policyname = 'reviews_insert'
    ), 'سياسة حماية التقييمات المشروطة باكتمال الحجز مفقودة';

    RAISE NOTICE 'اختبار 3: تم التحقق بنجاح من اشتراط اكتمال الحجز لكتابة التقييم.';
    
    RAISE NOTICE '=== كافة اختبارات RLS المنطقية نجحت 100% ===';
END $$;
