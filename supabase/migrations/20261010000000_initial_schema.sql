-- ==============================================================================
-- مشروع وسيم | WASEEM - ترحيل قاعدة البيانات الشامل
-- التاريخ: 2026-10-10
-- المرجع: القسم 8 من مواصفات المشروع
-- ملاحظة المرحلة 4: تعريف الجداول والمفاتيح والفهارس وقيود منع التعارض
-- ==============================================================================

-- 1. تفعيل الإضافات الأساسية
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- ==============================================================================
-- 2. الأنواع والقوائم (ENUMs)
-- ==============================================================================

CREATE TYPE user_role_enum AS ENUM ('client', 'barber', 'admin');
CREATE TYPE shop_status_enum AS ENUM ('pending_review', 'approved', 'suspended', 'rejected');
CREATE TYPE booking_status_enum AS ENUM (
    'pending_approval', 
    'confirmed', 
    'in_progress', 
    'completed', 
    'cancelled_by_client', 
    'cancelled_by_barber', 
    'no_show'
);
CREATE TYPE payment_status_enum AS ENUM ('pending', 'paid_online', 'paid_cash', 'refunded');
CREATE TYPE discount_type_enum AS ENUM ('percentage', 'fixed_amount');

-- ==============================================================================
-- 3. جدول الملفات الشخصية للمستخدمين (Profiles)
-- ==============================================================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role_enum NOT NULL DEFAULT 'client',
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(25) UNIQUE,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_phone ON profiles(phone_number);

-- ==============================================================================
-- 4. جدول تصنيفات ومناطق الصالونات (Regions & Categories)
-- ==============================================================================

CREATE TABLE regions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    city_name VARCHAR(100) NOT NULL,
    district_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(city_name, district_name)
);

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_ar VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    icon_name VARCHAR(50),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- ==============================================================================
-- 5. جدول صالونات الحلاقة (Barber Shops)
-- ==============================================================================

CREATE TABLE barber_shops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    region_id UUID REFERENCES regions(id) ON DELETE SET NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    address_text TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    logo_url TEXT,
    cover_image_url TEXT,
    status shop_status_enum NOT NULL DEFAULT 'pending_review',
    auto_confirm BOOLEAN NOT NULL DEFAULT TRUE,
    cancellation_window_hours INT NOT NULL DEFAULT 2,
    commission_rate NUMERIC(5, 2) DEFAULT 0.00,
    rating_average NUMERIC(3, 2) DEFAULT 0.00,
    rating_count INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_barber_shops_status ON barber_shops(status);
CREATE INDEX idx_barber_shops_owner ON barber_shops(owner_id);
CREATE INDEX idx_barber_shops_region ON barber_shops(region_id);

-- ==============================================================================
-- 6. جدول الحلاقين العاملين بالصالون (Barbers)
-- ==============================================================================

CREATE TABLE barbers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES barber_shops(id) ON DELETE CASCADE,
    profile_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    name VARCHAR(150) NOT NULL,
    title VARCHAR(100),
    photo_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_barbers_shop ON barbers(shop_id);

-- ==============================================================================
-- 7. جدول الخدمات وقائمة الأسعار (Services)
-- ==============================================================================

CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES barber_shops(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name_ar VARCHAR(150) NOT NULL,
    description TEXT,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_services_shop ON services(shop_id);
CREATE INDEX idx_services_category ON services(category_id);

-- ==============================================================================
-- 8. جدول أوقات العمل وفترات الراحة (Working Hours & Breaks)
-- ==============================================================================

CREATE TABLE working_hours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES barber_shops(id) ON DELETE CASCADE,
    day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0: Sunday, 6: Saturday
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    is_off_day BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(shop_id, day_of_week)
);

CREATE TABLE barber_breaks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    barber_id UUID NOT NULL REFERENCES barbers(id) ON DELETE CASCADE,
    day_of_week SMALLINT CHECK (day_of_week BETWEEN 0 AND 6),
    break_start TIME NOT NULL,
    break_end TIME NOT NULL,
    is_recurring BOOLEAN NOT NULL DEFAULT TRUE,
    specific_date DATE
);

-- ==============================================================================
-- 9. جدول العروض والخصومات (Promotions - عروض وسيم)
-- ==============================================================================

CREATE TABLE promotions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES barber_shops(id) ON DELETE CASCADE,
    code VARCHAR(50),
    title VARCHAR(150) NOT NULL,
    description TEXT,
    discount_type discount_type_enum NOT NULL DEFAULT 'percentage',
    discount_value NUMERIC(10, 2) NOT NULL CHECK (discount_value > 0),
    min_order_amount NUMERIC(10, 2) DEFAULT 0,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    max_uses INT,
    used_count INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_promotions_shop ON promotions(shop_id);
CREATE INDEX idx_promotions_active_dates ON promotions(start_date, end_date, is_active);

-- ==============================================================================
-- 10. جدول الحجوزات (Bookings) مع منع التعارض اللحظي
-- ==============================================================================

CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_reference VARCHAR(15) UNIQUE NOT NULL,
    client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    shop_id UUID NOT NULL REFERENCES barber_shops(id) ON DELETE RESTRICT,
    barber_id UUID NOT NULL REFERENCES barbers(id) ON DELETE RESTRICT,
    promotion_id UUID REFERENCES promotions(id) ON DELETE SET NULL,
    
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    booking_period TSTZRANGE GENERATED ALWAYS AS (tstzrange(start_time, end_time, '[)')) STORED,

    total_duration_minutes INT NOT NULL CHECK (total_duration_minutes > 0),
    subtotal_price NUMERIC(10, 2) NOT NULL,
    discount_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    final_price NUMERIC(10, 2) NOT NULL,

    status booking_status_enum NOT NULL DEFAULT 'confirmed',
    payment_status payment_status_enum NOT NULL DEFAULT 'pending',
    payment_method VARCHAR(50) NOT NULL DEFAULT 'cash',
    
    client_notes TEXT,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_time_validity CHECK (end_time > start_time)
);

-- قيد منع التعارض على مستوى قاعدة البيانات (Exclusion Constraint):
-- يمنع حجز نفس الحلاق لموعدين متداخلين إلا إذا كان أحدهما ملغياً
ALTER TABLE bookings ADD CONSTRAINT prevent_overlapping_barber_bookings
EXCLUDE USING GIST (
    barber_id WITH =,
    booking_period WITH &&
)
WHERE (status NOT IN ('cancelled_by_client', 'cancelled_by_barber', 'no_show'));

CREATE INDEX idx_bookings_client ON bookings(client_id);
CREATE INDEX idx_bookings_shop_date ON bookings(shop_id, start_time);
CREATE INDEX idx_bookings_barber_date ON bookings(barber_id, start_time);

-- ==============================================================================
-- 11. جدول عناصر وتفاصيل الخدمات المحجوزة (Booking Items)
-- ==============================================================================

CREATE TABLE booking_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    service_name_snapshot VARCHAR(150) NOT NULL,
    price_snapshot NUMERIC(10, 2) NOT NULL,
    duration_snapshot INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_booking_items_booking ON booking_items(booking_id);

-- ==============================================================================
-- 12. جدول التقييمات والمراجعات (Reviews)
-- ==============================================================================

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID UNIQUE NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    shop_id UUID NOT NULL REFERENCES barber_shops(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reviews_shop ON reviews(shop_id);

-- ==============================================================================
-- 13. جدول البلاغات والشكاوى (Reports)
-- ==============================================================================

CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    target_shop_id UUID REFERENCES barber_shops(id) ON DELETE SET NULL,
    target_booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    admin_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 14. جدول سجل التدقيق الإداري (Audit Logs)
-- ==============================================================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_name VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    details JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- ==============================================================================
-- 15. دالة ذرية لإنشاء الحجز والتحقق داخل Transaction خادمية (Atomic Booking RPC)
-- ==============================================================================

CREATE OR REPLACE FUNCTION create_appointment_atomic(
    p_client_id UUID,
    p_shop_id UUID,
    p_barber_id UUID,
    p_service_ids UUID[],
    p_start_time TIMESTAMPTZ,
    p_payment_method VARCHAR(50) DEFAULT 'cash',
    p_promotion_code VARCHAR(50) DEFAULT NULL,
    p_client_notes TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_duration INT := 0;
    v_subtotal NUMERIC(10, 2) := 0;
    v_discount NUMERIC(10, 2) := 0;
    v_final_price NUMERIC(10, 2) := 0;
    v_end_time TIMESTAMPTZ;
    v_booking_id UUID;
    v_booking_ref VARCHAR(15);
    v_promo_id UUID := NULL;
    v_service RECORD;
    v_overlap_count INT := 0;
BEGIN
    -- 1. حساب المدة الإجمالية والسعر من جدول الخدمات المعتمد خادمياً
    FOR v_service IN 
        SELECT id, name_ar, price, duration_minutes 
        FROM services 
        WHERE id = ANY(p_service_ids) AND shop_id = p_shop_id AND is_active = TRUE
    LOOP
        v_total_duration := v_total_duration + v_service.duration_minutes;
        v_subtotal := v_subtotal + v_service.price;
    END LOOP;

    IF v_total_duration = 0 THEN
        RAISE EXCEPTION 'الخدمات المحددة غير صالحة أو غير متوفرة بهذا الصالون';
    END IF;

    v_end_time := p_start_time + (v_total_duration || ' minutes')::INTERVAL;

    -- 2. التحقق من عدم وجود تضارب لحظي في الموعد لهذا الحلاق
    SELECT COUNT(*) INTO v_overlap_count
    FROM bookings
    WHERE barber_id = p_barber_id
      AND status NOT IN ('cancelled_by_client', 'cancelled_by_barber', 'no_show')
      AND tstzrange(start_time, end_time, '[)') && tstzrange(p_start_time, v_end_time, '[)');

    IF v_overlap_count > 0 THEN
        RAISE EXCEPTION 'عذراً، هذا الموعد تم حجزه للتو وغير متاح حالياً';
    END IF;

    -- 3. التحقق من كود العرض / الخصم إن وُجد
    IF p_promotion_code IS NOT NULL AND TRIM(p_promotion_code) <> '' THEN
        SELECT id, 
               CASE 
                   WHEN discount_type = 'percentage' THEN (v_subtotal * discount_value / 100)
                   ELSE discount_value 
               END INTO v_promo_id, v_discount
        FROM promotions
        WHERE shop_id = p_shop_id 
          AND UPPER(code) = UPPER(TRIM(p_promotion_code))
          AND is_active = TRUE
          AND NOW() BETWEEN start_date AND end_date
          AND (max_uses IS NULL OR used_count < max_uses);

        IF v_promo_id IS NOT NULL THEN
            IF v_discount > v_subtotal THEN
                v_discount := v_subtotal;
            END IF;
            UPDATE promotions SET used_count = used_count + 1 WHERE id = v_promo_id;
        ELSE
            v_discount := 0;
        END IF;
    END IF;

    v_final_price := v_subtotal - v_discount;
    v_booking_ref := 'WAS-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT), 1, 8));

    -- 4. إدراج الحجز
    INSERT INTO bookings (
        booking_reference,
        client_id,
        shop_id,
        barber_id,
        promotion_id,
        start_time,
        end_time,
        total_duration_minutes,
        subtotal_price,
        discount_amount,
        final_price,
        status,
        payment_method,
        client_notes
    ) VALUES (
        v_booking_ref,
        p_client_id,
        p_shop_id,
        p_barber_id,
        v_promo_id,
        p_start_time,
        v_end_time,
        v_total_duration,
        v_subtotal,
        v_discount,
        v_final_price,
        'confirmed',
        p_payment_method,
        p_client_notes
    ) RETURNING id INTO v_booking_id;

    -- 5. إدراج عناصر الخدمات بالحجز (Snapshots)
    INSERT INTO booking_items (booking_id, service_id, service_name_snapshot, price_snapshot, duration_snapshot)
    SELECT v_booking_id, id, name_ar, price, duration_minutes
    FROM services
    WHERE id = ANY(p_service_ids);

    RETURN jsonb_build_object(
        'success', TRUE,
        'booking_id', v_booking_id,
        'booking_reference', v_booking_ref,
        'start_time', p_start_time,
        'end_time', v_end_time,
        'final_price', v_final_price
    );
END;
$$;
