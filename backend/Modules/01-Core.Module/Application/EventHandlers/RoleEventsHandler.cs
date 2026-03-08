using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers
{
    public class RoleEventsHandler : 
        INotificationHandler<RoleCreatedEvent>,
        INotificationHandler<RoleRenamedEvent>,
        INotificationHandler<PermissionGrantedEvent>,
        INotificationHandler<PermissionRevokedEvent>
    {
        private readonly ILogger<RoleEventsHandler> _logger;
        private readonly ICacheService _cacheService;

        public RoleEventsHandler(ILogger<RoleEventsHandler> logger, ICacheService cacheService)
        {
            _logger = logger;
            _cacheService = cacheService;
        }

        public async Task Handle(RoleCreatedEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Role created: {RoleName} (ID: {RoleId}) at {OccurredOn}", 
                notification.RoleName, notification.RoleId, notification.OccurredOn);

            // Clear roles list cache
            await _cacheService.RemoveAsync("roles_list", cancellationToken);
        }

        public async Task Handle(RoleRenamedEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Role renamed: from {OldName} to {NewName} (ID: {RoleId}) at {OccurredOn}", 
                notification.OldName, notification.NewName, notification.RoleId, notification.OccurredOn);

            // Clear role cache
            await _cacheService.RemoveAsync($"role_detail_{notification.RoleId}", cancellationToken);
            await _cacheService.RemoveAsync("roles_list", cancellationToken);
        }

        public async Task Handle(PermissionGrantedEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Permission {PermissionId} granted to role {RoleId} by {GrantedBy} at {OccurredOn}", 
                notification.PermissionId, notification.RoleId, notification.GrantedBy, notification.OccurredOn);

            // Clear role cache
            await _cacheService.RemoveAsync($"role_detail_{notification.RoleId}", cancellationToken);
        }

        public async Task Handle(PermissionRevokedEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Permission {PermissionId} revoked from role {RoleId} at {OccurredOn}", 
                notification.PermissionId, notification.RoleId, notification.OccurredOn);

            // Clear role cache
            await _cacheService.RemoveAsync($"role_detail_{notification.RoleId}", cancellationToken);
        }
    }
}