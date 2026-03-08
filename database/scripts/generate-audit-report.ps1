 
# =============================================
# FILE: scripts/generate-audit-report.ps1
# PURPOSE: إنشاء تقارير التدقيق
# =============================================

param(
    [ValidateSet("daily", "weekly", "monthly", "custom")]
    [string]$ReportType = "daily",
    
    [datetime]$StartDate = (Get-Date).AddDays(-7),
    [datetime]$EndDate = (Get-Date),
    
    [string]$Format = "html", # html, csv, json
    [string]$OutputPath = "..\database\reports",
    [string[]]$Schemas = @("core", "organization", "hr", "assets", "field"),
    [switch]$IncludeDetails,
    [switch]$SendEmail
)

# إعدادات
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "audit_report_$($ReportType)_$timestamp.$Format"
$fullReportPath = "$OutputPath\$reportFile"

# إنشاء مجلد التقارير إذا لم يكن موجوداً
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# دالة لجلب البيانات من قاعدة البيانات
function Get-AuditStats {
    param([string]$FromDate, [string]$ToDate, [string]$Schema)
    
    $query = @"
    SELECT * FROM audit.get_audit_statistics(
        '$FromDate'::DATE,
        '$ToDate'::DATE,
        '$Schema'
    );
"@
    
    $result = docker exec project_db psql -U project_user -d project_db_system -t -A -F"," -c "$query"
    return $result
}

# دالة لجلب تفاصيل المستخدمين النشطين
function Get-ActiveUsers {
    param([string]$FromDate, [string]$ToDate)
    
    $query = @"
    SELECT 
        changed_by,
        COUNT(*) as action_count,
        MIN(changed_at) as first_action,
        MAX(changed_at) as last_action
    FROM audit.audit_log
    WHERE changed_at::DATE BETWEEN '$FromDate' AND '$ToDate'
    GROUP BY changed_by
    ORDER BY action_count DESC
    LIMIT 10;
"@
    
    $result = docker exec project_db psql -U project_user -d project_db_system -t -A -F"," -c "$query"
    return $result
}

# تحديد نطاق التاريخ حسب نوع التقرير
switch ($ReportType) {
    "daily" {
        $EndDate = Get-Date
        $StartDate = $EndDate.AddDays(-1)
    }
    "weekly" {
        $EndDate = Get-Date
        $StartDate = $EndDate.AddDays(-7)
    }
    "monthly" {
        $EndDate = Get-Date
        $StartDate = $EndDate.AddMonths(-1)
    }
}

$fromDateStr = $StartDate.ToString("yyyy-MM-dd")
$toDateStr = $EndDate.ToString("yyyy-MM-dd")

Write-Host "📊 إنشاء تقرير تدقيق" -ForegroundColor Cyan
Write-Host "📅 الفترة: $fromDateStr إلى $toDateStr" -ForegroundColor Cyan
Write-Host "📁 نوع التقرير: $ReportType" -ForegroundColor Cyan
Write-Host "📄 صيغة المخرجات: $Format" -ForegroundColor Cyan

# جمع الإحصائيات
$allStats = @()
$schemasStats = @{}

foreach ($schema in $Schemas) {
    Write-Host "🔄 جلب إحصائيات $schema..." -ForegroundColor Yellow
    $stats = Get-AuditStats -FromDate $fromDateStr -ToDate $toDateStr -Schema $schema
    if ($stats) {
        $schemasStats[$schema] = $stats
        $allStats += $stats
    }
}

# جلب المستخدمين النشطين
$activeUsers = Get-ActiveUsers -FromDate $fromDateStr -ToDate $toDateStr

# إنشاء التقرير حسب الصيغة المطلوبة
switch ($Format) {
    "html" {
        $html = @"
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <title>تقرير التدقيق - $ReportType</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .summary { background: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .stat-card { background: white; padding: 20px; border-radius: 10px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stat-value { font-size: 2em; font-weight: bold; color: #667eea; }
        .stat-label { color: #666; margin-top: 10px; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th { background: #667eea; color: white; padding: 12px; text-align: center; }
        td { padding: 10px; border-bottom: 1px solid #ddd; text-align: center; }
        tr:hover { background-color: #f5f5f5; }
        .footer { margin-top: 20px; text-align: center; color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 تقرير التدقيق</h1>
        <p>الفترة: $fromDateStr إلى $toDateStr</p>
        <p>نوع التقرير: $ReportType</p>
        <p>تاريخ الإنشاء: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>
    
    <div class="summary">
        <h2>ملخص عام</h2>
"@
        
        # إضافة الإحصائيات العامة
        $totalChanges = ($allStats | Measure-Object -Property total_changes -Sum).Sum
        $totalInserts = ($allStats | Measure-Object -Property inserts -Sum).Sum
        $totalUpdates = ($allStats | Measure-Object -Property updates -Sum).Sum
        $totalDeletes = ($allStats | Measure-Object -Property deletes -Sum).Sum
        $uniqueUsers = ($allStats | Measure-Object -Property unique_users -Sum).Sum
        
        $html += @"
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value">$totalChanges</div>
                <div class="stat-label">إجمالي التغييرات</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$totalInserts</div>
                <div class="stat-label">إضافات</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$totalUpdates</div>
                <div class="stat-label">تحديثات</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$totalDeletes</div>
                <div class="stat-label">حذف</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$uniqueUsers</div>
                <div class="stat-label">مستخدمين نشطين</div>
            </div>
        </div>
    </div>
    
    <h2>تفاصيل التغييرات حسب الجدول</h2>
    <table>
        <thead>
            <tr>
                <th>الـ Schema</th>
                <th>الجدول</th>
                <th>إجمالي</th>
                <th>إضافات</th>
                <th>تحديثات</th>
                <th>حذف</th>
                <th>مستخدمين</th>
                <th>أول تغيير</th>
                <th>آخر تغيير</th>
            </tr>
        </thead>
        <tbody>
"@
        
        foreach ($line in $allStats) {
            $parts = $line -split ','
            if ($parts.Count -ge 9) {
                $html += @"
            <tr>
                <td>$($parts[0])</td>
                <td>$($parts[1])</td>
                <td>$($parts[2])</td>
                <td>$($parts[3])</td>
                <td>$($parts[4])</td>
                <td>$($parts[5])</td>
                <td>$($parts[6])</td>
                <td>$($parts[7])</td>
                <td>$($parts[8])</td>
            </tr>
"@
            }
        }
        
        $html += @"
        </tbody>
    </table>
    
    <h2>أكثر المستخدمين نشاطاً</h2>
    <table>
        <thead>
            <tr>
                <th>المستخدم</th>
                <th>عدد الإجراءات</th>
                <th>أول نشاط</th>
                <th>آخر نشاط</th>
            </tr>
        </thead>
        <tbody>
"@
        
        foreach ($line in $activeUsers) {
            $parts = $line -split ','
            if ($parts.Count -ge 4) {
                $html += @"
            <tr>
                <td>$($parts[0])</td>
                <td>$($parts[1])</td>
                <td>$($parts[2])</td>
                <td>$($parts[3])</td>
            </tr>
"@
            }
        }
        
        $html += @"
        </tbody>
    </table>
    
    <div class="footer">
        <p>تم إنشاء هذا التقرير تلقائياً بواسطة نظام التدقيق</p>
    </div>
</body>
</html>
"@
        
        Set-Content -Path $fullReportPath -Value $html
    }
    
    "csv" {
        $csvContent = "schema,table,total_changes,inserts,updates,deletes,unique_users,first_change,last_change"
        foreach ($line in $allStats) {
            $csvContent += "`n$line"
        }
        Set-Content -Path $fullReportPath -Value $csvContent
    }
    
    "json" {
        $jsonData = @{
            report_type = $ReportType
            from_date = $fromDateStr
            to_date = $toDateStr
            generated_at = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            summary = @{
                total_changes = $totalChanges
                inserts = $totalInserts
                updates = $totalUpdates
                deletes = $totalDeletes
                unique_users = $uniqueUsers
            }
            details = @()
            active_users = @()
        }
        
        foreach ($line in $allStats) {
            $parts = $line -split ','
            if ($parts.Count -ge 9) {
                $jsonData.details += @{
                    schema = $parts[0]
                    table = $parts[1]
                    total_changes = [int]$parts[2]
                    inserts = [int]$parts[3]
                    updates = [int]$parts[4]
                    deletes = [int]$parts[5]
                    unique_users = [int]$parts[6]
                    first_change = $parts[7]
                    last_change = $parts[8]
                }
            }
        }
        
        foreach ($line in $activeUsers) {
            $parts = $line -split ','
            if ($parts.Count -ge 4) {
                $jsonData.active_users += @{
                    username = $parts[0]
                    action_count = [int]$parts[1]
                    first_action = $parts[2]
                    last_action = $parts[3]
                }
            }
        }
        
        $jsonData | ConvertTo-Json -Depth 10 | Set-Content $fullReportPath
    }
}

Write-Host "✅ تم إنشاء التقرير: $fullReportPath" -ForegroundColor Green

# إرسال البريد الإلكتروني إذا طلب
if ($SendEmail) {
    # هنا يمكن إضافة كود إرسال البريد الإلكتروني
    Write-Host "📧 سيتم إرسال التقرير عبر البريد الإلكتروني..." -ForegroundColor Yellow
    # Send-MailMessage -To "admin@project.com" -Subject "تقرير التدقيق" -Body "..." -Attachments $fullReportPath
}

# عرض حجم التقرير
$reportFileInfo = Get-Item $fullReportPath
$reportSize = [math]::Round($reportFileInfo.Length / 1KB, 2)
Write-Host "📦 حجم التقرير: $reportSize KB" -ForegroundColor Cyan