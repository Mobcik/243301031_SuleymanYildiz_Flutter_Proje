-- =============================================
-- Hukuk Takip Sistemi - Veritabanı Şeması
-- Migration: 001 - Initial Schema
-- =============================================

-- Kullanıcı profilleri tablosu
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('avukat', 'müvekkil')),
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Avukat alanları
  sicil_no TEXT,
  uzmanlik_alani TEXT,
  baro_adi TEXT,

  -- Müvekkil alanları
  tc_kimlik TEXT,
  birth_date DATE,
  address TEXT
);

-- Hukuk dosyaları tablosu
CREATE TABLE cases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  case_number TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  client_id UUID REFERENCES profiles(id),
  lawyer_id UUID REFERENCES profiles(id),
  status TEXT DEFAULT 'aktif' CHECK (status IN ('aktif', 'beklemede', 'kapalı')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Masraflar tablosu
CREATE TABLE expenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  description TEXT NOT NULL,
  expense_date DATE NOT NULL,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- İşlem logları tablosu
CREATE TABLE activity_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  action TEXT NOT NULL,
  details TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS devre dışı (öğrenci projesi)
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE cases DISABLE ROW LEVEL SECURITY;
ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs DISABLE ROW LEVEL SECURITY;
