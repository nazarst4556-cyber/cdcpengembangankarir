-- ══════════════════════════════════════════════════════════════════════════
-- DATABASE SCHEMA: PORTAL CDC / UPA. PKK POLITEKNIK NEGERI LHOKSEUMAWE
-- 100% Idempotent (Aman dijalankan berulang kali tanpa error di Supabase)
-- ══════════════════════════════════════════════════════════════════════════

-- 1. TABEL PROFIL PENGGUNA (PESERTA CDC / MAHASISWA / ALUMNI / UMUM)
CREATE TABLE IF NOT EXISTS public.profiles (
    id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    category TEXT DEFAULT 'mahasiswaPnl',
    identity_number TEXT,
    major TEXT,
    is_registered_job_fair BOOLEAN DEFAULT FALSE,
    ticket_code TEXT,
    session_slot TEXT,
    registered_at TIMESTAMPTZ,
    recovery_key TEXT,
    blockchain_block_hash TEXT,
    block_index INT,
    is_attended BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Pastikan kolom tambahan selalu ada jika tabel sudah pernah dibuat sebelumnya
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS recovery_key TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS blockchain_block_hash TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS block_index INT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_attended BOOLEAN DEFAULT FALSE;

-- 2. TABEL PENDAFTARAN E-TIKET JOB FAIR 2026
CREATE TABLE IF NOT EXISTS public.job_fair_registrations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id TEXT REFERENCES public.profiles(id) ON DELETE CASCADE,
    ticket_code TEXT NOT NULL,
    session_slot TEXT,
    event_name TEXT DEFAULT 'PNL Job Fair & Career Expo 2026',
    registered_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABEL PERUSAHAAN MITRA / DIREKTORI INDUSTRI
CREATE TABLE IF NOT EXISTS public.companies (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    sector TEXT NOT NULL,
    booth_number TEXT,
    open_positions INT DEFAULT 1,
    description TEXT,
    logo_code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Buat index unik pada nama perusahaan jika belum ada (aman dan tidak akan error)
CREATE UNIQUE INDEX IF NOT EXISTS companies_name_idx ON public.companies (name);

-- ══════════════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Idempotent: DROP POLICY IF EXISTS sebelum CREATE POLICY
-- ══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_fair_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

-- ── Kebijakan Profiles ──────────────────────────────────────────────────
DROP POLICY IF EXISTS "Allow public read profiles" ON public.profiles;
CREATE POLICY "Allow public read profiles" ON public.profiles
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public insert profiles" ON public.profiles;
CREATE POLICY "Allow public insert profiles" ON public.profiles
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public update profiles" ON public.profiles;
CREATE POLICY "Allow public update profiles" ON public.profiles
    FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public delete profiles" ON public.profiles;
CREATE POLICY "Allow public delete profiles" ON public.profiles
    FOR DELETE USING (true);

-- ── Kebijakan Registrasi E-Tiket ─────────────────────────────────────────
DROP POLICY IF EXISTS "Allow public read job_fair_registrations" ON public.job_fair_registrations;
CREATE POLICY "Allow public read job_fair_registrations" ON public.job_fair_registrations
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public insert job_fair_registrations" ON public.job_fair_registrations;
CREATE POLICY "Allow public insert job_fair_registrations" ON public.job_fair_registrations
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public delete job_fair_registrations" ON public.job_fair_registrations;
CREATE POLICY "Allow public delete job_fair_registrations" ON public.job_fair_registrations
    FOR DELETE USING (true);

-- ── Kebijakan Companies ──────────────────────────────────────────────────
DROP POLICY IF EXISTS "Allow public read companies" ON public.companies;
CREATE POLICY "Allow public read companies" ON public.companies
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public insert companies" ON public.companies;
CREATE POLICY "Allow public insert companies" ON public.companies
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public update companies" ON public.companies;
CREATE POLICY "Allow public update companies" ON public.companies
    FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public delete companies" ON public.companies;
CREATE POLICY "Allow public delete companies" ON public.companies
    FOR DELETE USING (true);

-- ══════════════════════════════════════════════════════════════════════════
-- SEED DATA PERUSAHAAN MITRA PNL JOB FAIR 2026 (Tanpa Duplikasi / Bebas Error)
-- ══════════════════════════════════════════════════════════════════════════

INSERT INTO public.companies (name, sector, booth_number, open_positions, description, logo_code)
SELECT v.name, v.sector, v.booth_number, v.open_positions, v.description, v.logo_code
FROM (
    VALUES
        ('PT Pupuk Iskandar Muda (PIM)', 'Petrokimia & Pupuk Nasional', 'Booth A-01 (Main Hall)', 8, 'Anak perusahaan PT Pupuk Indonesia yang beroperasi di Kawasan Ekonomi Khusus Lhokseumawe.', 'PIM'),
        ('PT Pertamina (Persero)', 'Energi, Minyak & Gas Bumi', 'Booth A-02 (Main Hall)', 12, 'BUMN energi terkemuka membuka kesempatan Management Trainee dan Teknisi Lapangan.', 'PERTAMINA'),
        ('PT Medco E&P Malaka', 'Eksplorasi Migas', 'Booth B-03', 6, 'Operator Blok A Aceh Timur yang berkomitmen menyerap talenta vokasi teknik dari PNL.', 'MEDCO'),
        ('Bank Syariah Indonesia (BSI)', 'Perbankan & Finansial Syariah', 'Booth B-04', 15, 'Membuka program Officer Development Program (ODP) dan Customer Relationship.', 'BSI'),
        ('PT Telkom Indonesia (Persero) Tbk', 'Telekomunikasi & Digital Solutions', 'Booth C-01', 10, 'Peluang karir di bidang Network Engineer, Data Analyst, dan Cloud Architect.', 'TELKOM'),
        ('PT Harum Energy Tbk', 'Pertambangan & Logistik Energi', 'Booth C-02', 7, 'Perusahaan energi terintegrasi untuk posisi Mechanical & Electrical Supervisor.', 'HARUM')
) AS v(name, sector, booth_number, open_positions, description, logo_code)
WHERE NOT EXISTS (
    SELECT 1 FROM public.companies c WHERE c.name = v.name
);
