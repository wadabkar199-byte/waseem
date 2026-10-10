-- ==============================================================================
-- مشروع وسيم | WASEEM - سياسات أمان الصفوف (RLS) والمصادقة والصلاحيات
-- التاريخ: 2026-10-10
-- المرجع: المرحلة 5 من مواصفات المشروع
-- ==============================================================================

-- 1. دوال مساعدة للتحقق من الأدوار من جهة الخادم (Security Functions)
CREATE OR REPLACE FUNCTION current_user_role()
RETURNS user_role_enum
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT role FROM profiles WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT (current_user_role() = 'admin');
$$;

CREATE OR REPLACE FUNCTION is_barber()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT (current_user_role() = 'barber');
$$;

-- 2. Trigger لإنشاء ملف تعريف تلقائي عند تسجيل مستخدم جديد عبر Supabase Auth
-- يضمن تعيين الدور الافتراضي 'client' أو 'barber' بشكل آمن خادمياً
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role user_role_enum := 'client';
    v_raw_role TEXT;
BEGIN
    -- استخراج الدور من البيانات الوصفية إن حُدد وقت التسجيل
    v_raw_role := new.raw_user_meta_data->>'role';
    IF v_raw_role = 'barber' THEN
        v_role := 'barber';
    ELSIF v_raw_role = 'admin' THEN
        -- منع ترقية أي مستخدم لنفسه إلى مدير وقت التسجيل
        v_role := 'client';
    END IF;

    INSERT INTO public.profiles (id, role, full_name, phone_number, avatar_url)
    VALUES (
        new.id,
        v_role,
        COALESCE(new.raw_user_meta_data->>'full_name', 'مستخدم جديد'),
        new.phone,
        new.raw_user_meta_data->>'avatar_url'
    );
    RETURN new;
END;
$$;

-- ربط الـ Trigger بجدول auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ==============================================================================
-- 3. تفعيل RLS على كافة الجداول بنسبة 100%
-- ==============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE regions ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE barber_shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE barbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE working_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE barber_breaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- 4. سياسات RLS لجدول الملفات الشخصية (profiles)
-- ==============================================================================

-- القراءة: مسموح للمستخدم بقراءة ملفه، أو للجميع قراءة الاسم والصورة، وللمدير قراءة الكل
CREATE POLICY "profiles_select_policy" ON profiles
    FOR SELECT USING (
        auth.uid() = id OR is_admin() OR role IN ('barber', 'client')
    );

-- التعديل: المستخدم يعدل ملفه فقط، ولا يمكنه ترقية حقله role (تُحمى عبر trigger أو عمود محمي)
CREATE POLICY "profiles_update_policy" ON profiles
    FOR UPDATE USING (auth.uid() = id)
    WITH CHECK (
        auth.uid() = id AND 
        (role = (SELECT role FROM profiles WHERE id = auth.uid()) OR is_admin())
    );

-- ==============================================================================
-- 5. سياسات RLS للمناطق والتصنيفات (regions & categories)
-- ==============================================================================

CREATE POLICY "regions_public_select" ON regions FOR SELECT USING (is_active = TRUE OR is_admin());
CREATE POLICY "regions_admin_all" ON regions FOR ALL USING (is_admin());

CREATE POLICY "categories_public_select" ON categories FOR SELECT USING (is_active = TRUE OR is_admin());
CREATE POLICY "categories_admin_all" ON categories FOR ALL USING (is_admin());

-- ==============================================================================
-- 6. سياسات RLS للصالونات (barber_shops)
-- ==============================================================================

-- القراءة: المعتمدة فقط تظهر للعامة، وأصحاب الصالونات يرون صالوناتهم، والمدير يرى الكل
CREATE POLICY "barber_shops_select" ON barber_shops
    FOR SELECT USING (
        status = 'approved' OR owner_id = auth.uid() OR is_admin()
    );

-- الإضافة: الحلاق المسجل يمكنه إنشاء طلب صالون (تكون حالته الافتراضية pending_review)
CREATE POLICY "barber_shops_insert" ON barber_shops
    FOR INSERT WITH CHECK (
        auth.uid() = owner_id AND (is_barber() OR is_admin())
    );

-- التعديل: المالك يعدل صالونه فقط دون تغيير حالة الاعتماد status إلا إذا كان مديراً
CREATE POLICY "barber_shops_update" ON barber_shops
    FOR UPDATE USING (
        owner_id = auth.uid() OR is_admin()
    ) WITH CHECK (
        (owner_id = auth.uid() AND status = (SELECT status FROM barber_shops WHERE id = barber_shops.id)) 
        OR is_admin()
    );

-- ==============================================================================
-- 7. سياسات RLS للحلاقين والخدمات وأوقات العمل
-- ==============================================================================

-- barbers
CREATE POLICY "barbers_select" ON barbers FOR SELECT USING (TRUE);
CREATE POLICY "barbers_modify" ON barbers FOR ALL USING (
    shop_id IN (SELECT id FROM barber_shops WHERE owner_id = auth.uid()) OR is_admin()
);

-- services
CREATE POLICY "services_select" ON services FOR SELECT USING (is_active = TRUE OR is_admin() OR shop_id IN (SELECT id FROM barber_shops WHERE owner_id = auth.uid()));
CREATE POLICY "services_modify" ON services FOR ALL USING (
    shop_id IN (SELECT id FROM barber_shops WHERE owner_id = auth.uid()) OR is_admin()
);

-- working_hours
CREATE POLICY "working_hours_select" ON working_hours FOR SELECT USING (TRUE);
CREATE POLICY "working_hours_modify" ON working_hours FOR ALL USING (
    shop_id IN (SELECT id FROM barber_shops WHERE owner_id = auth.uid()) OR is_admin()
);

-- barber_breaks
CREATE POLICY "barber_breaks_select" ON barber_breaks FOR SELECT USING (TRUE);
CREATE POLICY "barber_breaks_modify" ON barber_breaks FOR ALL USING (
    barber_id IN (SELECT b.id FROM barbers b JOIN barber_shops s ON b.shop_id = s.id WHERE s.owner_id = auth.uid()) OR is_admin()
);

-- promotions
CREATE POLICY "promotions_select" ON promotions FOR SELECT USING (
    (is_active = TRUE AND NOW() BETWEEN start_date AND end_date) OR
    shop_id IN (SELECT id FROM barber_shops WHERE owner_id = auth.uid()) OR
    is_admin()
);
CREATE POLICY "promotions_modify" ON promotions FOR ALL USING (
    shop_id IN (SELECT id FROM barber_shops WHERE owner_id = auth.uid()) OR is_admin()
);

-- ==============================================================================
-- 8. سياسات RLS للحجوزات (bookings & booking_items)
-- ==============================================================================

-- bookings: العميل يرى حجوزاته فقط، والحلاق يرى حجوزات صالونه فقط، والمدير يرى الكل
CREATE POLICY "bookings_select_policy" ON bookings
    FOR SELECT USING (
        client_id = auth.uid() OR
        shop_id IN (SELECT id FROM barber_shops WHERE owner_id = auth.uid()) OR
        barber_id IN (SELECT id FROM barbers WHERE profile_id = auth.uid()) OR
        is_admin()
    );

-- bookings: الإدراج مسموح للعميل لحسابه فقط أو عبر دالة RPC المحمية
CREATE POLICY "bookings_insert_policy" ON bookings
    FOR INSERT WITH CHECK (
        client_id = auth.uid() OR is_admin()
    );

-- bookings: التحديث (تحديث حالة الحجز أو الإلغاء)
CREATE POLICY "bookings_update_policy" ON bookings
    FOR UPDATE USING (
        client_id = auth.uid() OR
        shop_id IN (SELECT id FROM barber_shops WHERE owner_id = auth.uid()) OR
        is_admin()
    );

-- booking_items
CREATE POLICY "booking_items_select" ON booking_items
    FOR SELECT USING (
        booking_id IN (SELECT id FROM bookings WHERE client_id = auth.uid() OR shop_id IN (SELECT id FROM barber_shops WHERE owner_id = auth.uid())) OR
        is_admin()
    );

-- ==============================================================================
-- 9. سياسات RLS للتقييمات والبلاغات وسجل التدقيق
-- ==============================================================================

-- reviews
CREATE POLICY "reviews_select" ON reviews FOR SELECT USING (TRUE);
CREATE POLICY "reviews_insert" ON reviews FOR INSERT WITH CHECK (
    client_id = auth.uid() AND
    EXISTS (
        SELECT 1 FROM bookings 
        WHERE id = reviews.booking_id 
          AND client_id = auth.uid() 
          AND status = 'completed'
    )
);

-- reports
CREATE POLICY "reports_insert" ON reports FOR INSERT WITH CHECK (reporter_id = auth.uid());
CREATE POLICY "reports_select" ON reports FOR SELECT USING (reporter_id = auth.uid() OR is_admin());
CREATE POLICY "reports_modify_admin" ON reports FOR ALL USING (is_admin());

-- audit_logs: للقراءة فقط من قبل الإدارة
CREATE POLICY "audit_logs_admin_only" ON audit_logs FOR SELECT USING (is_admin());
CREATE POLICY "audit_logs_insert" ON audit_logs FOR INSERT WITH CHECK (TRUE);
