using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Application.Features.Users.Commands.DeactivateUser
{
    public class DeactivateUserCommandHandler : IRequestHandler<DeactivateUserCommand, Result>
    {
        private readonly IUserRepository _userRepository;
        private readonly ICacheService _cacheService;
        private readonly ICurrentUserService _currentUser;
        private readonly ILogger<DeactivateUserCommandHandler> _logger;

        public DeactivateUserCommandHandler(
            IUserRepository userRepository,
            ICacheService cacheService,
            ICurrentUserService currentUser,
            ILogger<DeactivateUserCommandHandler> logger)
        {
            _userRepository = userRepository;
            _cacheService = cacheService;
            _currentUser = currentUser;
            _logger = logger;
        }

        public async Task<Result> Handle(DeactivateUserCommand request, CancellationToken cancellationToken)
        {
            try
            {
                // Prevent deactivating yourself
                if (request.Id == _currentUser.UserId)
                {
                    return Result.Failure("You cannot deactivate your own account");
                }

                var user = await _userRepository.GetByIdAsync(request.Id);
                if (user == null)
                {
                    return Result.Failure($"User with ID {request.Id} not found");
                }

                user.Deactivate();
user.SetUpdatedBy(_currentUser.UserId?.ToString());                await _userRepository.UpdateAsync(user);

                // Terminate all sessions
                await _userRepository.TerminateAllUserSessionsAsync(user.Id);

                // Clear caches
                await _cacheService.RemoveAsync($"user_{user.Id}", cancellationToken);
                await _cacheService.RemoveAsync($"current_user_{user.Id}", cancellationToken);
                await _cacheService.RemoveAsync($"user_permissions_{user.Id}", cancellationToken);

                _logger.LogInformation("User {UserId} deactivated by {DeactivatorId}", user.Id, _currentUser.UserId);

                return Result.Success("User deactivated successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deactivating user {UserId}", request.Id);
                return Result.Failure("An error occurred while deactivating user");
            }
        }
    }
}