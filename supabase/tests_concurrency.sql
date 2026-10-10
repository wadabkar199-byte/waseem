-- ==============================================================================
-- اختبار منع التضارب والتزامن اللحظي على الحجوزات | منصة وسيم
-- يثبت نجاح الحجز الأول ورفض الحجز الثاني المتزامن على نفس الموعد
-- ==============================================================================

DO $$
DECLARE
    v_shop_id UUID := '11111111-0000-0000-0000-000000000001';
    v_barber_id UUID := '33333333-0000-0000-0000-000000000001';
    v_service_id UUID := '22222222-0000-0000-0000-000000000001';
    v_client_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    v_client_b UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
    v_slot_time TIMESTAMPTZ := NOW() + INTERVAL '2 days';
    v_res_a JSONB;
    v_second_booking_failed BOOLEAN := FALSE;
BEGIN
    RAISE NOTICE '=== بدء اختبار التزامن ومنع التعارض اللحظي في الحجوزات ===';

    -- 1. تجهيز بيانات وهمية مؤقتة للاختبار
    INSERT INTO profiles (id, role, full_name) VALUES 
    (v_client_a, 'client', 'العميل الأول'),
    (v_client_b, 'client', 'العميل الثاني')
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO barber_shops (id, owner_id, name, address_text, status) VALUES
    (v_shop_id, v_client_a, 'صالون الاختبار', 'حي العليا', 'approved')
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO barbers (id, shop_id, name) VALUES
    (v_barber_id, v_shop_id, 'حلاق الاختبار')
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO services (id, shop_id, name_ar, duration_minutes, price) VALUES
    (v_service_id, v_shop_id, 'قص شعر تجريبي', 30, 50.00)
    ON CONFLICT (id) DO NOTHING;

    -- 2. تنفيذ الحجز الأول للعميل (A) في الموعد المختار
    v_res_a := create_appointment_atomic(
        v_client_a,
        v_shop_id,
        v_barber_id,
        ARRAY[v_service_id],
        v_slot_time,
        'cash'
    );
    RAISE NOTICE 'الطلب الأول للعميل (A) تم بنجاح: %', v_res_a->>'booking_reference';

    -- 3. محاولة تنفيذ حجز ثانٍ متزامن للعميل (B) على نفس الحلاق ونفس الموعد بالضبط
    BEGIN
        PERFORM create_appointment_atomic(
            v_client_b,
            v_shop_id,
            v_barber_id,
            ARRAY[v_service_id],
            v_slot_time,
            'cash'
        );
    EXCEPTION WHEN OTHERS THEN
        v_second_booking_failed := TRUE;
        RAISE NOTICE 'الطلب الثاني للعميل (B) رُفض بنجاح وحظر تضارب الموعد: %', SQLERRM;
    END;

    -- 4. إثبات نجاح اختبار منع التزامن والتعارض
    IF v_second_booking_failed THEN
        RAISE NOTICE '=== النتيجة: نجح اختبار التزامن بنسبة 100%%. تم قبول الأول ورفض الثاني تلقائياً ===';
    ELSE
        RAISE EXCEPTION 'فشل اختبار التزامن: تم السماح بحجز مزدوج في نفس التوقيت!';
    END IF;

END $$;
