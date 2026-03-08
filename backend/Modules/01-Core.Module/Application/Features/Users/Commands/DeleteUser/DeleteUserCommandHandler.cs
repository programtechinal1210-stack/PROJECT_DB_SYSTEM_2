using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Exceptions;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Application.Features.Users.Commands.DeleteUser
{
    public class DeleteUserCommandHandler : IRequestHandler<DeleteUserCommand, Result>
    {
        private readonly IUserRepository _userRepository;
        private readonly ICacheService _cacheService;
        private readonly ICurrentUserService _currentUser;
        private readonly ILogger<DeleteUserCommandHandler> _logger;

        public DeleteUserCommandHandler(
            IUserRepository userRepository,
            ICacheService cacheService,
            ICurrentUserService currentUser,
            ILogger<DeleteUserCommandHandler> logger)
        {
            _userRepository = userRepository;
            _cacheService = cacheService;
            _currentUser = currentUser;
            _logger = logger;
        }

        public async Task<Result> Handle(DeleteUserCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var user = await _userRepository.GetByIdAsync(request.Id);
                if (user == null)
                {
                    return Result.Failure($"User with ID {request.Id} not found");
                }

                // Prevent deleting yourself
                if (user.Id == _currentUser.UserId)
                {
                    return Result.Failure("You cannot delete your own account");
                }

                // Prevent deleting system admin
                if (user.Username == "admin" || user.Username == "system")
                {
                    return Result.Failure("Cannot delete system user");
                }

                await _userRepository.DeleteAsync(request.Id);

                // Clear all caches for this user
                await _cacheService.RemoveAsync($"user_{user.Id}", cancellationToken);
                await _cacheService.RemoveAsync($"current_user_{user.Id}", cancellationToken);
                await _cacheService.RemoveAsync($"user_permissions_{user.Id}", cancellationToken);
                await _cacheService.RemoveAsync($"user_roles_{user.Id}", cancellationToken);

                _logger.LogInformation("User {UserId} deleted by {DeleterId}", user.Id, _currentUser.UserId);

                return Result.Success("User deleted successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting user {UserId}", request.Id);
                return Result.Failure("An error occurred while deleting user");
            }
        }
    }
}