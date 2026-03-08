using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Events;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.EventHandlers
{
    public class UserEventsHandler : 
        INotificationHandler<UserCreatedEvent>,
        INotificationHandler<UserLoggedInEvent>,
        INotificationHandler<UserLoggedOutEvent>,
        INotificationHandler<PasswordChangedEvent>,
        INotificationHandler<UserActivatedEvent>,
        INotificationHandler<UserDeactivatedEvent>
    {
        private readonly ILogger<UserEventsHandler> _logger;
        private readonly ICacheService _cacheService;

        public UserEventsHandler(ILogger<UserEventsHandler> logger, ICacheService cacheService)
        {
            _logger = logger;
            _cacheService = cacheService;
        }

        public async Task Handle(UserCreatedEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogInformation("User created: {Username} (ID: {UserId}) at {OccurredOn}", 
                notification.Username, notification.UserId, notification.OccurredOn);

            // Clear users list cache
            await _cacheService.RemoveAsync("users_list", cancellationToken);
        }

        public async Task Handle(UserLoggedInEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogInformation("User logged in: UserId {UserId} from IP {IpAddress} at {OccurredOn}", 
                notification.UserId, notification.IpAddress, notification.OccurredOn);
        }

        public async Task Handle(UserLoggedOutEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogInformation("User logged out: UserId {UserId} at {OccurredOn}", 
                notification.UserId, notification.OccurredOn);
        }

        public async Task Handle(PasswordChangedEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogWarning("Password changed for user: {UserId} at {OccurredOn}", 
                notification.UserId, notification.OccurredOn);

            // Clear user cache
            await _cacheService.RemoveAsync($"user_{notification.UserId}", cancellationToken);
            await _cacheService.RemoveAsync($"current_user_{notification.UserId}", cancellationToken);
        }

        public async Task Handle(UserActivatedEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogInformation("User activated: {UserId} at {OccurredOn}", 
                notification.UserId, notification.OccurredOn);

            // Clear user cache
            await _cacheService.RemoveAsync($"user_{notification.UserId}", cancellationToken);
            await _cacheService.RemoveAsync($"current_user_{notification.UserId}", cancellationToken);
        }

        public async Task Handle(UserDeactivatedEvent notification, CancellationToken cancellationToken)
        {
            _logger.LogWarning("User deactivated: {UserId} at {OccurredOn}", 
                notification.UserId, notification.OccurredOn);

            // Clear user cache and permissions
            await _cacheService.RemoveAsync($"user_{notification.UserId}", cancellationToken);
            await _cacheService.RemoveAsync($"current_user_{notification.UserId}", cancellationToken);
            await _cacheService.RemoveAsync($"user_permissions_{notification.UserId}", cancellationToken);
        }
    }
}