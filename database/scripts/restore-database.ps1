 # =============================================
# FILE: scripts/restore-database.ps1
# PURPOSE: استعادة قاعدة البيانات من نسخة احتياطية
# =============================================

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFile,
    [switch]$Force,
    [switch]$VerifyOnly,
    [string]$LogFile = "restore_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
)

# دالة للتسجيل
function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $logMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Add-Content -Path $LogFile -Value $logMessage
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Message
    $Host.UI.RawUI.ForegroundColor = "White"
}

Write-Log "بدء عملية استعادة قاعدة البيانات..." -Color "Cyan"

# التحقق من وجود الملف
if (-not (Test-Path $BackupFile)) {
    Write-Log "❌ الملف غير موجود: $BackupFile" -Color "Red"
    exit 1
}

# عرض معلومات الملف
$fileInfo = Get-Item $BackupFile
$fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
Write-Log "📄 ملف الاستعادة: $BackupFile" -Color "Cyan"
Write-Log "📊 حجم الملف: $fileSizeMB MB" -Color "Cyan"
Write-Log "📅 تاريخ التعديل: $($fileInfo.LastWriteTime)" -Color "Cyan"

# التأكيد
if (-not $Force) {
    Write-Log "⚠️ تحذير: هذه العملية ستستبدل قاعدة البيانات الحالية!" -Color "Red"
    $confirmation = Read-Host "هل أنت متأكد من الاستمرار؟ (y/n)"
    if ($confirmation -ne 'y') {
        Write-Log "❌ تم الإلغاء" -Color "Red"
        exit
    }
}

try {
    # التحقق من صحة الملف (إذا كان مضغوطاً)
    if ($BackupFile -like "*.zip") {
        Write-Log "📦 فك ضغط الملف..." -Color "Yellow"
        $tempDir = "temp_restore_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Expand-Archive -Path $BackupFile -DestinationPath $tempDir -Force
        
        # البحث عن ملف SQL
        $sqlFile = Get-ChildItem -Path $tempDir -Filter "*.sql" | Select-Object -First 1
        if (-not $sqlFile) {
            throw "لم يتم العثور على ملف SQL داخل الأرشيف"
        }
        
        $restoreSource = $sqlFile.FullName
        Write-Log "✅ تم فك الضغط: $($sqlFile.Name)" -Color "Green"
    } else {
        $restoreSource = $BackupFile
    }
    
    # إيقاف الاتصالات الحالية
    Write-Log "🔌 إيقاف الاتصالات الحالية..." -Color "Yellow"
    docker exec project_db psql -U project_user -c "
        SELECT pg_terminate_backend(pid) 
        FROM pg_stat_activity 
        WHERE datname = 'project_db_system' 
          AND pid <> pg_backend_pid();" 2>$null
    
    if ($VerifyOnly) {
        Write-Log "🔍 جاري التحقق من صحة ملف الاستعادة..." -Color "Yellow"
        
        # محاولة قراءة الملف والتحقق من تركيبه
        $content = Get-Content $restoreSource -First 10
        if ($content -match "PostgreSQL|project_db_system") {
            Write-Log "✅ ملف الاستعادة يبدو سليماً" -Color "Green"
        } else {
            Write-Log "⚠️ ملف الاستعادة قد يكون تالفاً" -Color "Yellow"
        }
    } else {
        # استعادة قاعدة البيانات
        Write-Log "🔄 جاري استعادة قاعدة البيانات..." -Color "Yellow"
        
        # حذف وإعادة إنشاء قاعدة البيانات
        docker exec project_db psql -U project_user -c "DROP DATABASE IF EXISTS project_db_system;"
        docker exec project_db psql -U project_user -c "CREATE DATABASE project_db_system ENCODING 'UTF8' LC_COLLATE 'ar_SA.UTF-8' LC_CTYPE 'ar_SA.UTF-8';"
        
        # استعادة البيانات
        Get-Content $restoreSource | docker exec -i project_db psql -U project_user -d project_db_system -v ON_ERROR_STOP=1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ تم استعادة قاعدة البيانات بنجاح" -Color "Green"
            
            # عرض ملخص بعد الاستعادة
            $summary = docker exec project_db psql -U project_user -d project_db_system -t -c "
                SELECT 
                    '👥 المستخدمين: ' || COUNT(*) FROM core.users
                UNION ALL
                    '🏢 الفروع: ' || COUNT(*) FROM organization.branches
                UNION ALL
                    '👤 الموظفين: ' || COUNT(*) FROM hr.employees;"
            
            Write-Log "📊 ملخص البيانات بعد الاستعادة:" -Color "Cyan"
            Write-Host $summary -ForegroundColor Cyan
        } else {
            throw "فشل استعادة قاعدة البيانات"
        }
    }
    
    # تنظيف الملفات المؤقتة
    if ($BackupFile -like "*.zip" -and (Test-Path $tempDir)) {
        Remove-Item -Path $tempDir -Recurse -Force
        Write-Log "🧹 تم تنظيف الملفات المؤقتة" -Color "Green"
    }
    
    Write-Log "✨ انتهت عملية الاستعادة بنجاح" -Color "Green"
    Write-Log "📝 سجل العملية محفوظ في: $LogFile" -Color "Cyan"
}
catch {
    Write-Log "❌ خطأ في الاستعادة: $_" -Color "Red"
    
    # تنظيف في حالة الخطأ
    if ($BackupFile -like "*.zip" -and (Test-Path $tempDir)) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
    exit 1
}