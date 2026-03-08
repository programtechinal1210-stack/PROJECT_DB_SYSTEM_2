 using BE.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace BE.API.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly HealthService _healthService;
    private readonly ILogger<HealthController> _logger;

    public HealthController(HealthService healthService, ILogger<HealthController> logger)
    {
        _healthService = healthService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetHealth()
    {
        var healthStatus = await _healthService.CheckHealthAsync();
        return Ok(healthStatus);
    }

    [HttpGet("live")]
    public IActionResult GetLiveness()
    {
        return Ok(new 
        { 
            status = "alive", 
            timestamp = DateTime.UtcNow 
        });
    }

    [HttpGet("ready")]
    public async Task<IActionResult> GetReadiness()
    {
        var isReady = await _healthService.IsReadyAsync();
        
        if (!isReady)
            return StatusCode(503, new { status = "not ready", timestamp = DateTime.UtcNow });

        return Ok(new { status = "ready", timestamp = DateTime.UtcNow });
    }

    [HttpGet("dependencies")]
    public async Task<IActionResult> GetDependenciesHealth()
    {
        var dependencies = await _healthService.CheckDependenciesAsync();
        return Ok(dependencies);
    }
}
