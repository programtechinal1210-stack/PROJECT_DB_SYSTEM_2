using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Application.Features.Users.Commands.ActivateUser
{
    public class ActivateUserCommandHandler : IRequestHandler<ActivateUserCommand, Result>
    {
        private readonly IUserRepository _userRepository;
        private readonly ICacheService _cacheService;
        private readonly ICurrentUserService _currentUser;
        private readonly ILogger<ActivateUserCommandHandler> _logger;

        public ActivateUserCommandHandler(
            IUserRepository userRepository,
            ICacheService cacheService,
            ICurrentUserService currentUser,
            ILogger<ActivateUserCommandHandler> logger)
        {
            _userRepository = userRepository;
            _cacheService = cacheService;
            _currentUser = currentUser;
            _logger = logger;
        }

        public async Task<Result> Handle(ActivateUserCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var user = await _userRepository.GetByIdAsync(request.Id);
                if (user == null)
                {
                    return Result.Failure($"User with ID {request.Id} not found");
                }

                user.Activate();
user.SetUpdatedBy(_currentUser.UserId?.ToString());
                // Clear caches
                await _cacheService.RemoveAsync($"user_{user.Id}", cancellationToken);
                await _cacheService.RemoveAsync($"current_user_{user.Id}", cancellationToken);

                _logger.LogInformation("User {UserId} activated by {ActivatorId}", user.Id, _currentUser.UserId);

                return Result.Success("User activated successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error activating user {UserId}", request.Id);
                return Result.Failure("An error occurred while activating user");
            }
        }
    }
}