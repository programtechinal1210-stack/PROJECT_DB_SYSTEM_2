using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Interfaces;

namespace Core.Module.Application.EventHandlers
{
    public class UserLoggedInHandler : INotificationHandler<UserLoggedInEvent>
    {
        private readonly ILogger<UserLoggedInHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;
        private readonly INotificationService _notificationService;

        public UserLoggedInHandler(
            ILogger<UserLoggedInHandler> logger,
            ICacheService cacheService,
            IAuditService auditService,
            INotificationService notificationService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
            _notificationService = notificationService;
        }

        public async Task Handle(UserLoggedInEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل الدخول
                _logger.LogInformation(
                    "[UserLoggedIn] User {UserId} logged in from IP {IpAddress} at {OccurredOn}",
                    notification.UserId,
                    notification.IpAddress,
                    notification.OccurredOn);

                // 2. تحديث آخر نشاط في الكاش
                await _cacheService.SetAsync(
                    $"last_login_{notification.UserId}",
                    notification.OccurredOn,
                    TimeSpan.FromDays(30),
                    cancellationToken);

                // 3. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "User",
                    notification.UserId,
                    "Login",
                    $"User logged in from IP {notification.IpAddress}",
                    cancellationToken);

                // 4. التحقق من وجود نشاط مشبوه
                await CheckForSuspiciousActivityAsync(notification, cancellationToken);

                // 5. تحديث إحصائيات تسجيل الدخول
                await UpdateLoginStatisticsAsync(notification, cancellationToken);

                _logger.LogDebug("Login event handling completed for user {UserId}", notification.UserId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling UserLoggedIn event for user {UserId}", notification.UserId);
            }
        }

        private async Task CheckForSuspiciousActivityAsync(UserLoggedInEvent notification, CancellationToken cancellationToken)
        {
            // الحصول على آخر IP للمستخدم
            var lastIp = await _cacheService.GetAsync<string>($"last_ip_{notification.UserId}", cancellationToken);

            if (lastIp != null && lastIp != notification.IpAddress)
            {
                // إذا تغير الـ IP، قد يكون نشاط مشبوه
                _logger.LogWarning(
                    "Suspicious login detected for user {UserId}. IP changed from {LastIp} to {NewIp}",
                    notification.UserId,
                    lastIp,
                    notification.IpAddress);

                // إرسال إشعار للمستخدم
                await _notificationService.SendSecurityAlertAsync(
                    notification.UserId,
                    $"New login from IP {notification.IpAddress}",
                    cancellationToken);
            }

            // حفظ الـ IP الحالي
            await _cacheService.SetAsync(
                $"last_ip_{notification.UserId}",
                notification.IpAddress,
                TimeSpan.FromDays(30),
                cancellationToken);
        }

        private async Task UpdateLoginStatisticsAsync(UserLoggedInEvent notification, CancellationToken cancellationToken)
        {
            var today = DateTime.UtcNow.ToString("yyyy-MM-dd");
            var loginCount = await _cacheService.GetAsync<int>($"login_count_{today}", cancellationToken);
            await _cacheService.SetAsync($"login_count_{today}", loginCount + 1, TimeSpan.FromDays(2), cancellationToken);
        }
    }
}