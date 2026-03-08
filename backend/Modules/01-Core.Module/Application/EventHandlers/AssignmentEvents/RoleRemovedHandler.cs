using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers.AssignmentEvents
{
    public class RoleRemovedHandler : INotificationHandler<RoleRemovedEvent>
    {
        private readonly ILogger<RoleRemovedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;
        private readonly INotificationService _notificationService;

        public RoleRemovedHandler(
            ILogger<RoleRemovedHandler> logger,
            ICacheService cacheService,
            IAuditService auditService,
            INotificationService notificationService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
            _notificationService = notificationService;
        }

        public async Task Handle(RoleRemovedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل إزالة الدور
                _logger.LogInformation(
                    "[RoleRemoved] Role {RoleId} removed from user {UserId} at {OccurredOn}",
                    notification.RoleId,
                    notification.UserId,
                    notification.OccurredOn);

                // 2. مسح كاش المستخدم
                await _cacheService.RemoveAsync($"user_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync($"current_user_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync($"user_permissions_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync($"user_roles_{notification.UserId}", cancellationToken);

                // 3. إشعار المستخدم
                // await _notificationService.SendRoleRemovedNotificationAsync(
                //     notification.UserId,
                //     notification.RoleId,
                //     cancellationToken);

                // 4. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "UserRole",
                    notification.UserId,
                    "RemoveRole",
                    $"Role {notification.RoleId} removed from user {notification.UserId}",
                    cancellationToken);

                _logger.LogDebug("Role removal event handling completed for user {UserId}", notification.UserId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling RoleRemoved event for user {UserId}", notification.UserId);
            }
        }
    }
}