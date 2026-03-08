using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Infrastructure.BackgroundServices
{
    public class TokenCleanupService : BackgroundService
    {
        private readonly IServiceProvider _services;
        private readonly ILogger<TokenCleanupService> _logger;
        private readonly TimeSpan _period = TimeSpan.FromHours(1);

        public TokenCleanupService(IServiceProvider services, ILogger<TokenCleanupService> logger)
        {
            _services = services;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            using var timer = new PeriodicTimer(_period);
            
            while (!stoppingToken.IsCancellationRequested && await timer.WaitForNextTickAsync(stoppingToken))
            {
                try
                {
                    await CleanupExpiredTokens(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error cleaning up expired tokens");
                }
            }
        }

        private async Task CleanupExpiredTokens(CancellationToken stoppingToken)
        {
            using var scope = _services.CreateScope();
            var userRepository = scope.ServiceProvider.GetRequiredService<IUserRepository>();

            _logger.LogInformation("Starting token cleanup at {Time}", DateTime.UtcNow);
            
            // This would need to be implemented in the repository
            // await userRepository.CleanupExpiredTokensAsync();
            
            _logger.LogInformation("Token cleanup completed at {Time}", DateTime.UtcNow);
        }
    }
}