using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Application.EventHandlers
{
    public class UserActivatedHandler : INotificationHandler<UserActivatedEvent>
    {
        private readonly ILogger<UserActivatedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IEmailService _emailService;
        private readonly IAuditService _auditService;
        private readonly IUserRepository _userRepository;

        public UserActivatedHandler(
            ILogger<UserActivatedHandler> logger,
            ICacheService cacheService,
            IEmailService emailService,
            IAuditService auditService,
            IUserRepository userRepository)
        {
            _logger = logger;
            _cacheService = cacheService;
            _emailService = emailService;
            _auditService = auditService;
            _userRepository = userRepository;
        }

        public async Task Handle(UserActivatedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل التفعيل
                _logger.LogInformation(
                    "[UserActivated] User {UserId} activated at {OccurredOn}",
                    notification.UserId,
                    notification.OccurredOn);

                // 2. مسح الكاش
                await _cacheService.RemoveAsync($"user_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync($"user_status_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync("users_list", cancellationToken);
                await _cacheService.RemoveAsync("inactive_users_count", cancellationToken);

                // 3. إرسال إيميل التفعيل
                var user = await _userRepository.GetByIdAsync(notification.UserId);
                if (user != null && !string.IsNullOrEmpty(user.Email))
                {
                    await _emailService.SendAccountActivatedEmailAsync(
                        user.Email,              // string
                        notification.UserId       // int
                    );
                }

                // 4. تسجيل في نظام التدقيق - بدون cancellationToken
                await _auditService.LogAsync(
                    "User",
                    notification.UserId,
                    "Activate",
                    "User account activated"
                );

                // 5. تحديث إحصائيات
                await UpdateActivationStatisticsAsync(cancellationToken);

                _logger.LogDebug("User activation event handling completed for user {UserId}", notification.UserId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling UserActivated event for user {UserId}", notification.UserId);
            }
        }

        private async Task UpdateActivationStatisticsAsync(CancellationToken cancellationToken)
        {
            var stats = await _cacheService.GetAsync<Dictionary<string, int>>("activation_statistics", cancellationToken)
                ?? new Dictionary<string, int>();

            var today = DateTime.UtcNow.ToString("yyyy-MM-dd");
            stats[today] = stats.GetValueOrDefault(today) + 1;

            await _cacheService.SetAsync("activation_statistics", stats, TimeSpan.FromDays(30), cancellationToken);
        }
    }
}