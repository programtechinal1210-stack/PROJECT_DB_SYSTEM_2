 
-- =============================================
-- FILE: security/03-encryption-keys.sql
-- PURPOSE: إدارة مفاتيح التشفير
-- =============================================

\c project_db_system;

-- إنشاء جدول لتخزين مفاتيح التشفير (مشفر)
CREATE TABLE IF NOT EXISTS core.encryption_keys (
    key_id SERIAL PRIMARY KEY,
    key_name VARCHAR(100) UNIQUE NOT NULL,
    key_value TEXT NOT NULL, -- سيتم تخزينه مشفراً
    key_purpose VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- دالة لتوليد مفتاح تشفير عشوائي
CREATE OR REPLACE FUNCTION core.generate_encryption_key()
RETURNS TEXT AS $$
BEGIN
    RETURN encode(gen_random_bytes(32), 'hex');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة لتشفير البيانات الحساسة
CREATE OR REPLACE FUNCTION core.encrypt_sensitive_data(
    p_data TEXT,
    p_key_name VARCHAR DEFAULT 'master_key'
)
RETURNS TEXT AS $$
DECLARE
    v_key TEXT;
BEGIN
    -- الحصول على المفتاح
    SELECT key_value INTO v_key 
    FROM core.encryption_keys 
    WHERE key_name = p_key_name AND is_active = true;
    
    IF v_key IS NULL THEN
        RAISE EXCEPTION 'Encryption key not found: %', p_key_name;
    END IF;
    
    -- تشفير البيانات
    RETURN encode(
        pgp_sym_encrypt(p_data, v_key),
        'base64'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة لفك تشفير البيانات
CREATE OR REPLACE FUNCTION core.decrypt_sensitive_data(
    p_encrypted_data TEXT,
    p_key_name VARCHAR DEFAULT 'master_key'
)
RETURNS TEXT AS $$
DECLARE
    v_key TEXT;
BEGIN
    -- الحصول على المفتاح
    SELECT key_value INTO v_key 
    FROM core.encryption_keys 
    WHERE key_name = p_key_name AND is_active = true;
    
    IF v_key IS NULL THEN
        RAISE EXCEPTION 'Encryption key not found: %', p_key_name;
    END IF;
    
    -- فك تشفير البيانات
    RETURN pgp_sym_decrypt(
        decode(p_encrypted_data, 'base64'),
        v_key
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إدراج المفتاح الرئيسي (في الإنتاج، يجب توليده بشكل آمن)
INSERT INTO core.encryption_keys (key_name, key_value, key_purpose)
SELECT 'master_key', core.generate_encryption_key(), 'Master encryption key for sensitive data'
WHERE NOT EXISTS (SELECT 1 FROM core.encryption_keys WHERE key_name = 'master_key');

-- رسالة تأكيد
SELECT '✅ Encryption keys configured' AS status;