using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers.RoleEvents
{
    public class RoleRenamedHandler : INotificationHandler<RoleRenamedEvent>
    {
        private readonly ILogger<RoleRenamedHandler> _logger;
        private readonly ICacheService _cacheService;
        private readonly IAuditService _auditService;

        public RoleRenamedHandler(
            ILogger<RoleRenamedHandler> logger,
            ICacheService cacheService,
            IAuditService auditService)
        {
            _logger = logger;
            _cacheService = cacheService;
            _auditService = auditService;
        }

        public async Task Handle(RoleRenamedEvent notification, CancellationToken cancellationToken)
        {
            try
            {
                // 1. تسجيل إعادة تسمية الدور
                _logger.LogInformation(
                    "[RoleRenamed] Role {RoleId} renamed from '{OldName}' to '{NewName}' at {OccurredOn}",
                    notification.RoleId,
                    notification.OldName,
                    notification.NewName,
                    notification.OccurredOn);

                // 2. مسح الكاش
                await _cacheService.RemoveAsync($"role_{notification.RoleId}", cancellationToken);
                await _cacheService.RemoveAsync($"role_detail_{notification.RoleId}", cancellationToken);
                await _cacheService.RemoveAsync("roles_list", cancellationToken);

                // 3. مسح كاش المستخدمين المرتبطين بهذا الدور
                await _cacheService.RemoveByPatternAsync($"users_by_role_{notification.RoleId}", cancellationToken);

                // 4. تسجيل في نظام التدقيق
                await _auditService.LogAsync(
                    "Role",
                    notification.RoleId,
                    "Rename",
                    $"Role renamed from '{notification.OldName}' to '{notification.NewName}'",
                    cancellationToken);

                _logger.LogDebug("Role rename event handling completed for role {RoleId}", notification.RoleId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling RoleRenamed event for role {RoleId}", notification.RoleId);
            }
        }
    }
}