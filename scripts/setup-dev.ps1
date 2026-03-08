 
 
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Development environment setup script for PROJECT_DB_SYSTEM
.DESCRIPTION
    Sets up the complete development environment including Docker containers,
    database initialization, and dependencies installation
.EXAMPLE
    ./setup-dev.ps1 -SkipDocker
    ./setup-dev.ps1 -ResetDatabase
#>

param(
    [switch]$SkipDocker,
    [switch]$ResetDatabase,
    [switch]$SkipFrontend,
    [switch]$SkipBackend
)

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.ForegroundColor = "Green"

Write-Host "🚀 Starting PROJECT_DB_SYSTEM development environment setup..." -ForegroundColor Cyan

# Function to check if command exists
function Test-Command($command) {
    $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

# Check prerequisites
Write-Host "`n📋 Checking prerequisites..." -ForegroundColor Yellow

if (-not (Test-Command docker)) {
    Write-Error "Docker is not installed. Please install Docker Desktop first."
    exit 1
}

if (-not (Test-Command node)) {
    Write-Error "Node.js is not installed. Please install Node.js first."
    exit 1
}

if (-not (Test-Command dotnet)) {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK first."
    exit 1
}

Write-Host "✅ Prerequisites check passed" -ForegroundColor Green

# Docker setup
if (-not $SkipDocker) {
    Write-Host "`n🐳 Setting up Docker containers..." -ForegroundColor Yellow
    
    # Navigate to infrastructure/docker
    Push-Location "$PSScriptRoot/../infrastructure/docker"
    
    # Stop existing containers if reset requested
    if ($ResetDatabase) {
        Write-Host "Resetting Docker containers..." -ForegroundColor Yellow
        docker-compose down -v
    }
    
    # Start Docker containers
    Write-Host "Starting Docker containers..." -ForegroundColor Yellow
    docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to start Docker containers"
        exit 1
    }
    
    Write-Host "✅ Docker containers started successfully" -ForegroundColor Green
    
    # Wait for database to be ready
    Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    Pop-Location
}

# Database initialization
Write-Host "`n🗄️  Initializing database..." -ForegroundColor Yellow

# Run database initialization script
Push-Location "$PSScriptRoot/../database/scripts"
try {
    if ($ResetDatabase) {
        & ".\reset-database.ps1"
    } else {
        & ".\initialize-database.sql"
    }
    
    Write-Host "✅ Database initialized successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to initialize database: $_"
    exit 1
}
finally {
    Pop-Location
}

# Backend setup
if (-not $SkipBackend) {
    Write-Host "`n⚙️  Setting up backend..." -ForegroundColor Yellow
    
    Push-Location "$PSScriptRoot/../backend"
    
    # Restore NuGet packages
    Write-Host "Restoring NuGet packages..." -ForegroundColor Yellow
    dotnet restore
    
    # Apply EF Core migrations
    Write-Host "Applying database migrations..." -ForegroundColor Yellow
    dotnet ef database update --project BE.API
    
    Write-Host "✅ Backend setup completed" -ForegroundColor Green
    
    Pop-Location
}

# Frontend setup
if (-not $SkipFrontend) {
    Write-Host "`n🎨 Setting up frontend..." -ForegroundColor Yellow
    
    Push-Location "$PSScriptRoot/../frontend"
    
    # Install dependencies
    Write-Host "Installing npm packages..." -ForegroundColor Yellow
    npm install
    
    # Install packages dependencies
    Write-Host "Installing shared packages..." -ForegroundColor Yellow
    Push-Location "$PSScriptRoot/../packages/core-abstractions"
    npm install
    npm run build
    
    Pop-Location
    
    Push-Location "$PSScriptRoot/../packages/shared-utils"
    npm install
    npm run build
    
    Pop-Location
    
    Write-Host "✅ Frontend setup completed" -ForegroundColor Green
    
    Pop-Location
}

# Create VS Code workspace settings
Write-Host "`n📝 Configuring VS Code..." -ForegroundColor Yellow

$vscodeSettings = @"
{
    "dotnet.defaultSolution": "PROJECT_DB_SYSTEM_2.sln",
    "files.watcherExclude": {
        "**/target": true,
        "**/bin": true,
        "**/obj": true,
        "**/node_modules": true
    },
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": true
    },
    "dotnet.preferRuntimeForProjectPaths": true,
    "omnisharp.enableEditorConfigSupport": true,
    "omnisharp.enableRoslynAnalyzers": true
}
"@

$vscodeSettings | Out-File -FilePath "$PSScriptRoot/../.vscode/settings.json" -Encoding utf8

# Create launch configurations
$launchConfig = @"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Backend",
            "type": "coreclr",
            "request": "launch",
            "preLaunchTask": "build-backend",
            "program": `${workspaceFolder}/backend/BE.API/bin/Debug/net8.0/BE.API.dll",
            "args": [],
            "cwd": `${workspaceFolder}/backend/BE.API`,
            "stopAtEntry": false,
            "env": {
                "ASPNETCORE_ENVIRONMENT": "Development"
            }
        },
        {
            "name": "Launch Frontend",
            "type": "chrome",
            "request": "launch",
            "url": "http://localhost:3000",
            "webRoot": `${workspaceFolder}/frontend/src`
        }
    ]
}
"@

$launchConfig | Out-File -FilePath "$PSScriptRoot/../.vscode/launch.json" -Encoding utf8

Write-Host "`n🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Start backend: dotnet run --project backend/BE.API"
Write-Host "2. Start frontend: cd frontend && npm run dev"
Write-Host "3. Access the application:"
Write-Host "   - Frontend: http://localhost:3000"
Write-Host "   - Backend API: http://localhost:5000"
Write-Host "   - PgAdmin: http://localhost:5050"
Write-Host "   - API Swagger: http://localhost:5000/swagger"