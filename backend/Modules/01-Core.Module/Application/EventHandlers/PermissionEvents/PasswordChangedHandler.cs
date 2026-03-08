using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers
{
    public class PasswordChangedHandler : INotificationHandler<PasswordChangedEvent>
    {
        private readonly ILogger<PasswordChangedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IEmailService _emailService;
        private readonly IAuditService _auditService;
        private readonly INotificationService _notificationService;

        public PasswordChangedHandler(
            ILogger<PasswordChangedHandler> logger,
            ICacheService cacheService,
            IEmailService emailService,
            IAuditService auditService,
            INotificationService notificationService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _emailService = emailService;
            _auditService = auditService;
            _notificationService = notificationService;
        }

        public async Task Handle(PasswordChangedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل تغيير كلمة المرور
                _logger.LogWarning(
                    "[PasswordChanged] Password changed for user {UserId} at {OccurredOn}",
                    notification.UserId,
                    notification.OccurredOn);

                // 2. مسح جميع جلسات المستخدم (إجباره على تسجيل الدخول مجدداً)
                await _cacheService.RemoveByPatternAsync($"session_*_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync($"user_permissions_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync($"current_user_{notification.UserId}", cancellationToken);

                // 3. إرسال إشعار للمستخدم
                // await _notificationService.SendPasswordChangedAlertAsync(
                //     notification.UserId,
                //     notification.OccurredOn,
                //     cancellationToken);

                // // 4. إرسال إيميل تأكيد
                // await _emailService.SendPasswordChangedEmailAsync(
                //     notification.UserId,
                //     notification.OccurredOn,
                //     cancellationToken);

                // 5. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "User",
                    notification.UserId,
                    "PasswordChanged",
                    "User password was changed",
                    cancellationToken);

                _logger.LogDebug("Password change event handling completed for user {UserId}", notification.UserId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling PasswordChanged event for user {UserId}", notification.UserId);
            }
        }
    }
}