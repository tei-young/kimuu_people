-- KIMUU Schedule Database Schema
-- Version: 1.0.0
-- Created: 2026-01-05

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. Users (원장님) 테이블
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    color TEXT NOT NULL DEFAULT '#4ECDC4',  -- HEX 색상코드
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    treatment_types TEXT[] NOT NULL DEFAULT ARRAY['눈썹문신', '입술문신', '애교살'],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 색상 중복 방지 (다른 사용자와 같은 색상 사용 불가)
CREATE UNIQUE INDEX idx_users_color ON users(color);

-- ============================================
-- 2. Appointments (일정) 테이블
-- ============================================
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    treatment_type TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    memo TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 인덱스: 날짜 범위 조회 최적화
CREATE INDEX idx_appointments_time ON appointments(start_time, end_time);
CREATE INDEX idx_appointments_user_id ON appointments(user_id);

-- ============================================
-- 3. Customers (고객) 테이블 - 추후 확장용
-- ============================================
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- Row Level Security (RLS) 정책
-- ============================================

-- Users 테이블 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 모든 인증된 사용자가 users 조회 가능 (다른 원장님 정보 확인용)
CREATE POLICY "Users are viewable by authenticated users" ON users
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- 본인 정보만 수정 가능
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Appointments 테이블 RLS
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- 모든 인증된 사용자가 일정 조회 가능 (다른 원장님 일정 확인용)
CREATE POLICY "Appointments are viewable by authenticated users" ON appointments
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- 본인 일정만 생성 가능
CREATE POLICY "Users can insert own appointments" ON appointments
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 본인 일정만 수정 가능 (Admin은 별도 처리)
CREATE POLICY "Users can update own appointments" ON appointments
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 본인 일정만 삭제 가능 (Admin은 별도 처리)
CREATE POLICY "Users can delete own appointments" ON appointments
    FOR DELETE
    USING (auth.uid() = user_id);

-- Customers 테이블 RLS
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers are viewable by authenticated users" ON customers
    FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Customers can be inserted by authenticated users" ON customers
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================
-- Updated_at 자동 갱신 트리거
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Admin 권한을 위한 함수 (서비스 역할에서 호출)
-- ============================================

-- Admin이 다른 사용자의 일정을 수정할 수 있도록 하는 함수
CREATE OR REPLACE FUNCTION admin_update_appointment(
    p_appointment_id UUID,
    p_customer_name TEXT DEFAULT NULL,
    p_customer_phone TEXT DEFAULT NULL,
    p_treatment_type TEXT DEFAULT NULL,
    p_start_time TIMESTAMPTZ DEFAULT NULL,
    p_end_time TIMESTAMPTZ DEFAULT NULL,
    p_memo TEXT DEFAULT NULL
)
RETURNS appointments AS $$
DECLARE
    v_result appointments;
BEGIN
    UPDATE appointments SET
        customer_name = COALESCE(p_customer_name, customer_name),
        customer_phone = COALESCE(p_customer_phone, customer_phone),
        treatment_type = COALESCE(p_treatment_type, treatment_type),
        start_time = COALESCE(p_start_time, start_time),
        end_time = COALESCE(p_end_time, end_time),
        memo = COALESCE(p_memo, memo)
    WHERE id = p_appointment_id
    RETURNING * INTO v_result;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Admin이 다른 사용자의 일정을 삭제할 수 있도록 하는 함수
CREATE OR REPLACE FUNCTION admin_delete_appointment(p_appointment_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM appointments WHERE id = p_appointment_id;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 초기 색상 팔레트 (참조용 - 앱에서 사용)
-- ============================================
COMMENT ON TABLE users IS '
사용 가능한 색상 팔레트:
- #FF6B6B (코랄 레드)
- #4ECDC4 (틸)
- #45B7D1 (스카이 블루)
- #96CEB4 (민트)
- #FFEAA7 (레몬)
- #DDA0DD (플럼)
- #98D8C8 (아쿠아)
- #F7DC6F (골드)
- #BB8FCE (라벤더)
- #85C1E9 (파스텔 블루)
- #F8B500 (앰버)
- #82E0AA (라이트 그린)
';
