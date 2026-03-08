using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace BE.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GatewayController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<GatewayController> _logger;
    private readonly HttpClient _httpClient;

    public GatewayController(
        IConfiguration configuration,
        ILogger<GatewayController> logger,
        IHttpClientFactory httpClientFactory)
    {
        _configuration = configuration;
        _logger = logger;
        _httpClient = httpClientFactory.CreateClient();
    }

    [HttpGet("modules")]
    public IActionResult GetModules()
    {
        var modules = new[]
        {
            new { id = 1, name = "Core", version = "1.0.0", status = "active" },
            new { id = 2, name = "Organization", version = "1.0.0", status = "active" },
            new { id = 3, name = "HR", version = "1.0.0", status = "active" },
            new { id = 4, name = "Assets", version = "1.0.0", status = "active" },
            new { id = 5, name = "Field", version = "1.0.0", status = "active" }
        };

        return Ok(new
        {
            success = true,
            data = modules,
            timestamp = DateTime.UtcNow
        });
    }

    [HttpGet("info")]
    public IActionResult GetSystemInfo()
    {
        return Ok(new
        {
            systemName = "PROJECT DB SYSTEM",
            version = "2.0.0",
            environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production",
            apiVersion = "v1",
            timestamp = DateTime.UtcNow
        });
    }

    [HttpPost("proxy/{module}/{*path}")]
    public async Task<IActionResult> ProxyRequest(
        string module, 
        string path, 
        CancellationToken cancellationToken)
    {
        try
        {
            var targetUrl = BuildTargetUrl(module, path);
            
            using var requestMessage = new HttpRequestMessage
            {
                Method = new HttpMethod(Request.Method),
                RequestUri = new Uri(targetUrl)
            };

            // Copy headers
            foreach (var header in Request.Headers)
            {
                if (!requestMessage.Headers.TryAddWithoutValidation(header.Key, header.Value.ToArray()))
                {
                    requestMessage.Content?.Headers.TryAddWithoutValidation(header.Key, header.Value.ToArray());
                }
            }

            // Copy body for POST/PUT
            if (Request.Method == "POST" || Request.Method == "PUT")
            {
                var content = await GetRequestBody();
                requestMessage.Content = new StringContent(content, System.Text.Encoding.UTF8, "application/json");
            }

            var response = await _httpClient.SendAsync(requestMessage, cancellationToken);
            var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

            return StatusCode((int)response.StatusCode, responseContent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error proxying request to {Module}/{Path}", module, path);
            return StatusCode(500, new { error = "Gateway error", message = ex.Message });
        }
    }

    private string BuildTargetUrl(string module, string path)
    {
        var modulePorts = new Dictionary<string, int>
        {
            ["core"] = 5001,
            ["organization"] = 5002,
            ["hr"] = 5003,
            ["assets"] = 5004,
            ["field"] = 5005
        };

        var port = modulePorts.GetValueOrDefault(module.ToLower(), 5000);
        return $"http://localhost:{port}/api/{path}";
    }

    private async Task<string> GetRequestBody()
    {
        using var reader = new StreamReader(Request.Body, leaveOpen: true);
        var body = await reader.ReadToEndAsync();
        Request.Body.Position = 0; // Reset for potential further reading
        return body;
    }
}