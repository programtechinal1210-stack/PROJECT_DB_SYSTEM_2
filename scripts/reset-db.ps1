#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Reset database script
.DESCRIPTION
    Drops and recreates the database with all migrations and seed data
#>

$ErrorActionPreference = "Stop"

Write-Host "⚠️  WARNING: This will delete all data in the database!" -ForegroundColor Red
$confirmation = Read-Host "Are you sure you want to continue? (y/N)"

if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n🔄 Resetting database..." -ForegroundColor Yellow

# Stop and remove containers
Push-Location "$PSScriptRoot/../infrastructure/docker"
docker-compose down -v
docker-compose up -d postgres redis
Pop-Location

Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Run migrations
Push-Location "$PSScriptRoot/../backend"
Write-Host "Dropping database..." -ForegroundColor Yellow
dotnet ef database drop --force --project BE.API

Write-Host "Creating database..." -ForegroundColor Yellow
dotnet ef database update --project BE.API
Pop-Location

# Run seed scripts
Push-Location "$PSScriptRoot/../database"
Write-Host "Running seed scripts..." -ForegroundColor Yellow
Get-ChildItem -Path seeds -Recurse -Filter *.sql | Sort-Object Name | ForEach-Object {
    Write-Host "Seeding: $($_.Name)" -ForegroundColor Gray
    & "psql" -U project_user -d project_db -h localhost -f $_.FullName
}
Pop-Location

Write-Host "✅ Database reset completed successfully!" -ForegroundColor Green