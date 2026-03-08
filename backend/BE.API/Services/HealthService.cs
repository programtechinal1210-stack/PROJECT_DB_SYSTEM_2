using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Reflection;

namespace BE.API.Services;

public class HealthService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<HealthService> _logger;
    private readonly IServiceProvider _serviceProvider;

    public HealthService(
        IConfiguration configuration,
        ILogger<HealthService> logger,
        IServiceProvider serviceProvider)
    {
        _configuration = configuration;
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    public async Task<object> CheckHealthAsync()
    {
        var checks = new Dictionary<string, object>
        {
            ["timestamp"] = DateTime.UtcNow,
            ["environment"] = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production",
            ["version"] = GetVersion()
        };

        var dependencies = await CheckDependenciesAsync();
        checks["dependencies"] = dependencies;

        var overallStatus = dependencies.All(d => 
        {
            var status = d.Value?.GetType().GetProperty("status")?.GetValue(d.Value)?.ToString();
            return status == "healthy";
        }) ? "healthy" : "degraded";

        checks["status"] = overallStatus;

        return checks;
    }

    public async Task<bool> IsReadyAsync()
    {
        try
        {
            var dependencies = await CheckDependenciesAsync();
            return dependencies.All(d => 
            {
                var status = d.Value?.GetType().GetProperty("status")?.GetValue(d.Value)?.ToString();
                return status == "healthy" || status == "degraded";
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Readiness check failed");
            return false;
        }
    }

    public async Task<Dictionary<string, object>> CheckDependenciesAsync()
    {
        var dependencies = new Dictionary<string, object>();

        try
        {
            using var scope = _serviceProvider.CreateScope();
            var healthCheckService = scope.ServiceProvider.GetRequiredService<HealthCheckService>();
            var report = await healthCheckService.CheckHealthAsync();

            foreach (var entry in report.Entries)
            {
                dependencies[entry.Key] = new
                {
                    status = entry.Value.Status.ToString().ToLower(),
                    description = entry.Value.Description,
                    duration = entry.Value.Duration,
                    exception = entry.Value.Exception?.Message,
                    data = entry.Value.Data
                };
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to check dependency health");
            dependencies["database"] = new
            {
                status = "unhealthy",
                error = ex.Message
            };
        }

        return dependencies;
    }

    private string GetVersion()
    {
        var assembly = Assembly.GetEntryAssembly();
        return assembly?
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?
            .InformationalVersion ?? "1.0.0";
    }
}