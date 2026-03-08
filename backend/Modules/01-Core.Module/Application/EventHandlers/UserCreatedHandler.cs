using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers
{
    public class UserCreatedHandler : INotificationHandler<UserCreatedEvent>
    {
        private readonly ILogger<UserCreatedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IEmailService _emailService;
        private readonly IAuditService _auditService;

        public UserCreatedHandler(
            ILogger<UserCreatedHandler> logger,
            ICacheService cacheService,
            IEmailService emailService,
            IAuditService auditService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _emailService = emailService;
            _auditService = auditService;
        }

        public async Task Handle(UserCreatedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل الحدث
                _logger.LogInformation(
                    "[UserCreated] User {Username} (ID: {UserId}) created at {OccurredOn}",
                    notification.Username,
                    notification.UserId,
                    notification.OccurredOn);

                // 2. مسح الكاش
                await _cacheService.RemoveAsync("users_list", cancellationToken);
                await _cacheService.RemoveAsync("dashboard_stats", cancellationToken);

                // 3. تسجيل في نظام التدقيق - بدون cancellationToken
                await _auditService.LogAsync(
                    "User",
                    notification.UserId,
                    "Create",
                    $"User {notification.Username} created");

                // 4. إرسال إيميل ترحيبي - بدون cancellationToken
                await _emailService.SendWelcomeEmailAsync(
                    notification.Email,
                    notification.UserId.ToString(),
                    notification.Username);

                // 5. تحديث إحصائيات
                await UpdateUserStatisticsAsync(cancellationToken);

                _logger.LogDebug("All handlers completed for UserCreated event for user {UserId}", notification.UserId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling UserCreated event for user {UserId}", notification.UserId);
                throw;
            }
        }

        private async Task UpdateUserStatisticsAsync(CancellationToken cancellationToken)
        {
            var stats = await _cacheService.GetAsync<Dictionary<string, int>>("user_statistics", cancellationToken)
                ?? new Dictionary<string, int>();

            var today = DateTime.UtcNow.ToString("yyyy-MM-dd");
            stats[today] = stats.GetValueOrDefault(today) + 1;

            await _cacheService.SetAsync("user_statistics", stats, TimeSpan.FromDays(7), cancellationToken);
        }
    }
}