# إنشاء ملف initialize-database.ps1
$scriptContent = @'
# E:\PROJECT_DB_SYSTEM_2\database\scripts\initialize-database.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   تهيئة قاعدة البيانات بالكامل" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$PROJECT_ROOT = "E:\PROJECT_DB_SYSTEM_2"
$DB_CONTAINER = "project_db_postgres"
$DB_USER = "project_user"
$DB_NAME = "project_db_system"

# التحقق من وجود الحاوية
$containerCheck = docker ps --filter "name=$DB_CONTAINER" --format "{{.Names}}"
if (-not $containerCheck) {
    Write-Host "❌ حاوية قاعدة البيانات غير قيد التشغيل" -ForegroundColor Red
    Write-Host "قم بتشغيل الحاوية أولاً باستخدام: cd ..\infrastructure\docker; docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n📦 1. إنشاء الإضافات (Extensions)..." -ForegroundColor Yellow
$extensions = @"
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
SELECT '✅ Extensions created' as status;
"@
$extensions | docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME

Write-Host "`n📁 2. إنشاء Schemas..." -ForegroundColor Yellow
$schemas = @"
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS organization;
CREATE SCHEMA IF NOT EXISTS hr;
CREATE SCHEMA IF NOT EXISTS assets;
CREATE SCHEMA IF NOT EXISTS field;
CREATE SCHEMA IF NOT EXISTS audit;
SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('core', 'organization', 'hr', 'assets', 'field', 'audit');
"@
$schemas | docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME

Write-Host "`n📊 3. التحقق من الجداول الموجودة..." -ForegroundColor Yellow
$checkTables = @"
SELECT 
    'core' as schema_name, COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'core'
UNION ALL
SELECT 'organization', COUNT(*) FROM information_schema.tables WHERE table_schema = 'organization'
UNION ALL
SELECT 'hr', COUNT(*) FROM information_schema.tables WHERE table_schema = 'hr'
UNION ALL
SELECT 'assets', COUNT(*) FROM information_schema.tables WHERE table_schema = 'assets'
UNION ALL
SELECT 'field', COUNT(*) FROM information_schema.tables WHERE table_schema = 'field'
UNION ALL
SELECT 'audit', COUNT(*) FROM information_schema.tables WHERE table_schema = 'audit';
"@
$checkTables | docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t

Write-Host "`n✅ تهيئة قاعدة البيانات اكتملت!" -ForegroundColor Green
Write-Host "`n📌 معلومات الاتصال:" -ForegroundColor Cyan
Write-Host "   Host: localhost:5432" -ForegroundColor White
Write-Host "   Database: $DB_NAME" -ForegroundColor White
Write-Host "   Username: $DB_USER" -ForegroundColor White
Write-Host "   Password: Project@123456" -ForegroundColor White
Write-Host "`n   pgAdmin: http://localhost:5050" -ForegroundColor White
Write-Host "   Email: admin@project.com" -ForegroundColor White
Write-Host "   Password: Admin@123" -ForegroundColor White
'@

# حفظ الملف
$scriptContent | Out-File -FilePath "initialize-database.ps1" -Encoding UTF8

Write-Host "✅ تم إنشاء ملف initialize-database.ps1 بنجاح" -ForegroundColor Green