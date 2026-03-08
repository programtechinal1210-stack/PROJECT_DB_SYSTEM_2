# # E:\PROJECT_DB_SYSTEM_2\database\scripts\run-database.ps1

# param(
#     [Parameter(Mandatory=$false)]
#     [ValidateSet("start", "stop", "reset", "backup", "restore", "status")]
#     [string]$Command = "start"
# )

# $DOCKER_DIR = "..\infrastructure\docker"
# $BACKUP_DIR = "..\database\backups"
# $PROJECT_ROOT = "E:\PROJECT_DB_SYSTEM_2"

# function Write-ColorOutput($ForegroundColor) {
#     $fc = $host.UI.RawUI.ForegroundColor
#     $host.UI.RawUI.ForegroundColor = $ForegroundColor
#     if ($args) {
#         Write-Output $args
#     }
#     $host.UI.RawUI.ForegroundColor = $fc
# }

# function Test-DockerInstalled {
#     try {
#         $version = docker --version 2>$null
#         return $true
#     } catch {
#         return $false
#     }
# }

# # التحقق من تثبيت Docker
# if (-not (Test-DockerInstalled)) {
#     Write-ColorOutput Red "Docker غير مثبت على النظام"
#     Write-ColorOutput Yellow "قم بتثبيت Docker Desktop من: https://www.docker.com/products/docker-desktop/"
#     exit 1
# }

# switch ($Command) {
#     "start" {
#         Write-ColorOutput Cyan "========================================"
#         Write-ColorOutput Cyan "   بدء تشغيل قاعدة البيانات"
#         Write-ColorOutput Cyan "========================================"
        
#         # التحقق من وجود مجلد docker
#         $dockerPath = Join-Path $PROJECT_ROOT "infrastructure\docker"
#         if (-not (Test-Path $dockerPath)) {
#             Write-ColorOutput Red "مجلد docker غير موجود: $dockerPath"
#             Write-ColorOutput Yellow "تأكد من أن المسار صحيح: E:\PROJECT_DB_SYSTEM_2\infrastructure\docker"
#             exit 1
#         }
        
#         # الذهاب إلى مجلد docker
#         Set-Location $dockerPath
        
#         # التحقق من وجود ملف docker-compose.yml
#         if (-not (Test-Path "docker-compose.yml")) {
#             Write-ColorOutput Red "ملف docker-compose.yml غير موجود"
#             exit 1
#         }
        
#         # إيقاف أي حاويات سابقة
#         Write-ColorOutput Yellow "إيقاف الحاويات القديمة..."
#         docker-compose down -v 2>$null
        
#         # تشغيل الحاويات
#         Write-ColorOutput Yellow "تشغيل حاويات Docker..."
#         docker-compose up -d
        
#         Write-ColorOutput Yellow "انتظار اكتمال التهيئة (30 ثانية)..."
#         Start-Sleep -Seconds 30
        
#         # التحقق من حالة الحاويات
#         $containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
#         Write-ColorOutput Cyan "`nحالة الحاويات:"
#         Write-Host $containers
        
#         # التحقق من صحة PostgreSQL
#         $maxRetries = 10
#         $retryCount = 0
#         $dbReady = $false
        
#         Write-ColorOutput Yellow "`nالتحقق من اتصال قاعدة البيانات..."
#         while ($retryCount -lt $maxRetries -and -not $dbReady) {
#             try {
#                 $result = docker exec project_db pg_isready -U project_user 2>$null
#                 if ($LASTEXITCODE -eq 0) {
#                     $dbReady = $true
#                     Write-ColorOutput Green "قاعدة البيانات جاهزة للاتصال"
#                 }
#             } catch {
#                 # تجاهل الأخطاء
#             }
#             $retryCount++
#             if (-not $dbReady -and $retryCount -lt $maxRetries) {
#                 Write-Host "محاولة $retryCount من $maxRetries..." -ForegroundColor Gray
#                 Start-Sleep -Seconds 2
#             }
#         }
        
#         if ($dbReady) {
#             Write-ColorOutput Green "`nقاعدة البيانات جاهزة!"
            
#             # عرض معلومات الاتصال
#             Write-ColorOutput Cyan "`n========================================"
#             Write-ColorOutput Cyan "PostgreSQL:"
#             Write-ColorOutput Cyan "   Host: localhost:5432"
#             Write-ColorOutput Cyan "   Database: project_db_system"
#             Write-ColorOutput Cyan "   Username: project_user"
#             Write-ColorOutput Cyan "   Password: Project@123456"
#             Write-ColorOutput Cyan "========================================"
#             Write-ColorOutput Cyan "pgAdmin:"
#             Write-ColorOutput Cyan "   URL: http://localhost:5050"
#             Write-ColorOutput Cyan "   Email: admin@project.com"
#             Write-ColorOutput Cyan "   Password: Admin@123"
#             Write-ColorOutput Cyan "========================================"
#             Write-ColorOutput Cyan "Redis:"
#             Write-ColorOutput Cyan "   Host: localhost:6379"
#             Write-ColorOutput Cyan "   Password: Redis@123456"
#             Write-ColorOutput Cyan "========================================"
            
#             # اختبار الاتصال
#             try {
#                 $test = docker exec project_db psql -U project_user -d project_db_system -c "SELECT 'اتصال ناجح' as status;" 2>$null
#                 if ($test) {
#                     Write-ColorOutput Green "اختبار الاتصال: ناجح"
#                 }
#             } catch {
#                 Write-ColorOutput Yellow "اختبار الاتصال: غير متاح حالياً"
#             }
            
#             # عرض عدد الجداول
#             try {
#                 Write-ColorOutput Cyan "`nجاري التحقق من الجداول..."
                
#                 # تنفيذ استعلامات منفصلة
#                 $coreResult = docker exec project_db psql -U project_user -d project_db_system -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'core';" 2>$null
#                 $orgResult = docker exec project_db psql -U project_user -d project_db_system -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'organization';" 2>$null
#                 $hrResult = docker exec project_db psql -U project_user -d project_db_system -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'hr';" 2>$null
#                 $assetsResult = docker exec project_db psql -U project_user -d project_db_system -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'assets';" 2>$null
#                 $fieldResult = docker exec project_db psql -U project_user -d project_db_system -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'field';" 2>$null
                
#                 Write-ColorOutput Cyan "`nإحصائيات الجداول:"
#                 Write-Host "core: $($coreResult.Trim())"
#                 Write-Host "organization: $($orgResult.Trim())"
#                 Write-Host "hr: $($hrResult.Trim())"
#                 Write-Host "assets: $($assetsResult.Trim())"
#                 Write-Host "field: $($fieldResult.Trim())"
#             } catch {
#                 Write-ColorOutput Yellow "لم يتم العثور على الجداول بعد - قد تحتاج لتشغيل التهيئة"
#             }
#         } else {
#             Write-ColorOutput Red "فشل تشغيل قاعدة البيانات"
#             Write-ColorOutput Yellow "آخر 20 سطر من السجلات:"
#             docker logs project_db --tail 20
#         }
        
#         # العودة للمجلد الأصلي
#         Set-Location -Path $PSScriptRoot
#         break
#     }
    
#     "stop" {
#         Write-ColorOutput Yellow "إيقاف قاعدة البيانات..."
#         $dockerPath = Join-Path $PROJECT_ROOT "infrastructure\docker"
#         if (Test-Path $dockerPath) {
#             Set-Location $dockerPath
#             docker-compose down
#             Write-ColorOutput Green "تم إيقاف جميع الحاويات"
#             Set-Location -Path $PSScriptRoot
#         } else {
#             Write-ColorOutput Red "مجلد docker غير موجود"
#         }
#         break
#     }
    
#     "reset" {
#         Write-ColorOutput Yellow "إعادة تعيين قاعدة البيانات..."
#         $dockerPath = Join-Path $PROJECT_ROOT "infrastructure\docker"
#         if (Test-Path $dockerPath) {
#             Set-Location $dockerPath
#             Write-ColorOutput Yellow "سيتم حذف جميع البيانات!"
#             $confirmation = Read-Host "هل أنت متأكد؟ (y/n)"
#             if ($confirmation -eq 'y') {
#                 docker-compose down -v
#                 docker-compose up -d
#                 Write-ColorOutput Green "تم إعادة تعيين قاعدة البيانات"
#             } else {
#                 Write-ColorOutput Yellow "تم الإلغاء"
#             }
#             Set-Location -Path $PSScriptRoot
#         } else {
#             Write-ColorOutput Red "مجلد docker غير موجود"
#         }
#         break
#     }
    
#     "backup" {
#         Write-ColorOutput Yellow "إنشاء نسخة احتياطية..."
#         $backupScript = Join-Path $PSScriptRoot "backup-database.ps1"
#         if (Test-Path $backupScript) {
#             & $backupScript
#         } else {
#             Write-ColorOutput Red "ملف backup-database.ps1 غير موجود"
#         }
#         break
#     }
    
#     "status" {
#         Write-ColorOutput Cyan "حالة قاعدة البيانات:"
#         $containers = docker ps --filter "name=project_db" --filter "name=project_pgadmin" --filter "name=project_redis" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
#         if ($containers) {
#             Write-Host $containers
#         } else {
#             Write-ColorOutput Yellow "لا توجد حاويات قيد التشغيل"
#         }
#         break
#     }
    
#     "restore" {
#         Write-ColorOutput Yellow "استعادة نسخة احتياطية..."
#         Write-ColorOutput Yellow "الرجاء تحديد ملف النسخة الاحتياطية"
#         break
#     }
    
#     default {
#         Write-ColorOutput Red "أمر غير معروف: $Command"
#         break
#     }
# }

# Write-ColorOutput Cyan "`nانتهى"


param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("start","stop","reset","status")]
    [string]$Command = "start"
)

$PROJECT_ROOT = "E:\PROJECT_DB_SYSTEM_2"
$DOCKER_PATH = Join-Path $PROJECT_ROOT "infrastructure\docker"

function Write-Color($msg,$color="White"){
    Write-Host $msg -ForegroundColor $color
}

function Test-Docker {
    try{
        docker --version | Out-Null
        return $true
    }catch{
        return $false
    }
}

if(!(Test-Docker)){
    Write-Color "Docker غير مثبت على النظام" Red
    exit 1
}

switch ($Command){

# =====================================================
# START
# =====================================================

"start" {

Write-Color "========================================" Cyan
Write-Color "تشغيل قاعدة البيانات" Cyan
Write-Color "========================================" Cyan

if(!(Test-Path $DOCKER_PATH)){
    Write-Color "مجلد docker غير موجود" Red
    exit 1
}

Set-Location $DOCKER_PATH

if(!(Test-Path "docker-compose.yml")){
    Write-Color "ملف docker-compose.yml غير موجود" Red
    exit 1
}

Write-Color "تشغيل الحاويات..." Yellow
docker compose up -d

Write-Color "انتظار جاهزية PostgreSQL..." Yellow
Start-Sleep -Seconds 10

$ready=$false

for($i=0;$i -lt 15;$i++){

    docker exec project_db pg_isready -U project_user >$null 2>&1

    if($LASTEXITCODE -eq 0){
        $ready=$true
        break
    }

    Start-Sleep -Seconds 2
}

if($ready){

Write-Color "قاعدة البيانات جاهزة" Green

Write-Color ""
Write-Color "معلومات الاتصال:" Cyan
Write-Color "Host: localhost:5432"
Write-Color "Database: project_db_system"
Write-Color "User: project_user"
Write-Color "Password: Project@123456"

Write-Color ""
Write-Color "pgAdmin:" Cyan
Write-Color "http://localhost:5050"

Write-Color ""
Write-Color "Redis:" Cyan
Write-Color "localhost:6379"

try{

$test = docker exec project_db psql -U project_user -d project_db_system -t -c "SELECT 1;" 2>$null

if($test){
Write-Color "اختبار الاتصال ناجح" Green
}

}catch{}

}else{

Write-Color "فشل تشغيل قاعدة البيانات" Red
docker logs project_db --tail 20

}

Set-Location $PSScriptRoot

break
}

# =====================================================
# STOP
# =====================================================

"stop" {

Write-Color "ايقاف الحاويات..." Yellow

if(Test-Path $DOCKER_PATH){

Set-Location $DOCKER_PATH
docker compose down

Write-Color "تم ايقاف الحاويات" Green

Set-Location $PSScriptRoot

}else{

Write-Color "مجلد docker غير موجود" Red

}

break
}

# =====================================================
# RESET
# =====================================================

"reset" {

Write-Color "تحذير: سيتم حذف جميع البيانات" Red

$confirm = Read-Host "هل تريد المتابعة؟ (y/n)"

if($confirm -ne "y"){
Write-Color "تم الإلغاء"
break
}

Set-Location $DOCKER_PATH

Write-Color "حذف الحاويات والبيانات..." Yellow

docker compose down -v

docker volume prune -f >$null

Write-Color "إعادة تشغيل الحاويات..." Yellow

docker compose up -d

Start-Sleep 10

Write-Color "تم إعادة تعيين قاعدة البيانات" Green

Set-Location $PSScriptRoot

break
}

# =====================================================
# STATUS
# =====================================================

"status" {

Write-Color "حالة الحاويات:" Cyan

docker ps --filter "name=project" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

break
}

}

Write-Color ""
Write-Color "انتهى التنفيذ" Cyan