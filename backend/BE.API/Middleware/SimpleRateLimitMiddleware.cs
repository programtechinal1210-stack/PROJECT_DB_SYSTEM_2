 
using Microsoft.Extensions.Caching.Memory;

namespace BE.API.Middleware;

public class SimpleRateLimitMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IMemoryCache _cache;
    private readonly IConfiguration _configuration;
    private readonly ILogger<SimpleRateLimitMiddleware> _logger;

    private readonly int _permitLimit;
    private readonly int _windowInSeconds;
    private readonly int _queueLimit;
    private readonly bool _enabled;

    public SimpleRateLimitMiddleware(
        RequestDelegate next,
        IMemoryCache cache,
        IConfiguration configuration,
        ILogger<SimpleRateLimitMiddleware> logger)
    {
        _next = next;
        _cache = cache;
        _configuration = configuration;
        _logger = logger;

        var rateLimitConfig = configuration.GetSection("RateLimiting");
        _enabled = rateLimitConfig.GetValue<bool>("Enabled");
        _permitLimit = rateLimitConfig.GetValue<int>("PermitLimit");
        _windowInSeconds = rateLimitConfig.GetValue<int>("WindowInSeconds");
        _queueLimit = rateLimitConfig.GetValue<int>("QueueLimit");
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (!_enabled)
        {
            await _next(context);
            return;
        }

        // Skip rate limiting for health checks
        if (context.Request.Path.StartsWithSegments("/health"))
        {
            await _next(context);
            return;
        }

        var clientId = GetClientIdentifier(context);
        var cacheKey = $"rate_limit_{clientId}";

        var rateLimitInfo = await _cache.GetOrCreateAsync(cacheKey, entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(_windowInSeconds);
            return Task.FromResult(new RateLimitInfo
            {
                Count = 1,
                WindowStart = DateTime.UtcNow
            });
        });

        if (rateLimitInfo!.Count > _permitLimit)
        {
            var retryAfter = _windowInSeconds - (int)(DateTime.UtcNow - rateLimitInfo.WindowStart).TotalSeconds;
            
            context.Response.StatusCode = 429;
            context.Response.Headers.Append("Retry-After", retryAfter.ToString());
            
            _logger.LogWarning("Rate limit exceeded for client {ClientId}", clientId);
            
            await context.Response.WriteAsJsonAsync(new
            {
                error = "Too Many Requests",
                message = $"Rate limit exceeded. Try again in {retryAfter} seconds.",
                retryAfter
            });
            
            return;
        }

        // Increment counter
        rateLimitInfo.Count++;
        _cache.Set(cacheKey, rateLimitInfo, TimeSpan.FromSeconds(_windowInSeconds));

        // Add rate limit headers
        context.Response.OnStarting(() =>
        {
            context.Response.Headers.Append("X-RateLimit-Limit", _permitLimit.ToString());
            context.Response.Headers.Append("X-RateLimit-Remaining", (_permitLimit - rateLimitInfo.Count + 1).ToString());
            context.Response.Headers.Append("X-RateLimit-Reset", 
                ((int)(rateLimitInfo.WindowStart.AddSeconds(_windowInSeconds) - DateTime.UtcNow).TotalSeconds).ToString());
            
            return Task.CompletedTask;
        });

        await _next(context);
    }

    private string GetClientIdentifier(HttpContext context)
    {
        // Try to get user ID from authenticated user
        var userId = context.User?.FindFirst("sub")?.Value;
        if (!string.IsNullOrEmpty(userId))
            return $"user_{userId}";

        // Fall back to IP address
        var ip = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return $"ip_{ip}";
    }

    private class RateLimitInfo
    {
        public int Count { get; set; }
        public DateTime WindowStart { get; set; }
    }
}