# =============================================
# FILE: scripts/backup-database.ps1
# PURPOSE: إنشاء نسخة احتياطية من قاعدة البيانات مع timestamp
# =============================================

param(
    [string]$BackupPath = "..\database\backups",
    [switch]$Compress,
    [switch]$IncludeBlobs,
    [int]$RetentionDays = 30,
    [string]$BackupType = "full" # full, schema-only, data-only
)

# إعدادات
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFile = "backup_$timestamp"
$logFile = "backup_log_$timestamp.txt"

# دالة للتسجيل
function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $logMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Add-Content -Path $logFile -Value $logMessage
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Message
    $Host.UI.RawUI.ForegroundColor = "White"
}

Write-Log "بدء عملية النسخ الاحتياطي..." -Color "Cyan"

# إنشاء مجلد النسخ إذا لم يكن موجوداً
if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    Write-Log "📁 تم إنشاء مجلد النسخ: $BackupPath" -Color "Green"
}

try {
    # تحديد خيارات pg_dump حسب نوع النسخة
    $dumpOptions = "-U project_user -d project_db_system --clean --if-exists"
    
    switch ($BackupType) {
        "schema-only" {
            $dumpOptions += " --schema-only"
            $backupFile += "_schema.sql"
            Write-Log "📋 وضع النسخ: هيكل فقط" -Color "Yellow"
        }
        "data-only" {
            $dumpOptions += " --data-only"
            $backupFile += "_data.sql"
            Write-Log "📋 وضع النسخ: بيانات فقط" -Color "Yellow"
        }
        default {
            $backupFile += "_full.sql"
            Write-Log "📋 وضع النسخ: كامل" -Color "Yellow"
        }
    }
    
    $fullBackupPath = "$BackupPath\$backupFile"
    
    # إنشاء النسخة الاحتياطية
    Write-Log "💾 جاري إنشاء النسخة الاحتياطية..." -Color "Yellow"
    
    # استخدام pg_dump داخل الحاوية
    $command = "docker exec project_db pg_dump $dumpOptions"
    Write-Log "🖥️ تنفيذ: $command" -Color "Gray"
    
    Invoke-Expression "$command > `"$fullBackupPath`""
    
    if ($LASTEXITCODE -ne 0) {
        throw "فشل إنشاء النسخة الاحتياطية"
    }
    
    # الحصول على حجم الملف
    $fileInfo = Get-Item $fullBackupPath
    $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    
    Write-Log "✅ تم إنشاء النسخة: $backupFile" -Color "Green"
    Write-Log "📊 حجم الملف: $fileSizeMB MB" -Color "Cyan"
    
    # ضغط الملف إذا طلب
    if ($Compress) {
        Write-Log "🗜️ جاري ضغط الملف..." -Color "Yellow"
        $zipFile = "$fullBackupPath.zip"
        Compress-Archive -Path $fullBackupPath -DestinationPath $zipFile -Force
        Remove-Item $fullBackupPath
        
        $zipInfo = Get-Item $zipFile
        $zipSizeMB = [math]::Round($zipInfo.Length / 1MB, 2)
        $compressionRatio = [math]::Round((1 - $zipSizeMB/$fileSizeMB) * 100, 2)
        
        Write-Log "✅ تم ضغط الملف بنجاح" -Color "Green"
        Write-Log "📦 حجم الملف المضغوط: $zipSizeMB MB (نسبة الضغط: $compressionRatio%)" -Color "Cyan"
    }
    
    # إنشاء ملف معلومات
    $infoFile = "$BackupPath\info_$timestamp.json"
    $info = @{
        timestamp = $timestamp
        type = $BackupType
        size_mb = $fileSizeMB
        compressed = $Compress
        tables = @()
    }
    
    # الحصول على قائمة الجداول
    $tables = docker exec project_db psql -U project_user -d project_db_system -t -c "
        SELECT schemaname || '.' || tablename 
        FROM pg_tables 
        WHERE schemaname IN ('core', 'organization', 'hr', 'assets', 'field')
        ORDER BY schemaname, tablename;"
    
    $info.tables = $tables -split "`n" | Where-Object { $_ -ne "" }
    
    $info | ConvertTo-Json | Set-Content $infoFile
    Write-Log "📄 تم إنشاء ملف المعلومات: info_$timestamp.json" -Color "Green"
    
    # تنظيف النسخ القديمة
    if ($RetentionDays -gt 0) {
        Write-Log "🧹 جاري تنظيف النسخ الأقدم من $RetentionDays يوم..." -Color "Yellow"
        $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
        
        Get-ChildItem -Path $BackupPath -Filter "backup_*" | Where-Object {
            $_.CreationTime -lt $cutoffDate
        } | ForEach-Object {
            Remove-Item $_.FullName -Force
            Write-Log "🗑️ تم حذف: $($_.Name)" -Color "Gray"
        }
    }
    
    Write-Log "✨ انتهت عملية النسخ الاحتياطي بنجاح" -Color "Green"
    Write-Log "📝 سجل العملية محفوظ في: $logFile" -Color "Cyan"
}
catch {
    Write-Log "❌ خطأ في إنشاء النسخة: $_" -Color "Red"
    exit 1
} 
