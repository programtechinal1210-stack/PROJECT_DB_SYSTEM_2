using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers.PermissionEvents
{
    public class PermissionRevokedHandler : INotificationHandler<PermissionRevokedEvent>
    {
        private readonly ILogger<PermissionRevokedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;

        public PermissionRevokedHandler(
            ILogger<PermissionRevokedHandler> logger,
            ICacheService cacheService,
            IAuditService auditService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
        }

        public async Task Handle(PermissionRevokedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل سحب الصلاحية
                _logger.LogWarning(
                    "[PermissionRevoked] Permission {PermissionId} revoked from role {RoleId} at {OccurredOn}",
                    notification.PermissionId,
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
                    "RolePermission",
                    notification.RoleId,
                    "RevokePermission",
                    $"Permission {notification.PermissionId} revoked from role {notification.RoleId}",
                    cancellationToken);

                _logger.LogDebug("Permission revoke event handling completed for role {RoleId}", notification.RoleId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling PermissionRevoked event for role {RoleId}", notification.RoleId);
            }
        }
    }
}