using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers.RoleEvents
{
    public class RoleCreatedHandler : INotificationHandler<RoleCreatedEvent>
    {
        private readonly ILogger<RoleCreatedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;

        public RoleCreatedHandler(
            ILogger<RoleCreatedHandler> logger,
            ICacheService cacheService,
            IAuditService auditService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
        }

        public async Task Handle(RoleCreatedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل إنشاء الدور
                _logger.LogInformation(
                    "[RoleCreated] Role {RoleName} (ID: {RoleId}) created at {OccurredOn}",
                    notification.RoleName,
                    notification.RoleId,
                    notification.OccurredOn);

                // 2. مسح الكاش
                await _cacheService.RemoveAsync("roles_list", cancellationToken);
                await _cacheService.RemoveAsync("dashboard_stats", cancellationToken);

                // 3. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "Role",
                    notification.RoleId,
                    "Create",
                    $"Role {notification.RoleName} created",
                    cancellationToken);

                _logger.LogDebug("Role creation event handling completed for role {RoleId}", notification.RoleId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling RoleCreated event for role {RoleId}", notification.RoleId);
            }
        }
    }
}