using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers.AssignmentEvents
{
    public class RoleAssignedHandler : INotificationHandler<RoleAssignedEvent>
    {
        private readonly ILogger<RoleAssignedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;
        private readonly INotificationService _notificationService;

        public RoleAssignedHandler(
            ILogger<RoleAssignedHandler> logger,
            ICacheService cacheService,
            IAuditService auditService,
            INotificationService notificationService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
            _notificationService = notificationService;
        }

        public async Task Handle(RoleAssignedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل تعيين الدور
                _logger.LogInformation(
                    "[RoleAssigned] Role {RoleId} assigned to user {UserId} by {AssignedBy} at {OccurredOn}",
                    notification.RoleId,
                    notification.UserId,
                    notification.AssignedBy,
                    notification.OccurredOn);

                // 2. مسح كاش المستخدم
                await _cacheService.RemoveAsync($"user_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync($"current_user_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync($"user_permissions_{notification.UserId}", cancellationToken);
                await _cacheService.RemoveAsync($"user_roles_{notification.UserId}", cancellationToken);

                // 3. إشعار المستخدم
                // await _notificationService.SendRoleAssignedNotificationAsync(
                //     notification.UserId,
                //     notification.RoleId,
                //     cancellationToken);

                // 4. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "UserRole",
                    notification.UserId,
                    "AssignRole",
                    $"Role {notification.RoleId} assigned to user {notification.UserId}",
                    cancellationToken);

                _logger.LogDebug("Role assignment event handling completed for user {UserId}", notification.UserId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling RoleAssigned event for user {UserId}", notification.UserId);
            }
        }
    }
}