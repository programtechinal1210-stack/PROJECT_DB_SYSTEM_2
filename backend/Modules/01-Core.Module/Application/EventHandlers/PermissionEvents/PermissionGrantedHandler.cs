using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers.PermissionEvents
{
    public class PermissionGrantedHandler : INotificationHandler<PermissionGrantedEvent>
    {
        private readonly ILogger<PermissionGrantedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;

        public PermissionGrantedHandler(
            ILogger<PermissionGrantedHandler> logger,
            ICacheService cacheService,
            IAuditService auditService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
        }

        public async Task Handle(PermissionGrantedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل منح الصلاحية
                _logger.LogInformation(
                    "[PermissionGranted] Permission {PermissionId} granted to role {RoleId} by {GrantedBy} at {OccurredOn}",
                    notification.PermissionId,
                    notification.RoleId,
                    notification.GrantedBy,
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
                    "GrantPermission",
                    $"Permission {notification.PermissionId} granted to role {notification.RoleId}",
                    cancellationToken);

                _logger.LogDebug("Permission grant event handling completed for role {RoleId}", notification.RoleId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling PermissionGranted event for role {RoleId}", notification.RoleId);
            }
        }
    }
}