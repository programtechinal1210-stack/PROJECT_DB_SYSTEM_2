using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers.RoleEvents
{
    public class RoleDeletedHandler : INotificationHandler<RoleDeletedEvent>
    {
        private readonly ILogger<RoleDeletedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;
        private readonly IEmailService _emailService;

        public RoleDeletedHandler(
            ILogger<RoleDeletedHandler> logger,
            ICacheService cacheService,
            IAuditService auditService,
            IEmailService emailService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
            _emailService = emailService;
        }

        public async Task Handle(RoleDeletedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل حذف الدور
                _logger.LogWarning(
                    "[RoleDeleted] Role {RoleName} (ID: {RoleId}) deleted at {OccurredOn}",
                    notification.RoleName,
                    notification.RoleId,
                    notification.OccurredOn);

                // 2. مسح الكاش
                await _cacheService.RemoveAsync($"role_{notification.RoleId}", cancellationToken);
                await _cacheService.RemoveAsync($"role_detail_{notification.RoleId}", cancellationToken);
                await _cacheService.RemoveAsync("roles_list", cancellationToken);

                // 3. إشعار المشرفين

                // 4. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "Role",
                    notification.RoleId,
                    "Delete",
                    $"Role {notification.RoleName} deleted",
                    cancellationToken);

                _logger.LogDebug("Role deletion event handling completed for role {RoleId}", notification.RoleId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling RoleDeleted event for role {RoleId}", notification.RoleId);
            }
        }
    }
}