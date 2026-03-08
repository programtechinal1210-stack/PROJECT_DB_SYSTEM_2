using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers.PermissionEvents
{
    public class RolePermissionsClearedHandler : INotificationHandler<RolePermissionsClearedEvent>
    {
        private readonly ILogger<RolePermissionsClearedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;

        public RolePermissionsClearedHandler(
            ILogger<RolePermissionsClearedHandler> logger,
            ICacheService cacheService,
            IAuditService auditService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
        }

        public async Task Handle(RolePermissionsClearedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل مسح الصلاحيات
                _logger.LogWarning(
                    "[RolePermissionsCleared] All permissions cleared from role {RoleId} at {OccurredOn}",
                    notification.RoleId,
                    notification.OccurredOn);

                // 2. مسح الكاش
                await _cacheService.RemoveAsync($"role_{notification.RoleId}", cancellationToken);
                await _cacheService.RemoveAsync($"role_detail_{notification.RoleId}", cancellationToken);
                await _cacheService.RemoveAsync($"role_permissions_{notification.RoleId}", cancellationToken);

                // 3. مسح كاش المستخدمين المرتبطين بهذا الدور
                await _cacheService.RemoveByPatternAsync($"users_by_role_{notification.RoleId}", cancellationToken);
                await _cacheService.RemoveByPatternAsync("user_permissions_*", cancellationToken);

                // 4. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "Role",
                    notification.RoleId,
                    "ClearPermissions",
                    "All permissions cleared from role",
                    cancellationToken);

                _logger.LogDebug("Role permissions cleared event handling completed for role {RoleId}", notification.RoleId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling RolePermissionsCleared event for role {RoleId}", notification.RoleId);
            }
        }
    }
}