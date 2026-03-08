using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers
{
    public class UserLoggedOutHandler : INotificationHandler<UserLoggedOutEvent>
    {
        private readonly ILogger<UserLoggedOutHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;

        public UserLoggedOutHandler(
            ILogger<UserLoggedOutHandler> logger,
            ICacheService cacheService,
            IAuditService auditService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
        }

        public async Task Handle(UserLoggedOutEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل الخروج
                _logger.LogInformation(
                    "[UserLoggedOut] User {UserId} logged out at {OccurredOn}",
                    notification.UserId,
                    notification.OccurredOn);

                // 2. إزالة الجلسة من الكاش
_logger.LogInformation("User {UserId} logged out with session {SessionId}", 
    notification.UserId, notification.SessionId);
                // 3. تحديث آخر نشاط
                await _cacheService.SetAsync(
                    $"last_logout_{notification.UserId}",
                    notification.OccurredOn,
                    TimeSpan.FromDays(30),
                    cancellationToken);

                // 4. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "UserSession",
                    notification.UserId,
                    "Logout",
                    $"User logged out, session: {notification.SessionId}",
                    cancellationToken);

                _logger.LogDebug("Logout event handling completed for user {UserId}", notification.UserId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling UserLoggedOut event for user {UserId}", notification.UserId);
            }
        }
    }
}