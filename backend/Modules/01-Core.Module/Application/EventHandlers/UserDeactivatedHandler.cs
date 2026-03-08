using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Domain.Interfaces;
namespace Core.Module.Application.EventHandlers
{
    public class UserDeactivatedHandler : INotificationHandler<UserDeactivatedEvent>
    {
        private readonly ILogger<UserDeactivatedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IEmailService _emailService;
        private readonly IAuditService _auditService;
        private readonly ISessionService _sessionService;
        private readonly IUserRepository _userRepository; // أضف هذا

        public UserDeactivatedHandler(
            ILogger<UserDeactivatedHandler> logger,
            ICacheService cacheService,
            IEmailService emailService,
            IAuditService auditService,
            ISessionService sessionService,
            IUserRepository userRepository) // أضف هذا
        {
            _logger = logger;
            _cacheService = cacheService;
            _emailService = emailService;
            _auditService = auditService;
            _sessionService = sessionService;
            _userRepository = userRepository;
        }

        public async Task Handle(UserDeactivatedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل التعطيل
                _logger.LogWarning(
                    "[UserDeactivated] User {UserId} deactivated at {OccurredOn}",
                    notification.UserId,
                    notification.OccurredOn);

                // 2. إنهاء جميع جلسات المستخدم - بدون cancellationToken
                await _sessionService.TerminateAllUserSessionsAsync(notification.UserId);

                // 3. مسح جميع بيانات المستخدم من الكاش
                await ClearUserCacheAsync(notification.UserId, cancellationToken);

                // 4. إرسال إيميل الإيقاف - مع reason
                var user = await _userRepository.GetByIdAsync(notification.UserId);
                if (user != null && !string.IsNullOrEmpty(user.Email))
                {
                    await _emailService.SendAccountDeactivatedEmailAsync(
                        user.Email,
                        notification.UserId,
                        "Account deactivated by administrator" // reason
                    );
                }

                // 5. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "User",
                    notification.UserId,
                    "Deactivate",
                    "User account deactivated",
                    cancellationToken);

                // 6. تحديث إحصائيات
                await UpdateDeactivationStatisticsAsync(cancellationToken);

                _logger.LogDebug("User deactivation event handling completed for user {UserId}", notification.UserId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling UserDeactivated event for user {UserId}", notification.UserId);
            }
        }

        private async Task ClearUserCacheAsync(int userId, CancellationToken cancellationToken)
        {
            var cacheKeys = new[]
            {
                $"user_{userId}",
                $"current_user_{userId}",
                $"user_permissions_{userId}",
                $"user_roles_{userId}",
                $"user_status_{userId}",
                $"last_login_{userId}",
                $"last_logout_{userId}",
                $"last_ip_{userId}"
            };

            foreach (var key in cacheKeys)
            {
                await _cacheService.RemoveAsync(key, cancellationToken);
            }

            await _cacheService.RemoveByPatternAsync($"session_*_{userId}", cancellationToken);
            await _cacheService.RemoveAsync("users_list", cancellationToken);
            await _cacheService.RemoveAsync("active_users_count", cancellationToken);
        }

        private async Task UpdateDeactivationStatisticsAsync(CancellationToken cancellationToken)
        {
            var stats = await _cacheService.GetAsync<Dictionary<string, int>>("deactivation_statistics", cancellationToken)
                ?? new Dictionary<string, int>();

            var today = DateTime.UtcNow.ToString("yyyy-MM-dd");
            stats[today] = stats.GetValueOrDefault(today) + 1;

            await _cacheService.SetAsync("deactivation_statistics", stats, TimeSpan.FromDays(30), cancellationToken);
        }
    }
}