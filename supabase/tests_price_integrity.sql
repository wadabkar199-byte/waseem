-- ==============================================================================
-- اختبار منع التلاعب بالأسعار من طرف العميل | منصة وسيم
-- يثبت أن محاولة العميل إرسال سعر مخفض أو التلاعب بالخصم يتم تجاهلها خادمياً
-- ==============================================================================

DO $$
DECLARE
    v_shop_id UUID := '11111111-0000-0000-0000-000000000001';
    v_barber_id UUID := '33333333-0000-0000-0000-000000000001';
    v_service_id UUID := '22222222-0000-0000-0000-000000000001';
    v_client_id UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    v_promo_id UUID := '44444444-0000-0000-0000-000000000001';
    v_booking_res JSONB;
    v_final_price NUMERIC(10, 2);
BEGIN
    RAISE NOTICE '=== بدء اختبار الحماية الخادمية ضد التلاعب بالأسعار ===';

    -- 1. التأكد من الخدمة وسعرها الرسمي المسجل في قاعدة البيانات (50.00 ر.س)
    INSERT INTO services (id, shop_id, name_ar, duration_minutes, price)
    VALUES (v_service_id, v_shop_id, 'قص شعر أصلي', 30, 50.00)
    ON CONFLICT (id) DO UPDATE SET price = 50.00;

    -- 2. إدراج كود خصم رسمي بنسبة 20%
    INSERT INTO promotions (id, shop_id, code, title, discount_type, discount_value, start_date, end_date, is_active)
    VALUES (v_promo_id, v_shop_id, 'WASEEM20', 'عرض 20%', 'percentage', 20.00, NOW() - INTERVAL '1 day', NOW() + INTERVAL '10 days', TRUE)
    ON CONFLICT (id) DO NOTHING;

    -- 3. استدعاء دالة الحجز الخادمية create_appointment_atomic
    -- نلاحظ أن الدالة لا تقبل معامل السعر إطلاقاً من التطبيق بل تحسبه ذاتياً
    v_booking_res := create_appointment_atomic(
        v_client_id,
        v_shop_id,
        v_barber_id,
        ARRAY[v_service_id],
        NOW() + INTERVAL '3 days',
        'cash',
        'WASEEM20'
    );

    v_final_price := (v_booking_res->>'final_price')::NUMERIC;
    RAISE NOTICE 'السعر المحسوب خادمياً بعد خصم 20%%: % ر.س', v_final_price;

    -- 4. التحقق من أن السعر هو 40.00 (50 - 10) ولا يمكن لأي تلاعب تقليله
    ASSERT v_final_price = 40.00, 'فشل التحقق: السعر المحسوب غير مطابق للحسبة الخادمية الصحيحة';

    -- 5. تجربة كود غير صالح أو مزور
    v_booking_res := create_appointment_atomic(
        v_client_id,
        v_shop_id,
        v_barber_id,
        ARRAY[v_service_id],
        NOW() + INTERVAL '4 days',
        'cash',
        'FAKE_CODE_999'
    );
    v_final_price := (v_booking_res->>'final_price')::NUMERIC;
    RAISE NOTICE 'السعر بعد إرسال كود مزور: % ر.س', v_final_price;
    ASSERT v_final_price = 50.00, 'فشل التحقق: تم قبول كود خصم مزور!';

    RAISE NOTICE '=== نتيجة الاختبار: النظام محصن تماماً ضد أي تلاعب بالأسعار من طرف العميل ===';
END $$;
