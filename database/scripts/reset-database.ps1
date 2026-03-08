 
# =============================================
# FILE: scripts/reset-database.ps1
# PURPOSE: إعادة تعيين قاعدة البيانات بالكامل مع تسجيل
# =============================================

param(
    [switch]$Force,
    [switch]$BackupBeforeReset,
    [string]$LogFile = "reset_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
)

# إعدادات الألوان
$Host.UI.RawUI.ForegroundColor = "Cyan"
Write-Host "========================================"
Write-Host "    إعادة تعيين قاعدة البيانات"
Write-Host "========================================"
$Host.UI.RawUI.ForegroundColor = "White"

# دالة للتسجيل في الملف
function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Add-Content -Path $LogFile -Value $logMessage
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Message
    $Host.UI.RawUI.ForegroundColor = "White"
}

# دالة للتأكيد
function Confirm-Action {
    param([string]$Message)
    $response = Read-Host "$Message (y/n)"
    return $response -eq 'y'
}

Write-Log "بدء عملية إعادة تعيين قاعدة البيانات..." -Color "Yellow"

# التحقق من وجود Docker
$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerInstalled) {
    Write-Log "❌ Docker غير مثبت على النظام" -Color "Red"
    exit 1
}

# التحقق من تشغيل الحاوية
$containerRunning = docker ps --filter "name=project_db" --filter "status=running" -q
if (-not $containerRunning) {
    Write-Log "⚠️ حاوية قاعدة البيانات غير قيد التشغيل" -Color "Yellow"
    $startContainer = Confirm-Action "هل تريد تشغيلها الآن؟"
    if ($startContainer) {
        Write-Log "جاري تشغيل حاوية قاعدة البيانات..." -Color "Yellow"
        cd ..\docker
        docker-compose up -d
        Start-Sleep -Seconds 10
    } else {
        Write-Log "❌ تم الإلغاء" -Color "Red"
        exit 1
    }
}

# التأكيد
if (-not $Force) {
    Write-Log "⚠️ تحذير: هذه العملية ستحذف جميع البيانات!" -Color "Red"
    $confirmation = Confirm-Action "هل أنت متأكد من الاستمرار؟"
    if (-not $confirmation) {
        Write-Log "❌ تم الإلغاء" -Color "Red"
        exit
    }
}

# عمل نسخة احتياطية قبل المسح
if ($BackupBeforeReset) {
    Write-Log "💾 جاري إنشاء نسخة احتياطية قبل المسح..." -Color "Yellow"
    $backupFile = "pre_reset_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
    
    try {
        docker exec project_db pg_dump -U project_user -d project_db_system > $backupFile
        Write-Log "✅ تم إنشاء النسخة الاحتياطية: $backupFile" -Color "Green"
        
        # ضغط الملف
        Compress-Archive -Path $backupFile -DestinationPath "$backupFile.zip" -Force
        Remove-Item $backupFile
        Write-Log "✅ تم ضغط النسخة الاحتياطية" -Color "Green"
    }
    catch {
        Write-Log "❌ فشل إنشاء النسخة الاحتياطية: $_" -Color "Red"
        $continue = Confirm-Action "هل تريد المتابعة بدون نسخة احتياطية؟"
        if (-not $continue) {
            exit 1
        }
    }
}

try {
    # إيقاف الاتصالات الحالية
    Write-Log "🔌 إيقاف الاتصالات الحالية..." -Color "Yellow"
    docker exec project_db psql -U project_user -c "
        SELECT pg_terminate_backend(pid) 
        FROM pg_stat_activity 
        WHERE datname = 'project_db_system' 
          AND pid <> pg_backend_pid();" 2>$null
    
    # إعادة تعيين قاعدة البيانات
    Write-Log "🔄 جاري إعادة تعيين قاعدة البيانات..." -Color "Yellow"
    
    # حذف وإعادة إنشاء قاعدة البيانات
    docker exec project_db psql -U project_user -c "DROP DATABASE IF EXISTS project_db_system;"
    docker exec project_db psql -U project_user -c "CREATE DATABASE project_db_system ENCODING 'UTF8' LC_COLLATE 'ar_SA.UTF-8' LC_CTYPE 'ar_SA.UTF-8';"
    
    # إعادة التهيئة
    Write-Log "🚀 جاري تهيئة قاعدة البيانات..." -Color "Yellow"
    
    # تشغيل سكريبت التهيئة
    Get-Content .\initialize-database.sql | docker exec -i project_db psql -U project_user -d project_db_system -v ON_ERROR_STOP=1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✅ تم إعادة تعيين قاعدة البيانات بنجاح" -Color "Green"
        
        # عرض ملخص
        $summary = docker exec project_db psql -U project_user -d project_db_system -t -c "
            SELECT 
                '👥 المستخدمين: ' || COUNT(*) FROM core.users
            UNION ALL
            SELECT 
                '🏢 الفروع: ' || COUNT(*) FROM organization.branches
            UNION ALL
            SELECT 
                '👤 الموظفين: ' || COUNT(*) FROM hr.employees;"
        
        Write-Log "📊 ملخص البيانات:" -Color "Cyan"
        Write-Host $summary -ForegroundColor Cyan
    } else {
        throw "فشل تنفيذ سكريبت التهيئة"
    }
}
catch {
    Write-Log "❌ خطأ: $_" -Color "Red"
    exit 1
}

Write-Log "✨ انتهت عملية إعادة التعيين بنجاح" -Color "Green"
Write-Log "📝 سجل العملية محفوظ في: $LogFile" -Color "Cyan"