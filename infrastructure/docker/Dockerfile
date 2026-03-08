 
# Backend Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY Directory.Build.props .
COPY global.json .
COPY BE.API/*.csproj BE.API/
COPY Modules/01-Core.Module/*.csproj Modules/01-Core.Module/
COPY Modules/02-Organization.Module/*.csproj Modules/02-Organization.Module/
COPY Modules/03-HR.Module/*.csproj Modules/03-HR.Module/
COPY Modules/04-Assets.Module/*.csproj Modules/04-Assets.Module/
COPY Modules/05-Field.Module/*.csproj Modules/05-Field.Module/

# Restore dependencies
RUN dotnet restore BE.API/BE.API.csproj

# Copy everything else and build
COPY . .
WORKDIR /src/BE.API
RUN dotnet publish -c Release -o /app/publish

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Install curl for healthchecks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .

# Create non-root user
RUN addgroup --system --gid 1000 appgroup && \
    adduser --system --uid 1000 --gid 1000 appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

ENTRYPOINT ["dotnet", "BE.API.dll"]