using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Exceptions;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Application.Features.Users.Commands.AssignRole
{
    public class AssignRoleCommandHandler : IRequestHandler<AssignRoleCommand, Result>
    {
        private readonly IUserRepository _userRepository;
        private readonly IRoleRepository _roleRepository;
        private readonly ICacheService _cacheService;
        private readonly ICurrentUserService _currentUser;
        private readonly ILogger<AssignRoleCommandHandler> _logger;

        public AssignRoleCommandHandler(
            IUserRepository userRepository,
            IRoleRepository roleRepository,
            ICacheService cacheService,
            ICurrentUserService currentUser,
            ILogger<AssignRoleCommandHandler> logger)
        {
            _userRepository = userRepository;
            _roleRepository = roleRepository;
            _cacheService = cacheService;
            _currentUser = currentUser;
            _logger = logger;
        }

        public async Task<Result> Handle(AssignRoleCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var user = await _userRepository.GetByIdAsync(request.UserId);
                if (user == null)
                {
                    return Result.Failure($"User with ID {request.UserId} not found");
                }

                var role = await _roleRepository.GetByIdAsync(request.RoleId);
                if (role == null)
                {
                    return Result.Failure($"Role with ID {request.RoleId} not found");
                }

                user.AddRole(role, _currentUser.UserId.Value);
                await _userRepository.UpdateAsync(user);

                // Clear cache
                await _cacheService.RemoveAsync($"user_permissions_{user.Id}", cancellationToken);

                _logger.LogInformation("Role {RoleName} assigned to user {Username} by {AssignerId}",
                    role.RoleName, user.Username, _currentUser.UserId);

                return Result.Success("Role assigned successfully");
            }
            catch (InvalidOperationException ex)
            {
                return Result.Failure(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error assigning role to user {UserId}", request.UserId);
                return Result.Failure("An error occurred while assigning role");
            }
        }
    }
}