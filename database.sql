-- ============================================================
-- TIPALERT DATABASE SCHEMA
-- ไปที่ Supabase > SQL Editor > วางทั้งหมด > กด Run
-- ============================================================

-- 1. STREAMER PROFILES
CREATE TABLE streamer_profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  bio TEXT DEFAULT '',
  platform TEXT DEFAULT 'YouTube',
  welcome_msg TEXT DEFAULT 'ขอบคุณที่ support นะครับ! 🙏',
  min_donation INTEGER DEFAULT 20,
  max_donation INTEGER,
  alert_duration INTEGER DEFAULT 8,
  tts_enabled BOOLEAN DEFAULT TRUE,
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. PAYMENT METHODS (แยกตาม user)
CREATE TABLE payment_methods (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES streamer_profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- promptpay, truemoney, bank
  label TEXT NOT NULL,
  icon TEXT DEFAULT '💳',
  account_number TEXT NOT NULL,
  account_name TEXT NOT NULL,
  bank_name TEXT, -- สำหรับประเภท bank
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. DONATIONS (ประวัติ donation แยกตาม user)
CREATE TABLE donations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  streamer_id UUID REFERENCES streamer_profiles(id) ON DELETE CASCADE,
  donor_name TEXT DEFAULT 'Anonymous',
  amount INTEGER NOT NULL,
  message TEXT DEFAULT '',
  payment_method TEXT,
  status TEXT DEFAULT 'confirmed', -- confirmed, pending, cancelled
  fired_at TIMESTAMPTZ DEFAULT NOW(),
  -- สำหรับ analytics
  month_year TEXT GENERATED ALWAYS AS (TO_CHAR(fired_at, 'YYYY-MM')) STORED
);

-- 4. MONTHLY SUMMARY VIEW (สรุปรายเดือน)
CREATE VIEW monthly_summary AS
SELECT
  streamer_id,
  month_year,
  COUNT(*) as total_donations,
  SUM(amount) as total_amount,
  AVG(amount)::INTEGER as avg_amount,
  MAX(amount) as max_donation,
  MIN(amount) as min_donation
FROM donations
WHERE status = 'confirmed'
GROUP BY streamer_id, month_year
ORDER BY month_year DESC;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE streamer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;

-- Profiles: ดูได้ทุกคน (สำหรับหน้า donate), แก้ได้เฉพาะเจ้าของ
CREATE POLICY "Public read profiles" ON streamer_profiles FOR SELECT USING (true);
CREATE POLICY "Own profile update" ON streamer_profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Own profile insert" ON streamer_profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Payment Methods: ดูได้ทุกคน (สำหรับหน้า donate), จัดการได้เฉพาะเจ้าของ
CREATE POLICY "Public read payments" ON payment_methods FOR SELECT USING (true);
CREATE POLICY "Own payments manage" ON payment_methods FOR ALL USING (auth.uid() = user_id);

-- Donations: เจ้าของเท่านั้นที่ดูได้
CREATE POLICY "Own donations" ON donations FOR ALL USING (auth.uid() = streamer_id);

-- ============================================================
-- INDEXES สำหรับ performance
-- ============================================================
CREATE INDEX idx_donations_streamer ON donations(streamer_id);
CREATE INDEX idx_donations_month ON donations(streamer_id, month_year);
CREATE INDEX idx_payments_user ON payment_methods(user_id);
CREATE INDEX idx_profiles_username ON streamer_profiles(username);
