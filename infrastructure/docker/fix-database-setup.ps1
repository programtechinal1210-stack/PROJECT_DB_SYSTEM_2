# fix-database-setup.ps1
Write-Host "=== Fixing database setup ===" -ForegroundColor Cyan

$container = "project_db_postgres"
$dbName = "project_db_system"

# 1. ????? ????? ???????? ??????
Write-Host "Creating database $dbName..." -ForegroundColor Yellow
docker exec $container psql -U postgres -c "CREATE DATABASE $dbName;" 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "Database created successfully" -ForegroundColor Green
} else {
    Write-Host "Database may already exist" -ForegroundColor Yellow
}

# 2. ????? ????? bootstrap
Write-Host "
Running bootstrap files..." -ForegroundColor Yellow

# schemas
Get-Content "E:\PROJECT_DB_SYSTEM_2\database\bootstrap\02-create-schemas.sql" | docker exec -i $container psql -U postgres -d $dbName
Write-Host "Schemas completed" -ForegroundColor Green

# extensions
Get-Content "E:\PROJECT_DB_SYSTEM_2\database\bootstrap\04-create-extensions.sql" | docker exec -i $container psql -U postgres -d $dbName
Write-Host "Extensions completed" -ForegroundColor Green

# 3. ??????
Write-Host "
Verification:" -ForegroundColor Cyan
docker exec $container psql -U postgres -d $dbName -c "\dn"

Write-Host "
Database setup fixed!" -ForegroundColor Green
